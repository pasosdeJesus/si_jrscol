# frozen_string_literal: true

require_relative "../../test_helper"

module Sivel2Sjr
  class PersonadeseaTest < ActiveSupport::TestCase
    PRUEBA_PERSONADESEA = {
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11",
    }

    test "valido" do
      personadesea = Personadesea.create(PRUEBA_PERSONADESEA)

      assert personadesea.valid?
      personadesea.destroy
    end

    test "no valido" do
      personadesea = Personadesea.new(PRUEBA_PERSONADESEA)
      personadesea.nombre = ""

      assert_not personadesea.valid?
      personadesea.destroy
    end

    test "existente" do
      personadesea = Sivel2Sjr::Personadesea.find_by(id: 0)

      assert_equal "SIN INFORMACIÓN", personadesea.nombre
    end
  end
end
