require 'fileutils'
require 'pry'

Dir["./lib/**/*.rb"].each {|file| require file }

RSpec.configure do |config|
  config.before(:each) do
    FileUtils.rm('rspec.history', {force: true})
  end
end
