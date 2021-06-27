# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'simplecov'

require_relative 'test_load_all'

SimpleCov.start
API_URL = app.config.API_URL
