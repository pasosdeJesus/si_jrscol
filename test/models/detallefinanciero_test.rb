require 'test_helper'

class DetallefinancieroTest < ActiveSupport::TestCase

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

  test "detallefinanciero valido" do
    actividad = Cor1440Gen::Actividad.create!(PRUEBA_ACTIVIDAD)
    detallefinanciero = ::Detallefinanciero.new(
      PRUEBA_DETALLEFINANCIERO)
    detallefinanciero.actividad_id = actividad.id
    assert(detallefinanciero.valid?)
    detallefinanciero.destroy
    actividad.destroy
  end

  test "detallefinanciero no valido" do
    detallefinanciero = ::Detallefinanciero.new(
      PRUEBA_DETALLEFINANCIERO)
    detallefinanciero.cantidad = -5
    assert_not(detallefinanciero.valid?)
    detallefinanciero.destroy
  end

end
