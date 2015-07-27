wintersmith-image-generator
==================

Image generator for [Wintersmith](https://github.com/jnordberg/wintersmith)
using [gm](https://www.npmjs.com/package/gm).

## Installing

Install globally or locally using npm

```
npm install [-g] wintersmith-image-generator
```

and add `wintersmith-image-generator` to your config.json

```json
{
  "plugins": [
    "wintersmith-image-generator"
  ]
}
```

then configure

```json
{
  "images": {
    "versions": {
      "small": {
        "resize": [300, 300]
      },
      "large": {
        "resize": [800, 800]
      }
    }
  }
}
```

then use in your templates

```jade
  img(src=env.helpers.getImageUrl(contents, page.cover, 'large'))
````
