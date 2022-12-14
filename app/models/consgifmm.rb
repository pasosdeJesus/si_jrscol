class Consgifmm < ActiveRecord::Base
  include Sip::Modelo

  belongs_to :detallefinanciero, 
    class_name: 'Detallefinanciero', 
    foreign_key: 'id', optional: false

  belongs_to :proyectofinanciero, 
    class_name: 'Cor1440Gen::Proyectofinanciero', 
    foreign_key: 'proyectofinanciero_id', optional: false

  belongs_to :actividadpf, 
    class_name: 'Cor1440Gen::Actividadpf', 
    foreign_key: 'actividadpf_id', optional: false

  belongs_to :actividad,
    class_name: 'Cor1440Gen::Actividad', 
    foreign_key: 'actividad_id', optional: false


  # Retorna el del primer proyecto y de la primera actividad o nil 
  def busca_indicador_gifmm
    if actividadpf
      actividadpf.indicadorgifmm_id
    else
      nil
    end
  end

  def cuenta_victimas_condicion
    cuenta = 0
    self.actividad.casosjr.each do |c|
      c.caso.victima.each do |v|
        if (yield(v))
          cuenta += 1
        end
      end
    end
    cuenta
  end


  def detalleah_unidad
    if detallefinanciero.nil?
      ''
    else
      detallefinanciero.unidadayuda ?
        detallefinanciero.unidadayuda.nombre :
        ''
    end
  end

  def detalleah_cantidad
    r = (detallefinanciero && detallefinanciero.unidadayuda &&
      detallefinanciero.cantidad && detallefinanciero.persona_ids) ?
      detallefinanciero.cantidad*detallefinanciero.persona_ids.count :
      ''
    r.to_s
  end

  def detalleah_modalidad
    (detallefinanciero && detallefinanciero.modalidadentrega) ?
      detallefinanciero.modalidadentrega.nombre :
      ''
  end

  def detalleah_tipo_transferencia
    (detallefinanciero && detallefinanciero.modalidadentrega &&
      detallefinanciero.modalidadentrega.nombre == 'Transferencia' &&
      detallefinanciero.tipotransferencia) ?
      detallefinanciero.tipotransferencia.nombre :
      ''
  end

  def detalleah_mecanismo_entrega
    (detallefinanciero && detallefinanciero.modalidadentrega &&
      detallefinanciero.modalidadentrega.nombre == 'Transferencia' &&
      detallefinanciero.mecanismodeentrega) ?
      detallefinanciero.mecanismodeentrega.nombre :
      ''
  end

  def detalleah_frecuencia_entrega
    (detallefinanciero && detallefinanciero.modalidadentrega &&
      detallefinanciero.modalidadentrega.nombre == 'Transferencia' &&
      detallefinanciero.frecuenciaentrega) ?
      detallefinanciero.frecuenciaentrega.nombre :
      ''
  end

  def detalleah_monto_por_persona
    (detallefinanciero && detallefinanciero.modalidadentrega &&
      detallefinanciero.modalidadentrega.nombre == 'Transferencia' &&
      r = detallefinanciero.valorunitario &&
      detallefinanciero.cantidad && detallefinanciero.valorunitario) ?
      detallefinanciero.cantidad*detallefinanciero.valorunitario :
      ''
    r.to_s
  end

  def detalleah_numero_meses_cobertura
    (detallefinanciero && detallefinanciero.modalidadentrega &&
      detallefinanciero.modalidadentrega.nombre == 'Transferencia' &&
      detallefinanciero.numeromeses) ?
      detallefinanciero.numeromeses :
      ''
  end

  def indicador_gifmm
    idig = self.busca_indicador_gifmm
    if idig != nil
      ::Indicadorgifmm.find(idig).nombre
    else
      ''
    end
  end


  # Auxiliar que retorna listado de identificaciones de personas de 
  # las víctimas del listado de casos que cumplan una condición
  def personas_victimas_condicion
    ids = []
    self.actividad.casosjr.each do |c|
      c.caso.victima.each do |v|
        if (yield(v))
          ids << v.id_persona
        end
      end
    end
    ids
  end


  # Auxiliar que retorna listado de identificaciones de personas del
  # listado de asistentes que cumplan una condición
  def personas_asistentes_condicion
    ids = []
    self.actividad.asistencia.each do |a| 
      if (yield(a))
        ids << a.persona_id
      end
    end
    ids
  end


  def beneficiarios_ids
    r = self.persona_ids.sort.uniq
    r.join(',')
  end


  def beneficiarios_nuevos_mes_ids
    idp = beneficiarios_ids.split(',').select {|pid|

      c = Cor1440Gen::Asistencia.joins(:actividad).joins(:persona).
        joins(
          'JOIN cor1440_gen_actividad_actividadpf '\
          'ON cor1440_gen_actividad_actividadpf.actividad_id=cor1440_gen_asistencia.actividad_id'\
          ' AND cor1440_gen_actividad_actividadpf.actividadpf_id='+self.actividadpf_id.to_s).
          where( # actividadpf lleva implicito proyectopf
                'cor1440_gen_actividad.fecha < ? ', 
                self.fecha.at_beginning_of_month).
                where('sip_persona.id = ?', pid.to_i)

      # Definicion de nuevo si usaran detalle financiero
      #c = ::Detallefinanciero.joins(:actividad).joins(:persona).where(
      #  proyectofinanciero_id: self.proyectofinanciero_id).where(
      #    actividadpf_id: self.actividadpf_id).where(
      #      'cor1440_gen_actividad.fecha < ? ' +
      #      'OR (cor1440_gen_actividad.fecha = ? '+
      #      'AND detallefinanciero.id < ?)', self.fecha, self.fecha, 
      #      self.detallefinanciero_id).
      #      where('sip_persona.id = ?', pid.to_i)
      c.count == 0
    }
    idp.sort.uniq.join(",")
  end


  # Auxiliar que retorna listado de identificaciones de entre
  # los beneficiarios nuevos que cumplan una condición sobre
  # la persona (recibida como bloque)
  def beneficiarios_nuevos_condicion_ids
    idn = beneficiarios_nuevos_mes_ids.split(',')
    idv = idn.select {|ip|
      p = Sip::Persona.find(ip)
      yield(p)
    }
    idv.sort.join(',')
  end


  def beneficiarios_nuevos_colombianos_retornados_ids
    finmes = actividad.fecha.end_of_month
    idcol = 170 # Colombia
    return beneficiarios_nuevos_condicion_ids {|p|
      (p.nacionalde == idcol || p.id_pais == idcol) &&
        p.victima.any? { |v|
        (v.victimasjr.fechadesagregacion.nil? ||
         v.victimasjr.fechadesagregacion <= finmes) &&
        v.caso.migracion.count > 0 &&
        v.persona &&
        (v.persona.nacionalde == idcol || v.persona.id_pais == idcol)
      }
    }
  end


  def beneficiarios_nuevos_comunidades_de_acogida_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      p.asistencia.any? {|as|
        as.actividad.fecha <= finmes &&
          as.perfilorgsocial && 
          as.perfilorgsocial.nombre == 'COMUNIDAD DE ACOGIDA'
      }
    }
  end


  def beneficiarios_nuevos_en_transito_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      GifmmHelper::perfilmigracion_de_beneficiario(p.id, finmes) == 
        'EN TRÁNSITO'
    }
  end


  # Retorna ids de beneficiarios nuevos del sexo dado
  # y una edad entre edadini o edadinf (pueden ser nil para indicar no limite).
  # Si con_edad es false ademas retorna aquellos cuya edad
  # sea desconocida
  def beneficiarios_nuevos_condicion_sexo_edad_ids(sexo, edadini, edadfin,
                                                  con_edad = true)
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      e = Sivel2Gen::RangoedadHelper::edad_de_fechanac_fecha(
          p.anionac, p.mesnac, p.dianac,
          finmes.year, finmes.month, finmes.day)
      p.sexo == sexo && 
        (!con_edad || p.anionac) &&
        (edadini.nil? || e >= edadini) &&
        (edadfin.nil? || e <= edadfin)
    }
  end

  def beneficiarias_nuevas_mujeres_adultas_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('F', 18, nil)
  end

  def beneficiarias_nuevas_mujeres_0_5_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('F', 0, 5)
  end

  def beneficiarias_nuevas_mujeres_6_12_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('F', 6, 12)
  end

  def beneficiarias_nuevas_mujeres_13_17_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('F', 13, 17)
  end

  def beneficiarias_nuevas_mujeres_18_59_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('F', 18, 59)
  end

  def beneficiarias_nuevas_mujeres_60_o_mas_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('F', 60, nil)
  end

  def beneficiarios_nuevos_ninos_adolescentes_y_se_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('M', nil, 17, false)
  end

  def beneficiarios_nuevos_hombres_adultos_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('M', 18, nil)
  end

  def beneficiarios_nuevos_hombres_0_5_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('M', 0, 5)
  end

  def beneficiarios_nuevos_hombres_6_12_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('M', 6, 12)
  end

  def beneficiarios_nuevos_hombres_13_17_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('M', 13, 17)
  end

  def beneficiarios_nuevos_hombres_18_59_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('M', 18, 59)
  end

  def beneficiarios_nuevos_hombres_60_o_mas_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('M', 60, nil)
  end

  def beneficiarios_nuevos_sinsexo_adultos_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('S', 60, nil)
  end

  def beneficiarios_nuevos_sinsexo_menores_y_se_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids('S', nil, 17, false)
  end

  def beneficiarios_nuevos_lgbti_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      p.victima.any? { |v| 
        (v.victimasjr.fechadesagregacion.nil? ||
         v.victimasjr.fechadesagregacion <= finmes) &&
        v.orientacionsexual != 'H'
      }
    }
  end

  def beneficiarios_nuevos_con_discapacidad_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      p.victima.any? { |v| 
        (v.victimasjr.fechadesagregacion.nil? ||
         v.victimasjr.fechadesagregacion <= finmes) &&
        v.victimasjr.discapacidad &&
        v.victimasjr.discapacidad.nombre != 'NINGUNA'
      }
    }
  end

  def beneficiarios_nuevos_afrodescendientes_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      e = GifmmHelper::etnia_de_beneficiario(p, finmes)
      e == 'AFRODESCENDIENTE' || 
        e == 'NEGRO'
    }
  end

  def beneficiarios_nuevos_indigenas_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      e = GifmmHelper::etnia_de_beneficiario(p, finmes)
      e != 'AFRODESCENDIENTE' &&
        e != 'NEGRO' &&
        e != 'ROM' &&
        e != 'MESTIZO' &&
        e != 'SIN INFORMACIÓN' &&
        e != ''
    }
  end

  def beneficiarios_nuevos_otra_etnia_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      e = GifmmHelper::etnia_de_beneficiario(p, finmes)
      e == 'ROM' ||
         e == 'MESTIZO' ||
         e == 'SIN INFORMACIÓN' ||
         e == ''
    }
  end

  def beneficiarias_nuevas_ninas_adolescentes_y_se_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      p.sexo == 'F' &&
      (p.anionac.nil? ||
        Sivel2Gen::RangoedadHelper::edad_de_fechanac_fecha(
          p.anionac, p.mesnac, p.dianac,
          finmes.year, finmes.month, finmes.day) < 18
      )
    }
  end


  def beneficiarios_nuevos_pendulares_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      GifmmHelper::perfilmigracion_de_beneficiario(p.id, finmes) == 
        'PENDULAR'
    }
  end


  def beneficiarios_nuevos_vocacion_permanencia_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      GifmmHelper::perfilmigracion_de_beneficiario(p.id, finmes) == 
        'CON VOCACIÓN DE PERMANENCIA'
    }
  end


  def sector_gifmm
    idig = self.busca_indicador_gifmm
    if idig != nil
      ::Indicadorgifmm.find(idig).sectorgifmm.nombre
    else
      ''
    end
  end

  def socio_principal
    sp = ''
    if proyectofinanciero && proyectofinanciero.financiador &&
        proyectofinanciero.financiador.count > 0
      if proyectofinanciero.financiador[0].nombregifmm &&
          proyectofinanciero.financiador[0].nombregifmm.strip != ''
        sp = proyectofinanciero.financiador[0].nombregifmm
      else
        sp = proyectofinanciero.financiador[0].nombre
      end
    end
    sp
  end


  def presenta(atr)
    puts "** ::Consgiffm.rb atr=#{atr.to_s.parameterize}"
    #if /^beneficiarias/.match(atr.to_s)
    #  byebug
    #end

    if respond_to?("#{atr.to_s.parameterize}")
      return send("#{atr.to_s.parameterize}")
    end

    if respond_to?("#{atr.to_s.parameterize}_ids")
      ids = send("#{atr.to_s.parameterize}_ids")
      return ids.split(",").count
    end

    m =/^beneficiari(.*)cuenta_y_enlaces$/.match(atr.to_s)
    if m && respond_to?("beneficiari#{m[1].parameterize}ids")
      bids = send("beneficiari#{m[1].parameterize}ids").split(',')
      enlaces = bids.map {|i|
        r="<a href='#{Rails.application.routes.url_helpers.sip_path + 
        'personas/' + i.to_s}' target='_blank'>#{i.to_s}</a>"
        r.html_safe
      }.join(", ".html_safe).html_safe
      return "#{bids.count} : #{enlaces}".html_safe
    end


    m =/^beneficiari(.*)enlaces$/.match(atr.to_s)
    if m && respond_to?("beneficiari#{m[1].parameterize}ids")
      bids = send("beneficiari#{m[1].parameterize}ids").split(',')
      return bids.map {|i|
        r="<a href='#{Rails.application.routes.url_helpers.sip_path + 
        'personas/' + i.to_s}' target='_blank'>#{i.to_s}</a>"
        r.html_safe
      }.join(", ".html_safe).html_safe
    end

    case atr.to_sym
    when :actividad_fecha_mes
      self.actividad.fecha ? self.actividad.fecha.month : ''

    when :actividad_id
      self.actividad_id

    when :actividad_nombre
      self.actividad.nombre

    when :actividad_observaciones
      self.actividad.observaciones

    when :actividad_proyectofinanciero
      self.actividad.proyectofinanciero ? 
        self.actividad.proyectofinanciero.map(&:nombre).join('; ') : ''

    when :actividad_responsable
      self.actividad.responsable.nusuario

    when :estado
      'En proceso'

    when :mes
      actividad.fecha ? 
        Sip::FormatoFechaHelper::MESES[actividad.fecha.month] : ''

    when :objetivo
      actividad.objetivo ? actividad.objetivo : ''

    when :sector_gifmm
      sector_gifmm

    when :socio_implementador
      if socio_principal == 'SJR Col'
        ''
      else
        'SJR Col'
      end

    when :tipo_implementacion
      if socio_principal == 'SJR Col'
        'Directa'
      else
        'Indirecta'
      end

    when :ubicacion
      lugar

    else
      self.actividad.presenta(atr)
    end #case

  end # presenta

  scope :filtro_actividad_id, lambda { |ida|
    where(actividad_id: ida.to_i)
  }

  scope :filtro_fechaini, lambda { |f|
    where('fecha >= ?', f)
  }

  scope :filtro_fechafin, lambda { |f|
    where('fecha <= ?', f)
  }

  scope :filtro_conveniofinanciado_nombre, lambda { |c|
    where(proyectofinanciero_id: c)
      #"proyectofinanciado_idunaccent(conveniofinanciado_nombre) ILIKE '%' || unaccent(?) || '%'", c)
  }

  scope :filtro_actividadmarcologico_nombre, lambda { |a|
    where(actividadpf_id: a)
      #"unaccent(actividadmarcologico_nombre) ILIKE '%' || unaccent(?) || '%'", a)
  }

  scope :filtro_departamento_gifmm, lambda { |d|
    where(departamento_gifmm: d)
  }



  CONSULTA='consgifmm'

  def self.interpreta_ordenar_por(campo)
    critord = ""
    case campo.to_s
    when /^fechadesc/
      critord = "fecha desc"
    when /^fecha/
      critord = "fecha asc"
    else
      raise(ArgumentError, "Ordenamiento invalido: #{ campo.inspect }")
    end
    critord += ", actividad_id"
    return critord
  end

  def self.consulta
    "SELECT (cor1440_gen_actividad.id::text || '-' || cor1440_gen_actividadpf.id::text || '-' || COALESCE(detallefinanciero.id::text, '')) AS id,
	    detallefinanciero.id as detallefinanciero_id,
      cor1440_gen_actividad.id AS actividad_id,
      cor1440_gen_actividadpf.proyectofinanciero_id,
      cor1440_gen_actividadpf.id AS actividadpf_id,
      detallefinanciero.unidadayuda_id,
      detallefinanciero.cantidad,
      detallefinanciero.valorunitario,
      detallefinanciero.valortotal,
      detallefinanciero.mecanismodeentrega_id,
      detallefinanciero.modalidadentrega_id,
      detallefinanciero.tipotransferencia_id,
      detallefinanciero.frecuenciaentrega_id,
      detallefinanciero.numeromeses,
      detallefinanciero.numeroasistencia,
      CASE WHEN detallefinanciero.id IS NULL THEN
        ARRAY(SELECT DISTINCT persona_id FROM
        (SELECT persona_id FROM cor1440_gen_asistencia 
          WHERE cor1440_gen_asistencia.actividad_id=cor1440_gen_actividad.id
        ) AS subpersona_ids)
      ELSE
        ARRAY(SELECT persona_id FROM detallefinanciero_persona WHERE
        detallefinanciero_persona.detallefinanciero_id=detallefinanciero.id)
      END AS persona_ids,
      cor1440_gen_actividad.objetivo AS actividad_objetivo,
      cor1440_gen_actividad.fecha AS fecha,
      cor1440_gen_proyectofinanciero.nombre AS conveniofinanciado_nombre,
      cor1440_gen_actividadpf.titulo AS actividadmarcologico_nombre,
      depgifmm.nombre AS departamento_gifmm,
      mungifmm.nombre AS municipio_gifmm
      FROM cor1440_gen_actividad
      JOIN cor1440_gen_actividad_actividadpf ON
        cor1440_gen_actividad.id=cor1440_gen_actividad_actividadpf.actividad_id
      JOIN cor1440_gen_actividadpf ON
        cor1440_gen_actividadpf.id=cor1440_gen_actividad_actividadpf.actividadpf_id
      JOIN cor1440_gen_proyectofinanciero ON
        cor1440_gen_actividadpf.proyectofinanciero_id=cor1440_gen_proyectofinanciero.id
      LEFT JOIN detallefinanciero ON
        detallefinanciero.actividad_id=cor1440_gen_actividad.id
      LEFT JOIN sip_ubicacionpre ON
        cor1440_gen_actividad.ubicacionpre_id=sip_ubicacionpre.id
      LEFT JOIN sip_departamento ON
        sip_ubicacionpre.departamento_id=sip_departamento.id
      LEFT JOIN depgifmm ON
        sip_departamento.id_deplocal=depgifmm.id
      LEFT JOIN sip_municipio ON
        sip_ubicacionpre.municipio_id=sip_municipio.id
      LEFT JOIN mungifmm ON
        (sip_departamento.id_deplocal*1000+sip_municipio.id_munlocal)=
          mungifmm.id
      WHERE cor1440_gen_actividadpf.indicadorgifmm_id IS NOT NULL
      AND (detallefinanciero.proyectofinanciero_id IS NULL OR
        detallefinanciero.proyectofinanciero_id=cor1440_gen_actividadpf.proyectofinanciero_id)
      AND (detallefinanciero.actividadpf_id IS NULL OR
        detallefinanciero.actividadpf_id=cor1440_gen_actividadpf.id)
    "
  end

  def self.crea_consulta(ordenar_por = nil)
    if ARGV.include?("db:migrate")
      return
    end
    if ActiveRecord::Base.connection.data_source_exists? CONSULTA
      ActiveRecord::Base.connection.execute(
        "DROP MATERIALIZED VIEW IF EXISTS #{CONSULTA}")
    end
    w = ''
    if ordenar_por
      w += ' ORDER BY ' + self.interpreta_ordenar_por(ordenar_por)
    else
      w += ' ORDER BY ' + self.interpreta_ordenar_por('fechadesc')
    end
    ActiveRecord::Base.connection.execute("CREATE 
              MATERIALIZED VIEW #{CONSULTA} AS
              #{self.consulta}
              #{w} ;")
  end # def crea_consulta

  def self.refresca_consulta(ordenar_por = nil)
    if !ActiveRecord::Base.connection.data_source_exists? "#{CONSULTA}"
      crea_consulta(ordenar_por = nil)
    else
      ActiveRecord::Base.connection.execute(
        "REFRESH MATERIALIZED VIEW #{CONSULTA}")
    end
  end

end

