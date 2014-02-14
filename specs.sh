#!/bin/bash
rm -f dummy/rspec.history dummy/rspec.failures
RSPEC_RERUN_RETRY_COUNT=3 rspec && cd dummy && rake rspec-rerun:spec && cd ..
cat dummy/rspec.history
