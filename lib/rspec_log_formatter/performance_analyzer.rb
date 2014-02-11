require 'erb'
require 'chartkick'

module RspecLogFormatter
  class ERBContext
    include Chartkick::Helper
    def initialize(hash)
      hash.each_pair do |key, value|
        instance_variable_set('@' + key.to_s, value)
      end
    end
    def get_binding
      binding
    end
  end
  class PerformanceAnalyzer
    def initialize(filepath)
      @history_manager = HistoryManager.new(filepath)
    end

    def write(description, filepath)
      chartkick_js = File.open(File.join(File.dirname(__FILE__), './javascripts/chartkick.js')).read
      context = ERBContext.new({chartkick_js: chartkick_js, plots: analyze(description)})
      template = ERB.new(File.open(File.join(File.dirname(__FILE__), './templates/charts.html.erb')).read)
      html = template.result(context.get_binding)
      File.open(filepath, 'w').write(html)
    end

    def analyze(test_description)
      @history_manager.results
      .select{ |result| result.description == test_description }
      .reduce({}) do |memo, result|
        memo[result.time.to_s] = result.duration
        memo
      end
    end
  end
end
