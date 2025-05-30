# frozen_string_literal: true

require "test_helper"

module Msip
  class ControlAccesoPersonasControllerTest < ActionDispatch::IntegrationTest
    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      if ENV["CONFIG_HOSTS"] != "www.example.com"
        raise "CONFIG_HOSTS debe ser www.example.com"
      end

      @persona = Msip::Persona.create!(PRUEBA_PERSONA)
      @persona2 = Msip::Persona.create!(PRUEBA_PERSONA2)
      @caso = Sivel2Gen::Caso.create!(PRUEBA_CASO)
      @victima = Sivel2Gen::Victima.create!(persona_id: @persona2.id, caso_id: @caso.id)
    end

    # No autenticado
    ################

    test "sin autenticar no debe gestionar ni leer personas" do
      assert_raise CanCan::AccessDenied do
        get msip.personas_path
      end
    end

    test "sin autenticar no debe presentar una persona existente" do
      assert_raise CanCan::AccessDenied do
        get msip.persona_path(@persona.id)
      end
    end

    test "sin autenticar no debe ver formulario de nueva" do
      assert_raise CanCan::AccessDenied do
        get msip.new_persona_path
      end
    end

    test "sin autenticar no debe acceder a personas remplazar" do
      assert_raise CanCan::AccessDenied do
        get msip.personas_remplazar_path
      end
    end

    test "sin autenticar no debe crear" do
      assert_raise CanCan::AccessDenied do
        post msip.personas_path, params: {
          persona: {
            id: nil,
            nombres: "Luis Alejandro",
            apellidos: "Cruz Ordoñez",
            sexo: "M",
            numerodocumento: "",
          },
        }
      end
    end

    test "sin autenticar no debe editar" do
      assert_raise CanCan::AccessDenied do
        get msip.edit_persona_path(@persona.id)
      end
    end

    test "sin autenticar no debe actualizar" do
      assert_raise CanCan::AccessDenied do
        patch msip.persona_path(@persona.id)
      end
    end

    test "sin autenticar no debe eliminar" do
      assert_raise CanCan::AccessDenied do
        delete msip.persona_path(@persona.id)
      end
    end

    # Autenticado como operador sin grupo
    #####################################

    test "autenticado como operador sin grupo debe presentar listado" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get msip.personas_path

      assert_response :ok
    end

    test "autenticado como operador sin grupo debe presentar resumen" do
      skip
      current_usuario = Usuario.create!(PRUEBA_USUARIO_OP)
      sign_in current_usuario
      get msip.persona_path(@persona.id)

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

    test "autenticado como operador analista debe presentar listado" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      get msip.personas_path

      assert_response :ok
    end

    test "autenticado como operador analista debe presentar resumen" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      get msip.persona_path(@persona.id)

      assert_response :ok
    end

    test "autenticado como operador analista debería poder editar" do
      skip
      current_usuario = inicia_analista
      sign_in current_usuario
      get msip.edit_persona_path(@persona.id)

      assert_response :ok
    end
  end
end
