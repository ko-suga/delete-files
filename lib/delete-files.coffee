{CompositeDisposable} = require 'atom'
shell = require 'shell'

module.exports = DeleteFiles =
  subscriptions: null
  patterns: []

  config:
    patternsString:
      title: 'File Patterns'
      type: 'string'
      default: '/.DS_Store$;/Thumbs.db$'
      description: 'Target file patterns (RegExp, Case insensitive). Separate by semicolon(;)'
      order: 1

  activate: (state) ->
    # Events subscribed to in atom's system
    # can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
          'Delete Files:Matching Patterns': => @deleteMatchingPatterns()

  deactivate: ->
    @subscriptions.dispose()

  gather: (patterns, dirs) ->
    list = []
    recurse = (it) ->
      if it.isFile()
        path = it.getPath().replace(/\\/g, "/")
        for pattern in patterns
          if pattern.test(path)
            list.push it
            return
      else if it.isDirectory()
        recurse(dir) for dir in it.getEntriesSync()

    for dir in dirs
      recurse(dir) if dir

    return list

  stringToPatterns: (input) ->
    return (RegExp(it.trim(), "i") for it in input.split(';'))

  deleteMatchingPatterns: ->
    patterns = @stringToPatterns(atom.config.get('delete-files.patternsString'))

    list = @gather(patterns, atom.project.getDirectories())

    if list.length > 0
      paths = (it.getPath() for it in list)

      return atom.confirm({
        message: "Are you sure you want to delete " +
                (paths.length > 1 ? "files" : "a file") + " ?",
        detailedMessage: "You are deleting:\n" + (paths.join('\n')),
        buttons: {
          "Move to Trash": ->
            results = []
            results.push shell.moveItemToTrash(path) for path in paths
            return results;
          "Cancel": null
        }
      } ) ;
    else
      return atom.confirm({
        message: "Target file not found.",
        buttons: ['OK']
      } )
