# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require File.expand_path '../../config/environment.rb', __FILE__

ENV['RACK_ENV'] = 'test'
require File.expand_path '../../app/main.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() Reversible end
end

RSpec.configure { |c| c.include RSpecMixin }