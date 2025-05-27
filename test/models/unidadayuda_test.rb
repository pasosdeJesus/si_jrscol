# frozen_string_literal: true

require "test_helper"

class UnidadayudaTest < ActiveSupport::TestCase
  PRUEBA_UNIDADAYUDA = {
    nombre: "Unidadayuda",
    fechacreacion: "2020-09-12",
    created_at: "2020-09-12",
  }

  test "valido" do
    unidadayuda = ::Unidadayuda.create(
      PRUEBA_UNIDADAYUDA,
    )

    assert(unidadayuda.valid?)
    unidadayuda.destroy
  end

  test "no valido" do
    unidadayuda = ::Unidadayuda.new(
      PRUEBA_UNIDADAYUDA,
    )
    unidadayuda.nombre = ""

    assert_not(unidadayuda.valid?)
    unidadayuda.destroy
  end

  test "existente" do
    unidadayuda = ::Unidadayuda.find_by(id: 10)

    assert_equal("MEDICAMENTOS", unidadayuda.nombre)
  end
end
