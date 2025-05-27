# frozen_string_literal: true

require "test_helper"

require "test_helper"

module Msip
  class TipoorgsocialTest < ActiveSupport::TestCase
    test "valido" do
      tipoorgsocial = Msip::Tipoorgsocial.create(
        PRUEBA_TIPOORGSOCIAL,
      )

      assert(tipoorgsocial.valid?)
      tipoorgsocial.destroy
    end

    test "no valido" do
      tipoorgsocial = Msip::Tipoorgsocial.new(
        PRUEBA_TIPOORGSOCIAL,
      )
      tipoorgsocial.nombre = ""

      assert_not(tipoorgsocial.valid?)
      tipoorgsocial.destroy
    end

    test "existente" do
      skip
      tipoorgsocial = Msip::Tipoorgsocial.find_by(id: 0)

      assert_equal("SIN INFORMACIÓN", tipoorgsocial.nombre)
    end
  end
end
