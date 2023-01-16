require 'test_helper'

class DetallefinancieroTest < ActiveSupport::TestCase

  test "detallefinanciero valido" do
    pf = Cor1440Gen::Proyectofinanciero.create!(PRUEBA_PROYECTOFINANCIERO)
    assert(pf.valid?)

    objetivopf = Cor1440Gen::Objetivopf.create!(PRUEBA_OBJETIVOPF)
    assert(objetivopf.valid?)

    resultadopf = Cor1440Gen::Resultadopf.create!(PRUEBA_RESULTADOPF)
    assert(resultadopf.valid?)

    actividadpf = Cor1440Gen::Actividadpf.create!(PRUEBA_ACTIVIDADPF)
    assert(actividadpf.valid?)

    area = Cor1440Gen::Proyecto.create!(PRUEBA_AREA)
    assert(area.valid?)

    upre = Msip::Ubicacionpre.create!(PRUEBA_UBICACIONPRE)
    assert(upre.valid?)

    actividad = Cor1440Gen::Actividad.new(PRUEBA_ACTIVIDAD)
    actividad.ubicacionpre_id = upre.id
    actividad.save(validate: false)
    actividad.proyecto_ids = [area.id]
    actividad.proyectofinanciero_ids = [10, pf.id]
    actividad.actividadpf_ids = [116, actividadpf.id]
    actividad.save
    assert(actividad.valid?)

    detallefinanciero = ::Detallefinanciero.create!(PRUEBA_DETALLEFINANCIERO)
    assert(detallefinanciero.valid?)

    detallefinanciero.destroy
    actividadpf.destroy
    resultadopf.destroy
    objetivopf.destroy
    actividad.destroy
    pf.destroy
  end

  test "detallefinanciero no valido" do
    detallefinanciero = ::Detallefinanciero.new(
      PRUEBA_DETALLEFINANCIERO)
    detallefinanciero.cantidad = -5
    assert_not(detallefinanciero.valid?)
    detallefinanciero.destroy
  end

end
