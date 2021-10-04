require 'test_helper'
require_relative '../../../models/sip/anexo_test'

module Sip
  module Admin

    class AnexosControllerTest < ActionController::TestCase
      include Engine.routes.url_helpers
      include Devise::Test::ControllerHelpers
      include Rails.application.routes.url_helpers


      setup do
        @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
        sign_in @current_usuario
        @anexo = Sip::Anexo.create(
          Sip::AnexoTest::PRUEBA_ANEXO)
        @controller = Sip::AnexosController.new 
      end

      test "should create anexo" do
        assert_difference('Anexo.count') do
        anexo = Sip::Anexo.create(
          Sip::AnexoTest::PRUEBA_ANEXO)
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
