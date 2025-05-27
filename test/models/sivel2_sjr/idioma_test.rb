# frozen_string_literal: true

require_relative "../../test_helper"

module Sivel2Sjr
  class IdiomaTest < ActiveSupport::TestCase
    PRUEBA_IDIOMA = {
      id: 10000,
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11",
    }

    test "valido" do
      idioma = Idioma.create(PRUEBA_IDIOMA)

      assert idioma.valid?
      idioma.destroy
    end

    test "no valido" do
      idioma = Idioma.new(PRUEBA_IDIOMA)
      idioma.nombre = ""

      assert_not idioma.valid?
      idioma.destroy
    end

    test "existente" do
      idioma = Idioma.find_by(id: 0)

      assert_equal "SIN INFORMACIÓN", idioma.nombre
    end
  end
end
