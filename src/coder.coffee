md5 = require 'MD5'

class Coder
  constructor: (@salt = '') ->

  priv2pub: (privKey) =>
    md5 privKey + @salt

  @priv2pub: (privKey, salt = '') =>
    md5 privKey + salt

  @randomKey: ->
    md5 Math.random()

  @randomSalt: ->
    md5 Math.random()

module.exports = Coder