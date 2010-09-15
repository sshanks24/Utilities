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

=begin
# Verify arguments
if ARGV.length != 6
  RDoc::usage
end

# Handle arguments
#TODO Check if these files exist in the beginning

begin

ARGV.each do |file_name|
  unless File.exist?(file_name)
    raise "#{file_name} is not a valid file name!"
  end
end

=end

begin
  
generator = TestCaseGenerator.new
generator.generate
generator.output_to_csv('output.csv')

rescue => e
  puts "Error occured: #{e}"
  puts "#{$@}"
  if e.to_s =~/Permission/ then
    puts "Do you have a file open?"
  else if e.to_s =~ /is not a valid file name!/
    end
  end
end