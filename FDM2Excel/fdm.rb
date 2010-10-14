require 'nokogiri'
require 'win32ole'
require 'liebert_xml'

class Fdm < LiebertXML

  def version
    @fdm.root.elements["/*"].attribute('version').to_s
  end

  def read_write_to_a
  end

  def data_ids_to_a
    output = Array.new
    @fdm.xpath("//dataPoint").each do |data_point|
      output << data_point.attribute('id').text
    end
    return output
  end
  
end
