# == Synopsis
#
# GenerateTestCase.rb generates CSV (from various inputs)
# for import into Testlog
#
# == Usage
#
# GenerateTestCase ????
#

$: << Dir.pwd

require 'TestCaseGenerator'

begin
  
generator = TestCaseGenerator.new
generator.path_to_fdm = 'C:\LMG_Test\ruby\Utilities\TestLogTestCases\iCOM_CR.xml'
generator.path_to_gdd = 'C:\LMG_Test\ruby\Utilities\TestLogTestCases\enp2dd.xml'
generator.protocol = 'MB'
generator.test_type = 'Monitor'
generator.test_case = 'C:\LMG_Test\ruby\Utilities\TestLogTestCases\MB - Monitor Template.tlg'
generator.input_type = 'xls'
generator.device_name = 'CRV'
generator.card_name = 'IS-IPBML'
generator.test_suite = 'Modbus'
generator.input_file = 'C:\LMG_Test\ruby\Utilities\TestLogTestCases\mb_iCOM_CR_fdm_462.xls'
generator.ip_address = ''

generator.generate
puts "#{generator.size} test cases created."

generator.output_header('output.csv')
generator.output_to_csv()

rescue => e
  puts "Error occured: #{e}"
  puts "#{$@}"
  if e.to_s =~/Permission/ then
    puts "Do you have a file open?"
  else if e.to_s =~ /is not a valid file name!/
    end
  end
end