# frozen_string_literal: true

require "test_helper"

class DificultadmigracionTest < ActiveSupport::TestCase
  PRUEBA_DIFICULTADMIGRACION = {
    nombre: "Dificultadmigracion",
    fechacreacion: "2020-07-21",
    created_at: "2020-07-21",
  }

  test "valido" do
    dificultadmigracion = ::Dificultadmigracion.create(
      PRUEBA_DIFICULTADMIGRACION,
    )

    assert(dificultadmigracion.valid?)
    dificultadmigracion.destroy
  end

  test "no valido" do
    dificultadmigracion = ::Dificultadmigracion.new(
      PRUEBA_DIFICULTADMIGRACION,
    )
    dificultadmigracion.nombre = ""

    assert_not(dificultadmigracion.valid?)
    dificultadmigracion.destroy
  end

  test "existente" do
    dificultadmigracion = ::Dificultadmigracion.find_by(id: 1)

    assert_equal("Caída", dificultadmigracion.nombre)
  end
end
