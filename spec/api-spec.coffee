fs = require 'fs'
request = require 'request'
assert = require('chai').assert
Coder = require '../src/coder'

#########
# Constants
#########

API_HOST = 'http://localhost:3333'

SALT = "0246d073-0572-48a1-9c6a-5acd1eb1e75e"
CODER = new Coder SALT
PROJECT_PRIVATE_KEY = "0246d0735acd1eb1e75e"
PROJECT_PUBLIC_KEY = (new Coder).priv2pub PROJECT_PRIVATE_KEY
IMAGE_PRIVATE_KEY = "1246d0735a2d1eb1e75e"

JPG_PATH = './spec/fixtures/lemongrab.jpg'

#########
# Helpers
#########

btoa = (string) ->
  new Buffer(string).toString('base64')

exitWithError = (error) ->
  throw "Fatal error -> #{error}"

errorFilterFor = (callback) ->
  return (error, response, body) ->
    exitWithError(error) if error?.code is 'ECONNREFUSED'
    callback(error, response, body)

uploadObjectToStockman = (privateObjectKey, filePath) ->
  new Promise (resolve, reject) =>
    url = "#{API_HOST}/#{PROJECT_PRIVATE_KEY}/#{privateObjectKey}"
    options =
      url: url
      formData:
        file: fs.createReadStream filePath
    request.post options, (error, response, _) ->
      resolve response

#########
# Tests
#########

describe 'Stockman api', ->
  before ->
    fs.writeFileSync "./tmp/#{PROJECT_PUBLIC_KEY}.salt", SALT

  describe 'for single picture', ->
    describe 'POST upload image', ->
      # POST http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
      it 'should be filled', () ->
        uploadObjectToStockman(IMAGE_PRIVATE_KEY, JPG_PATH).then (response) ->
          assert.equal response.statusCode, 200
          assert.equal response.body, '{}'

    describe 'GET download image', ->
      # GET http://v1.stockman.com/<PROJECT_PUBLIC_KEY>/<IMAGE_PUBLIC_KEY>[/<PROCESSING_STRING>][.<EXTENSION>]
      it 'should be filled', ->

    describe 'DELETE remove image', ->
      # DELETE http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
      it 'should be filled', ->
