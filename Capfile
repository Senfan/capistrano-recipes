# Load DSL and Setup Up Stages

require 'deploy'
require 'capistrano'
require 'capistrano/setup'
require 'capistrano/deploy'
require 'github_api'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/**/*.rb').each { |r| import r }

# Set default stage
Rake::Task[:production].invoke