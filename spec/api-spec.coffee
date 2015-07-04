fs = require 'fs'
request = require 'request'
assert = require('chai').assert
Coder = require '../coder'

#########
# Helpers
#########

salt = "0246d073-0572-48a1-9c6a-5acd1eb1e75e"
coder = new Coder salt


btoa = (string) ->
  new Buffer(string).toString('base64')

exitWithError = (error) ->
  throw "Fatal error -> #{error}"

errorFilterFor = (callback) ->
  return (error, response, body) ->
    exitWithError(error) if error?.code is 'ECONNREFUSED'
    callback(error, response, body)

uploadObjectToStockman = (categoryUniqKey, uniqObjectKey, filePath, callback) ->
  categoryPrivateKey = coder.uniq2priv categoryUniqKey
  objectPrivateKey = coder.uniq2priv uniqObjectKey
  url = "#{config.test.apiUrl}/#{project._id}/#{categoryPrivateKey}/#{objectPrivateKey}"
  options =
    url: url
    formData:
      file: fs.createReadStream filePath
  request.post options, errorFilterFor(callback)

test = (callback) ->
  options =
    url: "http://localhost:3333/1"

  request.get options, errorFilterFor(callback)
#########
# Tests
#########


describe 'Stockman api',  ->
  describe 'for single picture', ->
    describe 'POST upload image', ->
      # POST http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
      it 'should be filled', (done) ->
        test ->
          done()

    describe 'GET download image', ->
      # GET http://v1.stockman.com/<PROJECT_PUBLIC_KEY>/<IMAGE_PUBLIC_KEY>[/<PROCESSING_STRING>][.<EXTENSION>]
      it 'should be filled', ->

    describe 'DELETE remove image', ->
      # DELETE http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
      it 'should be filled', ->
