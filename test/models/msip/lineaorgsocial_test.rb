require 'test_helper'

module Msip
  class LineaorgsocialTest < ActiveSupport::TestCase
  
      PRUEBA_LINEAORGSOCIAL = {
        nombre: "Lineaorgsocial",
        fechacreacion: "2018-10-25",
        created_at: "2018-10-25",
      }
  
      test "valido" do
        lineaorgsocial = Msip::Lineaorgsocial.create(
          PRUEBA_LINEAORGSOCIAL)
        assert(lineaorgsocial.valid?)
        lineaorgsocial.destroy
      end
  
      test "no valido" do
        lineaorgsocial = Msip::Lineaorgsocial.new(
          PRUEBA_LINEAORGSOCIAL)
        lineaorgsocial.nombre = ''
        assert_not(lineaorgsocial.valid?)
        lineaorgsocial.destroy
      end
  
      test "existente" do
        skip
        lineaorgsocial = Msip::Lineaorgsocial.where(id: 0).take
        assert_equal(lineaorgsocial.nombre, "SIN INFORMACIÓN")
      end
  
  end
end
