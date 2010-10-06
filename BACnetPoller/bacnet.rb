=begin rdoc
*Revisions*
  | Initial File                              | Scott Shanks        | 9/10/2010|

*Module_Name*
  Bacnet

*Description*
  Bacnet methods - This is a wrapper for the bacnetconsole application created
by Chad Mrazek

http://126.4.1.113/twiki/bin/view/LmgEmbedded/MAT_BACnet_Client_Command_Line.

BACnet UDP Command Line Read / Write Tool
OPTIONS:
 /IP=, IP Address
 /P=, Send To Port
 /B=, Object Type
      ANALOG-INPUT
      ANALOG-OUTPUT
      ANALOG-VALUE
      BINARY-INPUT
      BINARY-OUTPUT
      BINARY-VALUE
      MULTISTATE-INPUT
      MULTISTATE-OUTPUT
      MULTISTATE-VALUE
 /I=, Instance Number
 /R=, Property ID
 /V=, Write Value, if present a write will occur
 /T=, Timeout in milliseconds

*Variables*

=end

  
class BacnetObject
  PATH_TO_BACNETCONSOLE = 'C:\LMG_Test\ruby\Utilities\BACnetPoller\Console\bacnetConsole.exe'
  def initialize(object_id,test_site=@test_site,property_id='PRESENT_VALUE',port='47808',timeout='1000')
    #attr_accessor :instance_id, :object_type

    @test_site = test_site
    @property_id=property_id
    @port=port
    @timeout = timeout
    @instance_id = object_id.split('-')[1]

    case object_id.split('-')[0]
    when 'AV' then @object_type = 'ANALOG-VALUE'
    when 'BV' then @object_type = 'BINARY-VALUE'
    when 'MSV' then @object_type = 'MULTISTATE-VALUE'
    else @object_type = 'UNKONWN'
    end
  end

  def get()
    command = "#{PATH_TO_BACNETCONSOLE} /IP #{@test_site} /P #{@port} /B #{@object_type} /I #{@instance_id} /R #{@property_id}"
    puts "#{command}"
    result = `#{command}`
    return result.strip
  end

  def set(value)
    command = "#{PATH_TO_BACNETCONSOLE} /IP #{@test_site} /P #{@port} /B #{@object_type} /I #{@instance_id} /R #{@property_id} /V #{value.to_i}"
    puts "#{command}"
    result = `#{command}`
    return result.strip
  end

end