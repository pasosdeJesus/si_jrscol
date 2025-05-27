# frozen_string_literal: true

require_relative "../../test_helper"

module Sivel2Sjr
  class AcreditacionTest < ActiveSupport::TestCase
    PRUEBA_ACREDITACION = {
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11",
    }

    test "valido" do
      acreditacion = Acreditacion.create(PRUEBA_ACREDITACION)

      assert acreditacion.valid?
      acreditacion.destroy
    end

    test "no valido" do
      acreditacion = Acreditacion.create(PRUEBA_ACREDITACION)
      acreditacion.nombre = ""

      assert_not acreditacion.valid?
      acreditacion.destroy
    end

    test "existente" do
      acreditacion = Sivel2Sjr::Acreditacion.find_by(id: 0)

      assert_equal "SIN INFORMACIÓN", acreditacion.nombre
    end
  end
end
