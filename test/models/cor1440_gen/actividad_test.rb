require_relative '../../test_helper'

module Cor1440Gen
  class ActividadTest < ActiveSupport::TestCase
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
      a = Cor1440Gen::Actividad.new PRUEBA_ACTIVIDAD
      a.save(validate: false)

      ActividadProyectofinanciero.create(
        actividad_id: a.id,
        financiador_id: 10 # PLAN ESTRATEGICO 1
      ) 
      ActividadAcitividadpf.create(
        actividad_id: a.id,
        actividadpf_id: 116 # ASISTENCIA HUMANITARIA
      )
      debugger
      assert a.valid?
      a.destroy
    end

    test "no valido" do
      a = Cor1440Gen::Actividad.new PRUEBA_ACTIVIDAD
      a.oficina_id=nil
      assert_not a.valid?
      a.destroy
    end

  end
end
