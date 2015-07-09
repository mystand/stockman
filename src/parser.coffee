ArgumentParser = require('argparse').ArgumentParser

parser = new ArgumentParser
  version: '0.0.1',
  addHelp: true,
  description: 'Image store and processing server'

parser.addArgument [ '-c', '--config' ],
  help: 'Load the configuration found in filename.'

parser.addArgument [ '-d', '--default-tile' ],
  help: 'Image that will get the client if the requested tile is not found'

parser.addArgument [ '--host' ],
  help: 'Server hostname'
  defaultValue: '0.0.0.0'

parser.addArgument [ '-l', '--log' ],
  help: 'Log file (default stockman.log)'
  defaultValue: 'stockman.log'

parser.addArgument [ '-p', '--port' ],
  help: 'Port (default 9999)'
  defaultValue: 9999

parser.addArgument [ '--pid' ],
  help: 'PID file'

parser.addArgument [ '-s', '--socket' ],
  help: 'Unix socket to listen'

module.exports = parser