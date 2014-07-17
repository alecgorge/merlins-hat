fs      = require 'fs'

express = require 'express'
merlin  = require 'merlins-hat'

STORAGE_DIR = './images'

if process.env.NODE_ENV is 'production'
  STORAGE_DIR = '/app/images'

if not fs.existsSync STORAGE_DIR
  fs.mkdirSync STORAGE_DIR

app = express()

class CacheImage
  constructor: (@key) ->
    @folder = @key[0..2]
    @file = STORAGE_DIR + '/' + @folder + '/' + @key + '.jpg'
    @folder_path = STORAGE_DIR + '/' + @folder
    @url = 'http://merlin.app.alecgorge.com/api/v1/images/' + @folder + '/' + @key + '.jpg'

  createWriteStream: () -> fs.createWriteStream @file
  createReadStream: () -> fs.createReadStream @file

store = (key, cb) ->
  c = new CacheImage key

  fs.exists c.folder_path, (exists) ->
    send_write_stream = ->
      cb new merlin.StoreResponse c.url, c.createWriteStream()

    if not exists
      fs.mkdir c.folder_path, ->
        send_write_stream()
    else
      send_write_stream()

fetch = (key, cb) ->
  c = new CacheImage key

  fs.stat c.file, (err, stats) ->
    return cb new merlin.FetchResponse false if err
    
    cb(new merlin.FetchResponse true, c.url, stats.size, c.createReadStream())

delete_key = (key, cb) ->
  c = new CacheImage key

  fs.unlink c.file, ->
    cb()

app.get '/api/v1/image', merlin.middleware(store, fetch, delete_key)
app.get '/api/v1/images/:folder/:key.jpg', (req, res) ->
  c = new CacheImage req.param key

  res.setHeader 'Content-Type', 'image/jpeg'
  res.sendfile c.file

console.log "Listening on #{process.env.PORT || 16484}. Storage in #{STORAGE_DIR}"
app.listen process.env.PORT || 16484
