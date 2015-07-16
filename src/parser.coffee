argparse = require 'argparse'
fs = require 'fs'

parser = new argparse.ArgumentParser
  version: '0.0.1'
  addHelp: true
  description: 'Image store and processing server'

parser.addArgument ['-p', '--path'],
  help: 'Working path'
  defaultValue: '.'

#storageModuleFiles = fs.readdirSync './storage'
#storageChoices = for storageModuleFile in storageModuleFiles
#  storageModuleFile.replace /-storage.\w+$/, ''
#
parser.addArgument ['-s', '--storage'],
  help: 'Using storage'
#  choices: storageChoices
  defaultValue: 'fs'

subparsers = parser.addSubparsers
  title: 'Commands'

# Start section

start = subparsers.addParser 'start',
  addHelp: true
  help: 'Start stockman server'

start.setDefaults command: 'start'

start = start.addArgumentGroup
  title: 'Base arguments'

start.addArgument ['--host'],
  help: 'Server hostname'
  defaultValue: '0.0.0.0'

start.addArgument ['-l', '--log'],
  help: 'Log file (default stockman.log)'
  defaultValue: 'stockman.log'

start.addArgument ['--port'],
  help: 'Port (default 9999)'
  defaultValue: 9999

start.addArgument ['--pid'],
  help: 'PID file'

start.addArgument ['--socket'],
  help: 'Unix socket to listen'

# add project section

addProject = subparsers.addParser 'add-project',
  addHelp: true,
  help: 'Generate new project, register it in the system and puts project SALT'

addProject.setDefaults command: 'add-project'

addProject.addArgument ['name'],
  help: 'Created project name'

# override error

_error = parser.error
parser.error = ->
  # Here we can override the default error message
  _error.apply @, arguments

module.exports = parser