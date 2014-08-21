through = require("through2")
gutil = require("gulp-util")

# gulp-indent
# Indents piped files
# Options: (key/default)
# * tabs: false
# * amount: 2

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
      @emit "error", new gutil.PluginError("gulp-indent", "Stream content is not supported")
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
      # Add the indentation to the lines
      lines = (indentation+line for line in lines)
      # Replace the file contents
      file.contents = new Buffer(lines.join "\n")
      # Return the file to the stream
      @push file
    #Return control to the stream
    done()

  through.obj indent