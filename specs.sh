#!/bin/bash
rm -f dummy/rspec.history
rspec && cd dummy && rspec && cd ..
cat dummy/rspec.history
