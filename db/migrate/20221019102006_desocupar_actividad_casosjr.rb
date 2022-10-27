class DesocuparActividadCasosjr < ActiveRecord::Migration[7.0]

  # Enviar salida estándar a un archivo que tendrá CSV con resultado
  # Reporte del avance se enviará a error estándar
  def up
    cien = Sivel2Sjr::ActividadCasosjr.all.count
    ultp = -1
    numr = 0
    numpersag = 0
    porelim = []
    totac = Sivel2Sjr::ActividadCasosjr.all.count
    STDERR.puts "Se modificarán #{totac} "\
      "actividades con caso.\n"\
      "Se añadirán como asistentes de cada actividad los beneficiarios del "\
      "caso:\n"\
      " 1. Nacidos después de la actividad\n"\
      " 2. No desagregados del caso o desagregados después de la actividad\n"\
      " 3. Que no estén en el listado de asistencia\n"\
      "----------------------------------------------"
    puts "actividad_id, caso_id, ids personas añadidas,  observaciones"
    Sivel2Sjr::ActividadCasosjr.all.each do |ac|
      numr += 1
      p = numr*100/cien
      if p.round>ultp
        STDERR.puts "Avance: #{p.round}%"
        ultp = p.round
      end
      casosjr = Sivel2Sjr::Casosjr.find(ac.casosjr_id)
      actividad = Cor1440Gen::Actividad.find(ac.actividad_id)
      persag = []
      Sivel2Gen::Victima.where(id_caso: casosjr.id_caso).each do |v|
        p = v.persona
        sv = Sivel2Sjr::Victimasjr.where(id_victima: v.id).take
        if !sv
          puts "#{actividad.id}, #{ac.casosjr_id}, , Víctima #{v.id} con persona #{p.id} no tiene estructura interna victimasjr creando"
          sv = Sivel2Sjr::Victimasjr.create!(
            id_victima: v.id,
            id_rolfamilia: 0
          )
        end
        # Esta persona nació antes de la actividad?
        if (!p.anionac || p.anionac < actividad.fecha.year ||
            (p.anionac == actividad.fecha.year && 
              (!p.mesnac || p.mesnac < actividad.fecha.month)) ||
            (p.anionac == actividad.fecha.year && 
             p.mesnac == actividad.fecha.month &&
             (!p.dianac || p.dianac <= actividad.fecha.day))
           )
          # No ha sido desagregada o fue desagregada después de la actividad
          if !sv.fechadesagregacion || sv.fechadesagregacion>=actividad.fecha
            # Esta persona debe agregarse --si falta-- al listado de asistencia
            # Inicialmente sin perfil ni organización social
            if Cor1440Gen::Asistencia.where(actividad_id: actividad.id,
                persona_id: v.id_persona).count == 0
              Cor1440Gen::Asistencia.create(actividad_id: actividad.id,
                                            persona_id: v.id_persona)
              persag << v.id_persona
              numpersag += 1
            end
          end
        end
      end
      puts "#{actividad.id}, #{ac.casosjr_id}, #{persag.join(' ')},"
      actividad.recalcula_poblacion
      porelim << ac.id
    end
    STDERR.puts "En total se añadieron #{numpersag} a #{totac} actividades"
    porelim.each do |i|
      Sivel2Sjr::ActividadCasosjr.find(i).delete
    end
    #drop_table :sivel2_sjr_actividad_casosjr
  end

  def down
    raise IrreversibleMigration
  end

end
