# == Synopsis
#
# enp2dd2csv: converts the enp2dd.xml to a csv file consisting of two columns.
#
# Column 1 is the programmatic name
#
# Column 2 is the OID name
# 
# == Usage
#
# enp2dd2csv path_to_enp2dd path_to_csv
#

require 'rexml/document'
require 'rdoc/usage'

include REXML

# Constants to define data headers of CSV - CH = Column Header
#TODO - Change the column header constants to an array to simplify output

CH1 = "Programmatic Name"
CH2 = "Velocity Register"

# Verify arguments
if ARGV.length != 2
  RDoc::usage(1)
end

# Handle arguments
path_to_enp2dd = ARGV.shift
path_to_csv = ARGV.shift


begin
  if File.exists?(path_to_enp2dd)
  # Create/Open the output file and write the column headers
  out_file = File.new(path_to_csv, 'w')
  out_file.puts CH1 << "," << CH2
  File.open(path_to_enp2dd) do |config_file|
    config = REXML::Document.new(config_file)
    #Create two arrays containing the programmatic name and the dataid
    all_names = config.elements.to_a("//DataDictEntry/ProgrammaticName")
    all_data_ids = config.elements.to_a("//DataDictEntry/DataId")
    for i in 0..all_names.size-1 do
      out_file.puts all_names[i].text + "," + all_data_ids[i].text
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

