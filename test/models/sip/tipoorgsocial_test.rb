require 'test_helper'


require 'test_helper'

module Sip
  class TipoorgsocialTest < ActiveSupport::TestCase
  
      PRUEBA_TIPOORGSOCIAL = {
        nombre: "Tipoorgsocial",
        fechacreacion: "2018-10-25",
        created_at: "2018-10-25",
      }
  
      test "valido" do
        tipoorgsocial = Sip::Tipoorgsocial.create(
          PRUEBA_TIPOORGSOCIAL)
        assert(tipoorgsocial.valid?)
        tipoorgsocial.destroy
      end
  
      test "no valido" do
        tipoorgsocial = Sip::Tipoorgsocial.new(
          PRUEBA_TIPOORGSOCIAL)
        tipoorgsocial.nombre = ''
        assert_not(tipoorgsocial.valid?)
        tipoorgsocial.destroy
      end
  
      test "existente" do
        skip
        tipoorgsocial = Sip::Tipoorgsocial.where(id: 0).take
        assert_equal(tipoorgsocial.nombre, "SIN INFORMACIÓN")
      end
  
  end
end
