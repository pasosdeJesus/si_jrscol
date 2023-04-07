require 'test_helper'

class AsesorhistoricoTest < ActiveSupport::TestCase

  test "valido" do
    caso = Sivel2Gen::Caso.create(PRUEBA_CASO)
    assert caso.valid?
    persona= Msip::Persona.create(PRUEBA_PERSONA)
    #puts persona.valid?
    #puts persona.errors.full_messages.join('. ')
    #debugger
    assert persona.valid?
    victima= Sivel2Gen::Victima.create({
      caso_id: caso.id,
      persona_id: persona.id
    })
    assert victima.valid?
    casosjr = Sivel2Sjr::Casosjr.create(PRUEBA_CASOSJR.merge(
      {caso_id: caso.id, contacto_id: persona.id}))
    assert casosjr.valid?
    asesorhistorico = ::Asesorhistorico.new(PRUEBA_ASESORHISTORICO)
    asesorhistorico.casosjr_id=casosjr.caso_id
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
