#!/usr/bin/env coffee

express = require 'express'
router = require './router'
fs = require 'fs'
parser = require './parser'

args = parser.parseArgs()
config = args # Temporary

Storage = require "./storage/#{config.storage}-storage"
storage = new Storage config

switch config.command
  when 'start'
    app = express()
    app.use router(config, storage)
    app.listen config.port, ->
      console.log "Stockman listen #{config.port} port..."
  when 'add-project'
    {projectPath, projectPrivateKey, salt} = storage.addProject args.name
    console.log {projectPath, projectPrivateKey, salt}