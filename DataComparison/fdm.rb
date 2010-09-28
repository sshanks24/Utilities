require 'rexml/document'
require 'win32ole'
require 'liebert_xml'

class Fdm < LiebertXML

  def version
    @xml.root.elements["/*"].attribute('version').to_s
  end

  def build_hashes
    puts "\nBuilding data hashes\n\n"
    @strings = build_string_id_hash("//String")
    @units = build_hash("//UomDefn","//UomDefn/TextId")
    @data = build_hash("//DataIdentifier","//DataLabel/TextID")
    puts "Finished building hashes"
  end
end

