# frozen_string_literal: true

require_relative "../../test_helper"

module Sivel2Sjr
  class DeclaroanteTest < ActiveSupport::TestCase
    PRUEBA_DECLAROANTE = {
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11",
    }

    test "valido" do
      declaroante = Declaroante.create(PRUEBA_DECLAROANTE)

      assert declaroante.valid?
      declaroante.destroy
    end

    test "no valido" do
      declaroante = Declaroante.new(PRUEBA_DECLAROANTE)
      declaroante.nombre = ""

      assert_not declaroante.valid?
      declaroante.destroy
    end

    test "existente" do
      declaroante = Sivel2Sjr::Declaroante.find_by(id: 0)

      assert_equal "SIN INFORMACIÓN", declaroante.nombre
    end
  end
end
