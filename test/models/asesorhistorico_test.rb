require 'test_helper'

class AsesorhistoricoTest < ActiveSupport::TestCase


    PRUEBA_CASO= {
      titulo: "ejemplo",
      fecha: "2021-04-14",
      memo: "Desplazamiento",
      created_at: "2021-04-14",
    }

    PRUEBA_PERSONA = {
      nombres: "Juan",
      apellidos: "Perez",
      sexo: 'M',
      anionac: 1980,
      id_pais: 170,
      tdocumento_id: 1,
      numerodocumento: 4,
      created_at: "2021-04-14",
    }

    PRUEBA_CASOSJR = {
      id_caso: 0, # por llenar
      contacto_id: 0, # por llenar
      fecharec: "2021-04-14",
      asesor: 1,
      created_at: "2021-04-14",
    }
    
  PRUEBA_ASESORHISTORICO = {
    casosjr_id: 1,
    usuario_id: 1,
    fechainicio: '2022-06-22',
    fechafin: '2022-06-23'
  }

  test "valido" do
    caso = Sivel2Gen::Caso.create(PRUEBA_CASO)
    assert caso.valid?
    persona= Sip::Persona.create(PRUEBA_PERSONA)
    #puts persona.valid?
    #puts persona.errors.full_messages.join('. ')
    assert persona.valid?
    victima= Sivel2Gen::Victima.create({
      id_caso: caso.id,
      id_persona: persona.id
    })
    assert victima.valid?
    casosjr = Sivel2Sjr::Casosjr.create(PRUEBA_CASOSJR.merge(
      {id_caso: caso.id, contacto_id: persona.id}))
    assert casosjr.valid?
    asesorhistorico = ::Asesorhistorico.new(PRUEBA_ASESORHISTORICO)
    asesorhistorico.casosjr_id=casosjr.id_caso
    assert asesorhistorico.valid?
    asesorhistorico.destroy
  end

  test "no valido" do
    asesorhistorico = ::Asesorhistorico.new PRUEBA_ASESORHISTORICO
    asesorhistorico.usuario_id = 0
    assert_not asesorhistorico.valid?
    asesorhistorico.destroy
  end

end
