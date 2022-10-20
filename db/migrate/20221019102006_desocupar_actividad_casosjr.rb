class DesocuparActividadCasosjr < ActiveRecord::Migration[7.0]
  def up
    cien = Sivel2Sjr::ActividadCasosjr.all.count
    ultp = -1
    numr = 0
    porelim = []
    Sivel2Sjr::ActividadCasosjr.all.each do |ac|
      numr += 1
      p = numr*100/cien
      if p.round>ultp
        puts p.round
        ultp = p.round
      end
      casosjr = Sivel2Sjr::Casosjr.find(ac.casosjr_id)
      actividad = Cor1440Gen::Actividad.find(ac.actividad_id)
      Sivel2Gen::Victima.where(id_caso: casosjr.id_caso).each do |v|
        sv = Sivel2Sjr::Victimasjr.where(id_victima: v.id).take
        p = v.persona
        # Esta persona nació antes de la actividad
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
            end
          end
        end
      end
      actividad.recalcula_poblacion
      porelim << ac.id
    end
    porelim.each do |i|
      Sivel2Sjr::ActividadCasosjr.find(i).delete
    end
    #drop_table :sivel2_sjr_actividad_casosjr
  end

  def down
    raise IrreversibleMigration
  end

end
