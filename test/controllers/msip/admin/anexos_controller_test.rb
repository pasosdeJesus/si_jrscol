require 'test_helper'
require_relative '../../../models/msip/anexo_test'

module Msip
  module Admin

    class AnexosControllerTest < ActionController::TestCase
      include Engine.routes.url_helpers
      include Devise::Test::ControllerHelpers
      include Rails.application.routes.url_helpers


      setup do
        @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
        sign_in @current_usuario
        @anexo = Msip::Anexo.create(
          Msip::AnexoTest::PRUEBA_ANEXO)
        @controller = Msip::AnexosController.new 
      end

      test "should create anexo" do
        assert_difference('Anexo.count') do
        anexo = Msip::Anexo.create(
          Msip::AnexoTest::PRUEBA_ANEXO)
        assert anexo.save
        end
      end

      test "should update anexo" do
        @anexo.descripcion= "descripcion actualizada",
        assert(@anexo.save)
      end

      test "should destroy anexo" do
        assert_difference('Anexo.count', -1) do
        anexo =  @anexo
        anexo.destroy!
        end
      end
    end

  end
end
