# frozen_string_literal: true

require "test_helper"

module Msip
  class FuenteprensaTest < ActiveSupport::TestCase
    PRUEBA_FUENTEPRENSA = {
      nombre: "Fuenteprensa",
      fechacreacion: "2018-10-25",
      created_at: "2018-10-25",
    }

    test "valido" do
      fuenteprensa = Msip::Fuenteprensa.create(
        PRUEBA_FUENTEPRENSA,
      )

      assert(fuenteprensa.valid?)
      fuenteprensa.destroy
    end

    test "no valido" do
      fuenteprensa = Msip::Fuenteprensa.new(
        PRUEBA_FUENTEPRENSA,
      )
      fuenteprensa.nombre = ""

      assert_not(fuenteprensa.valid?)
      fuenteprensa.destroy
    end
  end
end
