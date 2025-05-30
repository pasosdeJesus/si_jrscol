# frozen_string_literal: true

require "test_helper"

module Msip
  class ClaverespaldoTest < ActiveSupport::TestCase
    PRUEBA_CLAVERESPALDO = {
      clave: "Unaclave",
      created_at: "2018-10-25",
      updated_at: "2018-10-25",
    }

    test "valido" do
      claverespaldo = Msip::Claverespaldo.create(
        PRUEBA_CLAVERESPALDO,
      )

      assert(claverespaldo.valid?)
      claverespaldo.destroy
    end

    test "no valido por clave nula" do
      claverespaldo = Msip::Claverespaldo.new(
        PRUEBA_CLAVERESPALDO,
      )
      claverespaldo.clave = nil

      assert_not(claverespaldo.valid?)
      claverespaldo.destroy
    end

    test "no valido por created_at nula" do
      claverespaldo = Msip::Claverespaldo.new(
        PRUEBA_CLAVERESPALDO,
      )
      claverespaldo.created_at = nil

      assert_not(claverespaldo.valid?)
      claverespaldo.destroy
    end

    test "no valido por simbolo no permitido" do
      claverespaldo = Msip::Claverespaldo.new(
        PRUEBA_CLAVERESPALDO,
      )
      claverespaldo.clave = "alejo cruz."

      assert_not(claverespaldo.valid?)
      claverespaldo.destroy
    end
  end
end
