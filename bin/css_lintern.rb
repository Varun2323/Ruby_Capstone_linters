#!/usr/bin/env ruby

require_relative '../lib/linter_logic'

# Select the file you want to test here. By default the file is lib/style.css
# Copy or move your CSS file into the lib/ sub-directory of this program's root directory

file = 'lib/style.css'

f = File.open(file, 'r+')
new_check = Check.new
new_check.start(f)
puts 'No errors were detected in your css file' unless new_check.line_errors
