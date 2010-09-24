# To change this template, choose Tools | Templates
# and open the template in the editor.


class Fdm
  def initialize(fdm_file)
    File.open(fdm_file) do |config_file|
      @xml = REXML::Document.new(config_file)
    end
  end

  def version
    @xml.root.elements["/*"].attributes["version"].to_s
  end
end

