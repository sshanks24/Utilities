# == Synopsis
#
# v42csv: converts the savedDevice.xml produced by the Velocity Browser to a csv file consisting of three "columns".
#
# Column 1 is the Velocity 4 data label of the data point (with accompanying multimodule id and report name where appropriate.
# Column 2 is the Velocity 4 register.
# Column 3 is the value of that data point.
#
#
# == Usage
#
# v42csv path_to_xml path_to_csv
#

require 'rexml/document'
require 'rdoc/usage'

include REXML

# Constants to define data headers of CSV - CH = Column Header

CH1 = "Velocity Label"
CH2 = "Velocity Register"
CH3 = "Velocity Value"

# Verify arguments
if ARGV.length != 2
  RDoc::usage
end

# Handle arguments
path_to_xml = ARGV.shift
path_to_csv = ARGV.shift

# Create/Open the output file and write the column headers
begin

if File.exists?(path_to_xml)
  File.open(path_to_xml) do |config_file|
    # Open the document
    config = REXML::Document.new(config_file)
    i = 1
    multi_module_exists = FALSE
    
    # Create/Open the output file and write the column headers
    out_file = File.new(path_to_csv, 'w')
    out_file.puts CH1 << "," << CH2 << "," << CH3
    config.root.elements.each("Report") do |element|
     if element.next_element.attribute('reportID') == element.attribute('reportID') 
        multi_module_exists = TRUE
      else multi_module_exists = FALSE
      end unless element.next_element == nil
      element.each_element_with_attribute('id') do |child|
        value = child.text
        value = '' if child.text == nil
        multi_module_index = element.attribute('mmidx').to_s.to_i + 1
        if element.attribute('mmidx').to_s == '0' and multi_module_exists == FALSE
          out_file.puts child.attribute('name').to_s << "," << child.attribute('id').to_s << "," << value
        else out_file.puts child.attribute('name').to_s << " (#{element.attribute('name')} [#{multi_module_index.to_s}])," << child.attribute('id').to_s << "," << value
        end
      end
    end
  end
else raise 'Input XML file not found!'
end

rescue => e
  puts "Error occured: #{e}"
  if e.to_s =~/Permission/ then
    puts "Do you have a file open?"
  else puts "Maybe the XML file is malformed?"
  end
end