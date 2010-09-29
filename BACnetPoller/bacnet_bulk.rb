require 'bacnet_poller'

test = BacnetPoller.new('126.4.202.195', 'C:\LMG_Test\ruby\Utilities\BACnetPoller\BACnet_SC_fdm_29.xls')
test.run
