require 'data_comparison'
require 'data_point'
require 'gathered_data'
require 'gdd'
require 'fdm'
require 'threshold_data'

comparison = DataComparison.new('http',
                                'C:\LMG_Test\ruby\Utilities\DataComparison\mon_gather_data_points_webx_91691038.xls',
                                'C:\LMG_Test\ruby\Utilities\DataComparison\savedDevice.xml',
                                'C:\LMG_Test\ruby\Utilities\fdm_data\BDSU.xml',
                                'C:\LMG_Test\ruby\Utilities\fdm_data\enp2dd.xml')

#comparison.compare_and_output('I:\LMG TEST ENGINEERING\Projects\157291 Alber BDSU\Data Mapping\Bravo\1x1x40\09222010\comparison.xlsx')


#http_data = GatheredData.new('http','I:\LMG TEST ENGINEERING\Projects\157291 Alber BDSU\Data Mapping\Bravo\1x1x40\09222010\mon_gather_data_points_webx_922161951.xls')
#
#http_data.data_points.each do |data_point|
#  puts data_point
#end

#gdd = Gdd.new('C:\fdm\enp2dd.xml')

#Load 'marshaled' gdd for faster processing
#gdd = nil
#File.open("C:/fdm/hashes","rb") {|f| gdd = Marshal.load(f)}
#s = '°C'
#puts "Found it" if s =~ /°/
#puts gdd.unit_text_to_unit_id('°C')
#puts gdd.unit_text_to_unit_id('')
#puts gdd.data_id_to_data_text('4877')
#puts gdd.data_id_to_data_text('5002')
#puts gdd.unit_text_to_unit_id('microOhm')
#puts gdd.unit_id_to_unit_text('4132')

#fdm = Fdm.new('C:\LMG_Test\ruby\Utilities\fdm_data\BDSU.xml')
#
#puts fdm.text_to_id("System Date and TimeOops")
#puts fdm.text_to_id("Battery ID")
#puts fdm.text_to_id("Customer's Name")
#puts fdm.text_to_id("Strng Operating Mode")
#puts fdm.unit_text_to_unit_id("")
#puts fdm.unit_text_to_unit_id('°C')
#puts fdm.unit_text_to_unit_id('sec')
#puts fdm.unit_text_to_unit_id('A AC')
#fdm.build_hashes
#
#puts fdm.scales.inspect
#puts fdm.resolutions.inspect

#puts fdm.resolution?('5328')
#puts fdm.scale?('5328')
#
#puts fdm.unit_text_to_unit_id('microOhm')
#puts fdm.data_id_to_data_text('4113')
#puts fdm.data_id_to_data_text('5002')
#puts fdm.unit_text_to_unit_id('microOhm')
#puts fdm.unit_text_to_unit_id('°C') #Need to handle case with °
#puts fdm.unit_id_to_unit_text('4132')