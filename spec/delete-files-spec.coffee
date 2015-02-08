DeleteFiles = require '../lib/delete-files'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "DeleteFiles", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('delete-files')

  describe "get patterns", ->
    it "parse settings", ->
      patterns = DeleteFiles.stringToPatterns('/.DS_Store$;/Thumbs.db$')

      expect(patterns.length).toEqual(2)
      expect(patterns[0]).toEqual(RegExp('/.DS_Store$', 'i'))
      expect(patterns[1]).toEqual(RegExp('/Thumbs.db$', 'i'))

  describe "gather target files", ->
    it "exists", ->
      patterns = (RegExp(it, "i") for it in '/d2.txt$;/foo/d1.txt'.split(';'))
      dirs = atom.project.getDirectories()
      list = DeleteFiles.gather(patterns, dirs)

      expect(list.length).toEqual(2)
      expect(/\/spec\/testfiles\/foo\/d1.txt$/.test(list[0].getPath())).toBe(true)
      expect(/\/spec\/testfiles\/foo\/d2.txt$/.test(list[1].getPath())).toBe(true)
