# frozen_string_literal: true

require "test_helper"

module Msip
  class ControlAccesoOrgsocialesControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @caso = Sivel2Gen::Caso.create!(memo: "prueba", fecha: "2021-12-07")
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar ubicaciones/nuevo" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get msip.ubicaciones_nuevo_path

      assert_response :ok
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_analista
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.grupo_ids = [20]
      current_usuario.save
      current_usuario
    end

    test "autenticado como operador analista debe presentar ubi/nuevo" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      get msip.ubicaciones_nuevo_path

      assert_response :ok
    end
  end
end
