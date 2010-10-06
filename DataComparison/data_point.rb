=begin rdoc
*Revisions*
  | Initial File | Scott Shanks | DATE |

=end

require 'rexml/document'
require 'win32ole'
require 'data_comparison'

class DataPoint < DataComparison

  attr_reader :protocol, :data_identifier, :data_label_from_protocol, :data_label,
    :value_from_protocol, :value, :units_from_protocol, :units, :scale,
    :resolution, :type, :hierarchy, :multi_module_index

  def initialize(protocol, data_identifier, data_label, value, units, mm_index=0)
    @protocol = protocol
    @data_identifier = data_identifier
    @data_label_from_protocol = data_label
    @data_label = ''
    @value_from_protocol = value
    @value = ''
    @units_from_protocol = units
    @units = ''
    @scale = ''
    @resolution = ''
    @type = 'Type will go here'
    @hierarchy = ''
    @multi_module_index = mm_index
    normalize
  end

  def to_s
    string = "%15s: %s\n" %['Protocol',@protocol]
    string << "%15s: %s\n"%["Label(#{@protocol})",@data_label_from_protocol]
    string << "%15s: %s\n"%["Label",@data_label]
    string << "%15s: %s\n"%['Data ID',@data_identifier]
    string << "%15s: %s\n"%["Value(#{@protocol})",@value_from_protocol]
    string << "%15s: %s\n"%["Value",@value]
    string << "%15s: %s\n"%["Units(#{@protocol})",@units_from_protocol]
    string << "%15s: %s\n"%['Units',@units]
    string << "%15s: %s\n"%['Scale',@scale]
    string << "%15s: %s\n"%['Resolution',@resolution]
    string << "%15s: %s\n"%['MM Index',@multi_module_index]
    string << "\n"
    #TODO Print Hierarchy (and other information) if it exists
  end

  def equals?(data_point)
    if self.value == data_point.value and self.units == data_point.units
      return true
    else return false
    end
  end

  def reason_for_inequality?(data_point)
    reason = Array.new
    if self.value != data_point.value
      reason << "Values don't match"
    end
    if self.units != data_point.units
      reason << "Units don't match"
    end
    return reason
  end

  def valid?(data_point)
  end

  :private

  # This method will convert all of the protocol specific data into a normal
  # form for comparison
  def normalize
    begin
      if data_id?(@data_identifer) == false
        gdd_data_id = @@gdd.data_text_to_data_id(@data_identifier)
        if gdd_data_id == nil
        @data_identifier = gdd_data_id
        else @data_identifier = @@fdm.data_text_to_data_id(@data_identifier)
        end
      else #data_identifier is already a data id do nothing...
      end
      @data_label = 'v4 data label will be here'
      @scale = @@gdd.scale(@data_identifier)
      @resolution = @@gdd.resolution(@data_identifier)
      if (has_resolution? and has_scale?)
        @value = @value_from_protocol.to_i * @scale.to_i / 10**@resolution.to_i
      else
        @value = @value_from_protocol
      end
      if @protocol == 'v4'
        @units = 'units would go here'
      else
      @units = @@gdd.unit_text_to_unit_id(@units_from_protocol)
      end

      if self.has_unit_conversion_problem?
        puts self.to_s
      end
      puts self.to_s
      gets
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

  def has_unit_conversion_problem?
    if @units_from_protocol != '' and @units == ''
      puts "Unit conversion problem encountered"
      return true
    else return false
    end
  end
  
  def has_resolution?
    if @resolution != ''
      return true
    else return false
    end
  end

  def has_scale?
    if @scale != ''
      return true
    else return false
    end
  end

end
