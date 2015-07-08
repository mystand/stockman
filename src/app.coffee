express = require 'express'
router = require './router'
fs = require 'fs'
parser = require './parser'

#Find all implementations of storage
storageModuleFiles = fs.readdirSync './src/storage'
storageModules = {}
for storageModuleFile in storageModuleFiles
  storageName = storageModuleFile.replace /-storage.\w+$/, ''
  storageModule = require "./storage/#{storageModuleFile}"
  storageModules[storageName] = storageModule
  storageModule.addArguments? parser

app = express()
app.use router

if __filename == process.argv[1]
  app.listen 3333, ->
    console.log "Stockman listen #{3333} port..."

module.exports.app = app