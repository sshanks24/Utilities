# == Synopsis
#
# TestCaseGenerator.rb - class used for test log test case generation.
#


require 'rexml/document'
require 'win32ole'

include REXML

class Array

# This method 'pads' the output array with "".  In effect, it creates empty
# elements in an array.  In the context of TestCaseGenerator, it creates blank
# elements in the output csv file.
def pad(i)
  i.times {self << ""}
  return self.flatten!
end

end

class TestCaseGenerator

# Constant to define data headers of CSV - CH = Column Headers
CH = ["Type","Test Suite","ID","Title","Hours Expected","Type","Phase",
  "Configurations","Resources","Status","Attempts","Last Attempt Date",
  "Last Attempt Time","Actual Hours","Testers","Faults","CR ID","Results",
  "Version","Build","Link2","Result Notes","Requirements","Created Date",
  "Created Time","Updated Date","Updated Time","Author","Update By",
  "Prerequisites","Description","Results","Notes Field 1","Revision History",
  "Link","Priority"]
# Prompt used for user input
PROMPT = '>'
# Various data arrays that are used to cue input from the user.
PROTOCOLS = ["BN", "MB", "SP", "WB"]
TEST_TYPES = ["Control", "Events", "Monitor"]
INPUT_TYPES = ["web", "xls", "xml"]
DEVICES = ['APM','BDSU','Challenger','CRV','Deluxe','DS','HPC','HPM','Jumbo','Pex','PSI-700','XDC','XDP','XDPW','XP_Cray']
CARDS = ['IS-WEBCARD','IS-WEBX','IS-WEBL','IS-WEBS','IS-485X','IS-485L','IS-485S','IS-IPBMX','IS-IPBML','IS-IPBMS']

# Accessor methods are used for building a generator from within a script rather
# than at run-time with user input.
attr_accessor :path_to_fdm, :path_to_gdd , :protocol,:test_type,:test_case,
  :input_type,:device_name,:card_name,:test_suite,:input_file,:ip_address,
  :out_file,:strings,:data_ids,:dataID2string,:output

def initialize
  @path_to_fdm = ''
  @path_to_gdd = ''
  @protocol = ''
  @test_type = ''
  @test_case = ''
  @input_type = ''
  @device_name = ''
  @card_name = ''
  @test_suite = ''
  @input_file = ''
  @ip_address = ''
  @out_file = ''
  @output = Array.new
end

# This method is used to get all relevant input from the user.
def configure_from_user()
  @path_to_fdm = get_path("FDM")
  @path_to_gdd = get_path("GDD")
  @protocol = get_protocol
  @test_type = get_test_type
  @test_case = get_path("Test Case")
  @input_type = get_input_type
  @device_name = get_device_name
  @card_name = get_card_name

 case @input_type
  when 'xls' then 
    @input_file = get_input_file
    @test_suite = get_test_suite
  when 'xml' then @input_file = get_input_file
  when 'web' then @ip_address = ''
  else puts "#{input_type} not supported"; raise "Invalid input";
  end  
  puts "\nConfiguration Succesful!"
  
  build_hashes
#  global_strings = build_string_id_hash(@path_to_gdd,'/Enp2DataDict/GlobalStringDefinitions/String')
#  local_strings = build_string_id_hash(@path_to_fdm,'/*/LocalStringDefinitions/String')
#
#  @strings = global_strings.merge(local_strings)
#  @strings.default('UNKNOWN STRING ID')
#
#  @data_ids = build_data_id_hash(@path_to_gdd,'//DataDictEntry')
#  @data_ids.default('UNKNOWN STRING ID')
end

# Returns the size of the @output array divided by the number of columns.
# Used to count the number of test cases generated.
def size
  return @output.size / CH.size
end

# This method is used to obtain the path of the GDD, FDM, and Test Case from the
# user
def get_path(object)
  print "\nPlease enter the path to the #{object}\n(Default is #{Dir.pwd}/#{object}.xml)\n\n#{PROMPT}"
  path = gets
  if path == "" then path = Dir.pwd + object + ".xml"; end;
  if File.exists?(path.chomp!)
    return path
  else
    puts "#{path} is not a valid path to a file...\n\n"
    get_path(object)
  end
end

# This method is used to obtain the protocol from the user.
def get_protocol()
  print "\nPlease enter the protocol to generate\n#{PROTOCOLS.inspect}\n\n#{PROMPT}"
  protocol = gets
  protocol.chomp!
  PROTOCOLS.each do |input|
    if protocol =~ /#{input}/i and protocol.size == 2
      return protocol.upcase
    end
  end
  get_protocol
