require 'test_helper'

class ActoninoTest < ActiveSupport::TestCase

  test "valido" do
    caso = Sivel2Gen::Caso.create(PRUEBA_CASO) # 2021
    assert caso.valid?
    persona= Msip::Persona.create(PRUEBA_PERSONA2.merge( # 1988
      { anionac: 2018 }
    ))
    #puts persona.valid?
    #puts persona.errors.full_messages.join('. ')
    assert persona.valid?
    victima= Sivel2Gen::Victima.create({
      caso_id: caso.id,
      persona_id: persona.id
    })
    assert victima.valid?
    casosjr = Sivel2Sjr::Casosjr.create(PRUEBA_CASOSJR.merge(
      {caso_id: caso.id, contacto_id: persona.id}
    ))
    assert casosjr.valid?

    assert_equal 1, Msip::Pais.where(id: 100).count
    pais = Msip::Pais.find(100)
    ubicacionpre = Msip::Ubicacionpre.create(PRUEBA_UBICACIONPRE2)
    assert_predicate ubicacionpre, :valid?
    assert_equal ubicacionpre.pais_id, pais.id
    assert ubicacionpre.valid?

    actonino = ::Actonino.new(PRUEBA_ACTONINO.merge({
      caso_id: caso.id, 
      persona_id: persona.id,
      ubicacionpre_id: ubicacionpre.id
    }))
    assert actonino.valid?
    actonino.destroy
    ubicacionpre.destroy
    casosjr.destroy
    victima.destroy
    persona.destroy
    caso.destroy
  end

  test "no valido" do
    actonino = ::Actonino.new PRUEBA_ACTONINO
    actonino.persona_id = 0
    assert_not actonino.valid?
    actonino.destroy
  end

end
