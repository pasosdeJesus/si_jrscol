require 'sivel2_sjr/concerns/controllers/validarcasos_controller'

module Sivel2Gen
  class ValidarcasosController < ApplicationController


    load_and_authorize_resource class: Sivel2Gen::Caso
    include Sivel2Sjr::Concerns::Controllers::ValidarcasosController



    def filtro_benef_fechas(benef, cfecha = 'sip_persona.created_at')
      pfid = ''
      if (params[:validarcaso] && params[:validarcaso][:fechaini] && 
          params[:validarcaso][:fechaini] != '')
        pfi = params[:validarcaso][:fechaini]
        pfid = Sip::FormatoFechaHelper.fecha_local_estandar pfi
      else
        # Comenzar en semestre anterior
        pfid = Sip::FormatoFechaHelper.inicio_semestre(Date.today).to_s
      end
      benef = benef.where("#{cfecha} >= ?", pfid)
      if(params[:validarcaso] && params[:validarcaso][:fechafin] && 
          params[:validarcaso][:fechafin] != '')
        pff = params[:validarcaso][:fechafin]
        pffd = Sip::FormatoFechaHelper.fecha_local_estandar pff
        if pffd
          benef = benef.where("#{cfecha} <= ?", pffd)
        end
      end
      return benef
    end

    def validar_idrepetida
      benef = Sip::Persona.all
      puts "OJO 1 benef.count=#{benef.count}"
      benef = filtro_benef_fechas(benef)
      res="SELECT sub.sigla, sub.numerodocumento, sub.rep,\n"\
        "  ARRAY(SELECT id FROM (" + benef.to_sql + ") AS p2\n"\
        "        WHERE p2.tdocumento_id=sub.tdocumento_id\n"\
        "        AND p2.numerodocumento=sub.numerodocumento)\n"\
        "  FROM (SELECT t.sigla, p.tdocumento_id, numerodocumento,\n"\
        "      COUNT(p.id) AS rep "\
        "      FROM (" + benef.to_sql + ") AS p\n"\
        "      LEFT JOIN sip_tdocumento as t ON t.id=tdocumento_id\n"\
        "      GROUP BY 1,2,3) AS sub\n"\
        "  WHERE rep>1\n"\
        "  ORDER BY rep DESC";
      arr = ActiveRecord::Base.connection.select_all(res)
      @validaciones << { 
        titulo: 'Identificaciones repetidas de beneficiarios actualizados en el rango de fechas',
        encabezado: ['Tipo de documento', 'Núm. documento', 'Num. repetidos', 
                     'Identificaciones'],
        cuerpo: arr 
      }
    end


    def validar_sinderechovulnerado
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
      validar_idrepetida
      validar_sivel2_sjr
      validar_sinderechovulnerado
      validar_sivel2_gen
    end # def validar_interno
         
  end
end
