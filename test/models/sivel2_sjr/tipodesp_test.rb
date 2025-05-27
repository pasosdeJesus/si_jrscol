# frozen_string_literal: true

require_relative "../../test_helper"

module Sivel2Sjr
  class TipodespTest < ActiveSupport::TestCase
    PRUEBA_TIPODESP = {
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11",
    }

    test "valido" do
      tipodesp = Tipodesp.create(PRUEBA_TIPODESP)

      assert tipodesp.valid?
      tipodesp.destroy
    end

    test "no valido" do
      tipodesp = Tipodesp.new(PRUEBA_TIPODESP)
      tipodesp.nombre = ""

      assert_not tipodesp.valid?
      tipodesp.destroy
    end

    test "existente" do
      tipodesp = Tipodesp.find_by(id: 0)

      assert_equal "SIN INFORMACIÓN", tipodesp.nombre
    end
  end
end
