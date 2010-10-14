# == Synopsis
#
# fdm_to_excel: outputs an excel spreadsheet version of an fdm with the following
# columns:
#
# Data ID,Programmatic Name,Data Type,Data Label,
# Access,Minimum Value,Maximum Value,Resolution,Scale
#
# == Usage
#
# fdm_to_excel: path_to_fdm path_to_xlsx
#

require 'rdoc/usage'
require 'fdm'
require 'excel_results'

# Verify arguments
if ARGV.length != 2
  RDoc::usage
end

# Handle arguments
fdm_file_path = ARGV.shift
output = ARGV.shift

class FdmToExcel < Fdm
  include ExcelResults

  COLUMN_HEADINGS = ["Data ID","Programmatic Name","Data Type","Data Label",
    "Access","Minimum Value","Maximum Value","Resolution","Scale"]
  
  def initialize(fdm_file_path,ss_file_path)
    super(fdm_file_path)
    build_result_from_scratch(ss_file_path)

    output = Array.new
    data_ids_to_a.each do |data_id|
      output << data_id << programmatic_name(data_id) << type(data_id)
      output << id_to_text(data_id) << access(data_id)
      output << min_value(data_id) << max_value(data_id)
      output << resolution(data_id) << scale(data_id)
    end

    COLUMN_HEADINGS.to_spread_sheet(@ws,9,1,1)
    output.to_spread_sheet(@ws,9,2,1)
    @wb.save
    @wb.close
  end

end


FdmToExcel.new(fdm_file_path,output)
