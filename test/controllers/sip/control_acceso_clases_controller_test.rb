require 'test_helper'

module Sip
  class ControlAccesoClasesControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
    end

    # No autenticado
    ################

    test "sin autenticar debe acceder a tipoclase" do
      get sip.tipoclase_path + ".json?term=#{Sip::Clase.all.sample.id}"
      assert_response :ok
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe acceder a tipoclase" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get sip.tipoclase_path + ".json?term=#{Sip::Clase.all.sample.id}"
      assert_response :ok
    end

    # Autenticado como operador con grupo Analista de Casos
    #######################################################

    def inicia_ope(rol_id)
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.sip_grupo_ids = [rol_id]
      current_usuario.save
      return current_usuario
    end

    test "autenticado como operador analista debe acceder a tipoclase" do
      skip
      current_usuario = inicia_ope(20)
      sign_in current_usuario
      get sip.tipoclase_path + ".json?term=#{Sip::Clase.all.sample.id}"
      assert_response :ok
    end

    # Autenticado como obeservador de casos
    #######################################################

    test "autenticado como observador debe acceder a tipoclase" do
      skip
      current_usuario = inicia_ope(21)
      sign_in current_usuario
      get sip.tipoclase_path + ".json?term=#{Sip::Clase.all.sample.id}"
      assert_response :ok
    end
  end
end
