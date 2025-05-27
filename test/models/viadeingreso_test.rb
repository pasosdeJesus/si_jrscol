# frozen_string_literal: true

require "test_helper"

class ViadeingresoTest < ActiveSupport::TestCase
  PRUEBA_VIADEINGRESO = {
    nombre: "Viadeingreso",
    fechacreacion: "2020-07-11",
    created_at: "2020-07-11",
  }

  test "valido" do
    viadeingreso = ::Viadeingreso.create(
      PRUEBA_VIADEINGRESO,
    )

    assert(viadeingreso.valid?)
    viadeingreso.destroy
  end

  test "no valido" do
    viadeingreso = ::Viadeingreso.new(
      PRUEBA_VIADEINGRESO,
    )
    viadeingreso.nombre = ""

    assert_not(viadeingreso.valid?)
    viadeingreso.destroy
  end

  test "existente" do
    viadeingreso = ::Viadeingreso.find_by(id: 1)

    assert_equal("Puente oficial", viadeingreso.nombre)
  end
end
