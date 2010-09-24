require 'gdd'

gdd = Gdd.new('C:\fdm\enp2dd.xml')

#serialization
File.open("C:/fdm/hashes","wb") do |file|
   Marshal.dump(gdd,file)
end
