# frozen_string_literal: true

require "test_helper"

class MecanismodeentregaTest < ActiveSupport::TestCase
  PRUEBA_MECANISMODEENTREGA = {
    nombre: "Mecanismodeentrega",
    fechacreacion: "2020-09-11",
    created_at: "2020-09-11",
  }

  test "valido" do
    mecanismodeentrega = ::Mecanismodeentrega.create(
      PRUEBA_MECANISMODEENTREGA,
    )

    assert(mecanismodeentrega.valid?)
    mecanismodeentrega.destroy
  end

  test "no valido" do
    mecanismodeentrega = ::Mecanismodeentrega.new(
      PRUEBA_MECANISMODEENTREGA,
    )
    mecanismodeentrega.nombre = ""

    assert_not(mecanismodeentrega.valid?)
    mecanismodeentrega.destroy
  end

  test "existente" do
    mecanismodeentrega = ::Mecanismodeentrega.find_by(id: 2)

    assert_equal("Tarjeta pre-pago", mecanismodeentrega.nombre)
  end
end
