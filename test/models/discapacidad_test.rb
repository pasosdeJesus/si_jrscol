require 'test_helper'

class DiscapacidadTest < ActiveSupport::TestCase

  PRUEBA_DISCAPACIDAD = {
    nombre: "Discapacidad",
    fechacreacion: "2018-11-26",
    created_at: "2018-11-26"
  }

  test "valido" do
    discapacidad = ::Discapacidad.create(
      PRUEBA_DISCAPACIDAD)
    assert(discapacidad.valid?)
    discapacidad.destroy
  end

  test "no valido" do
    discapacidad = ::Discapacidad.new(
      PRUEBA_DISCAPACIDAD)
    discapacidad.nombre = ''
    assert_not(discapacidad.valid?)
    discapacidad.destroy
  end

  test "existente" do
    discapacidad = ::Discapacidad.where(id: 1).take
    assert_equal(discapacidad.nombre, "FÍSICA")
  end

end
