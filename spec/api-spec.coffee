fs = require 'fs'
request = require 'request'
assert = require('chai').assert

#########
# Helpers
#########

salt = "0246d073-0572-48a1-9c6a-5acd1eb1e75e"
coder = new Coder salt


exitWithError = (error) ->
  throw "Fatal error -> #{error}"


#########
# Tests
#########


describe 'Stockman api',  ->
  describe 'for single picture', ->
    describe 'POST upload image', ->
      # POST http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
      it 'should be filled', ->

    describe 'GET download image', ->
      # GET http://v1.stockman.com/<PROJECT_PUBLIC_KEY>/<IMAGE_PUBLIC_KEY>[/<PROCESSING_STRING>][.<EXTENSION>]
      it 'should be filled', ->

    describe 'DELETE remove image', ->
      # DELETE http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
      it 'should be filled', ->
