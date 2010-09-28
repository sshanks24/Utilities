=begin rdoc
*Revisions*
  | Initial File | Scott Shanks | DATE |

=end

require 'rexml/document'
require 'win32ole'
require 'liebert_xml'

class Gdd < LiebertXML

  def merge_hashes_with_fdm(fdm)
    self.strings.merge!(fdm.strings)
    self.units.merge!(fdm.units)
    self.data.merge!(fdm.data)
  end
  
end


