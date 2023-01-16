require 'test_helper'

module Msip
  class OficinaTest < ActiveSupport::TestCase
  
      PRUEBA_OFICINA = {
        nombre: "Oficina",
        fechacreacion: "2018-10-25",
        created_at: "2018-10-25",
      }
  
      test "valido" do
        oficina = Msip::Oficina.create(
          PRUEBA_OFICINA)
        assert(oficina.valid?)
        oficina.destroy
      end
  
      test "no valido" do
        oficina = Msip::Oficina.new(
          PRUEBA_OFICINA)
        oficina.nombre = ''
        assert_not(oficina.valid?)
        oficina.destroy
      end
  
      test "existente" do
        oficina = Msip::Oficina.where(id: 1).take
        assert_equal(oficina.nombre, "SIN INFORMACIÓN")
      end
  
  end
end
