require 'test_helper'

class DetallefinancieroPersonaTest < ActiveSupport::TestCase

  PRUEBA_DETALLEFINANCIEROPER = {
    persona_id: 1,
    detallefinanciero_id: 1
  }

  PRUEBA_DETALLEFINANCIERO = {
    id: 798,
    proyectofinanciero_id: nil,
    actividadpf_id: nil,
    unidadayuda_id: 9,
    cantidad: 2,
    valorunitario: 20000,
    valortotal: 40000,
    mecanismodeentrega_id: 3,
    modalidadentrega_id: 2,
    tipotransferencia_id: 2,
    frecuenciaentrega_id: 4,
    numeromeses: 3,
    numeroasistencia: 1,
    created_at: "2020-07-12",
    updated_at: "2020-07-12"
  }

  PRUEBA_ACTIVIDAD = {
    nombre:'n',
    fecha:'2017-03-02',
    oficina_id:1,
    usuario_id:1,
  }

  test "valido" do
    actividad = Cor1440Gen::Actividad.create!(PRUEBA_ACTIVIDAD)
    detallefinanciero = ::Detallefinanciero.new(
      PRUEBA_DETALLEFINANCIERO)
    debugger
    detallefinanciero.actividad_id = actividad.id
    assert(detallefinanciero.valid?)
    detallefinanciero.save
    p = Sip::Persona.take
    detallefinancieropersona = ::DetallefinancieroPersona.create({
      detallefinanciero_id: detallefinanciero.id,
      persona_id: p.id
    })
    debugger
    assert(detallefinancieropersona.valid?)

    detallefinancieropersona.destroy
    detallefinanciero.destroy
    actividad.destroy
  end


end
