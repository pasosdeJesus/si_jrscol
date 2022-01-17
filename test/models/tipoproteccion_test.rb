require 'test_helper'

class TipoproteccionTest < ActiveSupport::TestCase

  PRUEBA_TIPOPROTECCION = {
    nombre: "Tipoproteccion",
    fechacreacion: "2020-08-07",
    created_at: "2020-08-07"
  }

  test "valido" do
    tipoproteccion = ::Tipoproteccion.create(
      PRUEBA_TIPOPROTECCION)
    assert(tipoproteccion.valid?)
    tipoproteccion.destroy
  end

  test "no valido" do
    tipoproteccion = ::Tipoproteccion.new(
      PRUEBA_TIPOPROTECCION)
    tipoproteccion.nombre = ''
    assert_not(tipoproteccion.valid?)
    tipoproteccion.destroy
  end

  test "existente" do
    tipoproteccion = ::Tipoproteccion.where(id: 1).take
    assert_equal(tipoproteccion.nombre, "Individual")
  end

end
