# == Synopsis
#
# v42csv: converts the savedDevice.xml produced by the Velocity Browser to a csv file consisting of four "columns".
# The output style is controlled by the 3rd argument (modbus or bacnet)
#
# Column 1 is the Velocity 4 data label of the data point (with accompanying multimodule id and report name)
# Column 2 is the Velocity 4 numeric data identifier.
# Column 3 is the Velocity Multi-module index
# Column 4 is the value of that data point.
#
#
# == Usage
#
# v42csv path_to_xml path_to_csv modbus|bacnet
#

require 'saved_device_xml_parser'
require 'rdoc/usage'

include REXML

begin

# Verify number of arguments
if ARGV.length != 3
  RDoc::usage
end

# Handle arguments
path_to_xml = ARGV.shift
path_to_csv = ARGV.shift
switch_output = ARGV.shift

# Validate arguments
if File.exists?(path_to_xml) then
  # Do nothing if the arguments are valid
else raise "XML File does not exist!"
end

if switch_output =~ /(modbus)|(bacnet)/i
  # Do nothing if the arguements are valid
else RDoc::usage
end

transformation = SavedDeviceXMLParser.new(path_to_xml, switch_output)
transformation.output_to_csv(path_to_csv)

rescue => e
  puts "Error occured: #{e}"
  if e.to_s =~/Permission/ then
    puts "Do you have a file open?"
  else 
    puts "#{$@}"
  end
end



