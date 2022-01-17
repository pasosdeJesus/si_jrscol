require 'test_helper'

class DetallefinancieroPersonaTest < ActiveSupport::TestCase

  PRUEBA_DETALLEFINANCIEROPER = {
    persona_id: 1,
    detallefinanciero_id: 1
  }

  test "valido" do
    pf = Cor1440Gen::Proyectofinanciero.create!(PRUEBA_PROYECTOFINANCIERO)
    assert(pf.valid?)

    actividad = Cor1440Gen::Actividad.create!(PRUEBA_ACTIVIDAD)
    assert(actividad.valid?)

    objetivopf = Cor1440Gen::Objetivopf.create!(PRUEBA_OBJETIVOPF)
    assert(objetivopf.valid?)

    resultadopf = Cor1440Gen::Resultadopf.create!(PRUEBA_RESULTADOPF)
    assert(resultadopf.valid?)

    actividadpf = Cor1440Gen::Actividadpf.create!(PRUEBA_ACTIVIDADPF)
    assert(actividadpf.valid?)

    detallefinanciero = ::Detallefinanciero.create!(PRUEBA_DETALLEFINANCIERO)
    assert(detallefinanciero.valid?)

    p = Sip::Persona.create!(PRUEBA_PERSONA)
    assert(p.valid?)

    detallefinanciero.persona_ids = [p.id]
    detallefinanciero.save!
    
    assert_equal([detallefinanciero.id], p.detallefinanciero_ids)


    detallefinanciero.destroy
    actividadpf.destroy
    resultadopf.destroy
    objetivopf.destroy
    actividad.destroy
    pf.destroy
  end


end
