through = require("through2")
PluginError = require("plugin-error")

# gulp-indent
# Indents piped files
# Options: (key/default)
# * tabs: false
# * amount: 2

isEmptyLine = (string)->
    return string is "" or string is "\r"

module.exports = (options={}) ->
  
  options.tabs ?= false
  options.amount ?= 2

  indent = (file, enc, done) ->
    
    #jshint validthis:true
    
    # Do nothing if no contents
    if file.isNull()
      @push file
      return done()

    # Error if file is a stream
    if file.isStream()
      @emit "error", new PluginError("gulp-indent", "Stream content is not supported")
      return done()
  
    # Indent the file
    if file.isBuffer()
      # Tabs or spaces
      character = if options.tabs then "\t" else " "
      # Create the correct amount of indentation
      indentation = ""
      indentation += character for number in [0...options.amount]
      # Split the file into lines
      lines = file.contents.toString().split "\n"
      # Add the indentation to the lines, if they aren't empty.
      lines = ((if !isEmptyLine(line)  then indentation+line else line) for line in lines )
      # Replace the file contents
      file.contents = new Buffer(lines.join "\n")
      # Return the file to the stream
      @push file
    #Return control to the stream
    done()

  through.obj indent