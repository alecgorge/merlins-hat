# Merlin's Hat

Merlin's Hat is some express middleware to quickly provide an image from a URL of an arbitrary resolution with caching. You must implement your own storage method.

There is an example at `example/server.coffee`.

# Dependency

GraphicsMagick needs to be installed. You can do this on a Mac using homebrew very easily:

```
brew install graphicsmagick
```

On Ubuntu 14.04+ you can install it like this:

```
sudo apt-get install graphicsmagick
```

# Implementation

The middleware expects 3 functions to be passed:

* 1 to handle storing a resized image
* 1 to fetch a stored image/test if a store image exists
* 1 to delete a stored image

See `example/server.coffee`. 

# HTTP API

You need to mount the middleware on a route. Once you have done that, Merlin's Hat can be used very simply.

In this example, Merlin's Hat is mounted at `/api/v1/image`. The following query paramaterys are available to you:

* `width` : The max width to resize to
* `height` : The max height to resize to
* `quality` : From 0 to 100, what should be the quality of the resulting JPG (default: 80)
* `url` : The URL of the upstream image to download and resize.

**Note:** one of `width` and `height` are required, but not both.