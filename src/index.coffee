
fs      = require 'fs'
crypto  = require 'crypto'

gm      = require 'gm'
temp    = require 'temp'
request = require 'request'

md5 = (str) -> crypto.createHash('md5').update(str).digest('hex')

class MerlinStoreResponse
  constructor: (@permalink, @writeStream) ->

class MerlinFetchResponse
  constructor: (@exists, @permalink = null, @size = 0, @readStream = null) ->

merlin = (store_key, fetch_key, delete_key) ->
  return (req, res, next) ->
    w     = parseInt(req.query.width) || null
    h     = parseInt(req.query.height) || null
    q     = parseInt(req.query.quality) || 80
    url   = req.query.url

    if not url or (not w and not h)
      # bad input
      res.send 400, 'Invalid input'
      return

    key = md5 url + w + h + q

    send_response = (merlinResponse) ->
      res.setHeader 'Cache-Control', 'max-age=31556926'
      res.setHeader 'Content-Type', "image/jpeg"
      res.setHeader "Content-Length", merlinResponse.size
      merlinResponse.readStream.pipe res      

    fetch_key key, (fetchResponse) ->
      if fetchResponse.exists
        send_response fetchResponse
      else
        temp.open 'merlins_hat', (err, info) ->
          throw err if err

          temp_dl = info.path
          ws = fs.createWriteStream temp_dl

          # download image to temp file
          request(url).pipe(ws).on 'close', ->
            g = gm info.path
            g.quality q
            g.resize w, h
            g.autoOrient()

            store_key key, (storeResponse) ->
              p = g.stream('jpeg')
              p.pipe(storeResponse.writeStream).on 'close', (err) ->
                fs.unlink temp_dl, (err) ->
                  throw err if err

                if err
                  delete_key key, ->
                    console.log err
                    throw err
                else
                  fetch_key key, (fetchResponse) ->
                    if fetchResponse.exists
                      send_response fetchResponse
                    else
                      res.send 404

module.exports = 
  middleware: merlin
  FetchResponse: MerlinFetchResponse
  StoreResponse: MerlinStoreResponse

