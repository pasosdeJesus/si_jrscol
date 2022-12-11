require 'test_helper'


require 'test_helper'

module Msip
  class TipoorgsocialTest < ActiveSupport::TestCase
  
 
      test "valido" do
        tipoorgsocial = Msip::Tipoorgsocial.create(
          PRUEBA_TIPOORGSOCIAL)
        assert(tipoorgsocial.valid?)
        tipoorgsocial.destroy
      end
  
      test "no valido" do
        tipoorgsocial = Msip::Tipoorgsocial.new(
          PRUEBA_TIPOORGSOCIAL)
        tipoorgsocial.nombre = ''
        assert_not(tipoorgsocial.valid?)
        tipoorgsocial.destroy
      end
  
      test "existente" do
        skip
        tipoorgsocial = Msip::Tipoorgsocial.where(id: 0).take
        assert_equal(tipoorgsocial.nombre, "SIN INFORMACIÓN")
      end
  
  end
end
