# == Synopsis
#
# bacnet_bulk_write: performs a bulk set of bacnet writes from the supplied
# spreadsheet and creates a time stamped copy of that spreadsheet with results
#
# == Usage
#
# bacnet_bulk_write ip_address path_to_spreadsheet
#
require 'rdoc/usage'
require 'bacnet_poller'

# Verify arguments
if ARGV.length != 2
  RDoc::usage
end

# Handle arguments
ip_address = ARGV.shift
path_to_spreadsheet = ARGV.shift

bacnet_bulk = BacnetPoller.new(ip_address, path_to_spreadsheet)
bacnet_bulk.run_write
