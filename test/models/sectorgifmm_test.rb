# encoding: UTF-8

require 'test_helper'

class SectorgifmmTest < ActiveSupport::TestCase

  PRUEBA_SECTORGIFMM = {
    nombre: "Sectorgifmm",
    fechacreacion: "2020-07-12",
    created_at: "2020-07-12"
  }

  test "valido" do
    sectorgifmm = ::Sectorgifmm.create(
      PRUEBA_SECTORGIFMM)
    assert(sectorgifmm.valid?)
    sectorgifmm.destroy
  end

  test "no valido" do
    sectorgifmm = ::Sectorgifmm.new(
      PRUEBA_SECTORGIFMM)
    sectorgifmm.nombre = ''
    assert_not(sectorgifmm.valid?)
    sectorgifmm.destroy
  end

  test "existente" do
    sectorgifmm = ::Sectorgifmm.where(id: 1).take
    assert_equal(sectorgifmm.nombre, "Agua y saneamiento")
  end

end
