require 'wx'
include Wx

# This class was automatically generated from XRC source. It is not
# recommended that this file is edited directly; instead, inherit from
# this class and extend its behaviour there.
#
# Source file: noname.xrc
# Generated at: Fri Mar 19 16:46:34 -0400 2010

class Find_Replace_Frame < Frame

        attr_reader :m_statictext7, :m_textctrl5, :m_button5, :m_button8,
              :m_textctrl6, :m_statusbar2

        def initialize(parent = nil)
                super()
                xml = Wx::XmlResource.get
                xml.flags = 2 # Wx::XRC_NO_SUBCLASSING
                xml.init_all_handlers
                xml.load("noname.xrc")
                xml.load_frame_subclass(self, parent, "MyFrame2")

                finder = lambda do | x |
                        int_id = Wx::xrcid(x)
                        begin
                                Wx::Window.find_window_by_id(int_id, self) || int_id
                        # Temporary hack to work around regression in 1.9.2; remove
                        # begin/rescue clause in later versions
                        rescue RuntimeError
                                int_id
                        end
                end

                              
                @m_statictext7 = finder.call("m_staticText7")
                @m_textctrl5 = finder.call("m_textCtrl5")
                @m_button5 = finder.call("m_button5")
                @m_button8 = finder.call("m_button8")
                @m_textctrl6 = finder.call("m_textCtrl6")
                @m_statusbar2 = finder.call("m_statusBar2")
                if self.class.method_defined? "on_init"
                        self.on_init()
                end

        end



end



