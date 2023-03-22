# frozen_string_literal: true

require "test_helper"
require "cor1440_gen/conteos_helper"

# Lo copiamos y moficamos de cor1440_gen porque en JRS-Col
# los rangos de edad en actividad son diferentes a los de Cor1440Gen
module Cor1440Gen
  class ConteosHelperTest < ActionView::TestCase
    include ConteosHelper


    setup do
      Rails.application.config.x.formato_fecha = "yyyy-mm-dd"
    end

    # Si hace falta instalamos calculo de poblacion automatico con PostgreSQL
    # Probamos agregar, modificar, eliminar asistentes en una actividad
    # Así como:
    # * Modificar la fecha de la actividad --que implica cambio en 
    #   rangos de edad de todos los asistentes.
    # * Modificar fecha de nacimiento de una persona --que implica calculo
    #   de rangos edad en todas las actividades donde esté.
    test "calculo de poblacion en PostgreSQL" do
      if !Msip::SqlHelper.existe_función_pg?('cor1440_gen_actividad_cambiada')
        instala_calculo_poblacion_pg
      end
      persona = Msip::Persona.create!(PRUEBA_PERSONA.merge(
        anionac: 2020,
        mesnac: 1,
        dianac: 1
      ))

      assert persona.valid?


      # Para crear actividad
      assert_equal 1, Msip::Pais.where(id: 100).count
      pais = Msip::Pais.find(100)
      ubicacionpre = Msip::Ubicacionpre.create(PRUEBA_UBICACIONPRE2)

      assert_predicate ubicacionpre, :valid?
      assert_equal ubicacionpre.pais_id, pais.id

      actividad = Cor1440Gen::Actividad.new PRUEBA_ACTIVIDAD.merge(
        fecha: '2027-02-01',
        ubicacionpre_id: ubicacionpre.id)
      actividad.save(validate: false)

      ActividadProyectofinanciero.create(
        actividad_id: actividad.id,
        proyectofinanciero_id: 10 # PLAN ESTRATEGICO 1
      ) 
      ActividadActividadpf.create(
        actividad_id: actividad.id,
        actividadpf_id: 116 # ASISTENCIA HUMANITARIA
      )
      ap = ActividadProyecto.create!(
        actividad_id: actividad.id,
        proyecto_id: 101 # ACCIÓN HUMANITARIA
      )
      assert_predicate ap, :valid?

      actividad.ubicacionpre_id = ubicacionpre.id
      actividad.resultado = "res"

      assert actividad.valid?


      assert_equal 0, ActividadRangoedadac.where(
        actividad_id: actividad.id).count

      asistencia = Asistencia.create(
        actividad_id: actividad.id,
        persona_id: persona.id,
        perfilorgsocial_id: 1
      )
      assert_predicate asistencia, :valid?
      assert_equal([2], asistencia.actividad.rangoedadac_ids) # 6 a 12

      actividad.fecha = '2036-01-13'
      actividad.save
      actividad.reload
      asistencia.reload
      assert_predicate asistencia, :valid?
      assert_equal([3], actividad.rangoedadac_ids) # 13 a 17

      actividad.fecha = '2044-01-13'
      actividad.save
      actividad.reload
      asistencia.reload
      assert_predicate asistencia, :valid?
      assert_equal([4], actividad.rangoedadac_ids) # 18 a 26

      actividad.fecha = '2050-01-13'
      actividad.save
      actividad.reload
      asistencia.reload
      assert_predicate asistencia, :valid?
      assert_equal([5], actividad.rangoedadac_ids) # 27 a 59

      actividad.fecha = '2080-01-13'
      actividad.save
      actividad.reload
      asistencia.reload
      assert_predicate asistencia, :valid?
      assert_equal([6], actividad.rangoedadac_ids) # 60 en adelante


      persona.anionac = 2023;
      persona.save
      persona.reload
      actividad.fecha = '2024-01-13'
      actividad.save
      actividad.reload
      asistencia.reload
      assert_predicate asistencia, :valid?
      assert_equal([1], actividad.rangoedadac_ids) # 0 a 5

      persona.anionac = nil; 
      persona.save
      persona.reload
      actividad.reload
      asistencia.reload
      assert_predicate asistencia, :valid?
      assert_equal([7], actividad.rangoedadac_ids) # SIN INFORMACIÓN


      asistencia.destroy
      actividad.reload
      assert_equal([], actividad.rangoedadac_ids)

   end
  end  # class
end    # module
