# == Synopsis
#
# fdm2testlogcsv.rb
#
# Maybe one day this will do what I intend... to take a device FDM and the GDD and output test cases for import into test log.
#
#
# == Usage
#
# fdm2testlogcsv.rb path2fdm.xml path2gdd.xml path2out.csv
#

require 'rdoc/usage'
require 'rexml/document'

include REXML

# Constants to define data headers of CSV - CH = Column Headers

CH = ["Type","Test Suite","ID","Title","Hours Expected","Type","Phase",
  "Configurations","Resources","Status","Attempts","Last Attempt Date",
  "Last Attempt Time","Actual Hours","Testers","Faults","CR ID","Results",
  "Version","Build","Link2","Result Notes","Requirements","Created Date",
  "Created Time","Updated Date","Updated Time","Author","Update By",
  "Prerequisites","Description","Results","Notes Field 1","Revision History",
  "Link","Priority"]

# Verify arguments
if ARGV.length != 3
  RDoc::usage
end

# Handle arguments
path2fdm = ARGV.shift
path2gdd = ARGV.shift
path2out = ARGV.shift

def parseFDM(path_to_xml,path2gdd)
    if File.exists?(path_to_xml)
    File.open(path_to_xml) do |config_file|
      # Open the document
      config = REXML::Document.new(config_file)

      # Initialize variables (scope is outside of do loops)
      output = Array.new
      device_name = config.root.attribute('ProgrammaticName').to_s

      config.root.elements.each("/DataModel/ReportDescriptor") do |descriptor|
         # These are the web navigation folders
        if descriptor.attribute('id').to_s.to_i > 256 and descriptor.attribute('privateReport').to_s == 'False'
        report_name = descriptor.attribute('ProgrammaticName').to_s
        output << 'suite' << device_name + '\\' << report_name << report_name
        output.pad(32)
        descriptor.elements.each("dataPoint") do |data_point|
        output << 'case' << device_name + '\\' + report_name << '' #This needs to be a GUID
        output << buildTitle(data_point,path2gdd)
        output.pad(32) # buildTestCase(path_to_test_case)
        end
        end
      end
      return output
    end
  else raise 'Input XML file not found!'
  end
end

def buildTitle(datapoint, path2gdd)
  return 'title'
end

def buildTestCase(path_to_test_case)
  output = Array.new
  return output.pad(32)
end

class Array
def pad(i)
  i.times {self << ""}
  return self.flatten!
end
end

begin

  output = parseFDM(path2fdm,path2gdd)

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