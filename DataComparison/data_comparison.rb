=begin rdoc
*Revisions*
  | Initial File | Scott Shanks | DATE |


=end

require 'rexml/document'
require 'win32ole'


class DataComparison
  # gathered_data is the output of snmp/http/bacnet/modbus gather scripts
  # v4_device_xml is the output of the deviceBrowsertool
  def initialize(protocol, gathered_data,v4_device_xml,fdm,gdd)
    if gdd == '' then
      @@gdd = nil
      File.open('c:/fdm/hashes',"rb") {|f| @@gdd = Marshal.load(f)}
    else
    @@gdd = Gdd.new(gdd)
    @@fdm = Fdm.new(fdm)
    @@gdd.merge_hashes_with_fdm(@@fdm)
    end

    @protocol_under_test = GatheredData.new(protocol, gathered_data)

    # @velocity = GatheredData.new('v4',v4_device_xml)
  end

  # will output the relevant gathered data for the appropriate protocols, units,
  # scaling, resolution and a comparison based on the appropriate thresholds
  def compare_and_ouput(output_worksheet,threshold_definition)
  end
end

