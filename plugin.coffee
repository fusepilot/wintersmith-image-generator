gm = require 'gm'
path = require 'path'
fs = require 'fs'
minimatch = require 'minimatch'
_ = require 'lodash'

module.exports = (env, callback) ->

  defaults =
    pattern: '**/*.{png,jpg}'
    versions:
      thumbnail:
        resize: [100, 100]
      small:
        resize: [300, 300]
      large:
        resize: [800, 800]

  options = _.extend {}, defaults, env.config.images

  getImages = (contents) ->
    images = env.ContentTree.flatten contents
    images = images.filter (content) ->
      minimatch content.filepath?.relative, options.pattern, {dot: false}
    return images

  formatFileName = (filename, version) ->
    parsed = path.parse filename
    return "#{parsed.name}-#{version}#{parsed.ext}"

  class ImagePlugin extends env.ContentPlugin

    constructor: (@_filepath, @version) ->
      @filepathParse = path.parse @_filepath.relative

    getFilename: ->

      return "#{@filepathParse.dir}/#{@filepathParse.name}-#{@version}#{@filepathParse.ext}"

    getView: ->
      return (env, locals, contents, templates, callback) =>
        image = gm @_filepath.full

        for method, args of options.versions[@version]
          try
            unless image[method]
              throw Error("#{method} is not a recognized gm command.")

            if args or args != ''
              unless args instanceof Array then args = [args]
              image[method].apply image, args
            else
              image[method].call image
          catch error
            callback error

        image.toBuffer @filepathParse.ext, (err, buffer) ->
          if err
            console.error err
            return
          callback null, buffer

  env.helpers.getImageUrl = (contents, imagePath, version) ->
    imagePath = env.utils.resolveLink contents, imagePath, env.config.baseUrl

    name = formatFileName(imagePath, version)

    imagePathFull = env.contentsPath + imagePath

    images = getImages(contents)
    images = images.filter (content) ->
      content.filepath?.full == imagePathFull

    image = images[0]

    unless image
      env.logger.error "couldn't find image #{imagePath}"
      return ""

    unless options.versions[version]
      env.logger.error "couldn't find image version \"#{version}\""
      return image.url

    if version == "" or version == "original"
      return image.url

    parsed = path.parse imagePath
    treePath = parsed.dir.split('/')
    treePath.shift()
    treePath.push name

    return _.get(contents, treePath).url

  for version of options.versions
    do (version) ->
      env.registerGenerator 'images_'+version, (contents, callback) ->
        images = getImages(contents)

        tree = {}

        for image in images
          parsed = path.parse image.filepath.relative
          name = formatFileName(image.filepath.relative, version)

          treePath = parsed.dir.split('/')
          treePath.push name
          _.set tree, treePath, new ImagePlugin(image.filepath, version)

        callback null, tree

  callback()
