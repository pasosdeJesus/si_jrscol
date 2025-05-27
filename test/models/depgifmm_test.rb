# frozen_string_literal: true

require "test_helper"

class DepgifmmTest < ActiveSupport::TestCase
  PRUEBA_DEPGIFMM = {
    nombre: "Depgifmm",
    fechacreacion: "2021-11-04",
    created_at: "2021-11-04",
  }

  test "valido" do
    depgifmm = ::Depgifmm.create(
      PRUEBA_DEPGIFMM,
    )

    assert(depgifmm.valid?)
    depgifmm.destroy
  end

  test "no valido" do
    depgifmm = ::Depgifmm.new(
      PRUEBA_DEPGIFMM,
    )
    depgifmm.nombre = ""

    assert_not(depgifmm.valid?)
    depgifmm.destroy
  end
end
