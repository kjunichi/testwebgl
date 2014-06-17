{View} = require 'atom'
config = atom?.config
TestWebGLLib = require './testwebgl-lib'

module.exports =
class TestWebGLView extends View
  @startDelay: 1000
  @CONFIG:
      color : "#FFF",
      fontSize : 10,
      speed : 3,
      chance : 0.975,
      tailLength : 40

  @content: ->
    @ul class: 'testwebgl centered background-message', =>
      @li outlet: 'container'

  initialize: ->
    @index = -1

    rtable = [];
    for j in [0..10000]
      rtable.push(Math.random());

    TestWebGLLib.options.speedForColumn = (c, t) ->
      (3 * Math.pow(Math.sin(4 * Math.PI * c / Math.floor(t) ), 2) + 2 * rtable[c]);

    atom.workspaceView.on 'pane-container:active-pane-item-changed pane:attached pane:removed', => @updateVisibility()
    setTimeout @start, @constructor.startDelay

  attach: ->
    pane = atom.workspaceView.getActivePane()
    top = pane.children('.item-views').position()?.top ? 0
    @css('top', top)
    pane.append(this)

  updateVisibility: ->
    if @shouldBeAttached()
      @start()
    else
      @stop()

  shouldBeAttached: ->
    atom.workspaceView.getPanes().length is 1 and not atom.workspaceView.getActivePaneItem()?

  start: =>
    return if not @shouldBeAttached()
    @attach()
    @showTestWebGL()

  stop: =>
    TestWebGLLib.land @testwebgl
    @detach()

  showTestWebGL: =>
    @configureTestWebGL()
    @testwebgl = TestWebGLLib.fly(@container)
    @testwebgl.forcestop = true

  configureTestWebGL: =>
    return unless config?
    TestWebGLLib.options.color = config.get('testwebgl.color')
    TestWebGLLib.options.fontSize = config.get('testwebgl.fontSize')
    TestWebGLLib.options.speed = config.get('testwebgl.speed')
    TestWebGLLib.options.chance = config.get('testwebgl.chance')
    TestWebGLLib.options.tailLength = config.get('testwebgl.tailLength')
    characters = ""
    if config.get('testwebgl.chineseCharacters')
      characters += TestWebGLLib.letters.chinese;
    if config.get('testwebgl.lowercaseEnglishCharacters')
      characters += TestWebGLLib.letters.lowercaseEnglish
    if config.get('testwebgl.uppercaseEnglishCharacters')
      characters += TestWebGLLib.letters.uppercaseEnglish
    if config.get('testwebgl.digitCharacters')
      characters += TestWebGLLib.letters.digits
    if config.get('testwebgl.leetCharacters')
      characters += TestWebGLLib.letters.leet
    characters += config.get('testwebgl.customCharacters')
    if (characters is "")
      characters = TestWebGLLib.letters.lowercaseEnglish + TestWebGLLib.letters.uppercaseEnglish + TestWebGLLib.letters.digits
    TestWebGLLib.options.letters = characters
