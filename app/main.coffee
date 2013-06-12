$ ->
  _ = require 'underscore'
  _path = require 'path'

  gui = require 'nw.gui'
  win = gui.Window.get()

  $("#exit_btn").click (e) ->
    win.close()

  # prevent default D&D behavier.
  $(window).on "dragover", (e) ->
    e.preventDefault()
    return false
  .on "drop", (e) ->
    e.preventDefault()
    return false

  # buttons
  mode = "jshint"
  $("#jshint_btn").click (e) -> mode = "jshint"
  $("#uglify_btn").click (e) -> mode = "uglify"
  $("#csslint_btn").click (e) -> mode = "csslint"
  $("#cssmin_btn").click (e) -> mode = "cssmin"
  $("#coffee_btn").click (e) -> mode = "coffee"

  do_process = (path) ->
    # 拡張子チェック
    ext = _path.extname path
    if _.indexOf(["jshint", "uglify"], mode) != -1
      if ext != ".js"
        alert "JavaScriptファイルではありません"
        return
    else if mode == "coffee"
      if ext != ".coffee"
        alert "CoffeeScriptファイルではありません"
        return
    else
      if ext != ".css"
        alert "CSSファイルではありません"
        return
      
    func = switch mode
      when "jshint" then do_jshint
      when "uglify" then do_uglify
      when "csslint" then do_csslint
      when "cssmin" then do_cssmin
      when "coffee" then do_coffee
      else do_jshint
    func path
    return
    
  do_jshint = (path) -> 
    fs = require 'fs'

    source = fs.readFileSync path, 
      encoding: 'utf-8'

    JSHINT = require("jshint").JSHINT;
    
    success = JSHINT source

    if success
      $("#result-area").html $("<h1></h1>").text("Success!")
    else
      $("#result-area").html ""
      $("#result-area").append $("<h1></h1>").text("Fail! "+"There's "+JSHINT.errors.length+" errors!")
      _.each JSHINT.errors, (error, index, list) ->
        p = $("<p>")
        p.text path+": line "+error.line+", col "+error.character+", "+error.reason
        $("#result-area").append(p)
        return

    return

  do_uglify = (path) ->
    uglifier = require 'uglify-js'

    minified = uglifier.minify path

    $("#result-area").html ""
    $("#result-area").text(minified.code)

    return

  do_coffee = (path) ->
    coffee = require 'coffee-script'
    fs = require 'fs'

    source = fs.readFileSync path, 
      encoding: 'utf-8'

    result = coffee.compile source

    $("#result-area").html ""
    $("#result-area").append $("<pre>").text(result)

    return

  do_csslint = (path) ->
    csslint = require( "csslint" ).CSSLint
    fs = require 'fs'

    source = fs.readFileSync path, 
      encoding: 'utf-8'

    result = csslint.verify(source) 

    $("#result-area").html ""
    if result.messages.length
      # error
      $("#result-area").append $("<h1>").text("Fail! "+"There's "+result.messages.length+" errors!")
      $("#result-area").append $("<h2>").text(path+":")
      _.each result.messages, (message, index, list) ->
        p = $("<p>")
        if message.rollup
          p.text (index+1)+": "+message.type+ " "+message.message
        else
          p.text (index+1)+": "+message.type+ " at line "+message.line+", col "+message.col+" "+message.message+" "+message.evidence
        $("#result-area").append(p)
        return
    else
      # no error
      $("#result-area").html $("<h1></h1>").text("Success!")

    return

  do_cssmin = (path) -> #use css-clean
    cssmin = require 'clean-css'
    fs = require 'fs'

    source = fs.readFileSync path, 
      encoding: 'utf-8'

    result = cssmin.process source

    $("#result-area").html ""
    $("#result-area").text(result)

    return

  # drop
  $("#drop-area").on "dragenter", (e) ->
    $(this).addClass "hover"
    return false;
  .on "dragleave", (e) ->
    $(this).removeClass "hover"
    return false
  .on "drop", (e) ->
    path = e.originalEvent.dataTransfer.files[0].path
    filename = _path.basename path

    do_process path

    e.preventDefault()
    return false

  return
