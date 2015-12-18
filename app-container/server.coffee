spawn = require('child_process').spawn
chalk = require('chalk')

prefix = "[#{chalk.blue("Flask")}] "

print = (data)->
  data = data.toString('utf8')
  console.log prefix+data.slice(0,data.length-1)

startServer = (argsArray)->
  # Takes an array of args and returns
  # a child process object
  command = argsArray.shift()
  child = spawn command,
    argsArray, cwd: process.cwd()

  print "Starting application server "

  child.on 'exit',(code, signal) ->
    print "Server process quit unexpectedly "

  on_exit = ->
    child.kill("SIGINT")
    process.exit(0)

  child.stdout.on "data", print
  child.stderr.on "data", print
  return child

module.exports = startServer

