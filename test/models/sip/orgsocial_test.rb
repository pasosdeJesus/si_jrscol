require 'test_helper'

module Sip
  class OrgsocialTest < ActiveSupport::TestCase

    setup do
      @grupoper = Sip::Grupoper.create!(PRUEBA_GRUPOPER)
    end

    test "valido" do
      tipoorgsocial = Sip::Tipoorgsocial.create(
        PRUEBA_TIPOORGSOCIAL)
      assert(tipoorgsocial.valid?)
      orgsocial = Sip::Orgsocial.create(
        PRUEBA_ORGSOCIAL)
      assert(orgsocial.valid?)
      orgsocial.destroy
    end
  
    test "no valido por grupoper nulo" do
      orgsocial = Sip::Orgsocial.new(
        PRUEBA_ORGSOCIAL)
      orgsocial.grupoper_id = nil
      assert_not(orgsocial.valid?)
      orgsocial.destroy
    end

    test "no valido por tipo orgsocial requerido" do
      orgsocial = Sip::Orgsocial.new(
        PRUEBA_ORGSOCIAL)
      orgsocial.tipoorgsocial_id = nil
      assert_not(orgsocial.valid?)
      orgsocial.destroy
    end
  end
end
