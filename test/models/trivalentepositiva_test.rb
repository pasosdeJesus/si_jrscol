# encoding: utf-8
# frozen_string_literal: true

require "test_helper"

class TrivalentepositivaTest < ActiveSupport::TestCase
  PRUEBA_TRIVALENTEPOSITIVA = {
    nombre: "Trivalentepositiva",
    fechacreacion: "2020-07-12",
    created_at: "2020-07-12",
  }

  test "valido" do
    trivalentepositiva = ::Trivalentepositiva.create(
      PRUEBA_TRIVALENTEPOSITIVA,
    )

    assert(trivalentepositiva.valid?)
    trivalentepositiva.destroy
  end

  test "no valido" do
    trivalentepositiva = ::Trivalentepositiva.new(
      PRUEBA_TRIVALENTEPOSITIVA,
    )
    trivalentepositiva.nombre = ""

    assert_not(trivalentepositiva.valid?)
    trivalentepositiva.destroy
  end

  test "existente" do
    trivalentepositiva = ::Trivalentepositiva.find_by(id: 1)

    assert_equal("SIN RESPUESTA", trivalentepositiva.nombre)
  end
end
