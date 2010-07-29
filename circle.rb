if ARGV.size != 2
  puts 'Enter radius and aspect ratio (e.g. 4:3, 16:9)'
end

radius = ARGV[0]
aspect_ratio = ARGV[1]

# The standard equation for a circle is:
# (x - h)2 + (y - k)2 = r2
#
# h and k are always = to r in our case here...

class Circle
  def initialize(radius)
    @radius = radius.to_i
  end
  def draw(aspect_ratio='1:1')
    #parse aspect_ratio for width and height...
    width = aspect_ratio.split(':')[0].to_i
    height = aspect_ratio.split(':')[1].to_i
     a = Hash.new(' ')
     for i in 0..@radius*2*height
      for j in 0..@radius*2*width
#        puts "r^2: #{@radius*@radius}"
#        puts "the rest: #{(i - @radius)*(i - @radius) + (j - @radius)*(j - @radius)}"
        if @radius*@radius - (width*((i - @radius)*(i- @radius)) + height*((j - @radius)*(j - @radius))) >= 1
          a[[i,j]] = '#'
        end
      end
    end
     for i in 0..@radius*2
       for j in 0..@radius*2
         print a[[i,j]]
       end
       print "\n"
     end
  end
end

circle = Circle.new(radius)
circle.draw(aspect_ratio)