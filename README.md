wintersmith-image-generator
==================

Image generator for [Wintersmith](https://github.com/jnordberg/wintersmith)
using [gm](https://www.npmjs.com/package/gm).

## Installing

Install globally or locally using npm

```
npm install [-g] wintersmith-image-generator
```

And add `wintersmith-image-generator` to your config.json.

```json
{
  "plugins": [
    "wintersmith-image-generator"
  ]
}
```

Then configure the versions you'd like to generate.

```json
{
  "images": {
    "match": "**/pictures/*.jpg",
    "versions": {
      "small": {
        "resize": [300, 300]
      },
      "large": {
        "resize": [800, 800],
        "sepia": ""
      }
    }
  }
}
```

You can use most of the methods specified in the gm docs listed [here](http://aheckmann.github.io/gm/docs.html).

Then use the generated version in your templates.

```jade
h2 original images
- for image in page.parent.pictures._.files
  img(src=image.url)

h2 resized images
- for image in page.parent.pictures._.images_small
  img(src=image.url)
````
