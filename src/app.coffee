#!/usr/bin/env coffee

express = require 'express'
router = require './router'
fs = require 'fs'
parser = require './parser'

config = parser.parseArgs()

Storage = require "./storage/#{config.storage}-storage"
storage = new Storage config

switch config.command
  when 'start'
    app = express()
    app.use router

    app.listen config.port, ->
      console.log "Stockman listen #{config.port} port..."
  when 'add-project'
    {projectPath, projectPrivateKey, salt} = storage.addProject()
    console.log {projectPath, projectPrivateKey, salt}