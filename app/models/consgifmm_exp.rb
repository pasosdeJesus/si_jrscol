class ConsgifmmExp < ActiveRecord::Base
  include Msip::Modelo

  belongs_to :consgifmm, 
    optional: false

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
          ids << v.persona_id
        end
      end
    end
    ids
  end

  ## AUXILIARES
  #############

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


  #def beneficiarios_ids
  #  r = self.persona_ids.sort.uniq
  #  r.join(',')
  #end

  # Auxiliar que retorna listado de identificaciones de entre
  # los beneficiarios que cumplan una condición sobre
  # el registro de asistencia (recibida como bloque)
  def asistentes_condicion_ids
    idn = self.actividad.asistencia_ids
    idv = idn.select {|ia|
      p = Cor1440Gen::Asistencia.find(ia)
      yield(p)
    }
    idv.sort.join(',')
  end


  # Auxiliar que retorna listado de identificaciones de entre
  # los beneficiarios que cumplan una condición sobre
  # la persona (recibida como bloque)
  def beneficiarios_condicion_ids
    idn = beneficiarios_ids.split(',')
    idv = idn.select {|ip|
      p = Msip::Persona.find(ip)
      yield(p)
    }
    idv.sort.join(',')
  end

  # Retorna ids de beneficiarios del sexo dado
  # y una edad entre edadini o edadinf (pueden ser nil para indicar no limite).
  # Si con_edad es false ademas retorna aquellos cuya edad
  # sea desconocida
  def beneficiarios_condicion_sexo_edad_ids(sexo, edadini, edadfin,
                                                  con_edad = true)
    finmes = actividad.fecha.end_of_month
    return beneficiarios_condicion_ids {|p|
      e = Sivel2Gen::RangoedadHelper::edad_de_fechanac_fecha(
          p.anionac, p.mesnac, p.dianac,
          finmes.year, finmes.month, finmes.day)
      p.sexo.to_s == sexo.to_s && 
        (!con_edad || p.anionac) &&
        (edadini.nil? || e >= edadini) &&
        (edadfin.nil? || e <= edadfin)
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


  ## CUENTAS BENEFICIARIOS
  #########################

  def beneficiarias_mujeres_0_5_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 0, 5)
  end

  def beneficiarias_mujeres_6_12_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 6, 12)
  end

  def beneficiarias_mujeres_13_17_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 13, 17)
  end

  def beneficiarias_mujeres_18_25_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 18, 25)
  end

  def beneficiarias_mujeres_26_59_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 26, 59)
  end

  def beneficiarias_mujeres_60_o_mas_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 60, nil)
  end

  def beneficiarias_mujeres_sinedad_ids
    return beneficiarios_condicion_ids {|p|
      p.sexo == Msip::Persona::convencion_sexo[:sexo_femenino] && !p.anionac
    }
  end

  def beneficiarios_hombres_0_5_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 0, 5)
  end

  def beneficiarios_hombres_6_12_ids
    r = beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 6, 12)
    return r
  end

  def beneficiarios_hombres_13_17_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 13, 17)
  end

  def beneficiarios_hombres_18_25_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 18, 25)
  end

  def beneficiarios_hombres_26_59_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 26, 59)
  end

  def beneficiarios_hombres_60_o_mas_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 60, nil)
  end

  def beneficiarios_hombres_sinedad_ids
    return beneficiarios_condicion_ids {|p|
      p.sexo == Msip::Persona::convencion_sexo[:sexo_masculino] && !p.anionac
    }
  end

  def beneficiarios_intersexuales_0_5_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_intersexual], 0, 5)
  end

  def beneficiarios_intersexuales_6_12_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_intersexual], 6, 12)
  end

  def beneficiarios_intersexuales_13_17_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_intersexual], 13, 17)
  end

  def beneficiarios_intersexuales_18_25_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_intersexual], 18, 25)
  end

  def beneficiarios_intersexuales_26_59_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_intersexual], 26, 59)
  end

  def beneficiarios_intersexuales_60_o_mas_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_intersexual], 60, nil)
  end

  def beneficiarios_intersexuales_sinedad_ids
    return beneficiarios_condicion_ids {|p|
      p.sexo == Msip::Persona::convencion_sexo[:sexo_intersexual] && 
        !p.anionac
    }
  end

  def beneficiarios_sinsexo_0_5_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_sininformacion], 0, 5)
  end

  def beneficiarios_sinsexo_6_12_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_sininformacion], 6, 12)
  end

  def beneficiarios_sinsexo_13_17_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_sininformacion], 13, 17)
  end

  def beneficiarios_sinsexo_18_25_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_sininformacion], 18, 25)
  end

  def beneficiarios_sinsexo_26_59_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_sininformacion], 26, 59)
  end

  def beneficiarios_sinsexo_60_o_mas_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_sininformacion], 60, nil)
  end

  def beneficiarios_sinsexo_sinedad_ids
    return beneficiarios_condicion_ids {|p|
      p.sexo == Msip::Persona::convencion_sexo[:sexo_sininformacion] && 
        !p.anionac
    }
  end

  def beneficiarios_afrodescendientes_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_condicion_ids {|p|
      e = GifmmHelper::etnia_de_beneficiario(p, finmes)
      e == 'AFRODESCENDIENTE' || 
        e == 'NEGRO'
    }
  end

  def asistentes_colombianos_retornados_ids
    return asistentes_condicion_ids {|p|
      p.perfilorgsocial_id == 16
    }
  end

  def beneficiarios_colombianos_retornados_ids
    return beneficiarios_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 16
    }
  end

  def asistentes_comunidades_de_acogida_ids
    return asistentes_condicion_ids {|p|
      p.perfilorgsocial_id == 13
    }
  end

  def ieneficiarios_comunidades_de_acogida_ids
    return beneficiarios_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 13
    }
  end

  def beneficiarios_con_discapacidad_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_condicion_ids {|p|
      p.victima.any? { |v| 
        (v.victimasjr.fechadesagregacion.nil? ||
         v.victimasjr.fechadesagregacion <= finmes) &&
        v.victimasjr.discapacidad &&
        v.victimasjr.discapacidad.nombre != 'NINGUNA'
      }
    }
  end

  def asistentes_en_transito_ids
    return asistentes_condicion_ids {|p|
      p.perfilorgsocial_id == 11
    }
  end

  def beneficiarios_en_transito_ids
    return beneficiarios_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 11
    }
  end

  def beneficiarios_hombres_adultos_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 18, nil)
  end

  def beneficiarios_indigenas_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_condicion_ids {|p|
      e = GifmmHelper::etnia_de_beneficiario(p, finmes)
      e != 'AFRODESCENDIENTE' &&
        e != 'NEGRO' &&
        e != 'ROM' &&
        e != 'MESTIZO' &&
        e != 'SIN INFORMACIÓN' &&
        e != ''
    }
  end


  def beneficiarios_lgbti_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_condicion_ids {|p|
      p.victima.any? { |v| 
        (v.victimasjr.fechadesagregacion.nil? ||
         v.victimasjr.fechadesagregacion <= finmes) &&
        v.orientacionsexual != 'H' &&
        v.orientacionsexual != "S"
      }
    }
  end

  def beneficiarias_mujeres_adultas_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 18, nil)
  end

  def beneficiarias_ninas_adolescentes_y_se_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_condicion_ids {|p|
      p.sexo == Msip::Persona::convencion_sexo[:sexo_femenino] &&
      (p.anionac.nil? ||
        Sivel2Gen::RangoedadHelper::edad_de_fechanac_fecha(
          p.anionac, p.mesnac, p.dianac,
          finmes.year, finmes.month, finmes.day) < 18
      )
    }
  end

  def beneficiarios_ninos_adolescentes_y_se_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_condicion_ids {|p|
      p.sexo == Msip::Persona::convencion_sexo[:sexo_masculino] &&
      (p.anionac.nil? ||
        Sivel2Gen::RangoedadHelper::edad_de_fechanac_fecha(
          p.anionac, p.mesnac, p.dianac,
          finmes.year, finmes.month, finmes.day) < 18
      )
    }
  end



  def beneficiarios_nuevos_mes_ids
    idp = beneficiarios_ids.split(',').select {|pid|

      c = Cor1440Gen::Asistencia.joins(:actividad).joins(:persona).
        joins(
          'JOIN cor1440_gen_actividad_actividadpf '\
          'ON cor1440_gen_actividad_actividadpf.actividad_id=cor1440_gen_asistencia.actividad_id'\
          ' AND cor1440_gen_actividad_actividadpf.actividadpf_id='+self.actividadpf_id.to_s
        ).where(
          'cor1440_gen_actividad.fecha < ? ', 
          self.fecha.at_beginning_of_month
        ).where('msip_persona.id = ?', pid.to_i).
        where(
          'cor1440_gen_actividad.fecha >= ? ',
          self.fecha.at_beginning_of_year
        ) # Definicion de nuevo aumentada

      # Definicion de nuevo si usaran detalle financiero
      #c = ::Detallefinanciero.joins(:actividad).joins(:persona).where(
      #  proyectofinanciero_id: self.proyectofinanciero_id).where(
      #    actividadpf_id: self.actividadpf_id).where(
      #      'cor1440_gen_actividad.fecha < ? ' +
      #      'OR (cor1440_gen_actividad.fecha = ? '+
      #      'AND detallefinanciero.id < ?)', self.fecha, self.fecha, 
      #      self.detallefinanciero_id).
      #      where('msip_persona.id = ?', pid.to_i)
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
      p = Msip::Persona.find(ip)
      yield(p)
    }
    idv.sort.join(',')
  end

  def beneficiarios_nuevos_colombianos_retornados_ids
    return beneficiarios_nuevos_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 16
    }
  end

  def beneficiarios_nuevos_comunidades_de_acogida_ids
    return beneficiarios_nuevos_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 13
    }
  end

  def beneficiarios_nuevos_en_transito_ids
    return beneficiarios_nuevos_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 11
    }
  end

  def beneficiarias_nuevas_mujeres_adultas_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 18, nil)
  end

  def beneficiarias_nuevas_mujeres_0_5_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 0, 5)
  end

  def beneficiarias_nuevas_mujeres_6_12_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 6, 12)
  end

  def beneficiarias_nuevas_mujeres_13_17_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 13, 17)
  end

  def beneficiarias_nuevas_mujeres_18_59_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 18, 59)
  end

  def beneficiarias_nuevas_mujeres_60_o_mas_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_femenino], 60, nil)
  end

  def beneficiarios_nuevos_hombres_adultos_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 18, nil)
  end

  def beneficiarios_nuevos_hombres_0_5_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 0, 5)
  end

  def beneficiarios_nuevos_hombres_6_12_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 6, 12)
  end

  def beneficiarios_nuevos_hombres_13_17_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 13, 17)
  end

  def beneficiarios_nuevos_hombres_18_59_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 18, 59)
  end

  def beneficiarios_nuevos_hombres_60_o_mas_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_masculino], 60, nil)
  end

  def beneficiarios_nuevos_sinsexo_adultos_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_sininformacion], 60, nil)
  end

  def beneficiarios_nuevos_sinsexo_menores_y_se_ids
    beneficiarios_nuevos_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_sininformacion], nil, 17, false)
  end

  def beneficiarios_nuevos_lgbti_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      p.victima.any? { |v| 
        (v.victimasjr.fechadesagregacion.nil? ||
         v.victimasjr.fechadesagregacion <= finmes) &&
        v.orientacionsexual != 'H' && 
        v.orientacionsexual != "S"
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

  def beneficiarias_nuevas_ninas_adolescentes_y_se_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      p.sexo == Msip::Persona::convencion_sexo[:sexo_femenino] &&
      (p.anionac.nil? ||
        Sivel2Gen::RangoedadHelper::edad_de_fechanac_fecha(
          p.anionac, p.mesnac, p.dianac,
          finmes.year, finmes.month, finmes.day) < 18
      )
    }
  end

  def beneficiarios_nuevos_ninos_adolescentes_y_se_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_nuevos_condicion_ids {|p|
      p.sexo == Msip::Persona::convencion_sexo[:sexo_masculino] &&
      (p.anionac.nil? ||
        Sivel2Gen::RangoedadHelper::edad_de_fechanac_fecha(
          p.anionac, p.mesnac, p.dianac,
          finmes.year, finmes.month, finmes.day) < 18
      )
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


  def beneficiarios_nuevos_pendulares_ids
    return beneficiarios_nuevos_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 12
    }
  end

  def beneficiarios_nuevos_sinperfilpoblacional_ids
    return beneficiarios_nuevos_condicion_ids {|p|
      p.ultimoperfilorgsocial_id.nil?
    }
  end


  def beneficiarios_nuevos_victimas_ids
    return beneficiarios_nuevos_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 14
    }
  end

  def beneficiarios_nuevos_victimasdobleafectacion_ids
    return beneficiarios_nuevos_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 15
    }
  end

  def beneficiarios_nuevos_vocacion_permanencia_ids
    return beneficiarios_nuevos_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 10
    }
  end

  def beneficiarios_otra_etnia_ids
    finmes = actividad.fecha.end_of_month
    return beneficiarios_condicion_ids {|p|
      e = GifmmHelper::etnia_de_beneficiario(p, finmes)
      e == 'ROM' ||
         e == 'MESTIZO' ||
         e == 'SIN INFORMACIÓN' ||
         e == ''
    }
  end

  def asistentes_pendulares_ids
    return asistentes_condicion_ids {|p|
      p.perfilorgsocial_id == 12
    }
  end

  def beneficiarios_pendulares_ids
    return beneficiarios_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 12
    }
  end

  def asistentes_sinperfilpoblacional_ids
    return asistentes_condicion_ids {|a|
      a.perfilorgsocial_id.nil?
    }
  end


  def beneficiarios_sinperfilpoblacional_ids
    debugger
    return beneficiarios_condicion_ids {|p|
      p.ultimoperfilorgsocial_id.nil?
    }
  end

  def beneficiarios_sinsexo_adultos_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_sininformacion], 60, nil)
  end

  def beneficiarios_sinsexo_menores_y_se_ids
    beneficiarios_condicion_sexo_edad_ids(
      Msip::Persona::convencion_sexo[:sexo_sininformacion], nil, 17, false)
  end

  def asistentes_victimas_ids
    return asistentes_condicion_ids {|p|
      p.perfilorgsocial_id == 14
    }
  end

  def beneficiarios_victimas_ids
    return beneficiarios_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 14
    }
  end

  def asistentes_victimasdobleafectacion_ids
    return asistentes_condicion_ids {|p|
      p.perfilorgsocial_id == 15
    }
  end

  def beneficiarios_victimasdobleafectacion_ids
    return beneficiarios_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 15
    }
  end

  def asistentes_vocacion_permanencia_ids
    return asistentes_condicion_ids {|p|
      p.perfilorgsocial_id == 10
    }
  end

  def beneficiarios_vocacion_permanencia_ids
    return beneficiarios_condicion_ids {|p|
      p.ultimoperfilorgsocial_id == 10
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
    puts "** ::ConsgiffmExp.rb atr=#{atr.to_s.parameterize}"

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
        r="<a href='#{Rails.application.routes.url_helpers.msip_path + 
        'personas/' + i.to_s}' target='_blank'>#{i.to_s}</a>"
        r.html_safe
      }.join(", ".html_safe).html_safe
      return "#{bids.count} : #{enlaces}".html_safe
    end


    m =/^beneficiari(.*)enlaces$/.match(atr.to_s)
    if m && respond_to?("beneficiari#{m[1].parameterize}ids")
      bids = send("beneficiari#{m[1].parameterize}ids").split(',')
      return bids.map {|i|
        r="<a href='#{Rails.application.routes.url_helpers.msip_path + 
        'personas/' + i.to_s}' target='_blank'>#{i.to_s}</a>"
        r.html_safe
      }.join(", ".html_safe).html_safe
    end

    case atr.to_sym
    when :actividad_fecha_mes
      self.actividad.fecha ? self.actividad.fecha.month : ''

    when :actividad_id
      self.actividad_id

    when :actividad_observaciones
      self.actividad.observaciones

    when :actividad_proyectofinanciero
      self.actividad.proyectofinanciero ? 
        self.actividad.proyectofinanciero.map(&:nombre).join('; ') : ''

    when :actividad_responsable
      self.actividad.responsable.nusuario

    when :actividad_resultado
      self.actividad.resultado

    when :estado
      'En proceso'

    when :mes
      actividad.fecha ? 
        Msip::FormatoFechaHelper::MESES[actividad.fecha.month] : ''

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

  CONSULTA='consgifmm_exp'

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
    "SELECT consgifmm.id AS consgifmm_id,
      consgifmm.beneficiarios_ids,
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
      mungifmm.nombre AS municipio_gifmm,
      (SELECT nombre FROM msip_oficina WHERE id=cor1440_gen_actividad.oficina_id LIMIT 1) AS oficina,
      cor1440_gen_actividad.nombre AS actividad_nombre
      FROM consgifmm
      JOIN cor1440_gen_actividad ON
        consgifmm.actividad_id=cor1440_gen_actividad.id
      JOIN cor1440_gen_actividad_actividadpf ON
        consgifmm.actividadpf_id = cor1440_gen_actividad_actividadpf.actividadpf_id AND
        cor1440_gen_actividad.id=cor1440_gen_actividad_actividadpf.actividad_id
      JOIN cor1440_gen_actividadpf ON
        cor1440_gen_actividadpf.id=cor1440_gen_actividad_actividadpf.actividadpf_id
      JOIN cor1440_gen_proyectofinanciero ON
        cor1440_gen_actividadpf.proyectofinanciero_id=cor1440_gen_proyectofinanciero.id
      LEFT JOIN detallefinanciero ON
        consgifmm.detallefinanciero_id=cor1440_gen_actividad.id AND
        detallefinanciero.actividad_id=cor1440_gen_actividad.id
      LEFT JOIN msip_ubicacionpre ON
        cor1440_gen_actividad.ubicacionpre_id=msip_ubicacionpre.id
      LEFT JOIN msip_departamento ON
        msip_ubicacionpre.departamento_id=msip_departamento.id
      LEFT JOIN depgifmm ON
        msip_departamento.deplocal_cod=depgifmm.id
      LEFT JOIN msip_municipio ON
        msip_ubicacionpre.municipio_id=msip_municipio.id
      LEFT JOIN mungifmm ON
        (msip_departamento.deplocal_cod*1000+msip_municipio.munlocal_cod)=
          mungifmm.id
      WHERE cor1440_gen_actividadpf.indicadorgifmm_id IS NOT NULL
      AND (detallefinanciero.proyectofinanciero_id IS NULL OR
        detallefinanciero.proyectofinanciero_id=cor1440_gen_actividadpf.proyectofinanciero_id)
      AND (detallefinanciero.actividadpf_id IS NULL OR
        detallefinanciero.actividadpf_id=cor1440_gen_actividadpf.id)
    "
  end


  def self.crea_consulta(ordenar_por = nil, ids)
    if ARGV.include?("db:migrate")
      return
    end
    if ActiveRecord::Base.connection.data_source_exists? CONSULTA
      ActiveRecord::Base.connection.execute(
        "DROP MATERIALIZED VIEW IF EXISTS #{CONSULTA}")
    end
    w = 'AND consgifmm.id IN (' + 
      (ids.map {|sid| "'#{sid}'"}).join(',') + ') '
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


  def self.refresca_consulta(ordenar_por = nil, ids)
    #if !ActiveRecord::Base.connection.data_source_exists? "#{CONSULTA}"
      crea_consulta(ordenar_por = nil, ids)
    #else
    #  ActiveRecord::Base.connection.execute(
    #    "REFRESH MATERIALIZED VIEW #{CONSULTA}")
    #end
  end

end

