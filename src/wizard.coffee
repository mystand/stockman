Coder = require './coder'
path = require 'path'
fs = require 'fs'
imagemagick = require 'imagemagick'

class Wizard
  constructor: (@tmpPath) ->

  turnTo: (src, processingString) =>
    options = {}

    processingString.split(',').forEach (p) ->
      [key, option] = p.split '_'
      options[key] = option

    args = []
    if options.w || options.h
      args.push '-resize'
      args.push "#{options.w}x#{options.h}"

    new Promise (resolve, reject) =>
      ext = path.extname src
      tmpFilePath = path.join @tmpPath, "#{Coder.randomKey()}#{ext}"

      console.log '---------------'.yellow
      console.log [src, args..., tmpFilePath]
      console.log '---------------'.yellow

      imagemagick.convert [src, args..., tmpFilePath], (err) =>
        if !err
          resolve tmpFilePath
        else
          reject status: 500, error: err

module.exports = Wizard