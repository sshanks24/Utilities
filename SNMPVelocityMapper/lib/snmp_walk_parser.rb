# == Synopsis
#
#
#
#
#
#
#
#
#
# == Usage
#
#


ip_address = '126.4.202.91'
community = 'LiebertEM'
version = '2c'
oid = 'LIEBERT-GP-FLEXIBLE-MIB::lgpFlexibleEntryDataLabel.1.2.100'

command = "snmpwalk -v#{version} -c #{community} #{ip_address} #{oid}"
output = `#{command}`
output.split(/\n/).each do |string|
  string.split(/=/).each do |sub|
    if sub =~ /^L/
      puts sub
    end
    
  end
end
