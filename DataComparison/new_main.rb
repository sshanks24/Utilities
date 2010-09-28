
require 'data_comparison'
require 'data_point'
require 'gathered_data'
require 'gdd'
require 'threshold_data'

comparison = DataComparison.new('http',
                                'I:\LMG TEST ENGINEERING\Projects\157291 Alber BDSU\Data Mapping\Bravo\1x1x40\09222010\mon_gather_data_points_webx_922161951.xls',
                                'I:\LMG TEST ENGINEERING\Projects\157291 Alber BDSU\Data Mapping\Bravo\1x1x240\09162010\savedDevice.xml',
                                'C:\fdm\BDSU.xml',
                                '')



#http_data = GatheredData.new('http','I:\LMG TEST ENGINEERING\Projects\157291 Alber BDSU\Data Mapping\Bravo\1x1x40\09222010\mon_gather_data_points_webx_922161951.xls')
#
#http_data.data_points.each do |data_point|
#  puts data_point
#end

#gdd = Gdd.new('C:\fdm\enp2dd.xml')

#Load 'marshaled' gdd for faster processing
#gdd = nil
#File.open("C:/fdm/hashes","rb") {|f| gdd = Marshal.load(f)}

#puts gdd.unit_text_to_unit_id('deg C')
#puts gdd.data_id_to_data_text('4113')
#puts gdd.data_id_to_data_text('5002')
#puts gdd.unit_text_to_unit_id('microOhm')
#puts gdd.unit_text_to_unit_id('°C') #Need to handle case with °
#puts gdd.unit_id_to_unit_text('4132')