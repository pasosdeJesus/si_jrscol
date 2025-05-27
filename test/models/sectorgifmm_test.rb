# encoding: utf-8
# frozen_string_literal: true

require "test_helper"

class SectorgifmmTest < ActiveSupport::TestCase
  PRUEBA_SECTORGIFMM = {
    nombre: "Sectorgifmm",
    fechacreacion: "2020-07-12",
    created_at: "2020-07-12",
  }

  test "valido" do
    sectorgifmm = ::Sectorgifmm.create(
      PRUEBA_SECTORGIFMM,
    )

    assert(sectorgifmm.valid?)
    sectorgifmm.destroy
  end

  test "no valido" do
    sectorgifmm = ::Sectorgifmm.new(
      PRUEBA_SECTORGIFMM,
    )
    sectorgifmm.nombre = ""

    assert_not(sectorgifmm.valid?)
    sectorgifmm.destroy
  end

  test "existente" do
    sectorgifmm = ::Sectorgifmm.find_by(id: 1)

    assert_equal("Agua y saneamiento", sectorgifmm.nombre)
  end
end
