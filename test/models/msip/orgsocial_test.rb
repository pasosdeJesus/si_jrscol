# frozen_string_literal: true

require "test_helper"

module Msip
  class OrgsocialTest < ActiveSupport::TestCase
    setup do
      @grupoper = Msip::Grupoper.create!(PRUEBA_GRUPOPER)
    end

    test "valido" do
      tipoorgsocial = Msip::Tipoorgsocial.create(
        PRUEBA_TIPOORGSOCIAL,
      )

      assert(tipoorgsocial.valid?)
      orgsocial = Msip::Orgsocial.create(
        PRUEBA_ORGSOCIAL,
      )

      assert(orgsocial.valid?)
      orgsocial.destroy
    end

    test "no valido por grupoper nulo" do
      orgsocial = Msip::Orgsocial.new(
        PRUEBA_ORGSOCIAL,
      )
      orgsocial.grupoper_id = nil

      assert_not(orgsocial.valid?)
      orgsocial.destroy
    end

    test "no valido por tipo orgsocial requerido" do
      orgsocial = Msip::Orgsocial.new(
        PRUEBA_ORGSOCIAL,
      )
      orgsocial.tipoorgsocial_id = nil

      assert_not(orgsocial.valid?)
      orgsocial.destroy
    end
  end
end