end

# This method is used to obtain the test type from the user.
def get_test_type()
  print "\nPlease enter the test type to generate\n#{TEST_TYPES.inspect}\n\n#{PROMPT}"
  test_type = gets
  test_type.chomp!
  TEST_TYPES.each do |input|
    if test_type.casecmp(input) == 0
      return test_type.capitalize 
    end
  end
  get_test_type
end

# This method is used to obtain the input type from the user.
def get_input_type()
  print "\nPlease enter the type of input provided to generate test cases\n#{INPUT_TYPES.inspect}\n\n#{PROMPT}"
  input_type = gets
  input_type.chomp!
  INPUT_TYPES.each do |input|
    if input_type.casecmp(input) == 0
      return input_type.downcase
    end
  end
  get_input_type
end

# This method is used to obtain the input file from the user.
def get_input_file
  print "\nPlease enter the path to the #{@input_type} input file\n\n#{PROMPT}"
  path = gets
  if path == "" then path = Dir.pwd + "//input//" + ".#{@input_type}"; end;
  if File.exists?(path.chomp!)
    return path
  else
    puts "#{path} is not a valid path to a file...\n\n"
    get_input_file
  end
end

# This method is used to obtain the test suite from the user.
def get_test_suite
  print "\nPlease enter a test suite for these test cases\n\n#{PROMPT}"
  test_suite = gets.chomp
  if test_suite == "" then get_report; end;
  return test_suite
end

# This method is used to obtain the device name from the user.
def get_device_name
  print "\nPlease enter the device name for these test cases\n#{DEVICES.inspect}\n\n#{PROMPT}"
  device_name = gets.chomp
  if device_name == "" then get_device_name; end;
  return device_name
end

# This method is used to obtain the card name from the user.
def get_card_name
  print "\nPlease enter the card name for these test cases\n#{CARDS.inspect}\n\n#{PROMPT}"
  card_name = gets.chomp
  if card_name == "" then get_card_name; end;
  return card_name
end

# This method is used to obtain the output file path from the user.
def get_out_file
  begin
    print "\nPlease enter the path for the output file\n(Default is #{Dir.pwd}/output.csv\n\n#{PROMPT}"
    path = gets
    if path == "" then path = Dir.pwd + '/' + 'output.csv'; end;
    @out_file = File.new(path.chomp, 'w')
  rescue
    puts "#{path} is not a valid path to a file...\n\n"
    get_out_file
  end
end
# This method parses a file (pre-generated by the user) and returns an
# array of test case titles.  The pre-generated file is an excel spreadsheet
# that is easily generated by copying and pasting the information on the data
# logs page and delimiting by commas.
# TODO - Still need to implement for the following cases:
# TODO - Input_type - xls, Protocol - SNMP (SP)
# TODO - Input_type - xml, Protocol - Web (WB)
# TODO - Input_type - xml, Protocol - SNMP (SP)
# TODO - Input_type - xml, Protocol - Modbus (MB)
# TODO - Input_type - xml, Protocol - BACnet (BN)
# TODO - Input_type - web, Protocol - Web (WB)
# TODO - Input_type - web, Protocol - SNMP (SP)
# TODO - Input_type - web, Protocol - Modbus (MB)
# TODO - Input_type - web, Protocol - BACnet (BN)

def parse_input_file
  begin
    case @input_type
    when 'xls' then
      case @protocol
      when 'BN' then
        titles = Array.new
        ss = WIN32OLE::new('excel.Application')
        wb = ss.Workbooks.Open(@input_file)
        ws = wb.Worksheets(1)
        data = ws.UsedRange.Value
        for i in 1..data.size-1
          data_id = data[i][2].split('_')[0]
          data_label = @dataID2string[data_id]
          object_id = data[i][1]
          mm_index = 1
          if data[i][2].split('_').size > 2
            mm_index = data[i][2].split('_')[2]
          end
          hierarchy = data[i][2].split('_')[1]
          titles << "#{@protocol} - #{data_id} - #{data_label} - #{object_id}-#{mm_index}-#{hierarchy}"
        end
        return titles
      when 'MB' then
        titles = Array.new
        ss = WIN32OLE::new('excel.Application')
        wb = ss.Workbooks.Open(@input_file)
        ws = wb.Worksheets(1)
        data = ws.UsedRange.Value
        for i in 1..data.size-1
          data_label = data[i][2].split('(')[0].strip # Strip Multi-module index from label to lookup data id
          data_id = @dataID2string.index(data_label)
          register = data[i][1].split('(')[0]
          size = data[i][1].split('(')[1].sub(')','')
          data_label = data[i][2] # Put the index back into the label
          units = data[i][3]
          scale = data[i][4]
          access = data[i][5]
          title = "#{@protocol} - #{data_id} - #{register}(#{size}) - #{data_label} - #{units} - #{scale} - #{access}"
          title.gsub!(' -  -  - ','')
          title.gsub!('-  -','')
          titles << title
        end
        titles
      when 'SP' #TODO
        puts "Sorry, this feature has not yet been implemented."
        return nil
      when 'WB' then
        puts "Sorry, this feature has not yet been implemented."
        return nil
      else
      end
    when 'xml' then
      puts "Sorry, this feature has not yet been implemented."
      return nil
    when 'web' then
      puts "Sorry, this feature has not yet been implemented."
      return nil
    else puts "#{@input_type} not supported"; raise "Invalid input";
    end
  rescue
  end
