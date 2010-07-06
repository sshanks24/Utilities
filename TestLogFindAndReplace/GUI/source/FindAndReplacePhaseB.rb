# == Synopsis
#
# FindAndReplace: replaces all instances of a target file in a directory and subdirectories 
#
# == Usage
#
# FindAndReplace TARGET [DIRECTORY]
#

require 'getoptlong'
require 'rdoc/usage'
require 'ftools'
require 'find'
require 'rexml/document'

module Find
  def match(*paths)
    matched = []
    find(*paths) { |path| matched << path if yield path }
    return matched
  end
  module_function :match
end

class Test_log
  BACKUP_EXT = '.frb'
  @@valid_id_array = Array['id',	'test_title',	'test_duration',	'test_type',
    'test_phase',	'rec_test_configs',	'test_resources',	'test_status',
    'test_attempts',	'last_attempt_date',	'last_attempt_time',
    'actual_duration',	'testers',	'fault_report_id',	'change_req_id',
    'results_obtained',	'version_tested',	'build_tested',	'external_link2',
    'result_notes',	'requirement',	'create_date',	'create_time',
    'update_date',	'update_time',	'create_user_id',	'update_user_id',
    'prerequisites',	'test_description',	'test_result',	'notes1',	'notes2',
    'external_link',	'priority',	'history_entry']

  def replace_file(to_be_replaced, replacement)
    counter = 1
    while (line = to_be_replaced.gets)
      line.strip!
      if File.exists?(line) then File.copy(line, line + BACKUP_EXT); end;
      update_test_case(line, 'prerequisites', retrieve_test_case_value(replacement,'prerequisites'))
      update_test_case(line, 'test_description', retrieve_test_case_value(replacement,'test_description'))
      update_test_case(line, 'requirement', retrieve_test_case_value(replacement,'requirement'))
      update_test_case(line, 'notes2', retrieve_test_case_value(replacement,'notes2')) #Revision History
      update_test_case(line, 'external_link', retrieve_test_case_value(replacement,'external_link'))
      counter = counter + 1
    end
    to_be_replaced.close
    return "#{counter-1} file(s) replaced"
  end

  def find_file(root_directory,file,found_files)
    full_file_path = file.gsub('\\','/')
    file = File.basename(file)

    i=0
    Find.find(root_directory) do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == ?. and File.basename(path) != '.'
          Find.prune
        else
          next
        end
      else if File.fnmatch?(file, File.basename(path)) and !File.fnmatch?(full_file_path, path.gsub('\\','/'))
          found_files.puts(path)
          #results.puts(File.basename(path) + " found in " + File.dirname(path))
          #FileUtils.mv(path, temp_dir + File.basename(path) + i.to_s)
          i += 1
        end
      end
    end

    return "Found #{i} instances of #{file}.  A listing of the file(s) are located in #{found_files.path}"
  end

  def update_test_case(test_case_file, id, value)

  index = @@valid_id_array.index(id)

  case index
  when nil then puts "Invalid update statement: #{id} is not a valid test case field."; exit;
  when 15 then cdata = true
  when 19 then cdata = true
  when 27..31 then cdata = true
  else cdata = false
  end

  if cdata == true and value != nil
    if File.exists?(value)
      temp = ''
      File.open(value) do |file|
        file.each do |line|
        temp += line.chomp
        end
      end
    value = REXML::CData.new(temp)
    else
    value = REXML::CData.new(value)
    end
  end


  if File.exists?(test_case_file) and File.zero?(test_case_file) == false
    File.open(test_case_file) do |config_file|
      # Open the document and edit the value associated with id
      # puts test_case_file
      config = REXML::Document.new(config_file)
      config.root.elements[id].text = value

      # Write the result to a new file.
      formatter = REXML::Formatters::Default.new
      File.open(test_case_file, 'w') do |result|
      formatter.write(config, result)
      end
    end
  else
    puts "Invalid file name: \"#{test_case_file}\" is not a valid test case file."
    #exit
  end
  end

  def retrieve_test_case_value(test_case_file, id)

  index = @@valid_id_array.index(id)

  case index
  when nil then puts "Invalid update statement: #{id} is not a valid test case field."; exit;
  when 15 then cdata = true
  when 19 then cdata = true
  when 27..31 then cdata = true
  else cdata = false
  end

    if File.exists?(test_case_file)
      File.open(test_case_file) do |config_file|
        if cdata == true # This conditional and flag may be unneccessary
          config = REXML::Document.new(config_file)
          value = config.root.elements[id].text
          return value
        else
          config = REXML::Document.new(config_file)
          value = config.root.elements[id].text
          return value
        end
      end
    end
  
    #puts "Invalid test case file specified"
    exit

  end
end

# Testing...

#t = Test_log.new
#results = File.new('C:\FindAndReplaceResults.txt', 'r')
#puts t.replace_file(results, 'C:\Documents and Settings\shanksstemp\My Documents\Testlog\TestDB\Projects\Test_Project_ID\Project Test Cases\Test1\Test-ID.tlg')
