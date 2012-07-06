
child_process = require('child_process')
process = global.process
path = require('path')

runExternal = (command, callback) ->
  console.log("Running #{command}")
  child = child_process.spawn("/bin/sh", ["-c", command])
  child.stdout.on "data", (data) -> process.stdout.write(data)
  child.stderr.on "data", (data) -> process.stderr.write(data)
  child.on('exit', callback) if callback?

launchSpec = (args...) ->
  runExternal "NODE_ENV=test ./node_modules/.bin/mocha --compilers coffee:coffee-script " + args.join(" ")

task "spec", ->
  launchSpec("--recursive test")

task "spec:ci", ->
  launchSpec("--watch")
