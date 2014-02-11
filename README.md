# RspecLogFormatter

Saves a history of rspec test outcomes, and provides a few tools to learn from that data (i.e. flakyness, performance regressions)

## Installation

Add this line to your application's Gemfile:

    gem 'rspec_log_formatter'

## Usage

You can include the formatter in your suite, by configuring Rspec.

		RSpec.configure do |config|
		  config.formatters << RspecLogFormatter::Formatter::Factory.new.build
		  config.formatters << RspecLogFormatter::AnalyzerFormatter::Factory.new.build
		end
		
### Configuration

#### Build number access

The formatter reads `BUILD_NUMBER` environment variable to separate specs into builds.
	
	config.formatters << RspecLogFormatter::Formatter::Factory.new(
	  build_number: ENV["MY_BUILD_NUMBER"]
	).build
	
#### Limit history length

The formatter keeps appending to `rspec.history` to keep track of spec outcomes. If you wish to limit this, you can specify how many builds to keep:

	config.formatters << RspecLogFormatter::Formatter::Factory.new(
	  limit_history: 4
	).build
	
Now it will only keep last 4 builds of history and truncate the rest.
**NOTE**: this is separate from the `AnalyzerFormatter` option `builds_to_analyze`

#### Number of builds to analyze

Separate from the amount of history to keep, `builds_to_analyze` option, specifies how many of the recent builds to use when calculating test's flakyness.

	config.formatters << RspecLogFormatter::AnalyzerFormatter::Factory.new(
	  builds_to_analyze: 3
	).build

This instructs the analyzer to only use last 3 builds when calculating it's report.

#### What if I re-run my tests?

If you use something like 'rspec-rerun' gem to retry flaky tests, AnalyzerFormatter can estimate how much time does a flaky test is costing your test suite. Specify `max_reruns` to inform it of the max number of retries your suite is making.

	config.formatters << RspecLogFormatter::AnalyzerFormatter::Factory.new(
	  max_reruns: 3
	).build

### How it works

Results of each of the tests in your test suite will go in `rspec.history` in the directory the rspec is ran from. What you'll see in there is output like this(columns separated by tabs):

	654	2014-02-10 11:30:20 -0800	passed	Math works	./spec/dummy_spec.rb			0.000722
	
The colums are as follows(tab separated):

	BUILD_NUMBER	TIME_OF_RUN	PASS/FAIL	example description	example_filepath	exception.message	exception.class	test_duration	

## Contributing

1. Fork it ( http://github.com/<my-github-username>/rspec_log_formatter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
