#!/usr/bin/env ruby
# WANT_JSON

require 'json'
require 'yaml'
require 'time'

TAG_PREFIX = ''.freeze # could also be 'v' in some projects ,like `v.1.0.0`

def latest_tag_from_version
  return @_latest_tag_from_version if @_latest_tag_from_version
  fail unless system('../dev/releasenotes-md-to-yaml.rb') # generate combined YAML file
  release = YAML.load_file('../config/releases.yml')['releases'].first
  @_latest_tag_from_version = \
    "#{TAG_PREFIX}""#{release['version_major']}" \
    + ".#{release['version_minor']}.#{release['version_patch']}" \
    + (release['version_pre'] ? "-#{release['version_pre']}" : '')
end

def git_describe_tag
  @_git_describe_tag ||= `cd .. && git describe --tags`.strip
end

def git_tree_id
  @_git_tree_id ||= `cd .. && git log -n 1 --pretty=%T`.strip
end

def git_commit_id
  @_git_commit_id ||= `cd .. && git log -n 1 --pretty=%H`.strip
end

def git_commit_id_short
  @git_commit_id_short ||= `cd .. && git log -n 1 --pretty=%h`.strip
end

def git_commit_date
  @_git_commit_date ||= `cd .. && git log -n 1 --pretty=%cI`.strip
end

def git_commit_messages
  `cd .. && ./dev/git-release-notes origin/stable HEAD`.strip
end

# main

begin
  print JSON.dump(
    changed: false,
    stdout: 'deploy info found.',
    data: {
      git_describe_tag: git_describe_tag,
      # NOTE: this actually means "is_a_tagged_release", keeping the old alias to not break anything:
      build_is_latest_release: git_describe_tag == latest_tag_from_version,
      is_a_tagged_release: git_describe_tag == latest_tag_from_version,
      tree_id: git_tree_id,
      commit_id: git_commit_id,
      commit_id_short: git_commit_id_short,
      commit_date: git_commit_date,
      commit_messages: git_commit_messages,
      time: Time.now.utc.iso8601
    }
  )
rescue Exception => e
  print JSON.dump(
    failed: true,
    urls: nil,
    stdout: "Error: deploy info not found! '#{e}'"
  )
  exit 1
end
