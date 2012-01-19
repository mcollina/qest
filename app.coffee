#! /usr/bin/env coffee

# Module dependencies.

optimist = require 'optimist'
express = require 'express'
path = require 'path'
fs = require 'fs'
hbs = require('hbs')

# Create Server

module.exports.app = app = express.createServer()

# Configuration

app.configure -> 
  app.register('.hbs', hbs)
  app.set('views', __dirname + '/app/views')
  app.set('view engine', 'hbs')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ->
  app.use(express.errorHandler())

# load mqtt
app.mqtt = require("mqttjs")

load = (key) ->
  app[key] = {}
  loadPath = __dirname + "/app/#{key}/"
  for component in fs.readdirSync(loadPath)
    if component.match /(js|coffee)$/
      component = path.basename(component, path.extname(component))
      loadedModule = require(loadPath + component)
      component = loadedModule.name if loadedModule.name?
      app[key][component] = loadedModule
      app[key][component](app)

load("controllers")
load("models")

# Helpers
helpersPath = __dirname + "/app/helpers/"
for helper in fs.readdirSync(helpersPath)
  app.helpers require(helpersPath + helper) if helper.match /(js|coffee)$/

hbs.registerHelper 'json', (context) -> 
  new hbs.SafeString(JSON.stringify(context))

# Start the module if it's needed

optionParser = optimist.default('port', 3000).default('mqtt', 1883).
  usage("Usage: $0 [-p WEB-PORT] [-m MQTT-PORT]").
  alias('port', 'p').
  alias('mqtt', 'm').
  describe('port', 'The port the web server will listen to').
  describe('mqtt', 'The port the mqtt server will listen to').
  boolean("help").
  describe("help", "This help")

argv = optionParser.argv

start = module.exports.start = (opts={}) ->

  opts.port ||= argv.port
  opts.mqtt ||= argv.mqtt

  if argv.help
    optionParser.showHelp()
    return 1

  app.listen(opts.port)
  app.controllers.device_bridge.start(opts.mqtt)
  console.log("mqtt-rest web server listening on port %d in %s mode", opts.port, app.settings.env)
  console.log("mqtt-rest mqtt server listening on port %d in %s mode", opts.mqtt, app.settings.env)

if require.main.filename == __filename
  start()


