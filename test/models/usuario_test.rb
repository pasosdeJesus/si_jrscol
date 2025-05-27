# frozen_string_literal: true

require "test_helper"

module Msip
  class UsuarioTest < ActiveSupport::TestCase
    test "valido" do
      usuario = Usuario.create(PRUEBA_USUARIO_ANALI.merge(territorial_id: 1))

      assert usuario.valid?
      assert_equal 1, usuario.territorial_id
      usuario.destroy
    end

    #      test "no valido" do
    #        territorial = ::Territorial.new(
    #          PRUEBA_TERRITORIAL)
    #        territorial.nombre = ''
    #        assert_not(territorial.valid?)
    #        territorial.destroy
    #      end
    #
    #      test "existente" do
    #        territorial = ::Territorial.where(id: 1).take
    #        debugger
    #        assert_equal(territorial.nombre, "SIN INFORMACIÓN")
    #      end
    #
  end
end
