{WorkspaceView, $} = require 'atom'

TestWebGLView = require '../lib/testwebgl-view'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "TestWebGL", ->
  [testWebGL, testWebGLView] = []

  activatePackage = (callback) ->
    waitsForPromise ->
      atom.packages.activatePackage('testwebgl').then ({mainModule}) ->
        {testWebGLView} = mainModule

    runs ->
      callback()

  describe "when the package is activated when there is only one pane", ->
    beforeEach ->
      atom.workspaceView = new WorkspaceView
      expect(atom.workspaceView.getPanes().length).toBe 1

    describe "when the pane is empty", ->
      it "attaches the view after a delay", ->
        expect(atom.workspaceView.getActivePane().getItems().length).toBe 0

        activatePackage ->
          expect(testWebGLView.parent()).not.toExist()
          advanceClock TestWebGLView.startDelay + 1
          expect(testWebGLView.parent()).toExist()

    describe "when the pane is not empty", ->
      it "does not attach the view", ->
        atom.workspaceView.getActivePane().activateItem($("item"))

        activatePackage ->
          advanceClock TestWebGLView.startDelay + 1
          expect(testWebGLView.parent()).not.toExist()

    describe "when a second pane is created", ->
      it "detaches the view", ->
        activatePackage ->
          advanceClock TestWebGLView.startDelay + 1
          expect(testWebGLView.parent()).toExist()

          atom.workspaceView.getActivePane().splitRight()
          expect(testWebGLView.parent()).not.toExist()

  describe "when the package is activated when there are multiple panes", ->
    beforeEach ->
      atom.workspaceView = new WorkspaceView
      atom.workspaceView.getActivePane().splitRight()
      expect(atom.workspaceView.getPanes().length).toBe 2

    it "does not attach the view", ->
      activatePackage ->
        advanceClock TestWebGLView.startDelay + 1
        expect(testWebGLView.parent()).not.toExist()

    describe "when all but the last pane is destroyed", ->
      it "attaches the view", ->
        activatePackage ->
          atom.workspaceView.getActivePane().remove()
          advanceClock TestWebGLView.startDelay + 1
          expect(testWebGLView.parent()).toExist()

  describe "when the view is attached", ->
    beforeEach ->
      atom.workspaceView = new WorkspaceView
      expect(atom.workspaceView.getPanes().length).toBe 1

      activatePackage ->
        advanceClock TestWebGLView.startDelay + 1

    it "has a canvas in the container", ->
      expect(testWebGLView.container.children('canvas')).toBeTruthy()
