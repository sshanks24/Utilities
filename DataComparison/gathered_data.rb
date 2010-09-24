=begin rdoc
*Revisions*
  | Initial File | Scott Shanks | DATE |

=end

require 'rexml/document'
require 'win32ole'
require 'data_point'

class GatheredData

  DATA_WORKSHEET = 3

  attr_accessor :data_points
  
  def initialize(protocol,data_source)
    begin
      if File.exists?(data_source)
        @data_points = Array.new

        file_type = data_source.split('.')[data_source.split('.').size-1]
        case file_type
        when 'xls'
          ss = WIN32OLE::new('excel.Application')
          wb = ss.Workbooks.Open(data_source)
          ws = wb.Worksheets(DATA_WORKSHEET)
          ss.visible = false # true for Debug
          
          case protocol
          when /v4/i
            raise 'wrong protocol/data source combination'
          when /bacnet/i
            raise "#{protocol} not yet supported"
          when /http/i
            value_column = 2
            units_column = 3
            description_column = 1
            all_data = ws.UsedRange.Value

            for i in 1..all_data.size-1
              description = description(all_data[i][description_column].to_s.strip)
              value = all_data[i][value_column].to_s.strip
              units = all_data[i][units_column].to_s.strip
              mm_index = multi_module_index(description).to_s
              @data_points << DataPoint.new(protocol, description, value, units, mm_index)
            end

          when /modbus/i
            raise "#{protocol} not yet supported"
          when /snmp/i
            raise "#{protocol} not yet supported"
          end

        when 'xml'
          config_file = File.open(data_source)
          @xml = REXML::Document.new(config_file)
        else
          raise "Unknown file type passed as an argument"
          return nil
        end
      end
    rescue Exception => e
      puts" \n\n **********\n\n #{$@ } \n\n #{e} \n\n **********"
    end
  end

  :private

  def multi_module_index(description)
    if description =~ /\[\d+\]/
      return $&.gsub(/[\[\]]/,'') #Remove the brackets and return the number from last match
    else
      return ''
    end
  end

  def description(description)
    return description.split('[')[0].strip unless description.include?('(')
    return description.split('(')[0].strip
  end
end
