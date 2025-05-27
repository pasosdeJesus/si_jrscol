# frozen_string_literal: true

require_relative "../../test_helper"

module Sivel2Sjr
  class ProgestadoTest < ActiveSupport::TestCase
    PRUEBA_PROGESTADO = {
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11",
    }

    test "valido" do
      progestado = Progestado.create(PRUEBA_PROGESTADO)

      assert progestado.valid?
      progestado.destroy
    end

    test "no valido" do
      progestado = Progestado.new(PRUEBA_PROGESTADO)
      progestado.nombre = ""

      assert_not progestado.valid?
      progestado.destroy
    end

    test "existente" do
      progestado = Progestado.find_by(id: 0)

      assert_equal "SIN INFORMACIÓN", progestado.nombre
    end
  end
end
