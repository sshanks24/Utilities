=begin rdoc
*Revisions*
  | Initial File                              | Scott Shanks        | 9/29/2010|

*Description*
# Used for test driver spreadsheets.

=end

require 'win32ole'

# Generic Test Class
class Test
  XLUP = -4162 #Excel constant for the UP arrow
  #Every Test requires a spreadsheet that contains the data that drives the test.
  #path_to_base_ss is the file location of such a spreadsheet
  def initialize(path_to_base_ss)
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
end
