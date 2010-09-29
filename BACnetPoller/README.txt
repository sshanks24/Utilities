== Installing/Using bacnet_bulk

Copy the entire parent folder BACnetPoller to following directory on
your local drive:

C:\LMG_Test\ruby\Utilities\

call bacnet_bulk.exe from the console window

== Usage

bacnet_bulk ip_address path_to_spreadsheet

== Input Spreadsheet Description

The input spreadsheet takes a form similar to that displayed by clicking on the
bacnet elements link from the device data/logs tab:

 http://device.ip.address/support/supportShowBacnet.htm
 
The current iteration of this tool expects to see the following 5 column headers:

Index, Object Id, Object Name, Description, PRESENT_VALUE

= Index - just an index (counter)
= Object Id - contains the bacnet Object type and Instance number separated by a '-'
= Object Name - This field is the velocity data id, hierarchy number, and multi-module
	index separted by a '_'.
= Description  - description of the data point.
= PRESENT_VALUE - the present value returned by the device.