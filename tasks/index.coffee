git = require 'gift'
Q = require 'q'
colors = require 'colors'
exec = require('child_process').exec
grunt = require 'grunt'

fetchRemotes = (path) ->
  Q.nfcall exec, "cd #{path} && git fetch -a && git remote prune origin", timeout: 5000

getBranchNames = (branches) ->
  branches
  .filter (branch) ->
    branch.name isnt 'origin/HEAD'
  .map (branch) ->
    branch.name.split('origin/')[1]

getCommitHash = (path) ->
  Q.nfcall(exec, "cd #{path} && git rev-parse HEAD", timeout: 5000)
  .then (output) ->
    str = output.shift()
    str.substr 0, str.length - 2

getCurrentBranch = (path) ->
  Q.nfcall(exec, "cd #{path} && git rev-parse --abbrev-ref HEAD", timeout: 5000)
  .then (output) ->
    str = output.shift()
    str.substr 0, str.length - 1

queueTask = (branch, path, task) ->
  grunt.task.run "checkout:#{branch}:#{path}"
  grunt.task.run "commitinfo:#{path}"
  grunt.task.run task
  grunt.event.emit 'branches.taskqueued', branch, path
  grunt.log.ok "Task queued for #{colors.cyan(branch)}"

module.exports = (grunt) ->
  grunt.registerTask 'commitinfo', 'Announce commit info of submodule', (path) ->
    done = this.async()

    Q.all([getCurrentBranch(path),getCommitHash(path)])
    .then (info) ->
      branch = info[0]
      hash = info[1]
      grunt.event.emit 'branches.commitinfo', branch, hash, path
    .then(done, grunt.fail.warn)

  grunt.registerTask 'checkout', 'Checkout a specific branch', (branch, path) ->
    done = this.async()
    repo = git path

    repo.checkout branch, ->
      grunt.log.ok "Checked out #{colors.cyan(branch)}"
      grunt.event.emit 'branches.checkedout', branch, path
      done()

  grunt.registerMultiTask 'branches', 'Run specified task against all branches', (task = 'default') ->
    done = @async()

    path = @data.path
    repo = git path

    grunt.log.subhead "Queuing task #{colors.yellow(task)} for each branch"

    fetchRemotes(path)
    .then ->
      Q.nfcall(repo.remotes.bind(repo))
    .then(getBranchNames)
    .then (branchNames) ->
      branchNames
      .forEach (branch) ->
        queueTask branch, path, task
    .then(done, grunt.fail.warn)
