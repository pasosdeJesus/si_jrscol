require 'test_helper'

module Msip
  class TerritorialTest < ActiveSupport::TestCase
  
      PRUEBA_TERRITORIAL = {
        nombre: "Territorial",
        fechacreacion: "2018-10-25",
        created_at: "2018-10-25",
      }
  
      test "valido" do
        territorial = ::Territorial.create(
          PRUEBA_TERRITORIAL)
        assert(territorial.valid?)
        territorial.destroy
      end
  
      test "no valido" do
        territorial = ::Territorial.new(
          PRUEBA_TERRITORIAL)
        territorial.nombre = ''
        assert_not(territorial.valid?)
        territorial.destroy
      end
  
      test "existente" do
        territorial = ::Territorial.where(id: 1).take
        debugger
        assert_equal(territorial.nombre, "SIN INFORMACIÓN")
      end
  
  end
end
