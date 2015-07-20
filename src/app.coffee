#!/usr/bin/env coffee

express = require 'express'
router = require './router'
fs = require 'fs'
parser = require './parser'
_ = require 'underscore'
colors = require 'colors'
yaml = require 'js-yaml'

app = (argv) ->
  new Promise (resolve, reject) ->
    args = parser.parseArgs argv
    config = if args.config
      yaml.safeLoad(fs.readFileSync(args.config, 'utf8')).extend _(argv).omit('config')
    else
      args

    Storage = require "./storage/#{config.storage || 'fs'}-storage"
    storage = new Storage config

    switch config.command
      when 'start'
        app = express()
        app.use router(config, storage)
        app.listen config.port, ->
          resolve "Stockman listen #{config.port} port..."
        app
      when 'add-project'
        {projectPrivateKey, salt} = storage.addProject args.name
        resolve {projectPrivateKey, salt}

if __filename == process.argv[1]
  app(process.argv[2..]).then (result) ->
    console.log result

module.exports = app