# == Synopsis
#
# snmpXml2csv: converts the SNMP.xml to a csv file consisting of three "columns".
#
#Column 1 is the programatic name.
#
#Column 2 is the OID name.
#
#
# == Usage
#
# snmpXml2csv path_to_xml path_to_csv
#

require 'rexml/document'
require 'rdoc/usage'

include REXML

# Constants to define data headers of CSV - CH = Column Header

CH1 = "Programatic Name"
CH2 = "OID Name"
CH3 = "Index Name"

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

      # Create/Open the output file and write the column headers
      out_file = File.new(path_to_csv, 'w')
      out_file.puts CH1 << "," << CH2 << "," << CH3

      # Initialize variables (define scope)
      programmatic_name = ''
      oid_name = ''
      index_name = ''
      output = ''
      config.root.elements.each("GDD_POINT") do |datapoint|

        if datapoint.attribute('type').to_s == "DATA"
          datapoint.each_element do |oid|
            programmatic_name = datapoint.attribute('name').to_s
            oid_name = oid.attribute('OID').to_s.gsub(/\.hierarchy/,'')
            if oid.has_elements? then
            oid.each_element do |data_id|
              data_id.each_element do |index|
                index_name = index.attribute('descValue').to_s
                puts programmatic_name + "," + oid_name + "," + index_name
              end
            end
            else puts programmatic_name + "," + oid_name
            end
          end
        end
        if datapoint.attribute('type').to_s == "DATA"
          #TODO - Need to process alarm points...
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