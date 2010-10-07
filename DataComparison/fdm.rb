require 'rexml/document'
require 'win32ole'
require 'liebert_xml'

class Fdm < LiebertXML

  def version
    @xml.root.elements["/*"].attribute('version').to_s
  end
 
end