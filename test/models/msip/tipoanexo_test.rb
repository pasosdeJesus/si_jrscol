# frozen_string_literal: true

require "test_helper"

module Msip
  class TipoanexoTest < ActiveSupport::TestCase
    PRUEBA_TIPOANEXO = {
      nombre: "Tipoanexo",
      fechacreacion: "2018-10-25",
      created_at: "2018-10-25",
    }

    test "valido" do
      tipoanexo = Msip::Tipoanexo.create(
        PRUEBA_TIPOANEXO,
      )

      assert(tipoanexo.valid?)
      tipoanexo.destroy
    end

    test "no valido" do
      tipoanexo = Msip::Tipoanexo.new(
        PRUEBA_TIPOANEXO,
      )
      tipoanexo.nombre = ""

      assert_not(tipoanexo.valid?)
      tipoanexo.destroy
    end
  end
end
