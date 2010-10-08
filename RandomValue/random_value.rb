# To change this template, choose Tools | Templates
# and open the template in the editor.

class RandomValue

  attr_accessor :value
  
  def initialize(minimum_value, maximum_value)
    @value = rand(maximum_value+1)+minimum_value
  end
end
