express = require 'express'
mongodb = require 'mongodb'
router = require './router'

app = express()
app.use router

if __filename == process.argv[1]
  app.listen 3333, ->
    console.log "Stockman listen #{3333} port..."

module.exports.app = app