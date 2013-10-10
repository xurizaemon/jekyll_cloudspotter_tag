# Cloudspotter Tag

Generates an image gallery of your Cloudspotter uploads..

Usage:

    {% cloudspotter %}

Default Configuration (override in _config.yml):

    cloudspotter:
      token:         ''
      uid:           ''
      gallery_tag:   'p'
      gallery_class: 'gallery'
      a_href:        nil
      a_target:      '_blank'
      image_rel:     ''
      image_size:    's'

Thumbnails link to large-sized images on Cloudspotter.

You need to get your hands on a `uid` and a `token` - these go in your `_config.yml`, after which (hopefully) it'll work. I don't know yet if the tokens are time-limited, I only just wrote this :)

Cloudspotter app on your iOS device requests these when it retrieves a list of uploads from the Cloudspotter server, so you'll need to onserve the (SSL) request for `https://api.cloudspotterapp.com/get/user_cloudcollection/1/json` and grab the two parameters from it.
