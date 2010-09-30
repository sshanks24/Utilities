require 'gdd'
require 'fdm'

gdd = Gdd.new('C:\fdm\enp2dd.xml')
fdm = Fdm.new('C:\fdm\BDSU.xml')

gdd.merge_hashes_with_fdm(fdm)
#serialization
File.open("C:/fdm/hashes","wb") do |file|
   Marshal.dump(gdd,file)
end
