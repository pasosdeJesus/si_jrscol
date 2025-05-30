# frozen_string_literal: true

require "test_helper"

module Msip
  class ControlAccesoGruposperControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @grupoper = Msip::Grupoper.create!(PRUEBA_GRUPOPER)
      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
      @vicol = Sivel2Gen::Victimacolectiva.create!(
        grupoper_id: @grupoper.id,
        caso_id: @caso.id,
      )
      @vicol.save!
      @tipoorgsocial = Msip::Tipoorgsocial.create!(PRUEBA_TIPOORGSOCIAL)
      @orgsocial = Msip::Orgsocial.create!(PRUEBA_ORGSOCIAL)
    end

    # No autenticado
    ################

    test "sin autenticar no debe acceder a grupos de beneficiarios" do
      assert_raise CanCan::AccessDenied do
        get msip.gruposper_path + '?term="Cauca"'
      end
    end

    test "sin autenticar no debe acceder a grupos de beneficiarios reemplazar" do
      assert_raise CanCan::AccessDenied do
        get msip.gruposper_remplazar_path + "?grupoper_id=#{@grupoper.id}&victima_idcolectiva=#{@vicol.id}"
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar gruposper remplazar" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get msip.gruposper_remplazar_path + "?grupoper_id=#{@grupoper.id}&victima_idcolectiva=#{@vicol.id}"
      end
    end

    def inicia_ope(rol_id)
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AN)
      current_usuario.grupo_ids = [rol_id]
      current_usuario.save
      current_usuario
    end
  end
end