end

# This method 'generates' the test cases by appending the appropriate data to
# the output array.
# TODO - Still need to implement for the following cases:
# TODO - Input_type - xls, Protocol - SNMP (SP)
# TODO - Input_type - xml, Protocol - Web (WB)
# TODO - Input_type - xml, Protocol - SNMP (SP)
# TODO - Input_type - xml, Protocol - Modbus (MB)
# TODO - Input_type - xml, Protocol - BACnet (BN)
# TODO - Input_type - web, Protocol - Web (WB)
# TODO - Input_type - web, Protocol - SNMP (SP)
# TODO - Input_type - web, Protocol - Modbus (MB)
# TODO - Input_type - web, Protocol - BACnet (BN)
def generate()
  build_hashes
  puts "Generating test cases for: #{@device_name}"
  if @input_type == 'xls' then
    mm_index = ''
    test_cases = parse_input_file
    test_cases.each do |title|
      data_id = title.split('-')[1].strip
      case @protocol
      when 'BN' then
        mm_index = title.split('-')[title.split('-').size - 2].strip
        @output << 'case' << @test_suite << data_id + '-' + mm_index.to_s + '-' + @protocol + '-' + test_cases.index(title).to_s << title
      build_test_case(@test_case)
      when 'MB' then
        mm_index = 1
        if title =~ /\[/ then mm_index = title.split('[')[1].split(']')[0].strip; end
        @output << 'case' << @test_suite << data_id + '-' + mm_index.to_s + '-' + @protocol + '-' + test_cases.index(title).to_s << title
        build_test_case(@test_case)
      when 'SP' then #TODO Implement this case - SNMP
      when 'WB' then puts "This protocol is not supported"
      else mm_index = 1
      end
    end

  else
    File.open(@path_to_fdm) do |file|
      # Open the document
      fdm = REXML::Document.new(file)
      # Initialize variables (scope is outside of do loops)
      device_name = fdm.root.attribute('ProgrammaticName').to_s
      fdm.root.elements.each("/*/ReportDescriptor") do |descriptor|
        # These are the web navigation folders
        mm_index = descriptor.attribute('index').to_s.to_i
        if mm_index == 0 then mm_index = 1; end
        if descriptor.attribute('id').to_s.to_i >= 256 and descriptor.attribute('privateReport').to_s == 'False'
          report_name = @strings.fetch(descriptor.attribute('labelId').to_s)
          @output << 'suite' << device_name + "\\#{@test_type}\\" + report_name << report_name
          @output.pad(33)
          i = 1
          descriptor.elements.each("dataPoint") do |data_point|
            if mm_index == 1
              @output << 'case' << device_name + "\\#{@test_type}\\" + report_name << build_id(data_point)
              @output << build_title(data_point)
              build_test_case(@test_case)
            else
              while i <= mm_index
                @output << 'case' << device_name + "\\#{@test_type}\\" + report_name << build_id(data_point)
                @output << build_title(data_point) + " [#{report_name} [#{i}]]"
                build_test_case(@test_case)
                i += 1
              end
            end
          end
        end
      end
      return @output
    end
  end
end

# This method is not officially used yet.
def build_id(datapoint)
  data_label = ''
  id = datapoint.attribute('id').to_s
  
  datapoint.elements.each(type) do |data|
    data.elements.each('DataLabel/TextID') {|name| data_label = name.text}
  end

  if @strings.has_key?(data_label)
    data_label = @strings.fetch(data_label)
  else data_label = "UNKNOWN STRING ID: #{data_label}"
  end
  id = id + '_' + @protocol
  return id
end

# This method is not officially used yet.
def build_title(datapoint)
  data_label = ''
  id = datapoint.attribute('id').to_s
  type = datapoint.attribute('type').to_s
  datapoint.elements.each(type) do |data|
    data.elements.each('DataLabel/TextID') {|name| data_label = name.text}
  end

  if @strings.has_key?(data_label)
    data_label = @strings.fetch(data_label)
  else data_label = "UNKNOWN STRING ID: #{data_label}"
  end
  title = @protocol + ' - ' + id + ' - ' + data_label
  return title
end

# This method parses the appropriate fields in the test case supplied by the
# user and appends those fileds to the output array.
def build_test_case(path_to_xml)
  File.open(path_to_xml) do |config_file|
    # Open the document
    test_case = REXML::Document.new(config_file)

    counter = 1
    test_case.root.elements.each() do |element|
      if element.inspect.to_s =~ /history_entry/
        counter += 1
        next
      end
      if counter > 2 #Skip the firt two elements
        if element.text != nil
          if element.text =~ /"/
            escaped_text = element.text.gsub('"', '""')
            @output << '"' + escaped_text + '"'
          else @output << '"' + element.text + '"'
          end
        else @output << ""
        end
      end
      counter += 1
    end
  end
  return @output
end

# This method builds the hash tables that are used to lookup data labels given
# a data id.
# TODO - This method can be made more efficient by checking if the GDD has been
# parsed already or by doing some caching.
def build_hashes
  puts "\nBuilding data hashes\n\n"
  global_strings = build_string_id_hash(@path_to_gdd,'/Enp2DataDict/GlobalStringDefinitions/String')
  local_strings = build_string_id_hash(@path_to_fdm,'/*/LocalStringDefinitions/String')

  @strings = global_strings.merge(local_strings)
  @strings.default('UNKNOWN STRING ID')

  global_data_ids = build_data_id_hash(@path_to_gdd,'//DataDictEntry/DataId','//DataDictEntry/LabelTextId')
  local_data_ids = build_data_id_hash(@path_to_fdm,'///DataIdentifier','///DataLabel/TextID')

  @data_ids = global_data_ids.merge(local_data_ids)
  @data_ids.default('UNKNOWN DATA ID')

  @dataID2string = Hash.new
  @dataID2string.default('UNKNOWN DATA ID')
  
  @data_ids.each_key do |key|
    value = @strings[@data_ids[key]]
    @dataID2string[key] = value
  end
  puts "Finished building hashes"
end

# This method builds the hash table that maps text IDs to strings.
def build_string_id_hash(path_to_xml,path_to_string)
  if File.exists?(path_to_xml)
    File.open(path_to_xml) do |config_file|
      # Open the document
      config = REXML::Document.new(config_file)
      # Initialize variables (scope is outside of do loops)
      h = Hash.new
      puts "Parsing #{path_to_xml} for data labels."
      config.root.elements.each(path_to_string) do |string|
        key = string.attribute('Id').to_s
        if string.text == nil then
          value = ""
        else
          value = string.text
        end
        h[key] = value
      end
      return h
    end
  else raise 'Input XML file(GDD) not found!'
  end
end

# This method builds the hash that maps data identifiers to their text IDs.
def build_data_id_hash(path_to_xml,path_to_data_id,path_to_label_text_id)
  if File.exists?(path_to_xml)
    File.open(path_to_xml) do |config_file|
      # Open the document
      doc = REXML::Document.new(config_file)
      # Initialize variables (scope is outside of do loops)
      h = Hash.new
      puts "Parsing #{path_to_xml} for data ids."
      data_ids = XPath.match( doc, path_to_data_id)
      data_labels = XPath.match( doc, path_to_label_text_id)
      for i in 0..data_ids.size-1
        key = data_ids[i].text
        value = data_labels[i].text
        h[key] = value
      end
      return h
    end
  else raise 'Input XML file(GDD) not found!'
  end
end

# This method opens the supplied output file for writing and writes the data
# header array in a CSV format
def output_header()
  # Create/Open the output file and write the column headers
  for i in 0..CH.size-1 do
    if i < CH.size-1 then @out_file.print CH[i] + ","
    else @out_file.puts CH[i]
    end
  end
end

# This method writes the contents of the @output array to the supplied output
# file (@out_file) after calling the output_header method.
def output_to_csv()
  if @out_file != '' then
  @out_file = File.new(@out_file, 'w')
    output_header
    for i in 1..@output.size do
      if i == 1 then @out_file.print @output[i-1].to_s + ","; next; end;
      if i % CH.size != 0 then @out_file.print @output[i-1].to_s + ","
      else @out_file.puts @output[i-1].to_s
      end
    end
  else
    puts "Something went wrong with creating the output file..."
    get_out_file
  end
end

end
