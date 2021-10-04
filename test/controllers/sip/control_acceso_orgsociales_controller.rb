require 'test_helper'

module Sip
  class ControlAccesoOrgsocialesControllerTest < ActionDispatch::IntegrationTest

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup  do
      if ENV['CONFIG_HOSTS'] != 'www.example.com'
        raise 'CONFIG_HOSTS debe ser www.example.com'
      end
      @gupoper = Sip::Grupoper.create!(PRUEBA_GRUPOPER)
      @orgsocial = Sip::Orgsocial.create!(PRUEBA_ORGSOCIAL)
    end

    # No autenticado
    ################

    test "sin autenticar no debe presentar listado" do
      assert_raise CanCan::AccessDenied do
        get sip.orgsociales_path
      end
    end

    test "sin autenticar no debe presentar resumen de existente" do
      assert_raise CanCan::AccessDenied do
        get sip.orgsocial_path(@orgsocial.id)
      end
    end

    test "sin autenticar no debe ver formulario de nuevo" do
      assert_raise CanCan::AccessDenied do
        get sip.new_orgsocial_path()
      end
    end

    test "sin autenticar no debe crear" do
      assert_raise CanCan::AccessDenied do
        post sip.orgsociales_path, params: { 
          orgsocial: { 
            id: nil,
            grupoper_attributes: {
              id: nil,
              nombre: 'ZZ'
            }
          }
        }
      end
    end


    test "sin autenticar no debe editar" do
      assert_raise CanCan::AccessDenied do
        get sip.edit_orgsocial_path(@orgsocial.id)
      end
    end

    test "sin autenticar no debe actualizar" do
      assert_raise CanCan::AccessDenied do
        patch sip.orgsocial_path(@orgsocial.id)
      end
    end

    test "sin autenticar no debe eliminar" do
      assert_raise CanCan::AccessDenied do
        delete sip.orgsocial_path(@orgsocial.id)
      end
    end

    # Autenticado como analista
    ###########################

    test "autenticado como analista debe presentar listado" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_ANALI)
      sign_in current_usuario
      get sip.orgsociales_path
      assert_response :ok
    end

    test "autenticado como analista debe presentar resumen" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_ANALI)
      sign_in current_usuario
      get sip.orgsocial_path(@orgsocial.id)
      assert_response :ok
    end

    test "autenticado como analista no debe poder editar" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_ANALI)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sip.edit_orgsocial_path(@orgsocial.id)
      end
    end

    test "autenticado como analista no debe eliminar" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_ANALI)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete sip.orgsocial_path(@orgsocial.id)
      end
    end

    # Autenticado como sistematizador
    #################################

    test "autenticado como sistematizador debe presentar listado" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_SIST)
      sign_in current_usuario
      get sip.orgsociales_path
      assert_response :ok
    end

    test "autenticado como sistematizador debe presentar resumen" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_SIST)
      sign_in current_usuario
      get sip.orgsocial_path(@orgsocial.id)
      assert_response :ok
    end

    test "autenticado como sistematizador debería poder editar" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_SIST)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sip.edit_orgsocial_path(@orgsocial.id)
      end
    end

    test "autenticado como sistematizador no debe eliminar" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_SIST)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete sip.orgsocial_path(@orgsocial.id)
      end
    end

    # Autenticado como analista de prensa
    #####################################

    test "autenticado como analista de prensa no puede ver listado" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sip.orgsociales_path
      end
    end

    test "autenticado como analista de prensa no puede ver resumen" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sip.orgsocial_path(@orgsocial.id)
      end
    end

    test "autenticado como analista de prensa no puede editar" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sip.edit_orgsocial_path(@orgsocial.id)
      end
    end

    test "autenticado como analista de prensa no puede eliminar" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_AP)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete sip.orgsocial_path(@orgsocial.id)
      end
    end

    # Autenticado como invitado
    #####################################

    test "autenticado como invitado no puede ver listado" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_INV)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sip.orgsociales_path
      end
    end

    test "autenticado como invitado no puede ver resumen" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_INV)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sip.orgsocial_path(@orgsocial.id)
      end
    end

    test "autenticado como invitado no puede editar" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_INV)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        get sip.edit_orgsocial_path(@orgsocial.id)
      end
    end

    test "autenticado como invitado no puede eliminar" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_INV)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete sip.orgsocial_path(@orgsocial.id)
      end
    end

    # Autenticado como coordinador
    #####################################

    test "autenticado como coordinador no puede ver listado" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_COORD)
      sign_in current_usuario
      get sip.orgsociales_path
      assert_response :ok
    end

    test "autenticado como coordinador no puede ver resumen" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_COORD)
      sign_in current_usuario
      get sip.orgsocial_path(@orgsocial.id)
      assert_response :ok
    end

    test "autenticado como coordinador puede editar" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_COORD)
      sign_in current_usuario
      get sip.edit_orgsocial_path(@orgsocial.id)
      assert_response :ok
    end

    test "autenticado como coordinador no puede eliminar" do
      current_usuario = Usuario.create!(PRUEBA_USUARIO_COORD)
      sign_in current_usuario
      assert_raise CanCan::AccessDenied do
        delete sip.orgsocial_path(@orgsocial.id)
      end
    end

  end
end
