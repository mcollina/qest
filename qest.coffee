#! /usr/bin/env coffee

# Module dependencies.

optimist = require 'optimist'
express = require 'express'
path = require 'path'
fs = require 'fs'
hbs = require 'hbs'
redis = require 'redis'
EventEmitter = require('events').EventEmitter
connect = require 'connect'
cless = require 'connect-less'
RedisStore = require('connect-redis')(express)

# Create Server

module.exports.app = app = express.createServer()
http = require('http').createServer(app)

# Configuration

app.redis = {}

module.exports.configure = configure = ->
  app.configure -> 
    app.set('views', __dirname + '/app/views')
    app.set('view engine', 'hbs')
    app.use(connect.logger())
    app.use(express.bodyParser())
    app.use(express.methodOverride())
    app.use(connect.cookieParser())
    app.use(connect.session(secret: "wyRLuS5A79wLn3ItlGVF61Gt", 
      store: new RedisStore(), maxAge: 1000 * 60 * 60 * 24 * 14)) # two weeks
    app.use(cless(src: __dirname + "/app/", dst: __dirname + "/public", compress: true))
    app.use(app.router)
    app.use(express.static(__dirname + '/public'))

  app.configure 'development', ->
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

  app.configure 'production', ->
    app.use(express.errorHandler())

  # setup websockets
  io = app.io = require('socket.io').listen(http)

  io.configure 'production', ->
    io.enable('browser client minification');  # send minified client
    io.enable('browser client etag');          # apply etag caching logic based on version number
    io.enable('browser client gzip');          # gzip the file
    io.set('log level', 1)

    io.set('transports', [
      'htmlfile'
    , 'xhr-polling'
    , 'jsonp-polling'
    ])

  io.configure 'development', ->
    io.set('transports', ['websocket'])

  # Helpers
  helpersPath = __dirname + "/app/helpers/"
  for helper in fs.readdirSync(helpersPath)
    app.helpers require(helpersPath + helper) if helper.match /(js|coffee)$/

  load("models")
  load("controllers")

# load mqtt
app.mqtt = require("mqttjs")

load = (key) ->
  app[key] = {}
  loadPath = __dirname + "/app/#{key}/"
  for component in fs.readdirSync(loadPath)
    if component.match /(js|coffee)$/
      component = path.basename(component, path.extname(component))
      loadedModule = require(loadPath + component)(app)
      component = loadedModule.name if loadedModule.name?
      app[key][component] = loadedModule


hbs.registerHelper 'json', (context) -> 
  new hbs.SafeString(JSON.stringify(context))

hbs.registerHelper 'markdown', (options) ->
  input = options.fn(@)
  result = require( "markdown" ).markdown.toHTML(input)
  return result

# Start the module if it's needed

optionParser = optimist.
  default('port', 3000).
  default('mqtt', 1883).
  default('redis-port', 6379).
  default('redis-host', '127.0.0.1').
  default('redis-db', 0).
  usage("Usage: $0 [-p WEB-PORT] [-m MQTT-PORT] [-rp REDIS-PORT] [-rh REDIS-HOST]").
  alias('port', 'p').
  alias('mqtt', 'm').
  alias('redis-port', 'rp').
  alias('redis-host', 'rh').
  alias('redis-db', 'rd').
  describe('port', 'The port the web server will listen to').
  describe('mqtt', 'The port the mqtt server will listen to').
  describe('redis-port', 'The port of the redis server').
  describe('redis-host', 'The host of the redis server').
  boolean("help").
  describe("help", "This help")

argv = optionParser.argv

module.exports.setupRedis = setupRedis = (opts = {}) ->
  args = [opts.port, opts.host]
  app.redis.pubsub = redis.createClient(args...)
  app.redis.pubsub.select(opts.db || 0)
  app.redis.client = redis.createClient(args...)
  app.redis.client.select(opts.db || 0)

start = module.exports.start = (opts={}) ->

  opts.port ||= argv.port
  opts.mqtt ||= argv.mqtt
  opts.redisPort ||= argv['redis-port']
  opts.redisHost ||= argv['redis-host']
  opts.redisDB ||= argv['redis-db']

  if argv.help
    optionParser.showHelp()
    return 1

  setupRedis(port: opts.redisPort, host: opts.redisHost, db: opts.redisDB)
  configure()

  http.listen(opts.port)
  app.controllers.device_bridge.start(opts.mqtt)
  console.log("mqtt-rest web server listening on port %d in %s mode", opts.port, app.settings.env)
  console.log("mqtt-rest mqtt server listening on port %d in %s mode", opts.mqtt, app.settings.env)

if require.main.filename == __filename
  start()


