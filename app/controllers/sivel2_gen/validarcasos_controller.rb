require 'sivel2_sjr/concerns/controllers/validarcasos_controller'

module Sivel2Gen
  class ValidarcasosController < ApplicationController


    load_and_authorize_resource class: Sivel2Gen::Caso
    include Sivel2Sjr::Concerns::Controllers::ValidarcasosController


    def validar_sin_derechovulnerado
      casos = ini_filtro
      casos = casos.joins('JOIN sivel2_sjr_respuesta ON
              sivel2_sjr_respuesta.id_caso=sivel2_sjr_casosjr.id_caso')
      validacion_estandar(
        casos, 
        'Casos con respuesta pero sin derecho vulnerado',
        'sivel2_sjr_respuesta.id NOT IN 
               (SELECT id_respuesta FROM public.sivel2_sjr_derecho_respuesta)'
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
           (SELECT id_caso FROM public.sivel2_sjr_casosjr) '
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
              sivel2_sjr_respuesta.id_caso=sivel2_sjr_casosjr.id_caso')
      validacion_estandar(
        casos, 
        'Casos con respuesta/seguimiento pero sin respuesta del SJR',
        'sivel2_sjr_respuesta.id NOT IN 
           (SELECT id_respuesta FROM public.sivel2_sjr_ayudasjr_respuesta)
         AND sivel2_sjr_respuesta.id NOT IN 
           (SELECT id_respuesta FROM public.sivel2_sjr_aslegal_respuesta)
         AND sivel2_sjr_respuesta.id NOT IN 
           (SELECT id_respuesta FROM public.sivel2_sjr_motivosjr_respuesta)
        '
      )
    end

    def validar_interno
      @rango_fechas = 'Fecha de recepción'
      validar_sin_casosjr
      validar_sivel2_sjr
      validar_sin_derechovulnerado
      validar_sivel2_gen
    end # def validar_interno
         
  end
end
