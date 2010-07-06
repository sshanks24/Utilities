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

  def replace_file(to_be_replaced, replacement)
  counter = 1
  while (line = to_be_replaced.gets)
    line.strip!
    File.copy(line, line + BACKUP_EXT)
    File.copy(replacement, line)
    counter = counter + 1
  end
  to_be_replaced.close
  puts "#{counter-1} file(s) replaced"
end

  def find_file(root_directory,file,found_files)
  file = File.basename(file)
  i=0
  Find.find(root_directory) do |path|
    if FileTest.directory?(path)
      if File.basename(path)[0] == ?. and File.basename(path) != '.'
        Find.prune
      else
        next
      end
    else if File.fnmatch?(file, File.basename(path))
        found_files.puts(path)
        #results.puts(File.basename(path) + " found in " + File.dirname(path))
        #FileUtils.mv(path, temp_dir + File.basename(path) + i.to_s)
        i += 1

      end
    end
  end

  puts "Found #{i} instances of #{file}.  A listing of the file(s) are located in #{found_files.path}"
end
end

# Verify arguments
if (ARGV.length != 1 and ARGV.length != 2)
  RDoc::usage
end

# Handle defaults
if ARGV.length == 1
  #directory = 'I:\LMG TEST ENGINEERING\TestLog\Projects' # FOR PRODUCTION USE
  directory = 'C:\Documents and Settings\shanksstemp\My Documents\Testlog\1'
else directory = ARGV.shift
end

path_to_temp_file = "C:/FindAndReplaceResults.txt"
target = ARGV.shift

Dir.chdir(directory.gsub('/', '\\'))
print 'Current working directory: '
p Dir.pwd

puts "Finding targets to be replaced by...#{target}"

test_log = Test_log.new()
results = File.new(path_to_temp_file, 'w')
test_log.find_file(directory,target,results)

results.close

results = File.new(path_to_temp_file, 'r')

test_log.replace_file(results,target)




