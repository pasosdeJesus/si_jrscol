# frozen_string_literal: true

require "test_helper"

module Msip
  class ControlAccesoCentrospobladosControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end
    end

    # No autenticado
    ################

    test "sin autenticar debe acceder a tipocentropoblado" do
      get msip.tipocentropoblado_path + ".json?term=#{Msip::Centropoblado.all.sample.id}"

      assert_response :ok
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe acceder a tipocentropoblado" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get msip.tipocentropoblado_path + ".json?term=#{Msip::Centropoblado.all.sample.id}"

      assert_response :ok
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_ope(rol_id)
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.grupo_ids = [rol_id]
      current_usuario.save
      current_usuario
    end

    test "autenticado como operador analista debe acceder a tipocentropoblado" do
      skip
      current_usuario = inicia_ope(20)
      sign_in current_usuario
      get msip.tipocentropoblado_path + ".json?term=#{Msip::Centropoblado.all.sample.id}"

      assert_response :ok
    end

    # Autenticado como obeservador de casos
    #######################################################

    test "autenticado como observador debe acceder a tipocentropoblado" do
      skip
      current_usuario = inicia_ope(21)
      sign_in current_usuario
      get msip.tipocentropoblado_path + ".json?term=#{Msip::Centropoblado.all.sample.id}"

      assert_response :ok
    end
  end
end
