require_relative '../../test_helper'

module Cor1440Gen
  class GastoaprobadoTest < ActiveSupport::TestCase
    PRUEBA_ACTIVIDAD = {
      nombre:'n',
      fecha:'2017-03-02',
      oficina_id:1,
      usuario_id:1,
    }

    setup do
      Rails.application.config.x.formato_fecha = 'yyyy-mm-dd'
    end

    test "valido" do

      assert_equal 1, Msip::Pais.where(id: 100).count
      pais = Msip::Pais.find(100)
      ubicacionpre = Msip::Ubicacionpre.create(PRUEBA_UBICACIONPRE2)

      assert_predicate ubicacionpre, :valid?
      assert_equal ubicacionpre.pais_id, pais.id

      a = Cor1440Gen::Actividad.new PRUEBA_ACTIVIDAD
      a.save(validate: false)

      ActividadProyectofinanciero.create(
        actividad_id: a.id,
        proyectofinanciero_id: 10 # PLAN ESTRATEGICO 1
      ) 
      ActividadActividadpf.create(
        actividad_id: a.id,
        actividadpf_id: 116 # ASISTENCIA HUMANITARIA
      )
      ap = ActividadProyecto.create!(
        actividad_id: a.id,
        proyecto_id: 101 # ACCIÓN HUMANITARIA
      )
      assert_predicate ap, :valid?

      a.ubicacionpre_id = ubicacionpre.id
      a.resultado = "res"
      assert a.valid?

      gastoaprobado = Cor1440Gen::Gastoaprobado.create(
        actividad_id: a.id,
        actividadpf_id: 116,
        valor: 10
      )
      assert gastoaprobado.valid?

      gastoaprobado.destroy
      a.destroy
    end

    test "no valido" do
      gastoaprobado = Cor1440Gen::Gastoaprobado.new 
      assert_not gastoaprobado.valid?
    end

  end
end
