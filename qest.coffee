#! /usr/bin/env coffee

# Module dependencies.

optimist = require 'optimist'
express = require 'express'
path = require 'path'
fs = require 'fs'
hbs = require 'hbs'
redis = require 'redis'
mqtt = require "mqttjs"
EventEmitter = require('events').EventEmitter
RedisStore = require('connect-redis')(express)
ascoltatori = require('ascoltatori')

# Create Server

module.exports.app = app = express()
http = require('http').createServer(app)

# Configuration

app.redis = {}

module.exports.configure = configure = ->
  app.configure 'development', ->
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

  app.configure 'production', ->
    app.use(express.errorHandler())

  app.configure -> 
    app.set('views', __dirname + '/app/views')
    app.set('view engine', 'hbs')
    app.use(express.bodyParser())
    app.use(express.methodOverride())
    app.use(express.cookieParser())
    app.use(express.session(secret: "wyRLuS5A79wLn3ItlGVF61Gt", 
      store: new RedisStore(client: app.redis.client), maxAge: 1000 * 60 * 60 * 24 * 14)) # two weeks

    app.use(app.router)
    app.use(express.static(__dirname + '/public'))

  # setup websockets
  io = app.io = require('socket.io').listen(http)

  io.configure 'production', ->
    io.enable('browser client minification');  # send minified client
    io.enable('browser client etag');          # apply etag caching logic based on version number
    io.enable('browser client gzip');          # gzip the file
    io.set('log level', 0)

  io.configure 'test', ->
    io.set('log level', 0)

  load("models")
  load("controllers")
  load("helpers")

load = (key) ->
  app[key] = {}
  loadPath = __dirname + "/app/#{key}/"
  for component in fs.readdirSync(loadPath)
    if component.match /(js|coffee)$/
      component = path.basename(component, path.extname(component))
      loadedModule = require(loadPath + component)(app)
      component = loadedModule.name if loadedModule?.name? and loadedModule.name != ""
      app[key][component] = loadedModule

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

module.exports.setupAscoltatore = setupAscoltatore = (opts = {}) ->
  app.ascoltatore = new ascoltatori.RedisAscoltatore
    redis: redis
    port: opts.port
    host: opts.host
    db: opts.db

module.exports.setup = setup = (opts = {}) ->
  args = [opts.port, opts.host]
  app.redis.client = redis.createClient(args...)
  app.redis.client.select(opts.db || 0)

  setupAscoltatore(opts)


start = module.exports.start = (opts={}, cb=->) ->

  opts.port ||= argv.port
  opts.mqtt ||= argv.mqtt
  opts.redisPort ||= argv['redis-port']
  opts.redisHost ||= argv['redis-host']
  opts.redisDB ||= argv['redis-db']

  if argv.help
    optionParser.showHelp()
    return 1

  setup(port: opts.redisPort, host: opts.redisHost, db: opts.redisDB)
  configure()

  countDone = 0
  done = ->
    cb() if countDone++ == 2

  http.listen opts.port, ->
    console.log("mqtt-rest web server listening on port %d in %s mode", opts.port, app.settings.env)
    done()

  mqtt.createServer(app.controllers.mqtt_api).listen opts.mqtt, ->
    console.log("mqtt-rest mqtt server listening on port %d in %s mode", opts.mqtt, app.settings.env)
    done()

  app

if require.main.filename == __filename
  start()
