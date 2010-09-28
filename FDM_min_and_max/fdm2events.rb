# == Synopsis
#
# gdd2csv: converts global data dictionary (enp2dd.xml) file to a csv consisting of 3 'columns'
#
# Column 1 is the data ID
#
# Column 2 is the programmatic name
#
# Column 3 is the data label text id
#
#
# == Usage
#
# fdm2events path2fdm.xml path2out.csv
#

require 'rdoc/usage'
require 'rexml/document'

include REXML

# Constants to define data headers of CSV - CH = Column Headers

CH = ["dataID","programmaticName","textID"]

# Verify arguments
if ARGV.length != 2
  RDoc::usage
end

# Handle arguments
path2fdm = ARGV.shift
path2out = ARGV.shift

def parseFDM(path_to_xml)
    if File.exists?(path_to_xml)
    File.open(path_to_xml) do |config_file|
      # Open the document
      config = REXML::Document.new(config_file)

      # Initialize variables (scope is outside of do loops)
      output = Array.new

      config.root.elements.each("/DataModel/ReportDescriptor/dataPoint") do |datapoint|
        type = datapoint.attribute('type').to_s
        if type =~ /event/i
          datapoint.elements.each(type + '/DataIdentifier') do |id|
            #puts id.text
            output << id.text
          end
          datapoint.elements.each(type + '/ProgrammaticName') do |name|
            #puts name.text
            output << name.text
          end
          datapoint.elements.each(type + '/DataLabel/TextID') do |textID|
            #puts textID.text
            output << textID.text
          end
        end
      end
      return output
    end
  else raise 'Input XML file not found!'
  end
end

begin

  output = parseFDM(path2fdm)
  
  # Create/Open the output file and write the column headers
  out_file = File.new(path2out, 'w')
  for i in 0..CH.size-1 do
    if i < CH.size-1 then out_file.print CH[i] + ","
    else out_file.puts CH[i]
    end
  end

  for i in 1..output.size do
    if i == 1 then out_file.print output[i-1] + ","; next; end;
    if i % CH.size != 0 then out_file.print output[i-1] + ","
    else out_file.puts output[i-1]
    end
  end

rescue => e
  puts "Error occured: #{e}"
  puts "#{$@}"
  if e.to_s =~/Permission/ then
    puts "Do you have a file open?"
  else puts "???"
  end
end
