# RspecLogFormatter

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'rspec_log_formatter'

## Usage

You can include the formatter in your suite, by configuring the Rspec.

		RSpec.configure do |config|
		  config.formatters << RspecLogFormatter::Formatter::Factory
		  config.formatters << RspecLogFormatter::AnalyzerFormatter::Factory
		end
		

Results of each of the tests in your test suite will go in `rspec.history` in the directory the rspec is ran from. What you'll see in there is output like this(columns separated by tabs):

	654	2014-02-10 11:30:20 -0800	passed	Math works	./spec/dummy_spec.rb			0.000722
	
The colums are as follows:

	BUILD_NUMBER	TIME_OF_RUN	PASS/FAIL	example description	example_filepath		
	Build number
	Date and time
		


## Contributing

1. Fork it ( http://github.com/<my-github-username>/rspec_log_formatter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
