# Set test environment
ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', 'alreadyfound.rb')

require 'rubygems'
require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'

set :run, false
set :raise_errors, true
set :logging, false