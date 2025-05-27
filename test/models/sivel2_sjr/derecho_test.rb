# frozen_string_literal: true

require_relative "../../test_helper"

module Sivel2Sjr
  class DerechoTest < ActiveSupport::TestCase
    PRUEBA_DERECHO = {
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11",
    }

    test "valido" do
      derecho = Derecho.create(PRUEBA_DERECHO)

      assert derecho.valid?
      derecho.destroy
    end

    test "no valido" do
      derecho = Derecho.new(PRUEBA_DERECHO)
      derecho.nombre = ""

      assert_not derecho.valid?
      derecho.destroy
    end

    test "existente" do
      derecho = Derecho.find_by(id: 1)

      assert_equal "DERECHO A LA INTEGRIDAD PERSONAL", derecho.nombre
    end
  end
end
