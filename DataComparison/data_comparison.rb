=begin rdoc
*Revisions*
  | Initial File | Scott Shanks | DATE |


=end

require 'rexml/document'
require 'win32ole'


class DataComparison

  V4_HEADINGS = ["Data Label","Data Identifier", "Multi Module Index","Units"]
  PROTOCOL_HEADINGS = ["Protocol", "Data Identifier", "Data Label", "Value",
    "Value(from protocol)", "Units", "Units (from_protocol)", "Scale",
    "Resolution", "Type", "Hierarchy", "Multi-Module Index"]
  
  # gathered_data is the output of snmp/http/bacnet/modbus gather scripts
  # v4_device_xml is the output of the deviceBrowsertool
  def initialize(protocol, gathered_data,v4_device_xml,fdm,gdd)
    @@gdd = Gdd.new(gdd)
    @@fdm = Fdm.new(fdm)

    @protocol_under_test = GatheredData.new(protocol, gathered_data)

    @velocity = GatheredData.new('v4',v4_device_xml)
  end

  # will output the relevant gathered data for the appropriate protocols, units,
  # scaling, resolution and a comparison based on the appropriate thresholds
  def compare_and_output(output_worksheet,threshold_definition=nil)
    begin
      ss = WIN32OLE::new('excel.Application')
      wb = ss.Workbooks.Add()
      ss.visible = false # true for Debug
      @ws = wb.Worksheets(1)
      @ws.name = 'Analysis'

      wb.Worksheets.Add.name = @velocity.protocol
      @ws = wb.Worksheets(@velocity.protocol)
      write_headings(PROTOCOL_HEADINGS)
      write_data(@velocity)

      wb.Worksheets.Add.name = @protocol_under_test.protocol
      @ws = wb.Worksheets(@protocol_under_test.protocol)
      write_headings(PROTOCOL_HEADINGS)
      write_data(@protocol_under_test)

      @ws = wb.Worksheets('Analysis')
      write_headings(["Data Label", "Data Identifier", "Disposition", "Reason"])
      write_data_analysis

    rescue
      puts" \n\n **********\n\n #{$@ } \n\n #{$!} \n\n **********"
    ensure
      #Do Data Comparison and write results to spreadsheet
      ss.DisplayAlerts = false
      wb.saveas(output_worksheet)
      ss.DisplayAlerts = true
    end
  end

  :private

  def write_headings(header_array,work_sheet=@ws,start_column='a')
    for i in 1..header_array.size
      work_sheet.Range(start_column+'1')['Value'] = header_array[i-1]
      start_column.next!
    end
  end

  def write_data(protocol,work_sheet=@ws)
    #Write protocol data out to spreadsheet
    row = 2
    protocol.data_points.each do |data_point|
      work_sheet.Range("A#{row}")['Value'] = protocol.protocol
      work_sheet.Range("B#{row}")['Value'] = data_point.data_identifier
      work_sheet.Range("C#{row}")['Value'] = data_point.data_label
      work_sheet.Range("D#{row}")['Value'] = data_point.value
      work_sheet.Range("E#{row}")['Value'] = data_point.value_from_protocol
      work_sheet.Range("F#{row}")['Value'] = data_point.units
      work_sheet.Range("G#{row}")['Value'] = data_point.units_from_protocol
      work_sheet.Range("H#{row}")['Value'] = data_point.scale
      work_sheet.Range("I#{row}")['Value'] = data_point.resolution
      work_sheet.Range("J#{row}")['Value'] = data_point.type
      work_sheet.Range("K#{row}")['Value'] = data_point.hierarchy
      work_sheet.Range("L#{row}")['Value'] = data_point.multi_module_index
      row += 1
    end
  end

  def write_data_analysis(work_sheet=@ws)
    row = 2
    @protocol_under_test.data_points.each do |data_point|
      work_sheet.Range("A#{row}")['Value'] = data_point.data_label
      work_sheet.Range("B#{row}")['Value'] = data_point.data_identifier
      work_sheet.Range("C#{row}")['Value'] = 'Disposition will go here'
      work_sheet.Range("D#{row}")['Value'] = 'Reason will go here'
      row += 1
    end
  end

end

