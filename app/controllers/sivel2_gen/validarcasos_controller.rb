require 'sivel2_gen/concerns/controllers/validarcasos_controller'

module Sivel2Gen
  class ValidarcasosController < ApplicationController


    load_and_authorize_resource class: Sivel2Gen::Caso
    include Sivel2Gen::Concerns::Controllers::ValidarcasosController


    def validacion_estandar(casos, titulo, where, 
                            atr = ['sivel2_gen_caso.id', 
                                   'sivel2_gen_caso.fecha', 
                                   'usuario.nusuario', 
                                   'msip_oficina.nombre'],
                                   encabezado = [
                                     'Código', 'Fecha de Desp. Emb.', 
                                     'Asesor', 'Oficina'])
      res = casos.joins('JOIN usuario ON usuario.id=asesor').
        joins('JOIN msip_oficina ON 
                    msip_oficina.id=sivel2_sjr_casosjr.oficina_id').
                    where(where).select(atr)
      puts "validacion_estandar: res.to_sql=", res.to_sql
      arr = ActiveRecord::Base.connection.select_all(res.to_sql)
      @validaciones << { 
        titulo: titulo,
        encabezado: encabezado,
        cuerpo: arr 
      }
    end

    def filtro_oficina(casos, campo = 'sivel2_sjr_casosjr.oficina_id')
      if (params[:validarcaso] && params[:validarcaso][:oficina_id] && 
          params[:validarcaso][:oficina_id] != '')
        ofi = params[:validarcaso][:oficina_id].to_i
        casos = casos.where("#{campo} = ?", ofi)
      end
      return casos
    end

    def filtro_etiqueta(casos)
      if (params[:validarcaso] && 
          params[:validarcaso][:etiqueta_id] && 
          params[:validarcaso][:etiqueta_id] != '')
        eti = params[:validarcaso][:etiqueta_id].to_i
        casos = casos.where(
          "sivel2_gen_caso.id NOT IN (SELECT caso_id " +
          "FROM public.sivel2_gen_caso_etiqueta " +
          "WHERE etiqueta_id = ?)", eti)
      end
      return casos
    end


    def ini_filtro
      casos = Sivel2Sjr::Casosjr.joins(:caso).all.order(:fecharec)
      casos = filtro_fechas(casos, 'fecharec')
      casos = filtro_oficina(casos)
      casos = filtro_etiqueta(casos)
      return casos
    end

    def valida_contactonull
      casos = ini_filtro
      validacion_estandar(
        casos, 
        'Casos con contacto NULL', 
        "contacto_id IS NULL")
    end


    def valida_sincontacto
      casos = ini_filtro
      casos = casos.
        joins(
          'INNER JOIN msip_persona
                 ON msip_persona.id=sivel2_sjr_casosjr.contacto_id')
      #              joins(
      #                'INNER JOIN sivel2_gen_victima
      #                 ON sivel2_gen_victima.persona_id=sivel2_sjr_casosjr.contacto_id').
      validacion_estandar(
        casos, 
        'Casos con contacto de nombre muy corto', 
        "length(msip_persona.nombres)<=1  
              AND length(msip_persona.apellidos)<=1")
    end

    def valida_sinubicaciones
      casos = ini_filtro
      validacion_estandar(
        casos, 
        'Casos con menos de dos ubicaciones', 
        'caso_id NOT IN 
               (SELECT caso_id FROM 
                (SELECT caso_id, count(id) AS cubi
                 FROM public.msip_ubicacion GROUP BY 1) AS nubi 
                WHERE cubi>=2)')
    end

    def valida_sinrefugionidesplazamiento
      casos = ini_filtro
      validacion_estandar(
        casos, 
        'Casos sin desplazamiento y sin refugio', 
        'caso_id NOT IN 
               (SELECT caso_id FROM 
                (SELECT caso_id, count(id) AS cdes
                 FROM public.sivel2_sjr_desplazamiento GROUP BY 1) AS ndesp
                WHERE cdes>0)
               AND sivel2_sjr_casosjr.salida_id IS NULL
               AND sivel2_sjr_casosjr.llegada_id IS NULL
        ')
    end

    def valida_sinrespuesta
      casos = ini_filtro
      validacion_estandar(
        casos, 
        'Casos sin respuesta/seguimiento', 
        'caso_id NOT IN 
               (SELECT caso_id FROM 
                (SELECT caso_id, count(id) AS cresp
                 FROM sivel2_sjr_respuesta GROUP BY 1) AS nresp
                WHERE cresp>0)
        ')
    end

    def valida_sinfechadesp
      casos = ini_filtro
      validacion_estandar(
        casos, 
        'Casos con fecha de desp. emblemático igual o posterior a fecha de recepción', 
        'sivel2_gen_caso.fecha >= fecharec'
      )
    end

    def valida_sindocid
      casos = ini_filtro
      casos = casos.
        joins(
          'INNER JOIN msip_persona
                 ON msip_persona.id=sivel2_sjr_casosjr.contacto_id').
                 joins(
                   'INNER JOIN sivel2_gen_victima
                 ON sivel2_gen_victima.persona_id=msip_persona.id')
      validacion_estandar(
        casos, 
        'Casos con contacto sin documento de identidad', 
        'msip_persona.numerodocumento IS NULL 
               OR msip_persona.tdocumento_id IS NULL'
      )
    end


    def valida_sinayudasjr
      casos = ini_filtro
      casos = casos.joins('JOIN sivel2_sjr_respuesta ON
              sivel2_sjr_respuesta.caso_id=sivel2_sjr_casosjr.caso_id')
      validacion_estandar(
        casos, 
        'Casos con respuesta pero sin ayuda/asesoria del SJR',
        'sivel2_sjr_respuesta.id NOT IN 
               (SELECT respuesta_id FROM public.sivel2_sjr_ayudasjr_respuesta)
               AND sivel2_sjr_respuesta.id NOT IN 
               (SELECT respuesta_id FROM public.sivel2_sjr_aslegal_respuesta)
        '
      )
    end

    def validar_sivel2_sjr
      valida_contactonull
      valida_sincontacto
      #valida_sinubicaciones
      valida_sinrefugionidesplazamiento
      valida_sinrespuesta
      valida_sinfechadesp
      valida_sindocid
      valida_sinayudasjr
    end

    def validar_interno
      @rango_fechas = 'Fecha de recepción'
      validar_sivel2_sjr
      #valida_sinderechovulnerado
      validar_sivel2_gen
    end # def validar_interno

    def validarcasos_params
      params.require(:validarcaso).permit(
        :fechafin,
        :fechaini,
        :oficina
      )
    end


    def valida_beneficiarios_en_varios_casos
      base = ActiveRecord::Base.connection.execute(<<-SQL)
        SELECT id FROM (SELECT p.id, count(v.id)
          FROM msip_persona AS p
          JOIN sivel2_gen_victima AS v ON v.persona_id=p.id
          JOIN sivel2_sjr_victimasjr AS vs ON vs.victima_id=v.id
          WHERE vs.fechadesagregacion IS NULL
          GROUP BY 1) AS s
        WHERE s.count>1
        ORDER BY id;
      SQL
      ids = base.pluck("id")
      reg = Msip::Persona.joins(:tdocumento).where(id: ids)
      res = reg.
        select([:id, :nombres, :apellidos, 'msip_tdocumento.sigla', 
                :numerodocumento,
                "ARRAY_TO_STRING(ARRAY(SELECT caso_id "\
                " FROM sivel2_gen_victima AS v "\
                " JOIN sivel2_sjr_victimasjr AS vs ON vs.victima_id=v.id "\
                " WHERE v.persona_id=msip_persona.id AND "\
                "  vs.fechadesagregacion IS NULL "\
                " ORDER BY id), ',') AS caso_ids"
        ])
      arr = ActiveRecord::Base.connection.select_all(res.to_sql)
      @validaciones << { 
        titulo: 'Beneficiarios no desagregados en más de un caso',
        encabezado: ['Id', 'Nombres', 'Apellidos', 
                     'Tipo Doc.', 'Núm. Doc', 
                     'Códigos'],
        cuerpo: arr 
      }
    end



    def validar_sin_derechovulnerado
      casos = ini_filtro
      casos = casos.joins('JOIN sivel2_sjr_respuesta ON
              sivel2_sjr_respuesta.caso_id=sivel2_sjr_casosjr.caso_id')
      validacion_estandar(
        casos, 
        'Casos con respuesta pero sin derecho vulnerado',
        'sivel2_sjr_respuesta.id NOT IN 
               (SELECT respuesta_id FROM public.sivel2_sjr_derecho_respuesta)'
      )
    end

    def validar_sin_casosjr
      casos = Sivel2Gen::Caso.order(:id)
      casos = filtro_fechas(casos, 'fecha')
      casos = filtro_etiqueta(casos)
      atr = ['sivel2_gen_caso.id', 
              'sivel2_gen_caso.fecha' ]
      encabezado = [
        'Código', 'Fecha de Desp. Emb.', 
        'Asesor']
      where = 'sivel2_gen_caso.id NOT IN 
           (SELECT caso_id FROM public.sivel2_sjr_casosjr) '
      titulo = 'Casos parcialmente eliminados'
      res = casos.where(where).select(atr)
      puts "validacion_estandar: res.to_sql=", res.to_sql
      arr = ActiveRecord::Base.connection.select_all(res.to_sql)
      @validaciones << { 
        titulo: titulo,
        encabezado: encabezado,
        cuerpo: arr 
      }
    end


    ## Sobrecarga una de sivel2_sjr 
    def valida_sinayudasjr
      casos = ini_filtro
      casos = casos.joins('JOIN sivel2_sjr_respuesta ON
              sivel2_sjr_respuesta.caso_id=sivel2_sjr_casosjr.caso_id')
      validacion_estandar(
        casos, 
        'Casos con respuesta/seguimiento pero sin respuesta del SJR',
        'sivel2_sjr_respuesta.id NOT IN 
           (SELECT respuesta_id FROM public.sivel2_sjr_ayudasjr_respuesta)
         AND sivel2_sjr_respuesta.id NOT IN 
           (SELECT respuesta_id FROM public.sivel2_sjr_aslegal_respuesta)
         AND sivel2_sjr_respuesta.id NOT IN 
           (SELECT respuesta_id FROM public.sivel2_sjr_motivosjr_respuesta)
        '
      )
    end

    def valida_nombres_beneficiarios_cortos
      reg = Msip::Persona.
        where('length(msip_persona.nombres) <= 2 OR '\
              'length(msip_persona.apellidos) <= 2')
      reg = filtro_fechas(reg, 'msip_persona.created_at')
      res = reg.
        order(:id).
        select([:id, :nombres, :apellidos, 
                '(SELECT sigla FROM msip_tdocumento WHERE msip_tdocumento.id=tdocumento_id LIMIT 1)', :numerodocumento,
                "array_to_string(array(SELECT DISTINCT caso_id FROM sivel2_gen_victima WHERE persona_id=msip_persona.id), ';') AS casos",
                "array_to_string(array(SELECT DISTINCT actividad_id FROM cor1440_gen_asistencia WHERE persona_id=msip_persona.id), ';') AS actividades"
        ])

      arr = ActiveRecord::Base.connection.select_all(res.to_sql)
      @validaciones << { 
        titulo: 'Beneficiarios con nombres o apellidos muy cortos',
        encabezado: ['Id', 'Nombres', 'Apellidos', 
                     'Tipo Doc.', 'Núm. Doc', 
                     'Caso(s)', 
                     'Actividad(es)'],
        cuerpo: arr 
      }
    end

    def validar_interno
      @rango_fechas = 'Fecha de recepción'
      valida_beneficiarios_en_varios_casos
      valida_nombres_beneficiarios_cortos
      validar_sin_casosjr
      validar_sivel2_sjr
      validar_sin_derechovulnerado
      val2 = []
      Msip::AnexosController.validar_existencia_archivo(val2)
      if val2.nil? || val2[0].nil?
        return
      end
      @validaciones << {
        titulo: val2[0][:titulo],
        encabezado: ["Caso", "Victima en caso", "Actividad", "Convenido financiado"] + val2[0][:encabezado],
        cuerpo: val2[0][:cuerpo].map { |f| 
          caso = nil
          actividad = nil
          casovictima = nil
          pf = nil
          if Sivel2Gen::AnexoCaso.where(anexo_id: f[0]).count > 0
            caso = Sivel2Gen::AnexoCaso.where(anexo_id: f[0]).take.caso_id
          elsif Sivel2Gen::AnexoVictima.where(anexo_id: f[0]).count > 0
            casovictima = Sivel2Gen::AnexoVictima.where(anexo_id: f[0]).take.victima.caso_id
          elsif Cor1440Gen::ActividadAnexo.where(anexo_id: f[0]).count > 0
            actividad = Cor1440Gen::ActividadAnexo.where(anexo_id: f[0]).take.actividad_id
          elsif Cor1440Gen::AnexoProyectofinanciero.where(anexo_id: f[0]).count > 0
            pf = Cor1440Gen::AnexoProyectofinanciero.where(anexo_id: f[0]).take.proyectofinanciero_id
          end
          [[caso,caso], [casovictima, casovictima], [actividad, actividad], [pf, pf], [f[0], f[0]], [f[1], f[1]]]
        }
      }
    end # def validar_interno

  end
end
