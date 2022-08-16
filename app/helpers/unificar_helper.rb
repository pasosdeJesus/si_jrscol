module UnificarHelper

  include Rails.application.routes.url_helpers


  # @param c Sivel2Gen::Caso
  # @param menserror Colchon para mensajes de error
  # @return true y menserror es vacio o false y menserror indica problema
  def eliminar_caso(c, menserror)
    if !c || !c.id
      menserror << "Caso no válido.\n"
      return false
    end
    begin
      #Sivel2Gen::Caso.connection.execute('BEGIN')
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
      Sivel2Gen::Caso.connection.execute(
        "DELETE FROM sivel2_sjr_actividad_casosjr
        WHERE casosjr_id=#{c.id}")
      Sivel2Gen::Caso.connection.execute(
        "DELETE FROM sivel2_sjr_respuesta 
        WHERE id_caso=#{c.id}")
      cs = c.casosjr
      if cs
        cs.destroy
      end
      c.destroy
      return true
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


  def consulta_casos_en_blanco
    return Sivel2Gen::Caso.joins(:casosjr).where(
      "contacto_id IN (SELECT id FROM sip_persona "\
      "  WHERE COALESCE(nombres, '')='' "\
      "  AND COALESCE(apellidos, '')='') "\
      "AND COALESCE(memo, '')='' "
    )
  end
  module_function :consulta_casos_en_blanco


  def eliminar_casos_en_blanco
    mens = ""
    pore = UnificarHelper.consulta_casos_en_blanco
    lpore =[]
    pore.each do |ce|
      puts "Eliminando caso en blanco #{ce.id}"
      if eliminar_caso(ce, mens)
        lpore += [ce.id]
      else
        puts "Problema eliminando"
      end
    end
    if lpore.count == 0
      return "No se eliminaron casos en blanco" +
        (mens != '' ? ' (' + mens + ')' : '') + ".\n"
    else
      return "Se eliminaron #{lpore.count} casos en blanco "\
        "(#{lpore.join(', ')})" +
        (mens != '' ? ' ('+mens+')' : '') + ".\n"
    end
  end
  module_function :eliminar_casos_en_blanco


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

  def consulta_casos_por_arreglar
    Sivel2Gen::Caso.where('id NOT IN (SELECT id_caso FROM sivel2_sjr_casosjr)')
  end
  module_function :consulta_casos_por_arreglar


  def arreglar_casos_medio_borrados
    us = Usuario.habilitados.where(rol: Ability::ROLADMIN).take
    if !us
      return "No hay un administrador para asignarle casos.\n"
    end
    mens = "";
    lcom = [];
    lelim = [];
    pora = consulta_casos_por_arreglar
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

  def consulta_personas_en_blanco_por_eliminar
    Sip::Persona.where(
      "(tdocumento_id is null) AND
      (numerodocumento is null OR numerodocumento='') AND
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
  end
  module_function :consulta_personas_en_blanco_por_eliminar


  def eliminar_personas_en_blanco
    pore = consulta_personas_en_blanco_por_eliminar
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

  # después de ejecutar este refrescar vista materializada
  # sivel2_gen_conscaso
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
          Sivel2Sjr::Casosjr.connection.execute <<-SQL
            UPDATE sivel2_sjr_casosjr SET
              contacto_id=#{p1.id}
              WHERE contacto_id=#{p2.id}
          SQL
  #          csjr.contacto_id = p1.id
#          if !csjr.save
#            puts csjr.errors
#            debugger
#          end
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
      ep.observaciones += "Cambiada caracterizacíon #{cp.id}; "
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
    Sip::EtiquetaPersona.where(persona_id: p2.id).each do |ep2|
      ep2.persona_id = p1.id
      ep2.save
      ep.observaciones += "Cambiada etiqueta #{ep.etiqueta.nombre}; "
    end

    # cor1440_gen_beneficiariopf no tiene id
    lpf = Cor1440Gen::Beneficiariopf.where(persona_id: p2.id).
      pluck(:proyectofinanciero_id)
    lpf.each do |pfid|
      if Cor1440Gen::Beneficiariopf.where(persona_id: p1.id, 
          proyectofinanciero_id: pfid).count == 0
        Cor1440Gen::Beneficiariopf.connection.execute <<-SQL
          INSERT INTO cor1440_gen_beneficiariopf 
            (persona_id, proyectofinanciero_id) 
            VALUES (#{p1.id}, #{pfid});
        SQL
        ep.observaciones += "Cambiado beneficiario en convenio financiado #{pfid}; "
      end
      Cor1440Gen::Beneficiariopf.connection.execute <<-SQL
        DELETE FROM cor1440_gen_beneficiariopf WHERE 
          persona_id=#{p2.id} AND
          proyectofinanciero_id=#{pfid};
      SQL
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

  def consulta_duplicados_autom
# La siguiente vista haría breve la siguiente consulta pero
# su refresco toma como 15 min.
#    Sip::Persona.connection.execute <<-SQL
#       DROP MATERIALIZED VIEW IF EXISTS duplicados_rep;
#       CREATE MATERIALIZED VIEW duplicados_rep AS (
#         SELECT sub.sigla,
#         sub.numerodocumento,
#         sub.rep,
#         p1.id AS id1,
#         p2.id AS id2,
#         p1.nombres AS nombres1,
#         p1.apellidos AS apellidos1,
#         p2.nombres AS nombres2,
#         p2.apellidos AS apellidos2,
#         soundexespm(p1.nombres) AS sn1,
#         soundexespm(p1.apellidos) AS sa1,
#         soundexespm(p2.nombres) AS sn2,
#         soundexespm(p2.apellidos) AS sa2
#         FROM (SELECT t.sigla,
#           p.tdocumento_id,
#           p.numerodocumento,
#           count(p.id) AS rep
#           FROM sip_persona p
#             LEFT JOIN sip_tdocumento t ON t.id = p.tdocumento_id
#           GROUP BY t.sigla, p.tdocumento_id, p.numerodocumento) AS sub
#         JOIN sip_persona AS p1 ON
#           p1.tdocumento_id=sub.tdocumento_id
#           AND p1.numerodocumento=sub.numerodocumento
#         JOIN sip_persona AS p2 ON
#           p1.id<p2.id AND
#           p2.tdocumento_id=sub.tdocumento_id
#           AND p2.numerodocumento=sub.numerodocumento
#       );
#       CREATE INDEX i_duplicado_rep_id1 ON duplicados_rep (id1);
#       CREATE INDEX i_duplicado_rep_id2 ON duplicados_rep (id2);
#       CREATE INDEX i_duplicado_rep_numerodocumento ON duplicados_rep (numerodocumento);
#       CREATE INDEX i_duplicado_rep_sigla ON duplicados_rep (sigla);
#       CREATE INDEX i_duplicado_rep_n1 ON duplicados_rep (nombres1);
#       CREATE INDEX i_duplicado_rep_a1 ON duplicados_rep (apellidos1);
#       CREATE INDEX i_duplicado_rep_n2 ON duplicados_rep (nombres2);
#       CREATE INDEX i_duplicado_rep_a2 ON duplicados_rep (apellidos2);
#       CREATE INDEX i_duplicado_rep_tn1 ON duplicados_rep (TRIM(UPPER(unaccent(nombres1))));
#       CREATE INDEX i_duplicado_rep_ta1 ON duplicados_rep (TRIM(UPPER(unaccent(apellidos1))));
#       CREATE INDEX i_duplicado_rep_n2 ON duplicados_rep (TRIM(UPPER(unaccent(nombres2))));
#       CREATE INDEX i_duplicado_rep_a2 ON duplicados_rep (TRIM(UPPER(unaccent(apellidos2))));
#       CREATE INDEX i_duplicado_rep_sn1 ON duplicados_rep (sn1);
#       CREATE INDEX i_duplicado_rep_sa1 ON duplicados_rep (sa1);
#       CREATE INDEX i_duplicado_rep_sn2 ON duplicados_rep (sn2);
#       CREATE INDEX i_duplicado_rep_sa2 ON duplicados_rep (sa2);
#    SQL
#
    return Sip::Persona.connection.execute <<-SQL

  -- Las 3 opciones sin igualdad entre tdocumento y numerodocumento da
  -- 23'700.306.841 (mucho más que la suma de las opciones)
      SELECT p1.tdocumento_id, p1.numerodocumento, 
        p1.id AS id1, p1.nombres AS nombres1, soundexespm(p1.nombres) AS sn1,
        p1.apellidos AS apellidos1, soundexespm(p1.apellidos) AS sa1,
        p2.id AS id2, p2.nombres AS nombres2, soundexespm(p2.nombres) AS sn2,
        p2.apellidos AS apellidos2, soundexespm(p2.apellidos) AS sa2
      FROM sip_persona AS p1
      JOIN sip_persona AS p2 
      ON p1.id<p2.id
        AND p1.tdocumento_id=p2.tdocumento_id
        AND p1.numerodocumento=p2.numerodocumento
      WHERE
        p2.id<10 AND
        (soundexespm(p1.nombres) = soundexespm(p2.nombres)
          AND soundexespm(p1.apellidos) = soundexespm(p2.apellidos)
        )  --con indices explain da 662.181
        OR 
        (((LENGTH(p2.nombres)>0 AND
            unaccent_i(p1.nombres) LIKE unaccent_i(p2.nombres) || '%')
          OR (LENGTH(p1.nombres)>0 AND
            unaccent_i(p2.nombres) LIKE unaccent_i(p1.nombres) || '%')
          )
         AND ((LENGTH(p2.apellidos)>0 AND
            unaccent_i(p1.apellidos) LIKE unaccent_i(p2.apellidos) || '%')
          OR (LENGTH(p1.apellidos)>0 AND
            unaccent_i(p2.apellidos) LIKE unaccent_i(p1.apellidos) || '%')
         )
       ) --no susceptible de indices con explain da 5'574.709.919
        OR 
        (levenshtein(p1.nombres || ' ' ||
            p1.apellidos,
            p2.nombres || ' ' ||
            p2.apellidos) <= 3
        ) --no encontramos como indexar con explain da 4'612.693.352
    ;
    SQL
  end
  module_function :consulta_duplicados_autom

  # después de ejecutar este refrescar vista materializada
  # sivel2_gen_conscaso
  def deduplicar_automaticamente(current_usuario)
    pares = UnificarHelper.consulta_duplicados_autom
    res = {
      titulo: 'Beneficiarios en los que se intenta deduplicación automatica',
      encabezado: [
        'T. Doc', 'Num. doc', 'Id1', 'Nombres', 'Apellidos',
        'Id2', 'Nombres', 'Apellidos', 'Resultado'
      ],
      cuerpo: []
    }
    pares.each do |f|
      mens, idunif = unificar_dos_beneficiarios(f['id1'], f['id2'], current_usuario)
      if (mens == "")
          mens = "Unificados en <a href='personas/#{idunif}'>#{idunif}</a>".html_safe
      end
      res[:cuerpo] << [
        ['sigla', f['sigla']], 
        ['numerodocumento', f['numerodocumento']],
        ['Id. 1', f['id1']], 
        ['Nombres 1', f['nombres1']], 
        ['Apellidos 1', f['apellidos1']], 
        ['Id. 2', f['id2']], 
        ['Nombres 2', f['nombres2']],
        ['Apellidos 2', f['apellidos2']], 
        ['Restultado', mens]
      ]
    end
    return res
  end
  module_function :deduplicar_automaticamente
end
