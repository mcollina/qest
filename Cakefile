
child_process = require('child_process')
process = global.process
path = require('path')

runExternal = (command, callback) ->
  console.log("Running #{command}")
  child = child_process.spawn("/bin/sh", ["-c", command])
  child.stdout.on "data", (data) -> process.stdout.write(data)
  child.stderr.on "data", (data) -> process.stderr.write(data)
  child.on('exit', callback) if callback?

launchSpec = (args, callback) ->
  runExternal "NODE_ENV=test ./node_modules/.bin/mocha --compilers coffee:coffee-script-redux #{args}", callback

task "spec", ->
  launchSpec "--recursive test", (result) ->
    process.exit(result)

task "spec:ci", ->
  launchSpec "--watch --recursive test"

task "features", ->
  runExternal "NODE_ENV=test ./node_modules/.bin/cucumber.js -r node_modules/coffee-script-redux/lib/coffee-script/module.js -t ~@wip", (result) ->
    if result != 0
      console.log "FAIL: scenarios should not fail"
    process.exit(result)

task "features:wip", ->
  runExternal "NODE_ENV=test ./node_modules/.bin/cucumber.js -t @wip", (result) ->
    if result == 0
      console.log "FAIL: wip scenarios should fail"
      process.exit(1)
