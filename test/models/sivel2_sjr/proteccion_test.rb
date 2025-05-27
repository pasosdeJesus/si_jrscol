# frozen_string_literal: true

require_relative "../../test_helper"

module Sivel2Sjr
  class ProteccionTest < ActiveSupport::TestCase
    PRUEBA_PROTECCION = {
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11",
    }

    test "valido" do
      proteccion = Proteccion.create(PRUEBA_PROTECCION)

      assert proteccion.valid?
      proteccion.destroy
    end

    test "no valido" do
      proteccion = Proteccion.new(PRUEBA_PROTECCION)
      proteccion.nombre = ""

      assert_not proteccion.valid?
      proteccion.destroy
    end

    test "existente" do
      proteccion = Proteccion.find_by(id: 0)

      assert_equal "SIN INFORMACIÓN", proteccion.nombre
    end
  end
end
