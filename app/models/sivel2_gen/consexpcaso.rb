require 'sivel2_gen/concerns/models/consexpcaso'

class Sivel2Gen::Consexpcaso < ActiveRecord::Base
  include Sivel2Gen::Concerns::Models::Consexpcaso


  belongs_to :casosjr, class_name: 'Sivel2Sjr::Casosjr',
    primary_key: 'caso_id', foreign_key: 'caso_id', optional: false

  has_many :victimasjr, through: :casosjr,
    class_name: 'Sivel2Sjr::Victimasjr'

  def self.consulta_consexpcaso 
    "SELECT conscaso.*
             FROM public.sivel2_gen_conscaso AS conscaso"
  end

  def self.edad_familiar(tiempo, numfamiliar)
    "(SELECT #{tiempo} 
           FROM public.msip_persona AS persona, 
           public.sivel2_gen_victima AS victima WHERE persona.id=victima.persona_id 
         AND victima.caso_id=caso.id LIMIT 1 OFFSET #{numfamiliar})"
  end

  def self.consulta_consexpcaso
    c= "SELECT conscaso.caso_id,
        conscaso.fecharec AS fecharecepcion,
        conscaso.nusuario AS asesor,
        conscaso.oficina,
        conscaso.fecha AS fechadespemb,
        conscaso.expulsion,
        conscaso.llegada,
        conscaso.memo AS descripcion,
        CAST(EXTRACT(MONTH FROM ultimaatencion.fecha) AS INTEGER) AS ultimaatencion_mes,
        conscaso.ultimaatencion_fecha,
        conscaso.contacto,
        contacto.nombres AS contacto_nombres,
        contacto.apellidos AS contacto_apellidos,
        (COALESCE(tdocumento.sigla, '') || ' ' || contacto.numerodocumento) 
          AS contacto_identificacion,
        contacto.sexo AS contacto_sexo,
        msip_edad_de_fechanac_fecharef(
          contacto.anionac, contacto.mesnac, contacto.dianac, 
          CAST(EXTRACT(YEAR FROM conscaso.fecharec) AS INTEGER),
          CAST(EXTRACT(MONTH FROM conscaso.fecharec) AS INTEGER),
          CAST(EXTRACT(DAY FROM conscaso.fecharec) AS INTEGER))
          AS contacto_edad_fecha_recepcion,"
    [1, 2, 3, 4, 5].each do |num| 
      c+= "msip_edad_de_fechanac_fecharef(" + 
        edad_familiar('anionac', num) + ',' +
        edad_familiar('mesnac', num) + ',' +
        edad_familiar('dianac', num) + ',' +
        "CAST(EXTRACT(YEAR FROM conscaso.fecharec) AS INTEGER),
            CAST(EXTRACT(MONTH FROM conscaso.fecharec) AS INTEGER),
            CAST(EXTRACT(DAY FROM conscaso.fecharec) AS INTEGER))
            AS familiar#{num}_edad_fecha_recepcion,

            msip_edad_de_fechanac_fecharef(" +
            edad_familiar('anionac', num) + ',' +
            edad_familiar('mesnac', num) + ',' +
            edad_familiar('dianac', num) + ',' +
            "CAST(EXTRACT(YEAR FROM conscaso.ultimaatencion_fecha) AS INTEGER),
            CAST(EXTRACT(MONTH FROM conscaso.ultimaatencion_fecha) AS INTEGER),
            CAST(EXTRACT(DAY FROM conscaso.ultimaatencion_fecha) AS INTEGER))
            AS familiar#{num}_edad_ultimaatencion,
      "
    end
    convsexo = Msip::Persona::convencion_sexo
    c+= "(SELECT nombre FROM public.sivel2_gen_rangoedad 
          WHERE fechadeshabilitacion IS NULL 
          AND limiteinferior<=
            msip_edad_de_fechanac_fecharef(
            contacto.anionac, contacto.mesnac, contacto.dianac, 
            CAST(EXTRACT(YEAR FROM conscaso.fecharec) AS INTEGER),
            CAST(EXTRACT(MONTH FROM conscaso.fecharec) AS INTEGER),
            CAST(EXTRACT(DAY FROM conscaso.fecharec) AS INTEGER))
          AND limitesuperior>=
            msip_edad_de_fechanac_fecharef(
            contacto.anionac, contacto.mesnac, contacto.dianac, 
            CAST(EXTRACT(YEAR FROM conscaso.fecharec) AS INTEGER),
            CAST(EXTRACT(MONTH FROM conscaso.fecharec) AS INTEGER),
            CAST(EXTRACT(DAY FROM conscaso.fecharec) AS INTEGER))
          LIMIT 1) AS contacto_rangoedad_fecha_recepcion,
        msip_edad_de_fechanac_fecharef(
          contacto.anionac, contacto.mesnac, contacto.dianac, 
          CAST(EXTRACT(YEAR FROM conscaso.fecha) AS INTEGER),
          CAST(EXTRACT(MONTH FROM conscaso.fecha) AS INTEGER),
          CAST(EXTRACT(DAY FROM conscaso.fecha) AS INTEGER))
          AS contacto_edad_fecha_salida,
        (SELECT nombre FROM public.sivel2_gen_rangoedad 
          WHERE fechadeshabilitacion IS NULL 
          AND limiteinferior<=
            msip_edad_de_fechanac_fecharef(
            contacto.anionac, contacto.mesnac, contacto.dianac, 
            CAST(EXTRACT(YEAR FROM conscaso.fecha) AS INTEGER),
            CAST(EXTRACT(MONTH FROM conscaso.fecha) AS INTEGER),
            CAST(EXTRACT(DAY FROM conscaso.fecha) AS INTEGER))
          AND limitesuperior>=
            msip_edad_de_fechanac_fecharef(
            contacto.anionac, contacto.mesnac, contacto.dianac, 
            CAST(EXTRACT(YEAR FROM conscaso.fecha) AS INTEGER),
            CAST(EXTRACT(MONTH FROM conscaso.fecha) AS INTEGER),
            CAST(EXTRACT(DAY FROM conscaso.fecha) AS INTEGER))
          LIMIT 1) AS contacto_rangoedad_fecha_salida,
        COALESCE(etnia.nombre, '') AS contacto_etnia,
        ultimaatencion.contacto_edad AS contacto_edad_ultimaatencion,
        (SELECT nombre FROM public.sivel2_gen_rangoedad 
          WHERE fechadeshabilitacion IS NULL 
          AND limiteinferior<=ultimaatencion.contacto_edad AND 
          ultimaatencion.contacto_edad<=limitesuperior LIMIT 1) 
        AS contacto_rangoedad_ultimaatencion,

        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_masculino]}'
          AND rangoedad_id='7') AS beneficiarios_0_5_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_masculino]}'
          AND rangoedad_id='8') AS beneficiarios_6_12_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_masculino]}'
          AND rangoedad_id='9') AS beneficiarios_13_17_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_masculino]}'
          AND rangoedad_id='10') AS beneficiarios_18_26_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_masculino]}'
          AND rangoedad_id='11') AS beneficiarios_27_59_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_masculino]}'
          AND rangoedad_id='12') AS beneficiarios_60m_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_masculino]}'
          AND rangoedad_id='6') AS beneficiarios_se_fecha_salida,

        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_femenino]}'
          AND rangoedad_id='7') AS beneficiarias_0_5_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_femenino]}'
          AND rangoedad_id='8') AS beneficiarias_6_12_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_femenino]}'
          AND rangoedad_id='9') AS beneficiarias_13_17_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_femenino]}'
          AND rangoedad_id='10') AS beneficiarias_18_26_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_femenino]}'
          AND rangoedad_id='11') AS beneficiarias_27_59_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_femenino]}'
          AND rangoedad_id='12') AS beneficiarias_60m_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_femenino]}'
          AND rangoedad_id='6') AS beneficiarias_se_fecha_salida,

        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_sininformacion]}'
          AND rangoedad_id='7') AS beneficiarios_ss_0_5_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_sininformacion]}'
          AND rangoedad_id='8') AS beneficiarios_ss_6_12_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_sininformacion]}'
          AND rangoedad_id='9') AS beneficiarios_ss_13_17_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_sininformacion]}'
          AND rangoedad_id='10') AS beneficiarios_ss_18_26_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_sininformacion]}'
          AND rangoedad_id='11') AS beneficiarios_ss_27_59_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_sininformacion]}'
          AND rangoedad_id='12') AS beneficiarios_ss_60m_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_sininformacion]}'
          AND rangoedad_id='6') AS beneficiarios_ss_se_fecha_salida,

        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_intersexual]}'
          AND rangoedad_id='7') AS beneficiarios_os_0_5_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_intersexual]}'
          AND rangoedad_id='8') AS beneficiarios_os_6_12_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_intersexual]}'
          AND rangoedad_id='9') AS beneficiarios_os_13_17_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_intersexual]}'
          AND rangoedad_id='10') AS beneficiarios_os_18_26_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_intersexual]}'
          AND rangoedad_id='11') AS beneficiarios_os_27_59_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_intersexual]}'
          AND rangoedad_id='12') AS beneficiarios_os_60m_fecha_salida,
        (SELECT COUNT(*) FROM 
          public.sivel2_gen_victima AS victima JOIN public.msip_persona ON
            msip_persona.id=victima.persona_id
          WHERE victima.caso_id=caso.id AND msip_persona.sexo='#{convsexo[:sexo_intersexual]}'
          AND rangoedad_id='6') AS beneficiarios_os_se_fecha_salida,


        ARRAY_TO_STRING(ARRAY(SELECT supracategoria.tviolencia_id || ':' || 
            categoria.supracategoria_id || ':' || categoria.id || ' ' ||
            categoria.nombre FROM public.sivel2_gen_categoria AS categoria, 
            public.sivel2_gen_supracategoria AS supracategoria,
            public.sivel2_gen_acto AS acto
            WHERE categoria.id=acto.categoria_id
            AND supracategoria.id=categoria.supracategoria_id
            AND acto.caso_id=caso.id), ', ')
          AS tipificacion,
        ARRAY_TO_STRING(ARRAY(SELECT nombres || ' ' || apellidos 
          FROM public.msip_persona AS persona, 
          public.sivel2_gen_victima AS victima WHERE persona.id=victima.persona_id 
          AND victima.caso_id=caso.id), ', ')
        AS victimas,
        ARRAY_TO_STRING(ARRAY(SELECT departamento.nombre ||  ' / ' 
          || municipio.nombre 
          FROM public.msip_ubicacion AS ubicacion 
          LEFT JOIN public.msip_departamento AS departamento 
            ON (ubicacion.departamento_id = departamento.id)
          LEFT JOIN public.msip_municipio AS municipio 
            ON (ubicacion.municipio_id=municipio.id)
          WHERE ubicacion.caso_id=caso.id), ', ')
        AS ubicaciones, 
        ARRAY_TO_STRING(ARRAY(SELECT nombre 
          FROM public.sivel2_gen_presponsable AS presponsable, 
          public.sivel2_gen_caso_presponsable AS caso_presponsable
          WHERE presponsable.id=caso_presponsable.presponsable_id
          AND caso_presponsable.caso_id=caso.id), ', ')
        AS presponsables, 
        casosjr.memo1612 as memo1612,
        ultimaatencion.actividad_id AS ultimaatencion_actividad_id
        FROM public.sivel2_gen_conscaso AS conscaso
        JOIN public.sivel2_sjr_casosjr AS casosjr ON casosjr.caso_id=conscaso.caso_id
        JOIN public.sivel2_gen_caso AS caso ON casosjr.caso_id = caso.id 
        JOIN public.msip_oficina AS oficina ON oficina.id=casosjr.oficina_id
        JOIN public.usuario ON usuario.id = casosjr.asesor
        JOIN public.msip_persona as contacto ON contacto.id=casosjr.contacto_id
        LEFT JOIN public.msip_tdocumento AS tdocumento ON 
            tdocumento.id=contacto.tdocumento_id
        JOIN public.sivel2_gen_victima AS vcontacto ON 
            vcontacto.persona_id = contacto.id AND vcontacto.caso_id = caso.id
        LEFT JOIN public.sivel2_gen_etnia AS etnia ON
            vcontacto.etnia_id=etnia.id
        LEFT JOIN public.sivel2_sjr_ultimaatencion AS ultimaatencion ON
            ultimaatencion.caso_id = caso.id
    "
  end


  # Retorna valores a campos de formularios incrustados en 
  # actividades que tengan el caso en el listado de casos
  def valores_campos_respuestafor_actividades(campo_id)
    resp_ids = casosjr.actividad.joins(:respuestafor).
      pluck('mr519_gen_respuestafor.id')
    Mr519Gen::Valorcampo.joins(:respuestafor).
      where('mr519_gen_respuestafor.id IN (?)', resp_ids).
      where(campo_id: campo_id)
  end

  def resp_ultimaatencion(formulario_id, campo_id)
    ultatencion = Cor1440Gen::Actividad.
      where(id: ultimaatencion_actividad_id).take
    if !ultatencion
      return "Problema no existe actividad #{ultimaatencion_actividad_id}"
    end
    r =  Mr519Gen::ApplicationHelper.presenta_valor(
      ultatencion, formulario_id, campo_id)
    r ? r : ''
  end


  # Retorna cantidad de víctimas del caso caso_id
  # que tienen el sexo dado con edad entre inf y sup para la fecha dada
  # de la actividad con id actividad_id.
  # Caso especiales: 
  #   * si inf es nil peor sup no busca víctimas hasta de sup años
  #   * si inf no es nil pero sup es nil búsca víctimas desde inf años
  #   * si tanto inf como sup son nil busca víctimas sin edad
  #
  # Caso especial si inf y sup son nil busca víctimas sin edad
  def self.poblacion_a_fecha(caso_id, anio, mes, dia, sexo, inf, sup)
    cond_edad = ''
    if inf && inf >= 0
      cond_edad += " AND edad>='#{inf.to_i}'"
    end
    if sup && sup >= 0
      cond_edad += " AND edad<='#{sup.to_i}'"
    end
    if !inf && !sup
      cond_edad += " AND edad IS NULL"
    end

    r=Sivel2Gen::Victima.connection.execute("
        SELECT COUNT(*) FROM (
          SELECT v.id, msip_edad_de_fechanac_fecharef(
            p.anionac, p.mesnac, p.dianac,
            '#{anio.to_i}', '#{mes.to_i}', '#{dia.to_i}') AS edad 
          FROM public.sivel2_gen_victima AS v
          JOIN public.msip_persona AS p ON p.id=v.persona_id
          WHERE v.caso_id='#{caso_id.to_i}' AND 
           p.sexo='#{sexo[0]}') AS sub
        WHERE TRUE=TRUE 
        #{cond_edad}")
                                            return   r[0]['count'].to_i
  end

  # Retorna cantidad de víctimas del caso caso_id
  # que tienen el sexo dado con edad entre inf y sup para la fecha
  # de la actividad con id actividad_id.
  # Caso especiales: 
  #   * si inf es nil peor sup no busca víctimas hasta de sup años
  #   * si inf no es nil pero sup es nil búsca víctimas desde inf años
  #   * si tanto inf como sup son nil busca víctimas sin edad
  #
  # Caso especial si inf y sup son nil busca víctimas sin edad
  def self.poblacion_ultimaatencion(caso_id, actividad_id, sexo, inf, sup)
    ultatencion = Cor1440Gen::Actividad.
      where(id: actividad_id).take
    if !ultatencion
      return "Problema no existe actividad #{actividad_id}"
    end

    poblacion_a_fecha(
      caso_id, ultatencion.fecha.year, ultatencion.fecha.month,
      ultatencion.fecha.day, sexo, inf, sup)
  end


  def presenta(atr)
    casosjr = Sivel2Sjr::Casosjr.find(caso_id)
    contacto =  Msip::Persona.find(casosjr.contacto_id)
    victimac = Sivel2Gen::Victima.where(persona_id: contacto.id)[0]
    victimasjrc = Sivel2Sjr::Victimasjr.where(victima_id: victimac.id)[0]

    ## 3 primeras ubicaciones
    cubidob = ['pais', 'departamento', 'municipio', 'clase', 'tsitio']
    cubisim = ['longitud', 'latitud', 'sitio', 'lugar']
    cubi = /ubicacion(.*)$/.match(atr.to_s)
    ubicaciones = Sivel2Gen::Caso.find(caso_id).ubicacion
    if cubi
      numero = cubi[1].split("_")[0]
      campo = cubi[1].split("_")[1]
      if ubicaciones.count >= numero.to_i
        ubicacion = ubicaciones[numero.to_i-1]
        if ubicacion
          if cubidob.include? campo
            return ubicacion.send(campo) ? ubicacion.send(campo).nombre : ''
          end
          if cubisim.include? campo
            return ubicacion.send(campo) ?  ubicacion.send(campo) : ''
          end
        end
      else
        return ''
      end
    end
    ## 3 primeros presuntos responsables
    cprdob = ['presponsable']
    cprsim = ['bloque', 'frente', 'brigada', 'batallon', 'division', 'otro']
    cpr = /presponsable(.*)$/.match(atr.to_s)
    presponsables = Sivel2Gen::CasoPresponsable.where(caso_id: caso_id)
    if cpr
      numero = cpr[1].split("_")[0]
      campo = cpr[1].split("_")[1]
      if !presponsables.empty?
        presponsable = presponsables[numero.to_i-1]
        if presponsable
          if cprdob.include? campo
            return presponsable.send(campo) ? presponsable.send(campo).nombre : ''
          end
          if cprsim.include? campo
            return presponsable.send(campo) ?  presponsable.send(campo) : ''
          end
        else
          if cprdob.include? campo or cprsim.include? campo
            return ''
          end
        end
      else
        if cprdob.include? campo or cprsim.include? campo
          return ''
        end
      end
    end

    ## 5 primeros actos
    cacto = /acto(.*)$/.match(atr.to_s)
    actos = Sivel2Gen::Acto.where(caso_id: caso_id)
    if cacto
      numero = cacto[1].split("_")[0]
      campo = cacto[1].split("_")[1]
      if !actos.empty?
        acto = actos[numero.to_i-1]
        if acto
          actosjr = Sivel2Sjr::Actosjr.where(acto_id: acto.id)[0]
          case campo
          when 'presponsable', 'categoria'
            return acto.send(campo) ? acto.send(campo).nombre : ''
          when 'persona'
            return acto.send(campo) ? acto.send(campo).nombres : ''
          when 'fecha'
            return actosjr ? actosjr.fecha : ''
          when 'desplazamiento'
            if !actosjr || !actosjr.desplazamiento_id
              return ''
            end
            desplaza = Sivel2Sjr::Desplazamiento.
              where(id: actosjr.desplazamiento_id)
            return desplaza.count > 0 ? desplaza[0].fechaexpulsion : ''
          end
        else
          case campo
          when 'presponsable', 'categoria', 'persona', 'fecha', 'desplazamiento'
            return ''
          end
        end
      else
        case campo
        when 'presponsable', 'categoria', 'persona', 'fecha', 'desplazamiento'
          return ''
        end
      end
    end

    ## 3 primeros presuntos responsables
    cprdob = ['presponsable']
    cprsim = ['bloque', 'frente', 'brigada', 'batallon', 'division', 'otro']
    cpr = /presponsable(.*)$/.match(atr.to_s)
    presponsables = Sivel2Gen::CasoPresponsable.where(caso_id: caso_id)
    if cpr
      numero = cpr[1].split("_")[0]
      campo = cpr[1].split("_")[1]
      if !presponsables.empty?
        presponsable = presponsables[numero.to_i-1]
        if presponsable
          if cprdob.include? campo
            return presponsable.send(campo) ? presponsable.send(campo).nombre : ''
          end
          if cprsim.include? campo
            return presponsable.send(campo) ?  presponsable.send(campo) : ''
          end
        else
          if cprdob.include? campo or cprsim.include? campo
            return ''
          end
        end
      else
        if cprdob.include? campo or cprsim.include? campo
          return ''
        end
      end
    end

    # Desplazamiento del Caso
    desplaza_simples = ::Ability::CAMPOS_DESPLAZA_SIMPLES
    desplaza_rela = ::Ability::CAMPOS_DESPLAZA_RELA
    desplaza_multi = ::Ability::CAMPOS_DESPLAZA_MULTI
    desplaza_bool = ::Ability::CAMPOS_DESPLAZA_BOOL
    desplaza_espe = ::Ability::CAMPOS_DESPLAZA_ESPECIALES
    desplazamiento = Sivel2Sjr::Desplazamiento.where(caso_id: caso_id)[0]
    if desplaza_simples.include? atr.to_s
      if desplazamiento
        if atr.to_s == 'declaro'
          case desplazamiento.send(atr.to_s)
          when 'S'
            return 'Si'
          when 'N'
            return 'No'
          when 'R'
            return 'NO SABE / NO RESPONDE'
          end
        else
          return desplazamiento.send(atr.to_s) ? desplazamiento.send(atr.to_s) : ''
        end
      else
        return ''
      end
    end
    if desplaza_rela.include? atr.to_s
      if desplazamiento
        return desplazamiento.send(atr.to_s).nil? ? "No aplica o nulo" : desplazamiento.send(atr.to_s).nombre
      else
        return ''
      end
    end
    if desplaza_multi.include? atr.to_s
      if desplazamiento
        return desplazamiento.send(atr.to_s).count > 0 ? desplazamiento.send(atr.to_s).pluck(:nombre).join(", ") : ''
      else
        return ''
      end
    end
    if desplaza_bool.include? atr.to_s
      if desplazamiento
        if desplazamiento.send(atr.to_s)
          return "Si"
        else
          return desplazamiento.send(atr.to_s).nil? ? 'No responde' : 'No'
        end
      else
        return ''
      end
    end
    if desplaza_espe.include? atr.to_s
      if desplazamiento
        exp = desplazamiento.expulsion
        lle = desplazamiento.llegada
        res = ::DesplazamientoHelper.modageo_desplazamiento(exp, lle)
        case atr.to_s
        when 'expulsion', 'llegada'
          return desplazamiento.send(atr.to_s) ? Msip::UbicacionHelper.formato_ubicacion(desplazamiento.send(atr.to_s)) : ''
        when 'modalidadgeo'
          return res ? res[0] : ''
        when 'submodalidadgeo'
          return res ? res[1] : ''
        end
      else
        return ''
      end
    end

    ## 5 Victimas
    cpersonasimple = [
      'nombres', 'apellidos', 'sexo', 'anionac', 'mesnac', 'dianac',
      'numerodocumento']
    cpersonadoble = ['tdocumento', 'pais', 'departamento', 'municipio', 'clase']
    cvictimasimple = [ 'orientacionsexual']
    cvictimadoble = [ 'etnia', 'profesion', 'organizacion', 
                      'filiacion', 'vinculoestado']
    cvictimasjrbool = [
      'cabezafamilia', 'tienesisben', 'asisteescuela',
      'actualtrabajando']
    cvictimasjrdoble = [
      'maternidad', 'estadocivil', 'discapacidad', 'rolfamilia', 
      'regimensalud', 'escolaridad']
    especiales = ['actividadoficio', 'numeroanexos', 'numeroanexosconsen', 'edad_fecha_recepcion', 'edad_ultimaatencion']
    orientaciones = Msip::Persona::ORIENTACION_OPCIONES
    m = /familiar(.*)$/.match(atr.to_s)
    if m
      numero = m[1].split("_")[0]
      campo = m[1].split("_")[1]
      victimasf = Sivel2Gen::Victima.where(caso_id: caso_id).where.not(persona_id: contacto.id).order(:id)
      if !victimasf.empty?
        victimaf = victimasf[numero.to_i-1]
        if !victimaf.nil?
          personaf = Msip::Persona.find(victimaf.persona_id)
          victimasjrf = Sivel2Sjr::Victimasjr.where(victima_id: victimaf.id)[0]
          if cpersonasimple.include? campo
            return personaf.send(campo) ? personaf.send(campo) : ''
          end
          if cpersonadoble.include? campo
            return personaf.send(campo) ? personaf.send(campo).nombre : ''
          end
          if cvictimasimple.include? campo
            if victimaf.send(campo) and campo == "orientacionsexual"
              orientaciones.each do |ori|
                if ori[1].to_s == victimaf.send(campo).to_s
                  return ori[0].to_s
                end
              end
            else
              return victimaf.send(campo) ? victimaf.send(campo) : ''
            end
          end
          if cvictimadoble.include? campo
            return victimaf.send(campo) ? victimaf.send(campo).nombre : ''
          end
          if cvictimasjrdoble.include? campo
            return victimasjrf.send(campo) ? victimasjrf.send(campo).nombre : ''
          end
          if cvictimasjrbool.include? campo
            if victimasjrf.send(campo)
              return "Si"
            else 
              return victimasjrf.send(campo).nil? ? "No responde" : "No"
            end
          end
          if especiales.include? campo
            case campo.to_s
            when 'actividadoficio'
              aof = Sivel2Gen::Actividadoficio.find(victimasjrf.actividadoficio_id)
              return aof ? aof.nombre : ''
            when 'numeroanexos'
              return Sivel2Gen::AnexoVictima.where(victima_id: victimaf.id).
                where.not(tipoanexo_id: 11).count
            when 'numeroanexosconsen'
              return Sivel2Gen::AnexoVictima.where(
                victima_id: victimaf.id, tipoanexo_id: 11).count
            when 'edad_fecha_recepcion'
              byebug 
            when 'edad_ultimaatencion'
            end
          end
        else
          return ''
        end
      else
        return ''
      end
    end

    ## 5 Etiquetas
    ceti = /etiqueta(.*)$/.match(atr.to_s)
    etiquetas = Sivel2Gen::CasoEtiqueta.where(caso_id: caso_id)
    if ceti
      numero = ceti[1].split("_")[0]
      campo = ceti[1].split("_")[1]
      if !etiquetas.empty?
        etiqueta = etiquetas[numero.to_i-1]
        if etiqueta
          case campo
          when 'etiqueta'
            return etiqueta.send(campo) ? etiqueta.send(campo).nombre : ''
          when 'usuario'
            return etiqueta.send(campo) ? etiqueta.send(campo).nusuario : ''
          when 'fecha', 'observaciones'
            return etiqueta ? etiqueta.send(campo) : ''
          end
        else
          case campo
          when 'etiqueta', 'usuario', 'fecha', 'observaciones'
            return ''
          end
        end
      else
        case campo
        when 'etiqueta', 'usuario', 'fecha', 'observaciones'
          return ''
        end
      end
    end
    ## Migración del caso
    migra_simples = ::Ability::CAMPOS_MIGRA_SIMPLES
    migra_rela = ::Ability::CAMPOS_MIGRA_RELA
    migra_multi = ::Ability::CAMPOS_MIGRA_MULTI
    migracion = Sivel2Sjr::Migracion.where(caso_id: caso_id)[0]
    if migra_simples.include? atr.to_s
      if migracion
        return migracion.send(atr.to_s).nil? ? '' : migracion.send(atr.to_s)
      else 
        return ''
      end
    end
    if migra_rela.include? atr.to_s
      if migracion
        case atr.to_s
        when 'estatus_migratorio'
          m = migracion.send('statusmigratorio')
        else
          m = migracion.send(atr.to_s)
        end
        return m.nil? ? '' : m.nombre
      else 
        return ''
      end
    end
    if migra_multi.include? atr.to_s
      if migracion
        if atr.to_s == 'causaagresion'
          causasagresion = migracion.send(atr.to_s).pluck(:nombre)
          causasagresion.each_with_index do |cag, index|
            if cag == 'Otra'
              otracausa = migracion.otracausaagresion
              causasagresion[index] = "Otra: #{otracausa}"
            end
          end
          return migracion.send(atr.to_s).count > 0  ? causasagresion.join(", ") : '' 
        elsif atr.to_s == 'causaagrpais'
          causasagresion = migracion.send(atr.to_s).pluck(:nombre)
          causasagresion.each_with_index do |cag, index|
            if cag == 'Otra'
              otracausa = migracion.otracausagrpais
              causasagresion[index] = "Otra: #{otracausa}"
            end
          end
          return migracion.send(atr.to_s).count > 0  ? causasagresion.join(", ") : '' 
        else
          return migracion.send(atr.to_s).count > 0  ? migracion.send(atr.to_s).pluck(:nombre).join(", ") : '' 
        end
      else 
        return ''
      end
    end
    ## 5 Respuestas a Caso
    cres = /respuesta(.*)$/.match(atr.to_s)
    respuestas = Sivel2Sjr::ActividadCasosjr.where(casosjr_id: caso_id)
    if cres
      numero = cres[1].split("_")[0]
      campo = cres[1].split("_")[1]
      if !respuestas.empty?
        respuesta = respuestas[numero.to_i-1]
        if respuesta
          actividad = Cor1440Gen::Actividad.where(id: respuesta.actividad_id)[0]
          case campo
          when 'actividad'
            return actividad ? actividad.id : ''
          when 'fecha'
            return actividad ? actividad.fecha : ''
          when 'proyectofinanciero'
            convenios_ids = Cor1440Gen::ActividadProyectofinanciero.where(actividad_id: actividad.id).pluck(:proyectofinanciero_id)
            proyectosfinancieros = Cor1440Gen::Proyectofinanciero.find(convenios_ids - [10])
            return proyectosfinancieros ? proyectosfinancieros.pluck(:nombre).join(', ') : ''
          when 'actividadpf'
            actividadespf_ids = Cor1440Gen::ActividadActividadpf.where(actividad_id: actividad.id).pluck(:actividadpf_id)
            actividadespf = Cor1440Gen::Actividadpf.find(actividadespf_ids)
            return actividadespf ? actividadespf.pluck(:titulo).join(', ') : ''
          end
        else
          case campo
          when 'actividad', 'fecha', 'proyectofinanciero', 'actividadpf'
            return ''
          end
        end
      else
        case campo
        when 'actividad', 'fecha', 'proyectofinanciero', 'actividadpf'
          return ''
        end
      end
    end
    caso = Sivel2Gen::Caso.find(caso_id)
    convsexo = Msip::Persona::convencion_sexo
    case atr.to_s
    when 'actividades_departamentos'
      lai = casosjr.actividades_con_caso_ids
      Cor1440Gen::Actividad.where(id: lai).map{|a| a.presenta('departamento')}.
        select{|d| d != ''}.uniq.join('. ')

    when 'actividades_municipios'
      lai = casosjr.actividades_con_caso_ids
      Cor1440Gen::Actividad.where(id: lai).map{|a| a.presenta('municipio')}.
        select{|m| m != ''}.uniq.join('. ')

    when 'actividades_perfiles'
      bids = casosjr.beneficiarios_activos.pluck(:persona_id).uniq
      Cor1440Gen::Asistencia.where(persona_id: bids).
        joins(:perfilorgsocial).pluck('msip_perfilorgsocial.nombre').
        uniq.join('. ')

    when 'actividades_a_humanitaria_tipos_de_ayuda'
      bids = casosjr.beneficiarios_activos.pluck(:persona_id).uniq
      dfs = Detallefinanciero.joins(:persona).where(
        'msip_persona.id IN (?)', bids)
      us = dfs.joins(:unidadayuda).pluck('unidadayuda.nombre').uniq
      us.join('. ')

    when 'actividades_a_humanitaria_valor_de_ayuda'
      bids = casosjr.beneficiarios_activos.pluck(:persona_id).uniq
      dfs = Detallefinanciero.joins(:persona).where(
        'msip_persona.id IN (?)', bids)
      suma = 0
      dfs.each do |d|
        cantidad = d.persona_ids.intersection(bids).count
        if d.valorunitario
          suma += cantidad * d.valorunitario
        end
      end
      suma

    when 'actividades_a_humanitaria_modalidades_entrega'
      bids = casosjr.beneficiarios_activos.pluck(:persona_id).uniq
      dfs = Detallefinanciero.joins(:persona).where(
        'msip_persona.id IN (?)', bids)
      us = dfs.joins(:modalidadentrega).pluck('modalidadentrega.nombre').uniq
      us.join('. ')

    when 'actividades_a_humanitarias_convenios_financiados'
      bids = casosjr.beneficiarios_activos.pluck(:persona_id).uniq
      dfs = Detallefinanciero.joins(:persona).where(
        'msip_persona.id IN (?)', bids)
      us = dfs.joins(:proyectofinanciero).
        pluck('cor1440_gen_proyectofinanciero.nombre').uniq
      us.join('. ')

    when 'actividades_asesorias_juridicas'
      vcs = valores_campos_respuestafor_actividades(130)
      r = vcs.map {|v| v.presenta_valor(false)}.uniq.join('. ')
      r += ' - Nota: Para presentar mejor implementar detalle de asesoria '\
        'jurídica por beneficiario (estilo detalle de ayuda humanitaria).'
      r

    when 'actividades_as_juridicas_convenios_financiados'
      vcs = valores_campos_respuestafor_actividades(130)
      rf = vcs.joins(:respuestafor).pluck('mr519_gen_respuestafor.id')
      ac = Cor1440Gen::Actividad.joins(:respuestafor).
        where('mr519_gen_respuestafor.id IN (?)', rf).distinct
      ac.joins(:proyectofinanciero).
        pluck('cor1440_gen_proyectofinanciero.nombre').uniq.join('. ')  +
        ' - Nota: para presentar mejor implementar prerequisito R-2098 '\
        'o mejor aún especificar detalle de asesoria jurídica por '\
        'beneficiario (estilo detalle de ayuda humanitaria).'

    when 'actividades_acompañamientos_psicosociales'
      vcs = valores_campos_respuestafor_actividades(150)
      r = vcs.map {|v| v.presenta_valor(false)}.uniq.join('. ')
      r += ' - Nota: Se presentan otros servicios y asesorias porque '\
        'no se han especificado tipos de acompañamiento psicosocial, y '\
        'de hacerlo deberían especificarse por beneficiario (estilo '\
        'detalle de ayuda humanitaria).'
      r

    when 'actividades_a_psicosociales_convenios_financiados'
      vcs = valores_campos_respuestafor_actividades(150)
      rf = vcs.joins(:respuestafor).pluck('mr519_gen_respuestafor.id')
      ac = Cor1440Gen::Actividad.joins(:respuestafor).
        where('mr519_gen_respuestafor.id IN (?)', rf).distinct
      ac.joins(:proyectofinanciero).
        pluck('cor1440_gen_proyectofinanciero.nombre').uniq.join('. ')  +
        ' - Nota: Se presentan otros convenios en actividades con otros '\
        'servicios y asesorias porque no se han especificado '\
        'acompañamiento psicosocial por beneficiario'


    when 'beneficiarios_0_5_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_masculino], 0, 5)
    when 'beneficiarios_6_12_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_masculino], 6, 12)
    when 'beneficiarios_13_17_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_masculino], 13, 17)
    when 'beneficiarios_18_26_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_masculino], 18, 26)
    when 'beneficiarios_27_59_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_masculino], 27, 59)
    when 'beneficiarios_60m_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_masculino], 60, nil)
    when 'beneficiarios_se_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_masculino], nil, nil)
    when 'beneficiarias_0_5_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_femenino], 0, 5)
    when 'beneficiarias_6_12_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_femenino], 6, 12)
    when 'beneficiarias_13_17_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_femenino], 13, 17)
    when 'beneficiarias_18_26_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_femenino], 18, 26)
    when 'beneficiarias_27_59_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_femenino], 27, 59)
    when 'beneficiarias_60m_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_femenino], 60, nil)
    when 'beneficiarias_se_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_femenino], nil, nil)
    when 'beneficiarios_ss_0_5_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_sininformacion], 0, 5)
    when 'beneficiarios_ss_6_12_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_sininformacion], 6, 12)
    when 'beneficiarios_ss_13_17_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_sininformacion], 13, 17)
    when 'beneficiarios_ss_18_26_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_sininformacion], 18, 26)
    when 'beneficiarios_ss_27_59_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_sininformacion], 27, 59)
    when 'beneficiarios_ss_60m_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_sininformacion], 60, nil)
    when 'beneficiarios_ss_se_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_sininformacion], nil, nil)
    when 'beneficiarios_os_0_5_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_intersexual], 0, 5)
    when 'beneficiarios_os_6_12_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_intersexual], 6, 12)
    when 'beneficiarios_os_13_17_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_intersexual], 13, 17)
    when 'beneficiarios_os_18_26_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_intersexual], 18, 26)
    when 'beneficiarios_os_27_59_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_intersexual], 27, 59)
    when 'beneficiarios_os_60m_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_intersexual], 60, nil)
    when 'beneficiarios_os_se_fecha_recepcion'
      self.class.poblacion_a_fecha(
        caso_id, fecharecepcion.year, fecharecepcion.month, fecharecepcion.day,
        convsexo[:sexo_intersexual], nil, nil)



      ## CONTACTO
    when 'contacto_anionac'
      contacto.anionac ? contacto.anionac : ''
    when 'contacto_mesnac'
      contacto.mesnac ? contacto.mesnac : ''
    when 'contacto_dianac'
      contacto.dianac ? contacto.dianac : ''
    when 'contacto_tdocumento'
      contacto.tdocumento ? contacto.tdocumento.nombre : ''
    when 'contacto_numerodocumento'
      contacto.numerodocumento ? contacto.numerodocumento : ''
    when 'contacto_pais'
      contacto.pais ? contacto.pais.nombre : ''
    when 'contacto_departamento'
      contacto.departamento ? contacto.departamento.nombre : ''
    when 'contacto_municipio'
      contacto.municipio ? contacto.municipio.nombre : ''
    when 'contacto_clase'
      contacto.clase ? contacto.clase.nombre : ''
    when 'telefono'
      casosjr.telefono ? casosjr.telefono : ''
    when 'direccion'
      casosjr.direccion ? casosjr.direccion : ''
    when 'contacto_numeroanexos'
      Sivel2Gen::AnexoVictima.where(victima_id: victimac.id).where.
        not(tipoanexo_id: 11).count
    when 'contacto_numeroanexosconsen'
      Sivel2Gen::AnexoVictima.where(
        victima_id: victimac.id, tipoanexo_id: 11).count
    when 'contacto_etnia'
      victimac.etnia ? victimac.etnia.nombre : ''
    when 'contacto_orientacionsexual'
      if victimac.orientacionsexual
        orientaciones.each do |ori|
          if ori[1].to_s == victimac.orientacionsexual.to_s
            return ori[0].to_s
          end
        end
      else
        return ''
      end
    when 'contacto_maternidad'
      victimasjrc.maternidad ? victimasjrc.maternidad.nombre : ''
    when 'contacto_estadocivil'
      victimasjrc.estadocivil ? victimasjrc.estadocivil.nombre : ''
    when 'contacto_discapacidad'
      victimasjrc.discapacidad ? victimasjrc.discapacidad.nombre : ''
    when 'contacto_cabezafamilia'
      if victimasjrc.cabezafamilia
        "Si"
      else 
        victimasjrc.cabezafamilia.nil? ? "No responde" : "No"
      end
    when 'contacto_rolfamilia'
      victimasjrc.rolfamilia.nombre
    when 'contacto_tienesisben'
      if victimasjrc.tienesisben
        "Si"
      else 
        victimasjrc.tienesisben.nil? ? "No responde" : "No"
      end
    when 'contacto_regimensalud'
      victimasjrc.regimensalud.nombre
    when 'contacto_asisteescuela'
      if victimasjrc.asisteescuela
        "Si"
      else 
        victimasjrc.asisteescuela.nil? ? "No responde" : "No"
      end
    when 'contacto_escolaridad'
      victimasjrc.escolaridad.nombre
    when 'contacto_actualtrabajando'
      if victimasjrc.actualtrabajando
        "Si"
      else 
        victimasjrc.actualtrabajando.nil? ? "No responde" : "No"
      end
    when 'contacto_profesion'
      victimac.profesion ? victimac.profesion.nombre : ''
    when 'contacto_actividadoficio'
      Sivel2Gen::Actividadoficio.find(victimasjrc.actividadoficio_id).nombre
    when 'contacto_filiacion'
      victimac.filiacion ? victimac.filiacion.nombre : ''
    when 'contacto_organizacion'
      victimac.organizacion ? victimac.organizacion.nombre : ''
    when 'contacto_vinculoestado'
      victimac.vinculoestado ? victimac.vinculoestado.nombre : ''
    when 'contacto_comosupo'
      casosjr.comosupo ? casosjr.comosupo.nombre : ''
    when 'contacto_consentimientosjr'
      casosjr.concentimientosjr ? "Si" : "No"
    when 'contacto_consentimientobd'
      casosjr.concentimientobd ? "Si" : "No"
    when 'memo'
      caso.memo ? caso.memo : ''
    when 'numeroanexos'
      Sivel2Gen::AnexoCaso.where(caso_id: caso_id).count
    when 'numero_beneficiarios'
      caso.victimasjr.where(fechadesagregacion: nil).count
    when 'numero_madres_gestantes'
      caso.victimasjr.where(fechadesagregacion: nil).
        where(maternidad_id: 1).count
    when 'ultimaatencion_as_humanitaria'
      resp_ultimaatencion(11,110)
    when 'ultimaatencion_ac_juridica'
      r = ''
      if resp_ultimaatencion(14,140) != ''
        r += resp_ultimaatencion(14,140) + ": " + 
          resp_ultimaatencion(14,141) + '. '
      end
      if resp_ultimaatencion(14,142) != ''
        r += resp_ultimaatencion(14,142) + ": " + 
          resp_ultimaatencion(14,143) + '. '
      end
      r
    when 'ultimaatencion_as_juridica'
      resp_ultimaatencion(13,130)
    when 'ultimaatencion_beneficiarios_0_5'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_masculino], 0, 5)
    when 'ultimaatencion_beneficiarios_6_12'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_masculino], 6, 12)
    when 'ultimaatencion_beneficiarios_13_17'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_masculino], 13, 17)
    when 'ultimaatencion_beneficiarios_18_26'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_masculino], 18, 26)
    when 'ultimaatencion_beneficiarios_27_59'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_masculino], 27, 59)
    when 'ultimaatencion_beneficiarios_60m'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_masculino], 60, nil)
    when 'ultimaatencion_beneficiarios_se'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_masculino], nil, nil)
    when 'ultimaatencion_beneficiarias_0_5'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_femenino], 0, 5)
    when 'ultimaatencion_beneficiarias_6_12'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_femenino], 6, 12)
    when 'ultimaatencion_beneficiarias_13_17'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_femenino], 13, 17)
    when 'ultimaatencion_beneficiarias_18_26'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_femenino], 18, 26)
    when 'ultimaatencion_beneficiarias_27_59'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_femenino], 27, 59)
    when 'ultimaatencion_beneficiarias_60m'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_femenino], 60, nil)
    when 'ultimaatencion_beneficiarias_se'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_femenino], nil, nil)
    when 'ultimaatencion_beneficiarios_ss_0_5'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_sininformacion], 0, 5)
    when 'ultimaatencion_beneficiarios_ss_6_12'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_sininformacion], 6, 12)
    when 'ultimaatencion_beneficiarios_ss_13_17'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_sininformacion], 13, 17)
    when 'ultimaatencion_beneficiarios_ss_18_26'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_sininformacion], 18, 26)
    when 'ultimaatencion_beneficiarios_ss_27_59'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_sininformacion], 27, 59)
    when 'ultimaatencion_beneficiarios_ss_60m'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_sininformacion], 60, nil)
    when 'ultimaatencion_beneficiarios_ss_se'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_sininformacion], nil, nil)
    when 'ultimaatencion_beneficiarios_os_0_5'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_intersexual], 0, 5)
    when 'ultimaatencion_beneficiarios_os_6_12'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_intersexual], 6, 12)
    when 'ultimaatencion_beneficiarios_os_13_17'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_intersexual], 13, 17)
    when 'ultimaatencion_beneficiarios_os_18_26'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_intersexual], 18, 26)
    when 'ultimaatencion_beneficiarios_os_27_59'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_intersexual], 27, 59)
    when 'ultimaatencion_beneficiarios_os_60m'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_intersexual], 60, nil)
    when 'ultimaatencion_beneficiarios_os_se'
      self.class.poblacion_ultimaatencion(
        caso_id, ultimaatencion_actividad_id, convsexo[:sexo_intersexual], nil, nil)


    when 'ultimaatencion_derechosvul'
      resp_ultimaatencion(10,100)
    when 'ultimaatencion_descripcion_at', 'ultimaatencion_objetivo'
      ultatencion = Cor1440Gen::Actividad.
        where(id: ultimaatencion_actividad_id).take
      if !ultatencion
        return "Problema no existe actividad #{ultimaatencion_actividad_id}"
      end
      ultatencion.objetivo ? ultatencion.objetivo : ''
    when 'ultimaatencion_otros_ser_as'
      resp_ultimaatencion(15,150)

    else
      if respond_to?(atr)
        send(atr)
      else
        caso.presenta(atr)
      end
    end
  end

  def self.porsjrc
    "porsjrc"
  end

end



