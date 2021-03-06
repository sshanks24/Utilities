=begin rdoc
*Revisions*
  | Initial File                              | Scott Shanks        | 9/29/2010|

*Description*
# Used to bulk poll bacnet interface give a specially constructed spreadsheet.

=end

require 'test'
require 'bacnet'

class BacnetPoller < Test
  PRESENT_VALUE = 'e'
  VALUE_TO_WRITE = 'f'
  SUBSEQUENT_VALUE = 'g'
  def initialize(ip_address, path_to_base_ss,path_to_bacnet_console=BacnetObject::PATH_TO_BACNETCONSOLE)
      super(path_to_base_ss)
      @ip_address = ip_address
      @path_to_bacnet_console = path_to_bacnet_console
  end

  def run
    @start_time = Time.now
    @total_rows = @ws.Range("A65536").End(Test::XLUP).Row
    row = @row_ptr
    test_site = @ip_address
    puts "Polling started at: #{@start_time}"
    while (row <= @total_rows)
      bacnet_object = BacnetObject.new(@ws.Range("b#{row}")['Value'].to_s,test_site)
      value = bacnet_object.get
      @ws.Range("#{PRESENT_VALUE}#{row}")['Value'] = value
      puts value
      row += 1
    end
    @wb.save
    @fin = Time.now
    @elapsed = (@fin - @start_time)
    puts "Elapsed time is seconds is: #{@elapsed}"
    @wb.close
  end

  def run_write
    @start_time = Time.now
    @total_rows = @ws.Range("A65536").End(Test::XLUP).Row
    row = @row_ptr
    test_site = @ip_address
    puts "Polling started at: #{@start_time}"
    while (row <= @total_rows)
      bacnet_object = BacnetObject.new(@ws.Range("b#{row}")['Value'].to_s,test_site)

      value = bacnet_object.get
      @ws.Range("#{PRESENT_VALUE}#{row}")['Value'] = value

      write_value = @ws.Range("#{VALUE_TO_WRITE}#{row}")['Value'].to_s.to_i
      bacnet_object.set(write_value)

      sleep(2)
      
      subsequent_value = bacnet_object.get
      @ws.Range("#{SUBSEQUENT_VALUE}#{row}")['Value'] = subsequent_value
      puts "Read: #{value} Write: #{write_value} Result: #{subsequent_value}"
      
      row += 1
    end
    @wb.save
    @fin = Time.now
    @elapsed = (@fin - @start_time)
    puts "Elapsed time is seconds is: #{@elapsed}"
    @wb.close
  end

end