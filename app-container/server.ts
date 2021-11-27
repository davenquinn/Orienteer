/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { spawn } = require("child_process");
const chalk = require("chalk");

const prefix = `[${chalk.blue("Flask")}] `;

const print = function (data) {
  data = data.toString("utf8");
  return console.log(prefix + data.slice(0, data.length - 1));
};

const startServer = function (argsArray) {
  // Takes an array of args and returns
  // a child process object
  const command = argsArray.shift();
  const child = spawn(command, argsArray, { cwd: process.cwd() });

  print("Starting application server ");

  child.on("exit", (code, signal) =>
    print("Server process quit unexpectedly ")
  );

  const on_exit = function () {
    child.kill("SIGINT");
    return process.exit(0);
  };

  child.stdout.on("data", print);
  child.stderr.on("data", print);
  return child;
};

module.exports = startServer;
