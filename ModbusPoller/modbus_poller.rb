# Required for OLE automation with Microsoft Excel
require 'win32ole'
require 'test'

# "Virtual" class that implements most of the nasty stuff
class ModbusPoller < Test
  #Excel constant for the UP arrow - from http://techsupt.winbatch.com/ts/T000001033005F9.html
  XLUP = -4162
  PATH_TO_MODPOLL = 'C:\LMG_Test\ruby\Utilities\ModbusPoller\Console\modpoll.exe'

  def initialize(path_to_base_ss,path_to_modpoll)
    super(path_to_base_ss)
    @path_to_modpoll = path_to_modpoll
  end
  def run
    @start_time = Time.now
    puts "Polling started at: #{@start_time}"
    
    @total_rows = @ws.Range("A65536").End(XLUP).Row
    @row = 2
    while (@row <= @total_rows)
      @inner_row = @row
      register_value = query_modbus(@ws.Range("b#{@row}")['Value'])
      if @bit_position != nil then
        if register_value.to_i == 0 then
          @ws.Range("g#{@inner_row}")['Value'] = 0
        else
        s = "%.16b" % register_value.to_i.abs.to_s(2)
        @ws.Range("g#{@inner_row}")['Value'] = s[s.size-1-@bit_position.to_i].chr
        end
        @inner_row += 1
      else
      register_value.split.each do |s|
        @ws.Range("g#{@inner_row}")['Value'] = s
        @inner_row += 1
      end
      end
      @row += 1
      @wb.Save
    end
    @wb.Save
    @wb.Close
    @fin = Time.now
    @elapsed = (@fin - @start_time)
    puts "Elapsed time is seconds is: #{@elapsed}"
  end
  def query_modbus(register)
    count = 1
    bit_count = 0
    starting_register_and_type = register_type(register)
    starting_register = starting_register_and_type[0]

    #Determine the appropriate count of registers to query.
    while (@row <= @total_rows)

      current_register_and_type = register_type(@ws.Range("b#{@row}")['Value'])
      current_register = current_register_and_type[0]
      type = current_register_and_type[1]
      current_register_size = current_register_and_type[2]
      @bit_position = current_register_and_type[3]

      if @row < @total_rows
        next_register_and_type = register_type(@ws.Range("b#{@row+1}")['Value'])
        next_register = next_register_and_type[0]
        next_register_size = next_register_and_type[2]
        next_bit_position = next_register_and_type[3]
      end

      if @bit_position == nil and next_bit_position == nil then
        if(current_register_size == next_register_size and
              next_register.to_i == current_register.to_i + current_register_size.to_i and
              count < 99) then
          count += 1
          @row += 1
        else break
        end
      else break
      end
    end

    #Build and pass the commands to the OS
    if (@row <= @total_rows) then
    command = @base_cmd + count.to_s + ' -a ' + @slave_addr.to_s + type + ' -r ' + starting_register + ' ' + @target
    puts"command = #{command}"
    modbus_values =''
    modbus_data = `#{command}`.each do |s|
      if s =~ /^\[/ #If stdout line starts with a '['
        array = s.split(/ /)
        modbus_values << array[1]
      end
    end
    return modbus_values
    end
  end
  def register_type(register)
    #Determine the type of register.

    type = case register
    when /^3.*1\)$/ then ' -t 3' #16 bit input register
    when /^3.*2\)$/ then ' -t 3:int -i' #32 bit input register - Date/Time fields need the -i switch (Big Endian)
    when /^3.*20\)$/ then ' -t 3' #16 bit input register
    when /^4.*1\)$/ then ' -t 4' #16 bit holding register
    when /^4.*2\)$/ then ' -t 4:int -i' #32 bit holding register - Date/Time fields need the -i switch (Big Endian)
    when /^4.*1\).*Bit.*/ then type = ' -t 4'
    when /^1/ then ' -t 1' #Discrete input register
    end

    type = ' -t 0' if register.length() < 8
    #Cleanup the register value

    register_size = register.slice(/\(.*\)/) #Match the parenthetical portion of the string (size)
    bit_position = register.slice(/ - Bit.*$/)  #Match the Bit specification
    register_value = register.gsub(/\(.*\)/,'') #Remove the parenthetical portion of the string
    register_value = register_value.gsub(/^./,'') unless type == ' -t 0' #Remove the first character
    register_value = register_value.gsub(/^0+/,'') #Remove any leading zeros
    register_value = register_value.gsub(/ - Bit.*/,'') #Remove the - Bit specification

    #Build an array of register number type and size

    return_value = Array.new
    bit_position = bit_position.gsub(' - Bit ','') unless bit_position == nil
    return_value[0,3] = [register_value, type, register_size.tr('()',''),bit_position]
 end

end

# Class to poll modbus TCP interfaces
class ModbusPollerTCP < ModbusPoller
  # slave_addr:: the address of the modpoll server.
  # ip:: the ip address of the modpoll server.
  # path_to_base_ss:: the spreadsheet that contains the modbus datapoints to poll.
  # path_to_modpoll:: the path to the modpoll executable.
  # encapsulation:: whether or not to use encapsulated RTU over TCP
  def initialize(slave_addr, ip,path_to_base_ss,path_to_modpoll,encapsulation)

    super(path_to_base_ss,path_to_modpoll)
    case encapsulation
    when 'enc' then @base_cmd = @path_to_modpoll + ' -o 5.0 -p 8002 -1 -m enc -c '
    else @base_cmd = @path_to_modpoll + ' -o 5.0 -1 -m tcp -c ' #TODO This should get more specific or use an optional argument
    end

    @slave_addr = slave_addr
    @target = ip
  end
  # Call run to begin the test
  def run
    super
  end
end

# Class to poll modbus 485 interfaces
class ModbusPoller485 < ModbusPoller
  # slave_addr:: the address of the modpoll server.
  # com_port:: the serial interface attached to the modpoll server (e.g. com1, com2, com3...).
  # path_to_base_ss:: the spreadsheet that contains the modbus datapoints to poll.
  # path_to_modpoll:: the path to the modpoll executable.
  def initialize(slave_addr, com_port,path_to_base_ss,path_to_modpoll)
    super(path_to_base_ss,path_to_modpoll)
    @base_cmd = 'modpoll -o 5.0 -1 -p none -c '
    @slave_addr = slave_addr
    @target = com_port
  end
  # Call run to begin the test
  def run
    super
  end
end