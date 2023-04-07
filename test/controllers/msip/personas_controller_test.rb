# frozen_string_literal: true

require_relative '../../test_helper'

module Msip
  class PersonasControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
    end

#    PRUEBA_PERSONA = {
#      nombres: 'Nombres',
#      apellidos: 'Apellidos',
#      anionac: 1974,
#      mesnac: 1,
#      dianac: 1,
#      sexo: 'F',
#      pais_id: 170,
#      departamento_id: 17,
#      municipio_id: 1152,
#      clase_id: 2626,
#      tdocumento_id: 1,
#      numerodocumento: '123',
#      nacionalde: 170
#    }
#
    PRUEBA_PERSONA_SINDOC = {
      nombres: 'Nombres',
      apellidos: 'Apellidos',
      sexo: 'F',
      numerodocumento: ''
    }

    test 'Crea una persona y la elimina' do
      assert_difference('Msip::Persona.count') do
        post msip.personas_url, params: { persona: PRUEBA_PERSONA }
        #puts response.body
      end
      assert_redirected_to persona_url(Msip::Persona.last)
      assert_difference('Msip::Persona.count', -1) do
        delete msip.persona_url(Msip::Persona.last)
      end
    end

    test 'no debería crear beneficiario sin numero de documento' do
      assert_no_difference('Msip::Persona.count') do
        post msip.personas_url, params: { persona: PRUEBA_PERSONA.merge(
          numerodocumento: '',
          tdocumento_id: nil
        )}
      end
    end
  end
end
