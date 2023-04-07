require 'sivel2_sjr/concerns/controllers/validarcasos_controller'

module Sivel2Gen
  class ValidarcasosController < ApplicationController


    load_and_authorize_resource class: Sivel2Gen::Caso
    include Sivel2Sjr::Concerns::Controllers::ValidarcasosController


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

      puts res.to_sql
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
      valida_nombres_beneficiarios_cortos
      validar_sin_casosjr
      validar_sivel2_sjr
      validar_sin_derechovulnerado
      #validar_sivel2_gen
    end # def validar_interno
         
  end
end
