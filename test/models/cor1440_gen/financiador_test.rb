# frozen_string_literal: true

require "test_helper"

module Cor1440Gen
  class Cor1440GenFinanciadorTest < ActiveSupport::TestCase
    setup do
      Rails.application.config.x.formato_fecha = "yyyy-mm-dd"
    end

    test "valido" do
      f = Financiador.create(PRUEBA_FINANCIADOR)

      assert f.valid?
      f.destroy
    end

    test "no valido" do
      f = Financiador.new(PRUEBA_FINANCIADOR)
      f.nombre = ""

      assert_not f.valid?
      f.destroy
    end
  end
end
