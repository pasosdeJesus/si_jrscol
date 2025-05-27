# frozen_string_literal: true

require "test_helper"

class TerritorialTest < ActiveSupport::TestCase
  PRUEBA_TERRITORIAL = {
    nombre: "Territorial",
    fechacreacion: "2018-10-25",
    created_at: "2018-10-25",
  }

  test "valido" do
    territorial = ::Territorial.create(
      PRUEBA_TERRITORIAL,
    )

    assert(territorial.valid?)
    territorial.destroy
  end

  test "no valido" do
    territorial = ::Territorial.new(
      PRUEBA_TERRITORIAL,
    )
    territorial.nombre = ""

    assert_not(territorial.valid?)
    territorial.destroy
  end

  test "existente" do
    territorial = ::Territorial.find_by(id: 1)

    assert_equal("SIN INFORMACIÓN", territorial.nombre)
  end
end
