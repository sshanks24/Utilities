require 'main' # or 'main','attempt2' replace textctr 6 with 4. Leave textctrl 5 alone
require 'thread'
require 'FindAndReplacePhaseB'

class Find_Replace_Events < Find_Replace_Frame

   def initialize
     super
     @directory = 'I:\LMG TEST ENGINEERING\TestLog'
     @path_to_temp_file = @directory + "\\" + "FindAndReplaceResults.txt"
     $stdout = $stderr = File.new(@directory + "\\" + ".#{Process.pid}.log", "w")
     evt_button(@m_button5.get_id()) { browse_button_click()} # or 5,3
     evt_button(@m_button8.get_id()) { replace_button_click()} # or 8,4
   end

   def browse_button_click()
     @m_textctrl5.value = ''
        fd = FileDialog.new(nil,"Choose a file", @directory, "", "*.tlg")
        if fd.show_modal == Wx::ID_OK
          @m_textctrl5.value = fd.path
          @target = fd.path
        end
    end

   def replace_button_click()
     if File.exists?(@m_textctrl5.value)
       #Thread.new {find_and_replace()} #So the screen updating works...
       find_and_replace()
     else
       @m_textctrl6.value = @m_textctrl6.value + "Invalid file specified.  Please select another file." + "\n"
     end
   end

   def find_and_replace()
       @m_textctrl6.value = ''
       Dir.chdir(@directory.gsub('/', '\\'))

       @m_textctrl6.value = "\n" + @m_textctrl6.value + "Current working directory: #{Dir.pwd}\n"
       @m_textctrl6.value = @m_textctrl6.value + "Finding targets to be replaced by #{@target}\n"

       start_time = Time.now
       @m_textctrl6.value = @m_textctrl6.value + "Find and Replace started at #{start_time}\n"
       @m_textctrl6.value = @m_textctrl6.value + @target + "\n"

       test_log = Test_log.new()
       @results = File.new(@path_to_temp_file, 'w')
       found_result = test_log.find_file(@directory,@target,@results) + "\n"
       @m_textctrl6.value = @m_textctrl6.value + found_result + "\n"
       @results.close
       @results = File.new(@path_to_temp_file, 'r')
       found_result = test_log.replace_file(@results,@target) + "\n"
       @m_textctrl6.value = @m_textctrl6.value + found_result + "\n"

       end_time = Time.now
       @m_textctrl6.value = @m_textctrl6.value + "Find and Replace completed at #{end_time}" + "\n"
       @m_textctrl6.value = @m_textctrl6.value + "Total run time: #{end_time - start_time}"
   end
end

class Find_Replace_App < Wx::App
  def on_init
     #t = Wx::Timer.new(self, 55)
     #evt_timer(5500) { Thread.pass }
     #t.start(100)
     f =  ::Find_Replace_Events.new()
     f.show
   end
end

Find_Replace_App.new.main_loop


