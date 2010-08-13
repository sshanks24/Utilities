# == Synopsis
#
# fdm2testlogcsv.rb
#
# Maybe one day this will do what I intend... to take a device FDM and the GDD and output test cases for import into test log.
#
#
# == Usage
#
# fdm2testlogcsv.rb path2fdm.xml path2gdd.xml path2testcase.xml path2out.csv
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
if ARGV.length != 4
  RDoc::usage
end

# Handle arguments
#TODO Check if these files exist in the beginning
path2fdm = ARGV.shift
path2gdd = ARGV.shift
path2testcase = ARGV.shift
path2out = ARGV.shift


def parse_fdm(path_to_xml,path_to_test_case) #TODO Need to handle Multi-module test cases...
  if File.exists?(path_to_xml)
    File.open(path_to_xml) do |config_file|
      # Open the document
      config = REXML::Document.new(config_file)

      # Initialize variables (scope is outside of do loops)
      output = Array.new
      device_name = config.root.attribute('ProgrammaticName').to_s

      #TODO This is sometimes /DataModel instead of /DevModel need to figure out
      config.root.elements.each("/DevModel/ReportDescriptor") do |descriptor|
        # These are the web navigation folders
        if descriptor.attribute('id').to_s.to_i > 256 and descriptor.attribute('privateReport').to_s == 'False'
          report_name = descriptor.attribute('ProgrammaticName').to_s
          output << 'suite' << device_name << report_name << report_name
          output.pad(32)
          descriptor.elements.each("dataPoint") do |data_point|
            output << 'case' << device_name + '\\' + report_name << '' #This needs to be a GUID
            output << build_title(data_point)
            output.push(build_test_case(path_to_test_case))
          end
        end
        # Need logic for Control Test cases - /dataPoint/TYPE/AccessDefn = RW
        # Need logic for Events - /dataPoint/TYPE =~ /event/i
        # Need logic/input for SNMP/Modbus inputs
      end
      return output
    end
  else raise 'Input XML file not found!'
  end
end

def build_title(datapoint)
  interface = 'WB'
  data_label = ''
  id = datapoint.attribute('id').to_s
  type = datapoint.attribute('type').to_s
  datapoint.elements.each(type) do |data|
    data.elements.each('DataLabel/TextID') {|name| data_label = name.text}
  end

  if $strings.has_key?(data_label)
    data_label = $strings.fetch(data_label)
  else data_label = "UNKNOWN STRING ID: #{data_label}"
  end
  title = interface + ' - ' + id + ' - ' + data_label
  puts title
  return title
end

def build_test_case(path_to_xml)
  # Initialize variables (scope is outside of do loops)
  output = Array.new
  File.open(path_to_xml) do |config_file|
    # Open the document
    config = REXML::Document.new(config_file)

    counter = 1
    config.root.elements.each() do |element|
      if element.inspect.to_s =~ /history_entry/
        counter += 1
        next
      end
      if counter > 2 #Skip the firt two elements
        if element.text != nil
          output << element.text
          else output << ""
        end
      end
      counter += 1
    end
  end
  return output
end

def build_string_id_hash(path_to_xml,path_to_string)
  if File.exists?(path_to_xml)
    File.open(path_to_xml) do |config_file|
      # Open the document
      config = REXML::Document.new(config_file)
      # Initialize variables (scope is outside of do loops)
      h = Hash.new
      puts "Parsing #{path_to_xml} for data labels."
      config.root.elements.each(path_to_string) do |string|
        key = string.attribute('Id').to_s
        if string.text == nil then
          value = ""
        else
          value = string.text
        end
        h[key] = value
      end
      return h
    end
  else raise 'Input XML file(GDD) not found!'
  end
end

class Array
def pad(i)
  i.times {self << ""}
  return self.flatten!
end
end

begin

  global_strings = Hash.new
  global_strings = build_string_id_hash(path2gdd, '/Enp2DataDict/GlobalStringDefinitions/String')
  local_strings = Hash.new
  local_strings = build_string_id_hash(path2fdm, '/DevModel/LocalStringDefinitions/String')

  $strings = global_strings.merge(local_strings)
  $strings.default('UNKNOWN STRING ID')
  output = parse_fdm(path2fdm,path2testcase)

  # Create/Open the output file and write the column headers
  out_file = File.new(path2out, 'w')
  for i in 0..CH.size-1 do
    if i < CH.size-1 then out_file.print CH[i] + ","
    else out_file.puts CH[i]
    end
  end

  for i in 1..output.size do
    if i == 1 then out_file.print output[i-1].to_s + ","; next; end;
    if i % CH.size != 0 then out_file.print output[i-1].to_s + ","
    else out_file.puts output[i-1].to_s
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