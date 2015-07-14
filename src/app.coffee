#!/usr/bin/env coffee

express = require 'express'
router = require './router'
fs = require 'fs'
parser = require './parser'

command = process.argv[2]

switch command
  when 'start'
    config = parser.parseArgs()
    Storage = require "./storage/#{config.storage}-storage"
    storage = new Storage config

    app = express()
    app.use router

    app.listen config.port, ->
      console.log "Stockman listen #{config.port} port..."
  when 'add-project'
    config = parser.parseArgs()
    Storage = require "./storage/#{config.storage}-storage"
    storage = new Storage config

    {projectPath, projectPrivateKey, salt} = storage.addProject()
    console.log {projectPath, projectPrivateKey, salt}
  else
    parser.printHelp()
    process.exit()