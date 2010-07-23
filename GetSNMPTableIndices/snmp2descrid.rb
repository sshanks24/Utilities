# == Synopsis
#
# snmp2descrid: performs a walk of the specified device (with community string) and outputs a csv file containing the following:
#
# Column 1 is an OID.
#
# Column 2 is the index corresponding to the OID in column 1.
#
# == Usage
#
# snmp2descrid community_string ip_address path_to_csv
#

require 'rdoc/usage'

# Constants to define data headers of CSV - CH = Column Headers

CH = ["OID","Index"]

# Verify arguments
if ARGV.length != 3
  RDoc::usage
end

# Handle arguments
community_string = ARGV.shift
ip_address = ARGV.shift
path_to_csv = ARGV.shift

def snmp_get_descriptions(ip=@test_site,com_str=@community_string,version='2c',oid='.1')
  command = "snmpwalk -v #{version} -c #{com_str} #{ip} #{oid}"
  snmp_data = `#{command}`.to_s

  a = Array.new
  snmp_data.each_line do |line|
    if line =~ /Descr[^i]/
      line.split('.')[1].each do |value_and_oid|
        a << value_and_oid.split('=')[0].strip
        value_and_oid.split('::')[1].each do |oid|
          a << oid
        end
      end

    end
  end
  return a.compact
end

begin

  output = snmp_get_descriptions(ip_address,community_string,'2c','private')

  # Create/Open the output file and write the column headers
  out_file = File.new(path_to_csv, 'w')
  for i in 0..CH.size-1 do
    if i < CH.size-1 then out_file.print CH[i] + ","
    else out_file.puts CH[i]
    end
  end

  for i in 0..output.size-1 do
    if i % 2 == 0 then out_file.print output[i] + ","
    else out_file.puts output[i]
    end
  end

rescue => e
  puts "Error occured: #{e}"
  if e.to_s =~/Permission/ then
    puts "Do you have a file open?"
  else puts "???"
  end
end