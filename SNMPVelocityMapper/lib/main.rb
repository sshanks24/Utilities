# == Synopsis
#
# snmpXml2csv: converts the SNMP.xml to a csv file consisting of four "columns".
#
#Column 1 is the programatic name
#Column 2 is the OID name.
#Column 3 is the OID numeric representation
#Column 4 is the Velocity Register
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
CH3 = "OID Numeric"
CH4 = "Velocity Register"

# Verify arguments
if ARGV.length != 2
  RDoc::usage
end

# Handle arguments
path_to_xml = ARGV.shift
path_to_csv = ARGV.shift
path_to_dd = 'C:\\LMG_Test\\ruby\\Utilities\\SNMPVelocityMapper\\fdm\\enp2dd.xml'


def find_velocity_register(datapoint,path_to_dd)
  if datapoint.attribute('type').to_s == 'DATA'
    datapoint.each_element_with_attribute("name") do |oid|
      if oid.attribute('OID').to_s =~ /hierarchy/
        tmp_array = oid.attribute('OID').to_s.split('.')
        tmp_array.pop #Remove the hierarchy string at the end of the array
        return tmp_array.pop #Return
      end
    end
  end
  if datapoint.attribute('type').to_s == 'ALARM'
    File.open(path_to_dd) do |config_file|
      config = REXML::Document.new(config_file)
      config.root.elements.each("DataDictEntry/ProgrammaticName") do |name|
        if name.text == datapoint.attribute('name').to_s
          puts 'Match Found!'
          config.root.elements.each("DataDictEntry/DataId") do |id|
            return id.text
          end
        end
      end
    end
  end
  return 'Not Found!'
end

# Create/Open the output file and write the column headers
begin

  if File.exists?(path_to_xml)
    File.open(path_to_xml) do |config_file|
      # Open the document
      config = REXML::Document.new(config_file)

      # Create/Open the output file and write the column headers
      out_file = File.new(path_to_csv, 'w')
      out_file.puts CH1 << "," << CH2 << "," << CH3 << "," << CH4
      config.root.elements.each("GDD_POINT") do |datapoint|
        velocity_register = find_velocity_register(datapoint,path_to_dd)
        datapoint.each_element_with_attribute("name") do |oid|
          programmatic_name = datapoint.attribute('name').to_s
          next if oid.attribute('name').to_s == 'lgpFlexibleEntryReadableValue'
          puts programmatic_name + "," + oid.attribute('name').to_s + "," + oid.attribute('OID').to_s + "," + velocity_register
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