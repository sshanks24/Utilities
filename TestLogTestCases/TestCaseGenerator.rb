# == Synopsis
#
# fdm2testlogcsv.rb
#
# Maybe one day this will do what I intend... to take a device FDM and the GDD and output test cases for import into test log.
#
#
# == Usage
#
# fdm2testlogcsv.rb path2fdm.xml path2gdd.xml path2webtestcase.xml path2snmp.xml path2snmptestcase.xml path2out.csv
#

require 'rdoc/usage'
require 'rexml/document'
require 'win32ole'

include REXML

class Array
def pad(i)
  i.times {self << ""}
  return self.flatten!
end
end

class TestCaseGenerator

# Constants to define data headers of CSV - CH = Column Headers

CH = ["Type","Test Suite","ID","Title","Hours Expected","Type","Phase",
  "Configurations","Resources","Status","Attempts","Last Attempt Date",
  "Last Attempt Time","Actual Hours","Testers","Faults","CR ID","Results",
  "Version","Build","Link2","Result Notes","Requirements","Created Date",
  "Created Time","Updated Date","Updated Time","Author","Update By",
  "Prerequisites","Description","Results","Notes Field 1","Revision History",
  "Link","Priority"]
PROMPT = '>'
PROTOCOLS = ["BN", "MB", "SP", "WB"]
TEST_TYPES = ["Control", "Events", "Monitor"]
INPUT_TYPES = ["web", "xls", "xml"]
DEVICES = ['APM','BDSU','Challenger','CRV','Deluxe','DS','HPC','HPM','Jumbo','Pex','PSI-700','XDC','XDP','XDPW','XP_Cray']
CARDS = ['IS-WEBCARD','IS-WEBX','IS-WEBL','IS-WEBS','IS-485X','IS-485L','IS-485S','IS-IPBMX','IS-IPBML','IS-IPBMS']

attr_accessor :path_to_fdm, :path_to_gdd, :protocol, :type

def initialize()
  @path_to_fdm = get_path("FDM")
  @path_to_gdd = get_path("GDD")
  @protocol = get_protocol
  @test_type = get_test_type
  @test_case = get_path("Test Case")
  @input_type = get_input_type
  @device_name = get_device_name
  @card_name = get_card_name

#  @path_to_fdm = 'C:\LMG_Test\ruby\Utilities\TestLogTestCases\iCOM_CR.xml'
#  @path_to_gdd = 'C:\Documents and Settings\shanksstemp\Desktop\BDSU\Testlog\XSLT\enp2dd.xml'
#  @protocol = 'BN'
#  @test_type = 'Monitor'
#  @test_case = 'C:\LMG_Test\ruby\Utilities\TestLogTestCases\BN - Monitor Template.tlg'
#  @input_type = 'xls'
#  @device_name = 'CR'

  case @input_type
  when 'xls' then 
    @input_file = get_input_file
    @test_suite = get_test_suite
  when 'xml' then @input_file = get_input_file
  when 'web' then @ip_address = ''
  else puts "#{input_type} not supported"; raise "Invalid input";
  end
  
  puts "\nConfiguration Succesful!"
  
  global_strings = build_string_id_hash(@path_to_gdd,'/Enp2DataDict/GlobalStringDefinitions/String')
  local_strings = build_string_id_hash(@path_to_fdm,'/*/LocalStringDefinitions/String')

  @strings = global_strings.merge(local_strings)
  @strings.default('UNKNOWN STRING ID')

  @data_ids = build_data_id_hash(@path_to_gdd,'//DataDictEntry')
  @data_ids.default('UNKNOWN STRING ID')

  @output = Array.new
end

def size
  return @output.size / CH.size
end

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

def get_test_suite
  print "\nPlease enter a test suite for these test cases\n\n#{PROMPT}"
  test_suite = gets.chomp
  if test_suite == "" then get_report; end;
  return test_suite
end

def get_device_name
  print "\nPlease enter the device name for these test cases\n#{DEVICES.inspect}\n\n#{PROMPT}"
  device_name = gets.chomp
  if device_name == "" then get_device_name; end;
  return device_name
end

def get_card_name
  print "\nPlease enter the card name for these test cases\n#{CARDS.inspect}\n\n#{PROMPT}"
  card_name = gets.chomp
  if card_name == "" then get_card_name; end;
  return card_name
end

