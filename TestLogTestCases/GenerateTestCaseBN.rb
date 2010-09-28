# == Synopsis
#
# GenerateTestCase.rb generates CSV (from various inputs)
# for import into Testlog
#
# == Usage
#
# GenerateTestCase ????
#

#Add current working directory to Ruby's path
$: << Dir.pwd

require 'TestCaseGenerator'

begin
  
generator = TestCaseGenerator.new
generator.path_to_gdd = 'C:\LMG_Test\ruby\Utilities\TestLogTestCases\enp2dd.xml'
generator.protocol = 'BN'
generator.test_type = 'BACnet'
generator.test_case = 'C:\LMG_Test\ruby\Utilities\TestLogTestCases\BN - Monitor Template.tlg'
generator.input_type = 'xls'
generator.card_name = 'IS-IPBML'
#generator.out_file = 'C:\LMG_Test\ruby\Utilities\TestLogTestCases\output2.csv'

#generator.device_name = 'CRV'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\TestLogTestCases\iCOM_CR.xml'
#generator.test_suite = generator.card_name + '\\' + "CR" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\CR\BACnet\bn_iCOM_CR_fdm_462.xls'
#generator.generate
#
#generator.device_name = 'Challenger'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_PA.xml'
#generator.test_suite = generator.card_name + '\\' + "PA" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\PA\BACnet\bn_iCOM_PA_fdm_36.xls'
#generator.generate
#
#generator.device_name = 'Deluxe'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_PA.xml'
#generator.test_suite = generator.card_name + '\\' + "PA" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\PA\BACnet\bn_iCOM_PA_fdm_36.xls'
#generator.generate
#
#generator.device_name = 'DS'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_PA.xml'
#generator.test_suite = generator.card_name + '\\' + "PA" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\PA\BACnet\bn_iCOM_PA_fdm_36.xls'
#generator.generate
#
#generator.device_name = 'HPM'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_PA.xml'
#generator.test_suite = generator.card_name + '\\' + "PA" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\PA\BACnet\bn_iCOM_PA_fdm_36.xls'
#generator.generate
#
#generator.device_name = 'Jumbo CW'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_PA.xml'
#generator.test_suite = generator.card_name + '\\' + "PA" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\PA\BACnet\bn_iCOM_PA_fdm_36.xls'
#generator.generate
#
#generator.device_name = 'PeX'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_PA.xml'
#generator.test_suite = generator.card_name + '\\' + "PA" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\PA\BACnet\bn_iCOM_PA_fdm_36.xls'
#generator.generate

generator.device_name = 'HPC_Large'
generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_SC.xml'
generator.test_suite = generator.card_name + '\\' + "SC" + '\\' + generator.device_name + '\\' + '814. BACnet'
generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\SC\BACnet\bn_iCOM_sc_fdm_29.xls'
generator.generate

generator.device_name = 'HPC_Medium'
generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_SC.xml'
generator.test_suite = generator.card_name + '\\' + "SC" + '\\' + generator.device_name + '\\' + '814. BACnet'
generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\SC\BACnet\bn_iCOM_sc_fdm_29.xls'
generator.generate

#generator.device_name = 'XDC'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_XP.xml'
#generator.test_suite = generator.card_name + '\\' + "XP" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\XP\BACnet\bn_iCOM_XP_fdm_207.xls'
#generator.generate
#
#generator.device_name = 'XDP'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_XP.xml'
#generator.test_suite = generator.card_name + '\\' + "XP" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\XP\BACnet\bn_iCOM_XP_fdm_207.xls'
#generator.generate
#
#generator.device_name = 'XDPW'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iCOM_XP.xml'
#generator.test_suite = generator.card_name + '\\' + "XP" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\XP\BACnet\bn_iCOM_XP_fdm_207.xls'
#generator.generate
#
#generator.device_name = 'XDP'
#generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\fdm_data\iXPCray.xml'
#generator.test_suite = generator.card_name + '\\' + "XP_Cray" + '\\' + generator.device_name + '\\' + '814. BACnet'
#generator.input_file = 'C:\Documents and Settings\shanksstemp\Desktop\BACNet\Testlog\XP_Cray\BACnet\bn_iCOM_XPCray_fdm_247.xls'
#generator.generate

rescue => e
  puts "Error occured: #{e}"
  puts "#{$@}"
  if e.to_s =~/Permission/ then
    puts "Do you have a file open?"
  else if e.to_s =~ /is not a valid file name!/
    end
  end
ensure
  generator.output_to_csv()
  puts "\n#{generator.size} test cases created."
end