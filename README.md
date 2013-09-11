grunt-branches
==============
Run specified task against all remote branches of a git submodule.

[grunt]: https://github.com/gruntjs/grunt
[getting_started]: https://github.com/gruntjs/grunt/wiki/Getting-started

## Getting Started
Install this grunt plugin next to your project's [grunt.js gruntfile][getting_started] with: ``npm install grunt-branches --save-dev``

Then add this line to your project's ``Gruntfile.coffee``:

```coffeescript
grunt.loadNpmTasks 'grunt-branches'
```

## Documentation

```coffeescript
grunt.initConfig

  # ... other configs

  branches:
    foo:
      path: 'ext/foo'

  # ... other configs
```

To run the task 'b' on all remote branches of the submodule 'foo' run: ``grunt branches:foo:b``

Or register a shortcut:
```coffeescript
grunt.registerTask 'buildall', ['branches:foo:b']
```

### Events
The following events are emitted and can be subscribed to using [grunt.emit.on](https://github.com/gruntjs/grunt/wiki/grunt.event)

* **branches.checkedout** - params: branch, path
* **branches.taskqueued** - params: branch, path

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [grunt][grunt].

## License
Copyright (c) 2013, Derek Petersen

Licensed under the MIT license.