def parse_input_file
  begin
    case @input_type
    when 'xls' then
      case @protocol
      when 'BN' then
        #format_string = %(#{@protocol} - #{data_id} - #{data_label} - #{object_id}-#{mm_index}-#{hierarchy})
        titles = Array.new
        ss = WIN32OLE::new('excel.Application')
        wb = ss.Workbooks.Open(@input_file)
        ws = wb.Worksheets(1)
        data = ws.UsedRange.Value
        for i in 1..data.size-1
          data_id = data[i][2].split('_')[1].split('-')[0]
          data_label = @strings.fetch(@data_ids.fetch(data_id))
          object_id = data[i][1]
          mm_index = data[i][2].split('_')[1].split('-')[1]
          hierarchy = data[i][2].split('_')[1].split('-')[2]
          titles << "#{@protocol} - #{data_id} - #{data_label} - #{object_id}-#{mm_index}-#{hierarchy}"
        end
        return titles
      when 'MB' then
        #format_string = %(#{@protocol} - #{data_id} - #{register}(#{size}) - #{data_label} - #{units}-#{scale}-#{access})
        titles = Array.new
        ss = WIN32OLE::new('excel.Application')
        wb = ss.Workbooks.Open(@input_file)
        ws = wb.Worksheets(1)
        data = ws.UsedRange.Value
        for i in 1..data.size-1
          data_id = @data_ids.index(@strings.index(data[i][2]))
          register = data[i][1].split('(')[0]
          size = data[i][1].split('(')[1].sub(')','')
          data_label = data[i][2].split('(')[0].strip
          units = data[i][3]
          scale = data[i][4]
          access = data[i][5]
          title = "#{@protocol} - #{data_id} - #{register}(#{size}) - #{data_label} - #{units} - #{scale} - #{access}"
          title.sub!('- -','-')
          title.sub!('- -','')
          title.strip
          titles << title
        end
        return titles
      when 'SP' #TODO
      when 'WB' #TODO
      else
      end
    when 'xml' then
      #TODO
    when 'web' then
      #TODO
    else puts "#{input_type} not supported"; raise "Invalid input";
    end
  rescue
  end
end

def generate() #TODO Need to handle Multi-module test cases...
  if @input_type == 'xls' then
    mm_index = ''
    test_cases = parse_input_file
    test_cases.each do |title|
      data_id = title.split('-')[1].strip
      case @protocol
      when 'BN' then
        mm_index = title.split('-')[title.split('-').size - 2].strip
        @output << 'case' << @device_name + "\\#{@test_type}\\" + @test_suite << data_id + '-' + mm_index + '-' + @protocol << title
      build_test_case(@test_case)
      when 'MB' then
        mm_index = 1
        if mm_index =~ /\[/ then mm_index = title.split('[')[1].split(']')[0].strip; end
        @output << 'case' << @device_name + "\\#{@test_type}\\" + @test_suite << data_id + '-' + mm_index.to_s + '-' + @protocol << title
        build_test_case(@test_case)
      when 'SP' then #TODO Implement this case - SNMP
      when 'WB' then #TODO Implement this case - Web
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

def build_test_case(path_to_xml)
  File.open(path_to_xml) do |config_file|
    # Open the document
    config = REXML::Document.new(config_file)

    counter = 1
    config.root.elements.each() do |element|
      if element.inspect.to_s =~ /history_entry/
        counter += 1
        next
      end
      if counter > 2 #Skip the firt two elements
        if element.text != nil
          @output << element.text
        else @output << ""
        end
      end
      counter += 1
    end
  end
  return @output
end

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

def build_data_id_hash(path_to_xml,path_to_data_dict_entry)
  if File.exists?(path_to_xml)
    File.open(path_to_xml) do |config_file|
      # Open the document
      doc = REXML::Document.new(config_file)
      # Initialize variables (scope is outside of do loops)
      h = Hash.new
      puts "Parsing #{path_to_xml} for data ids."
      data_ids = XPath.match( doc, path_to_data_dict_entry + '/DataId' )
      data_labels = XPath.match( doc, path_to_data_dict_entry + '/LabelTextId' )
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

def output_to_csv(path2out)
  # Create/Open the output file and write the column headers
  out_file = File.new(path2out, 'w')
  for i in 0..CH.size-1 do
    if i < CH.size-1 then out_file.print CH[i] + ","
    else out_file.puts CH[i]
    end
  end

  for i in 1..@output.size do
    if i == 1 then out_file.print @output[i-1].to_s + ","; next; end;
    if i % CH.size != 0 then out_file.print @output[i-1].to_s + ","
    else out_file.puts @output[i-1].to_s
    end
  end
end

end
