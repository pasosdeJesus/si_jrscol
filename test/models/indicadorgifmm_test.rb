# encoding: UTF-8

require 'test_helper'

class IndicadorgifmmTest < ActiveSupport::TestCase

  PRUEBA_INDICADORGIFMM = {
    nombre: "Indicadorgifmm",
    fechacreacion: "2020-07-12",
    created_at: "2020-07-12"
  }

  PRUEBA_SECTORGIFMM = {
    nombre: "Sectorgifmm",
    fechacreacion: "2020-07-12",
    created_at: "2020-07-12"
  }
  
  test "indicadorgifmm valido" do
    sectorgifmm = Sectorgifmm.create!(PRUEBA_SECTORGIFMM)
    indicadorgifmm = ::Indicadorgifmm.new(
      PRUEBA_INDICADORGIFMM)
    indicadorgifmm.sectorgifmm_id = sectorgifmm.id
    assert(indicadorgifmm.valid?)
    indicadorgifmm.destroy
    sectorgifmm.destroy
  end

  test "indicadorgifmm no valido" do
    indicadorgifmm = ::Indicadorgifmm.new(
      PRUEBA_INDICADORGIFMM)
    indicadorgifmm.nombre = ''
    assert_not(indicadorgifmm.valid?)
    indicadorgifmm.destroy
  end

end
