# frozen_string_literal: true

require_relative "../../test_helper"

module Sivel2Sjr
  class StatusmigratorioTest < ActiveSupport::TestCase
    PRUEBA_STATUSMIGRATORIO = {
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11",
    }

    test "valido" do
      statusmigratorio = Statusmigratorio.create(PRUEBA_STATUSMIGRATORIO)

      assert statusmigratorio.valid?
      statusmigratorio.destroy
    end

    test "no valido" do
      statusmigratorio = Statusmigratorio.new(PRUEBA_STATUSMIGRATORIO)
      statusmigratorio.nombre = ""

      assert_not statusmigratorio.valid?
      statusmigratorio.destroy
    end

    test "existente" do
      statusmigratorio = Sivel2Sjr::Statusmigratorio.find_by(id: 0)

      assert_equal "SIN INFORMACIÓN", statusmigratorio.nombre
    end
  end
end
