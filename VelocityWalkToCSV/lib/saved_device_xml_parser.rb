#Class to parse the savedDevice.xml class that is produced by the device browser.

require 'rexml/document'

class SavedDeviceXMLParser

  # Constants to define data headers of CSV - CH = Column Header
  CH =["Velocity Label","Velocity Register","MultiModule Index","Velocity Value"]
  
  def initialize(path_to_xml, switch_output)
    if File.exists?(path_to_xml)
      @xml = REXML::Document.new(File.open(path_to_xml))
      @output = Array.new()
      @switch_output = switch_output
    else raise 'Input XML file not found!'
    end

  end

  def parse

    multi_module_exists = FALSE

    @xml.root.elements.each("Report") do |element|
      if element.next_element.attribute('reportID') == element.attribute('reportID')
        multi_module_exists = TRUE
      else multi_module_exists = FALSE
      end unless element.next_element == nil
      element.each_element_with_attribute('id') do |child|
        value = child.text
        value = '' if child.text == nil
        multi_module_index = element.attribute('mmidx').to_s.to_i + 1
        if @switch_output =~ /modbus/i
          if element.attribute('mmidx').to_s == '0' and multi_module_exists == FALSE
            @output << child.attribute('name').to_s << child.attribute('id').to_s << '1' << value
          else @output << child.attribute('name').to_s + " (#{element.attribute('name')} [#{multi_module_index.to_s}])" << child.attribute('id').to_s << multi_module_index.to_s << value
          end
        end
        if @switch_output =~ /bacnet/i
          if element.attribute('mmidx').to_s == '0' and multi_module_exists == FALSE
             @output << child.attribute('name').to_s + " (#{element.attribute('name').to_s})" << child.attribute('id').to_s << '1' << value
          else @output << child.attribute('name').to_s + " (#{element.attribute('name').to_s}->#{element.attribute('name').to_s} [#{multi_module_index.to_s}])" << child.attribute('id').to_s << multi_module_index.to_s << value
          end
        end
        if @switch_output =~ /hierarchy/i
          if element.attribute('mmidx').to_s == '0' and multi_module_exists == FALSE
            @output << child.attribute('name').to_s + " (#{element.attribute('name').to_s})" << child.attribute('id').to_s << '1' << value
          else @output << child.attribute('name').to_s + " (#{element.attribute('name').to_s}->#{element.attribute('name').to_s} [#{multi_module_index.to_s}])" << child.attribute('id').to_s << multi_module_index.to_s << value
          end
      end
    end

  end

  def output_to_csv(path_to_csv)
    parse
    # Create/Open the output file and write the column headers
    @out_file = File.new(path_to_csv, 'w')

    for i in 0..CH.size-1 do
      if i < CH.size-1 then @out_file.print CH[i] + ","
      else @out_file.puts CH[i]
      end
    end

    for i in 1..@output.size do
      if i == 1 then @out_file.print @output[i-1].to_s + ","; next; end;
      if i % CH.size != 0 then @out_file.print @output[i-1].to_s + ","
      else @out_file.puts @output[i-1].to_s
      end
    end
  end
  
end
