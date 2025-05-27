# frozen_string_literal: true

require "test_helper"

class EspaciopartTest < ActiveSupport::TestCase
  PRUEBA_ESPACIOPART = {
    id: 100,
    nombre: "Espaciopart",
    fechacreacion: "2018-11-26",
    created_at: "2018-11-26",
  }

  test "valido" do
    espaciopart = ::Espaciopart.create(
      PRUEBA_ESPACIOPART,
    )

    assert(espaciopart.valid?)
    espaciopart.destroy
  end

  test "no valido" do
    espaciopart = ::Espaciopart.new(
      PRUEBA_ESPACIOPART,
    )
    espaciopart.nombre = ""

    assert_not(espaciopart.valid?)
    espaciopart.destroy
  end

  test "existente" do
    espaciopart = ::Espaciopart.find_by(id: 1)

    assert_equal("JUNTA DE ACCIÓN COMUNAL", espaciopart.nombre)
  end
end
