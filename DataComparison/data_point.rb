=begin rdoc
*Revisions*
  | Initial File | Scott Shanks | DATE |

=end

require 'rexml/document'
require 'win32ole'
require 'data_comparison'

class DataPoint < DataComparison

  def initialize(protocol, data_identifier, value, units, mm_index=0)
    @protocol = protocol
    @data_identifier = data_identifier
    @value = value
    @units = units
    @hierarchy = ''
    @mm_index = mm_index
    normalize
  end

  def to_s
    string = "%15s: %s\n" %['Protocol',@protocol]
    string << "%15s: %s\n"%['Data ID',@data_identifier]
    string << "%15s: %s\n"%['Value',@value]
    string << "%15s: %s\n"%['Units',@units]
    string << "%15s: %s\n"%['MM Index',@mm_index]
    string << "\n"
    #TODO Print Hierarchy (and other information) if it exists
  end

  def equals?(data_point)
  end

  def valid?(data_point)
  end

  :private

  # This method will convert all of the protocol specific data into a normal
  # form for comparison
  def normalize
    begin
      puts @data_identifier
      @data_identifier = @@gdd.data_text_to_data_id(@data_identifier) unless data_id?(@data_identifier)
      puts @data_identifier
    rescue Exception => e
      puts" \n\n **********\n\n #{$@ } \n\n #{e} \n\n **********"
    end
  end

  def data_id?(data_identifier)
    if data_identifier.to_i.to_s =~ /^([1-9]\d{0,3})$/ # Matches 1 - 9999
      return true
    end
    return false
  end
end
