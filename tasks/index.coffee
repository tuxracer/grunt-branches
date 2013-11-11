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

queueTask = (branch, path, task) ->
  grunt.task.run "checkout:#{branch}:#{path}"
  grunt.task.run task
  grunt.event.emit 'branches.taskqueued', branch, path
  grunt.log.ok "Task queued for #{colors.cyan(branch)}"

module.exports = (grunt) ->
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
