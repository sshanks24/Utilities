# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'test/unit'
require 'random_value'

class RandomTest < Test::Unit::TestCase
  def test_simple
    number = RandomValue.new(-32000,32000)
    boolean = number.value > -32000 and number.value < 32000
    assert(boolean)
  end
end
