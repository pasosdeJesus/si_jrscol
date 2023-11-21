# frozen_string_literal: true

require_relative "../../test_helper"

module Msip
  class UbicacionTest < ActiveSupport::TestCase
    test "simple" do
      caso = Sivel2Gen::Caso.create(PRUEBA_CASO)

      pais = Pais.find(862)
      ubicacion = Ubicacion.create(PRUEBA_UBICACION.merge(
        caso_id: caso.id
      ))
      ubicacion.pais = pais

      assert_predicate ubicacion, :valid?
    end

    test "no valido" do
      caso = Sivel2Gen::Caso.create(PRUEBA_CASO)
      ubicacion = Ubicacion.create(PRUEBA_UBICACION.merge(
        caso_id: caso.id
      ))
      ubicacion.tsitio_id = nil

      assert_not ubicacion.valid?
    end

    test "no valido 2" do
      caso = Sivel2Gen::Caso.create(PRUEBA_CASO)
      ubicacion = Ubicacion.create(PRUEBA_UBICACION.merge(
        caso_id: caso.id
      ))
      ubicacion.pais_id = nil

      assert_not ubicacion.valid?
    end

    test "presenta_nombre" do
      caso = Sivel2Gen::Caso.create(PRUEBA_CASO)

      u = Ubicacion.create(PRUEBA_UBICACION.merge(
        caso_id: caso.id
      ))

      assert_equal "Venezuela / Distrito Capital / Bolivariano Libertador / Caracas",
        u.presenta_nombre
      assert_equal "Venezuela / Distrito Capital / Bolivariano Libertador",
        u.presenta_nombre({ sin_centropoblado: 1 })
      assert_equal "Venezuela / Distrito Capital",
        u.presenta_nombre({ sin_centropoblado: 1, sin_municipio: 1 })
      assert_equal "Venezuela",
        u.presenta_nombre({ sin_centropoblado: 1, sin_municipio: 1, sin_departamento: 1 })
      assert_equal "",
        u.presenta_nombre({
          sin_centropoblado: 1,
          sin_municipio: 1,
          sin_departamento: 1,
          sin_pais: 1,
        })
    end
  end
end
