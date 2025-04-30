require "test_helper"

class ExtracompletocasosTest < ActionDispatch::IntegrationTest


  self.use_transactional_tests = false
  # Buscando evitar el error:
  # ActiveRecord::StatementInvalid: PG::InFailedSqlTransaction: ERROR:  current
  # transaction is aborted, commands ignored until end of transaction block
  #
  # El compromiso es que la prueba elimine los datos que cree

  include Devise::Test::IntegrationHelpers

  setup do
    Rails.application.try(:reload_routes_unless_loaded)
    @current_usuario = Usuario.find_by(nusuario: 'sjrcol')
    @current_usuario.password = 'sjrcol123'
    sign_in @current_usuario
    get root_path
    assert_response :success
  end

  PRUEBA_CASO1 = {
    fecha: '2021-06-05',
    memo: 'La descripción',
    created_at: '2021-06-05',
  }

  test "extracompleto sin job" do
    get sivel2_gen.casos_path
    assert_response :success
    caso = Sivel2Gen::Caso.create! PRUEBA_CASO1
    numdoc=1
    while Msip::Persona.where(numerodocumento: numdoc).count > 0 do
      numdoc +=1
    end
    persona = Msip::Persona.create! PRUEBA_PERSONA.merge(numerodocumento: numdoc)
    Sivel2Gen::Victima.create!(
      caso_id: caso.id, persona_id: persona.id)
    casosjr = Sivel2Sjr::Casosjr.create PRUEBA_CASOSJR
    casosjr.caso_id=caso.id
    casosjr.contacto_id=persona.id
    casosjr.asesor=@current_usuario.id
    casosjr.save!
    Sivel2Gen::Conscaso::refresca_conscaso
    get sivel2_gen.casos_path
    assert_response :success
    assert_operator css_select('span[id=numconscaso]').text.to_i, :>, 0

    ruta="/casos.ods?utf8=%E2%9C%93"\
      "&filtro[codigo]=#{caso.id}"\
      "&idplantilla=44"\
      "&formato=ods"\
      "&formatosalida=ods"\
      "&commit=Enviar"
    get ruta
    assert_response :redirect
    a = flash["notice"][/\/generados\/listado_extracompleto_de_casos-([0-9][0-9]*).ods/]
    assert !a.nil?
    ruta = Rails.configuration.x.heb412_ruta.join(a.sub(/^\//,'') + "-0")
    assert File.exist?(ruta)
  end

end
