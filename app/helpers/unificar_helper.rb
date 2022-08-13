module UnificarHelper

  def eliminar_casos_en_blanco
    pore = Sivel2Gen::Caso.joins(:casosjr).where(
      "contacto_id IN (SELECT id FROM sip_persona "\
      "  WHERE COALESCE(nombres, '')='' "\
      "  AND COALESCE(apellidos, '')='') "\
      "AND COALESCE(memo, '')='' "
    )
    lpore =[]
    pore.each do |ce|
      lpore += [ce.id]
      puts "Eliminando caso en blanco #{ce.id}"
      Sivel2Sjr::ActividadCasosjr.where(casosjr_id: ce.id).destroy_all
      cs = ce.casosjr
      cs.destroy!
      ce.destroy!
    end
    if lpore.count == 0
      return "No hay casos en blanco por eliminar.\n"
    else
      return "Se eliminaron #{lpore.count} casos en blanco (#{lpore.join(', ')}).\n"
    end
  end
  module_function :eliminar_casos_en_blanco

  def eliminar_caso(c, menserror)
    if !c || !c.id
      menserror << "Caso no válido.\n"
      return false
    end
    begin
      Sivel2Gen::Caso.connection.execute('BEGIN')
      Sivel2Gen::Caso.connection.execute(
        "DELETE FROM sivel2_sjr_categoria_desplazamiento 
           WHERE desplazamiento_id IN (SELECT id FROM sivel2_sjr_desplazamiento 
              WHERE id_caso=#{c.id});"
      )
      Sivel2Gen::Caso.connection.execute("DELETE FROM sivel2_sjr_desplazamiento 
        WHERE id_caso=#{c.id};")
      Sivel2Gen::Caso.connection.execute("UPDATE sivel2_gen_caso 
        SET ubicacion_id=NULL
          WHERE id=#{c.id};")
      Sivel2Gen::Caso.connection.execute("DELETE FROM sip_ubicacion 
        WHERE id_caso=#{c.id};")
      Sivel2Gen::Caso.connection.execute("DELETE FROM sivel2_sjr_actosjr
        WHERE id_acto IN (SELECT id FROM sivel2_gen_acto 
          WHERE id_caso=#{c.id});")
      Sivel2Gen::Caso.connection.execute('COMMIT;')
      c.destroy
    rescue Exception => e
      menserror << "Problema eliminando caso #{e}.\n"
      return false
    end

#    Sivel2Gen::Caso.connection.execute("DELETE FROM sivel2_gen_acto
#      WHERE id_caso=#{c.id};")
#    Sivel2Gen::Caso.connection.execute("DELETE FROM sivel2_gen_caso 
#      WHERE id=#{c.id};")
#    Sivel2Gen::Caso.connection.execute('COMMIT;')
  end
  module_function :eliminar_caso

  # Crear un casosjr para el caso c  o lo elimina si no tiene víctimas
  # disponibles para esto.
  # @param caso Sivel2Gen::CAso
  # @parama asesor Usuario que quedará como asesor
  # @param lcom Lista de caso completados
  # @param lelim Lista de casos eliminados
  # @param mens Colchon para mensajes de error
  def arreglar_un_caso_medio_borrado(caso, asesor, lcom, lelim, mens)
    if caso.casosjr
      puts "Este caso no necesita ser arreglado"
      return
    end
    if caso.victima_ids == []
      puts "Caso sin víctimas, es mejor eliminarlo"
      if UnificarHelper.eliminar_caso(caso, mens)
        lelim << caso.id
      end
    else
      vpos = caso.victima_ids.select{
        |vid| 
        idp = Sivel2Gen::Victima.find(vid).id_persona
        Sivel2Gen::Victima.where('id_caso<>?', caso.id).
          where('id_persona<>?', idp).count == 0
      }
      if vpos.count == 0
        puts "Todas las víctimas están en otros casos es mejor eliminarlo"
        if UnificarHelper.eliminar_caso(caso, mens)
          lelim << [caso.id]
        end
      else
        puts "Completando"
        cs = Sivel2Sjr::Casosjr.create(
          id_caso: caso.id,
          contacto_id: vpos[0],
          asesor: us.id,
          oficina: 1 # SIN INFORMACION
        )
        cs.save
        lcom += [caso.id]
      end
    end
  end
  module_function :arreglar_un_caso_medio_borrado


  def arreglar_casos_medio_borrados
    us = Usuario.habilitados.where(rol: Ability::ROLADMIN).take
    if !us
      return "No hay un administrador para asignarle casos.\n"
    end
    mens = "";
    lcom = [];
    lelim = [];
    pora = Sivel2Gen::Caso.where('id NOT IN (SELECT id_caso FROM sivel2_sjr_casosjr)')
    numpora = pora.count
    pora.each do |c|
      puts "Arreglando caso medio borrado #{c.id}"
      arreglar_un_caso_medio_borrado(c, us, lcom, lelim, mens)
    end
    if numpora == 0
      mens = "No hay casos parcialmente eliminados.\n"
    else
      mens = "De los #{numpora} casos parcialmente eliminados, se completaron #{lcom.count} (i.e #{lcom.join(', ')}) y se eliminaron #{lelim.count} que no tenían beneficiarios o cuyos beneficiarios estaban en otros casos (i.e #{lelim.join(', ')}).\n";
    end
    return mens
  end
  module_function :arreglar_casos_medio_borrados

  def eliminar_personas_en_blanco
    pore = Sip::Persona.where(
      "(tdocumento_id is null) AND
      (numerodocumento is null) AND 
      id NOT IN (SELECT persona_id FROM cor1440_gen_asistencia) AND 
      id NOT IN (SELECT persona_id FROM cor1440_gen_caracterizacionpersona) AND 
      id NOT IN (SELECT persona_id FROM sip_orgsocial_persona) AND 
      id NOT IN (SELECT id_persona FROM sivel2_gen_victima) AND 
      (trim(nombres) IN ('','N','NN')) AND 
      (trim(apellidos) in ('','N','NN')) AND 
      id NOT IN (SELECT  persona1 FROM sip_persona_trelacion) AND 
      id NOT IN (SELECT persona2 FROM sip_persona_trelacion) AND 
      id NOT IN (SELECT persona_id FROM detallefinanciero_persona) AND 
      id NOT IN (SELECT persona_id FROM cor1440_gen_beneficiariopf)"
    )
    lpore = []
    pore.each do |p|
      lpore += ["#{p.id} #{p.nombres} #{p.apellidos}"]
      puts "Eliminando persona en blanco #{p.id}"
      p.destroy
    end
    if lpore.count == 0 
      mens = "No hay personas en blanco.\n"
    else
      mens = "Se eliminaron #{lpore.count} personas en blanco no asociadas a casos ni a actividades (#{lpore.join(', ')}).\n"
    end
    return mens
  end
  module_function :eliminar_personas_en_blanco

  def preparar_automaticamente
    mens = arreglar_casos_medio_borrados
    puts mens
    mens2 = eliminar_casos_en_blanco
    puts mens2
    mens += mens2
    mens2 = eliminar_personas_en_blanco
    mens += mens2
    return mens
  end
  module_function :preparar_automaticamente


  # Unificar la información de un segundo beneficario en un primero y elimina el
  # segundo
  # @return [menserr, null] si hay error o ["", persona_id] si no
  def unificar_dos_beneficiarios(p1_id, p2_id, current_usuario)
    menserr = ''
    if !p1_id || p1_id.to_i <= 0 || 
        Sip::Persona.where(id: p1_id.to_i).count == 0
      menserr += "Primera identificación de persona no válida #{p1_id.to_s}.\n"
    end
    if !p2_id || p2_id.to_i <= 0 ||
        Sip::Persona.where(id: p2_id.to_i).count == 0
      menserr += "Segunda identificación de persona no válida #{p2_id.to_s}.\n"
    end
    if p1_id.to_i == p2_id.to_i
      menserr += "Primera y segunda identificación son iguales no unificando.\n"
    end
    if menserr != ""
      return [menserr, nil]
    end

    p1 = Sip::Persona.find([p1_id.to_i, p2_id.to_i].min)
    p2 = Sip::Persona.find([p1_id.to_i, p2_id.to_i].max)

    cp1 = Sivel2Gen::Victima.where(id_persona: p1.id).pluck(:id_caso)
    cp2 = Sivel2Gen::Victima.where(id_persona: p2.id).pluck(:id_caso)
    cc = cp1 & cp2
    if cc.count == 1
      menserr += "El caso #{cc.first} tiene ambos beneficiarios como víctimas; por previción antes debe eliminar alguna de esas víctimas de ese caso.\n"
    elsif cc.count > 1
      menserr += "Los casos #{cc.inspect} tienen a ambos beneficiarios como víctimas; por previción antes en cada uno de esos casos debe eliminar alguna de las dos víctimas.\n"
    end

    cc1 = Sivel2Sjr::Casosjr.where(contacto_id: p1.id).pluck(:id_caso)
    cc2 = Sivel2Sjr::Casosjr.where(contacto_id: p2.id).pluck(:id_caso)
    if cc1.count > 0 and cc2.count > 0
      menserr += "Primer beneficiario (#{p1.id} #{p1.nombres.to_s} #{p1.apellidos.to_s}) es contacto en caso #{cc1} y segundo beneficiario (#{p2.id} #{p2.nombres} #{p2.apellidos}) es contacto en caso #{cc2}, sería una unificación más compleja. Eliminar uno de los dos casos.\n"
    end


    ap1 = Cor1440Gen::Asistencia.where(persona_id: p1.id).pluck(&:id_actividad)
    ap2 = Cor1440Gen::Asistencia.where(persona_id: p2.id).pluck(&:id_actividad)
    ac = ap1 & ap2
    if ac.count == 1
      menserr += "La actividad #{ac.first} tiene ambos beneficiarios como asistentes; por previción antes debe eliminar alguno de esos asistentes de esa actividad.\n"
    elsif ac.count > 1
      menserr += "Las actividades #{ac.inspect} tienen a ambos beneficiarios como asistentes; por previción antes en cada una de esas actividades debe eliminar alguno de los dos asistentes.\n"
    end

    eunif = Sip::Etiqueta.where(nombre:'BENEFICIARIOS UNIFICADOS').take
    if !eunif
      menserr += "No se encontró etiqueta BENEFICIARIOS UNIFICADOS.\n"
    end

    if menserr != ""
      return [menserr, nil]
    end

    ep = Sip::EtiquetaPersona.new(
      persona_id: p1.id,
      etiqueta_id: eunif.id,
      usuario_id: current_usuario.id,
      fecha: Date.today(),
      observaciones: ""
    )
    [ :anionac, :mesnac, :dianac,
      :numerodocumento, :tdocumento_id,
      :id_departamento, :id_municipio,
      :id_clase, :nacionalde, :id_pais
    ].each do |c|
      if !p1[c] && p2[c]
        p1[c] = p2[c]
        ep.observaciones += "#{c}->#{p2[c]}; "
      end
    end
    p1.save
    ep.save

    cp2.each do |cid|
      Sivel2Gen::Victima.where(
        id_caso: cid, id_persona: p2.id
      ).each do |vic|
        if Sivel2Gen::Victima.where(id_caso: cid, id_persona: p1.id).count == 0
          nv = vic.dup
          nv.id_persona = p1.id
          nv.save!
          ep.observaciones += "Creada víctma en caso #{cid}; "
        end
        ep.save
        csjr = vic.caso.casosjr
        if csjr.contacto_id == p2.id
          csjr.contacto_id = p1.id
          csjr.save!
          ep.observaciones += "Cambiado contacto en caso #{cid}; "
        end
        ep.save
        Sivel2Gen::Acto.where(id_caso: cid, id_persona: p1.id).each do |ac|
          ac.id_persona = p1.id
          ac.save!
          ep.observaciones += "Cambiado acto en caso #{cid}; "
        end
        ep.save
        ep.observaciones += "Elimina víctima #{vic.id_persona} del caso #{cid}; "
        vic.destroy
        ep.save
      end
    end

    Cor1440Gen::Caracterizacionpersona.where(persona_id: p2.id).each do |cp|
      cp.persona_id = p1.id
      cp.save
      ep.observaciones += "Cambiada caracterizacíon #{respuestafor_id}; "
    end
    Sip::PersonaTrelacion.where(persona1: p2.id).each do |pt|
      pt.persona1 = p1.id
      pt.save
      ep.observaciones += "Cambiada relacion con persona #{pt.persona2}; "
    end
    Sip::PersonaTrelacion.where(persona2: p2.id).each do |pt|
      pt.persona2 = p1.id
      pt.save
      ep.observaciones += "Cambiada relacion con persona #{pt.persona1}; "
    end

    #sip_datosbio no debe estar lleno
    Sip::OrgsocialPersona.where(persona_id: p2.id).each do |op|
      op.persona_id = p1.id
      op.save
      ep.observaciones += "Cambiada organización social #{op.orgsocial_id}; "
    end
 
    #mr519_gen_encuestapersona no debería estar llena
    Sip::EtiquetaPersona.where(persona_id: p2.id).each do |ep|
      ep.persona_id = p1.id
      ep.save
      ep.observaciones += "Cambiada etiqueta #{ep.etiqueta.nombre}; "
    end

    Cor1440Gen::Beneficiariopf.where(persona_id: p2.id).each do |bp|
      bp.persona_id = p1.id
      bp.save
      ep.observaciones += "Cambiado beneficiario en convenio financiado #{bp.proyectofinanciero_id}; "
    end

    ::Detallefinanciero.joins(:persona).where(
      'sip_persona.id' => p2.id
    ).each do |bp|
      bp.persona_id = p1.id
      bp.save
      ep.observaciones += "Cambiado detalle financiero #{bp.detallefinanciero_id}; "
    end
    #detallefinanciero_persona

    ep.save
    p2.destroy
    ep.observaciones += "Se unificó y eliminó el registro de beneficiario #{p2.id}; "\
        "Nombres: #{p2.nombres.to_s}; "\
        "Apellidos: #{p2.apellidos.to_s}; "\
        "Tipo doc.: #{p2.tdocumento_id ? p2.tdocumento.sigla : ''}; "\
        "Número de doc.: #{p2.numerodocumento.to_s}; "\
        "Año nac.: #{p2.anionac.to_s}; "\
        "Mes nac.: #{p2.mesnac.to_s}; "\
        "Dia nac.: #{p2.dianac.to_s}; "\
        "Sexo nac.: #{p2.sexo.to_s}; "\
        "Pais nac.: #{p2.id_pais ? p2.pais.nombre : ''}; "\
        "Departamento nac.: #{p2.id_departamento ? p2.departamento.nombre : ''}; "\
        "Muncipio nac.: #{p2.id_municipio ? p2.municipio.nombre : ''}; "\
        "Centro poblado nac.: #{p2.id_clase ? p2.clase.nombre : ''}; "\
        "Nacional de: #{p2.nacionalde ? p2.nacional.nombre : ''}; "\
        "Fecha creación: #{p2.created_at.to_s}; "\
        "Fecha actualización: #{p2.updated_at.to_s}. "[0..4999]
    ep.save
 
    return ["", p1.id]
  end
  module_function :unificar_dos_beneficiarios

end
