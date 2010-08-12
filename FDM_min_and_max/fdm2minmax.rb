# == Synopsis
#
# fdm2csv: converts a device FDM file to a csv consisting of 5 'columns'
#
# Column 1 is the data ID
#
# Column 2 is the programmatic name
#
# Column 3 is the maximum value
#
# Column 4 is the minimum value
#
# Column 5 is the String ID for the Units of Measure
#
# Column 6 is the Enumeration data ID
#
# == Usage
#
# fdm2csv path2fdm.xml path2gdd.xml path2out.csv
#

require 'rdoc/usage'
require 'rexml/document'

include REXML

# Constants to define data headers of CSV - CH = Column Headers

CH = ["dataID","programmaticName","MaxValue","MinValue", "Units", "Enumeration"]

# Verify arguments
if ARGV.length != 3
  RDoc::usage
end

# Handle arguments
path2fdm = ARGV.shift
$path2gdd = ARGV.shift
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
        # Skip over event,text, and time data types
        if type =~ /(event)|(text)|(time)/i then next; end;
        datapoint.elements.each(type + '/DataIdentifier') do |id|
          #puts id.text
          output << id.text
        end
        datapoint.elements.each(type + '/ProgrammaticName') do |name|
          #puts name.text
          output << name.text
        end
        if type =~ /int/i
          datapoint.elements.each(type + '/ValueMax') do |max|
            #puts max.text
            output << max.text
          end
          datapoint.elements.each(type + '/ValueMin') do |min|
            #puts min.text
            output << min.text
          end
          datapoint.elements.each(type + '/UnitsOfMeasure') do |uom|
            #puts uom.text
            output << $strings.fetch(uom.text)
          end
          output << "" #Blank field for Enumeration
        end
        if type =~ /enum/i
          value = Array.new
          datapoint.elements.each(type + '/EnumStateDefnID') do |enum|
            output << "" << "" << "" #Blank fields for min, max, and units of measure
            value.push($enums.fetch(enum.text.to_i))
          end
          output << value
        end
      end
      return output
    end
  else raise 'Input XML file not found!'
  end
end

def create_enum_hash(path_to_xml, xpath_to_def='/Enp2DataDict/EnumStateDefn')
  if File.exists?(path_to_xml)
    File.open(path_to_xml) do |config_file|
      # Open the document
      config = REXML::Document.new(config_file)
      # Initialize variables (scope is outside of do loops)
      h = Hash.new

      config.root.elements.each(xpath_to_def) do |enum|
        key = enum.attribute('Id').to_s.to_i
        value = Array.new
        enum.elements.each('EnumState') do |state|
          value.push(state.text)
        end
        h.store(key,value)
      end
      return h
    end
  else raise 'Input XML file not found!'
  end
end

def create_string_hash(path_to_xml, xpath_to_def='/Enp2DataDict/GlobalStringDefinitions/String')
  if File.exists?(path_to_xml)
    File.open(path_to_xml) do |config_file|
      # Open the document
      config = REXML::Document.new(config_file)
      # Initialize variables (scope is outside of do loops)
      h = Hash.new
      puts "Parsing #{path_to_xml} for data labels."
      config.root.elements.each(xpath_to_def) do |string|
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

begin

  #global_enums = Hash.new
  global_enums = create_enum_hash($path2gdd)

  #local_enums = Hash.new
  local_enums = create_enum_hash(path2fdm,'/DataModel/LocalEnumDefinitions/EnumStateDefn')

  $enums = global_enums.merge(local_enums)
  $enums.default('unknown')
  
#  $enums.each do |key,value|
#    puts "Looking up #{key}...#{$enums.fetch(key)}"
#  end

  #global_strings = Hash.new
  global_strings = create_string_hash($path2gdd)

  #local_strings = Hash.new
  local_strings = create_string_hash(path2fdm,'/DataModel/LocalStringDefinitions/String')

  $strings = global_strings.merge(local_strings)
  $strings.default('unknown')

#   $strings.each do |key,value|
#    puts "Looking up #{key}...#{$strings.fetch(key)}"
#  end

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
