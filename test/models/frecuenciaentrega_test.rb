require 'test_helper'

class FrecuenciaentregaTest < ActiveSupport::TestCase

  PRUEBA_FRECUENCIAENTREGA = {
    nombre: "Frecuenciaentrega",
    fechacreacion: "2020-09-12",
    created_at: "2020-09-12"
  }

  test "valido" do
    frecuenciaentrega = ::Frecuenciaentrega.create(
      PRUEBA_FRECUENCIAENTREGA)
    assert(frecuenciaentrega.valid?)
    frecuenciaentrega.destroy
  end

  test "no valido" do
    frecuenciaentrega = ::Frecuenciaentrega.new(
      PRUEBA_FRECUENCIAENTREGA)
    frecuenciaentrega.nombre = ''
    assert_not(frecuenciaentrega.valid?)
    frecuenciaentrega.destroy
  end

  test "existente" do
    frecuenciaentrega = ::Frecuenciaentrega.where(id: 1).take
    assert_equal(frecuenciaentrega.nombre, "Una sola entrega")
  end

end
