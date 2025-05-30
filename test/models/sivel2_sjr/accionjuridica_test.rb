# frozen_string_literal: true

require "test_helper"

module Sivel2Sjr
  class AccionjuridicaTest < ActiveSupport::TestCase
    PRUEBA_ACCIONJURIDICA = {
      nombre: "Accionjuridica",
      fechacreacion: "2016-12-02",
      created_at: "2016-12-02",
    }

    test "valido" do
      accionjuridica = Sivel2Sjr::Accionjuridica.create(PRUEBA_ACCIONJURIDICA)

      assert accionjuridica.valid?
      accionjuridica.destroy
    end

    test "no valido" do
      accionjuridica = Sivel2Sjr::Accionjuridica.new(PRUEBA_ACCIONJURIDICA)
      accionjuridica.nombre = ""

      assert_not accionjuridica.valid?
      accionjuridica.destroy
    end

    test "existente" do
      skip
      accionjuridica = Sivel2Sjr::Accionjuridica.find_by(id: 0)

      assert_equal "SIN INFORMACIÓN", accionjuridica.nombre
    end
  end
end
