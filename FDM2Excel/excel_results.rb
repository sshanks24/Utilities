=begin rdoc
*Revisions*
  | Initial File                              | Scott Shanks        | 10/14/2010|

*Description*
# Used for storing results in a spreadsheet.

=end

require 'win32ole'
require 'enumerator' #Necessary to use each_slice Array method

module ExcelResults
  XLUP = -4162 #Excel constant for the UP arrow
  attr_accessor :base_ss
  
  #Every Test requires a spreadsheet that contains the data that drives the test.
  #path_to_base_ss is the file location of such a spreadsheet
  def build_result_from_base(path_to_base_ss)
    begin
      @base_ss = path_to_base_ss
      if !File.exists?(@base_ss) then raise "File #{@base_ss} does not exist"; end;

      @new_ss = (@base_ss.chomp(".xls")<<'_'<<Time.now.to_a.reverse[5..9].to_s<<(".xls"))
      @start_time = Time.now
      @end_time = ''
      ss = WIN32OLE::new('excel.Application')

      @wb = ss.Workbooks.Open(File.expand_path(@base_ss))
      @wb.SaveAs(@new_ss)
      @ws = @wb.Worksheets(1)
      @row_ptr = 2
    end
  end

  def build_result_from_scratch(path_to_new_ss)
    @start_time = Time.now
    @end_time = ''
    ss = WIN32OLE::new('excel.Application')
    ss.DisplayAlerts = false
    
    @wb = ss.Workbooks.Add

    @wb.SaveAs(path_to_new_ss)
    @ws = @wb.Worksheets(1)
    @row_ptr = 2
    ss.DisplayAlerts = true
  end

end

class Array
  #  - An attempt to generalize outputting an array of values to a result spread
  #  - sheet.
  #  - Variables
  #  - ws - the worksheet to write the array to
  #  - depth - for multi-dimensional arrays - think # of columns
  #  - row_start -
  #  - col_start -
  def to_spread_sheet(ws,depth=1,row_start=1,col_start=1)
    tmp = self.flatten
    tmp.each_slice(depth) do |row|
      col = col_start
      row.each do |item|
        ws.cells(row_start, col).value = item.to_s
        col +=1
      end
      row_start += 1
    end
  end
end