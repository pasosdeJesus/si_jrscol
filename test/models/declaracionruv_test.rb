# frozen_string_literal: true

require "test_helper"

class DeclaracionruvTest < ActiveSupport::TestCase
  PRUEBA_DECLARACIONRUV = {
    nombre: "Declaracionruv",
    fechacreacion: "2020-07-12",
    created_at: "2020-07-12",
  }

  test "declaracionruv valido" do
    declaracionruv = ::Declaracionruv.create(
      PRUEBA_DECLARACIONRUV,
    )

    assert(declaracionruv.valid?)
    declaracionruv.destroy
  end

  test "declaracionruv no valido" do
    declaracionruv = ::Declaracionruv.new(
      PRUEBA_DECLARACIONRUV,
    )
    declaracionruv.nombre = ""

    assert_not(declaracionruv.valid?)
    declaracionruv.destroy
  end
end
