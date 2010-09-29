== Installing/Using modbus_bulk

Copy the entire parent folder ModbusPoller to following directory on
your local drive:

C:\LMG_Test\ruby\Utilities\

call modbus_bulk.exe from the console window

== Usage

modbus_bulk ip_address|comport path_to_spreadsheet

== Input Spreadsheet Description

The input spreadsheet takes a form similar to that displayed by clicking on the
bacnet elements link from the device data/logs tab:

 http://device.ip.address/support/supportShowModbus.htm

The current iteration of this tool expects to see the following 5 column headers:

Index, Register(Num), Data Label, Unit, Scale, Access, Value

= Index - just an index (counter)
= Register(Num) - contains the modbus register and size (size is in parenthesis)
= Data Label - description of the data point.
= Unit - units of the returned value
= Scale - scaling factor to be applied to the units
= Access - RO,RW,WO 
= Value - the present value returned by the device.
