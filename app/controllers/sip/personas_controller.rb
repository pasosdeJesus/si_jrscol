require 'sivel2_sjr/concerns/controllers/personas_controller'

module Sip
  class PersonasController < Heb412Gen::ModelosController

    before_action :set_persona, only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: Sip::Persona

    include Sivel2Sjr::Concerns::Controllers::PersonasController

    def atributos_show
      atributos_show_sivel2_sjr + [
        :detallefinanciero_ids,
        :etiqueta_ids
      ]
    end

    def atributos_index
      atributos_index_sivel2_sjr  + [
        :detallefinanciero_ids,
        :etiqueta_ids
      ]
    end 

    def atributos_form
      a = atributos_form_sivel2_sjr - [
        :detallefinanciero_ids, :etiqueta_ids] +
        [:etiqueta_ids => []]
      return a
    end


    def filtro_etiqueta(ide)
      joins(:sip_etiqueta_persona).where(etiqueta_id: ide)
    end

    def filtro_benef_fechas(benef, cfecha = 'sip_persona.created_at')
      pfid = ''
      if (params[:reporterepetido] && params[:reporterepetido][:fechaini] && 
          params[:reporterepetido][:fechaini] != '')
        pfi = params[:reporterepetido][:fechaini]
        pfid = Sip::FormatoFechaHelper.fecha_local_estandar pfi
      else
        # Comenzar en semestre anterior
        pfid = Sip::FormatoFechaHelper.inicio_semestre(Date.today).to_s
      end
      benef = benef.where("#{cfecha} >= ?", pfid)
      if(params[:reporterepetido] && params[:reporterepetido][:fechafin] && 
          params[:reporterepetido][:fechafin] != '')
        pff = params[:reporterepetido][:fechafin]
        pffd = Sip::FormatoFechaHelper.fecha_local_estandar pff
        if pffd
          benef = benef.where("#{cfecha} <= ?", pffd)
        end
      end
      return benef
    end

    def reporterepetidos

      @validaciones = []
      benef = Sip::Persona.all
      puts "OJO 1 benef.count=#{benef.count}"
      benef = filtro_benef_fechas(benef)
      res= "SELECT sub2.sigla, sub2.numerodocumento, sub2.rep, "\
        "     sub2.identificaciones[1:5] as identificaciones5, "\
        "     ARRAY(SELECT DISTINCT ac.id"\
        "     FROM cor1440_gen_asistencia AS asi"\
        "     JOIN cor1440_gen_actividad AS ac ON ac.id=asi.actividad_id "\
        "     WHERE asi.persona_id = ANY(sub2.identificaciones[2:]) "\
        "     ) AS actividades_ben,\n"\
        "     ARRAY(SELECT DISTINCT usuario.nusuario "\
        "     FROM cor1440_gen_asistencia AS asi"\
        "     JOIN sip_persona AS p2 ON p2.id=asi.persona_id "\
        "       AND p2.id = ANY(sub2.identificaciones[2:]) "\
        "     JOIN cor1440_gen_actividad AS ac ON ac.id=asi.actividad_id "\
        "     JOIN sip_bitacora AS bit ON bit.modelo='Cor1440Gen::Actividad' "\
        "       AND bit.modelo_id=ac.id "\
        "       AND DATE_PART('minute', bit.fecha-p2.created_at)<10 "\
        "     JOIN usuario ON usuario.id=bit.usuario_id "\
        "     ) AS posibles_rep\n"\
        "FROM ("\
        "     SELECT sub.sigla, sub.tdocumento_id, sub.numerodocumento, sub.rep, \n"\
        "    ARRAY(SELECT id FROM (" + benef.to_sql + ") AS p2\n"\
        "        WHERE (p2.tdocumento_id=sub.tdocumento_id OR (sub.tdocumento_id IS NULL AND p2.tdocumento_id IS NULL))\n"\
        "        AND (p2.numerodocumento=sub.numerodocumento OR (sub.numerodocumento IS NULL AND p2.numerodocumento IS NULL))\n"\
        "        ORDER BY id) AS identificaciones\n"\
        "  FROM (SELECT t.sigla, p.tdocumento_id, numerodocumento,\n"\
        "      COUNT(p.id) AS rep "\
        "      FROM (" + benef.to_sql + ") AS p\n"\
        "      LEFT JOIN sip_tdocumento as t ON t.id=tdocumento_id\n"\
        "      GROUP BY 1,2,3) AS sub\n"\
        "  WHERE rep>1\n"\
        "  ORDER BY rep DESC) AS sub2";
      arr = ActiveRecord::Base.connection.select_all(res)
      @validaciones << { 
        titulo: 'Identificaciones repetidas de beneficiarios actualizados en el rango de fechas',
        encabezado: ['Tipo Doc.', 'Núm. Doc.', 'Num. personas', 
                     'Ids 5 primeras personas', 'Ids Actividades', 
                     'Editores Act. cerca a ingreso personas'],
        cuerpo: arr 
      }
      render :reporterepetidos, layout: 'application'
    end

    def deduplicar
      @res_preparar_automaticamente = UnificarHelper::preparar_automaticamente
      render :deduplicar, layout: 'application'
    end

    def unificar
      m, p1 = UnificarHelper.unificar_dos_beneficiarios(
        params[:id1], params[:id2], current_usuario)
      if (m != "")
        flash[:error] = m
        redirect_to Rails.configuration.relative_url_root
        return
      end
      redirect_to sip.persona_path(p1)

    end



    def lista_params
      atributos_form + [
        :id_pais,
        :id_departamento,
        :id_municipio,
        :id_clase,
        :tdocumento_id,
        :numerodocumento
      ] +
#     [
#       :datosbio_attributes => [
#         :afiliadoarl,
#         :anioaprobacion,
#         :correo,
#         :cvulnerabilidad_id,
#         :res_departamento_id,
#         :direccionres,
#         :otradiscapacidad,
#         :eps,
#         :discapacidad_id,
#         :escolaridad_id,
#         :espaciopart_id,
#         :fechaingespaciopp,
#         :mayores60acargo,
#         :menores12acargo,
#         :res_municipio_id,
#         :nivelsisben,
#         :nombreespaciopp,
#         :personashogar,
#         :telefono,
#         :veredares,
#         :sistemapensional,
#         :subsidioestado,
#         :telefono,
#         :tipocotizante
#       ]
#      ] + 
      [
        "caracterizacionpersona_attributes" =>
        [ :id,
          "respuestafor_attributes" => [
            :id,
            "valorcampo_attributes" => [
              :valor,
              :campo_id,
              :id,
              :valor_ids => []
            ]
        ] ]
      ] + [
        'proyectofinanciero_ids' => []
      ] + [ 
        etiqueta_persona_attributes:  [
          :etiqueta_id, 
          :fecha_localizada,
          :id,
          :observaciones,
          :usuario_id,
          :_destroy
        ]
      ]
    end

    def validaciones(registro)
      if params[:persona][:numerodocumento].blank?
        @validaciones_error = "Se requiere número de documento" 
        return false
      end
      return true
    end

  end
end
