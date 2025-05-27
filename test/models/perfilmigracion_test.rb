# frozen_string_literal: true

require "test_helper"

class PerfilmigracionTest < ActiveSupport::TestCase
  PRUEBA_PERFILMIGRACION = {
    nombre: "Perfilmigracion",
    fechacreacion: "2019-11-27",
    created_at: "2019-11-27",
  }

  test "valido" do
    perfilmigracion = ::Perfilmigracion.create(
      PRUEBA_PERFILMIGRACION,
    )

    assert(perfilmigracion.valid?)
    perfilmigracion.destroy
  end

  test "no valido" do
    perfilmigracion = ::Perfilmigracion.new(
      PRUEBA_PERFILMIGRACION,
    )
    perfilmigracion.nombre = ""

    assert_not(perfilmigracion.valid?)
    perfilmigracion.destroy
  end

  test "existente" do
    perfilmigracion = ::Perfilmigracion.find_by(id: 2)

    assert_equal("EN TRÁNSITO", perfilmigracion.nombre)
  end
end
