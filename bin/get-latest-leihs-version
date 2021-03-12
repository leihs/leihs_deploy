#!/usr/bin/env ruby
# WANT_JSON

require 'json'
require 'yaml'

begin
  Dir.chdir(__dir__)
  fail unless system('../../dev/releasenotes-md-to-yaml.rb') # generate combined YAML file
  release = YAML.load_file('../../config/releases.yml')['releases'].first
  raise "no latest release found" unless release
  puts \
    "#{release['version_major']}" \
    + ".#{release['version_minor']}.#{release['version_patch']}" \
    + (release['version_pre'] ? "-#{release['version_pre']}" : '')

rescue Exception => e
  puts e
  puts "Error: leihs version not found! '#{e}'"
  exit 1
end
