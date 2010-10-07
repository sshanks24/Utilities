require 'gdd'
require 'fdm'

gdd = Gdd.new('C:\fdm\enp2dd.xml')
fdm = Fdm.new('C:\fdm\BDSU.xml')

fdm.build_fdm_hashes
gdd.build_gdd_hashes


#gdd.merge_hashes_with_fdm(fdm)
#serialization
File.open("C:/fdm/fdm_test","wb") do |file|
   Marshal.dump(fdm,file)
end

File.open("C:/fdm/gdd","wb") do |file|
   Marshal.dump(gdd,file)
end