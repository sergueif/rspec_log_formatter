require "rspec_log_formatter/version"
module RspecLogFormatter
  FILENAME = "rspec.history"
end
Dir[File.join(File.dirname(__FILE__), "./**/*.rb")].each {|file| require file }
