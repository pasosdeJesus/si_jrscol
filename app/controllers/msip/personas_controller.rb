require 'sivel2_gen/concerns/controllers/personas_controller'
require 'cor1440_gen/concerns/controllers/personas_controller'

module Msip
  class PersonasController < Heb412Gen::ModelosController

    before_action :set_persona, only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: Msip::Persona

    include Sivel2Gen::Concerns::Controllers::PersonasController
    include Cor1440Gen::Concerns::Controllers::PersonasController


    def atributos_comunes
      a = atributos_show_msip - [
        :mesnac, 
        :dianac
      ] + [ 
        :ultimoperfilorgsocial_id,
        :ultimoestatusmigratorio_id,
        :ppt,
        :caso_ids, 
        :proyectofinanciero_ids, 
        :actividad_ids, 
        :detallefinanciero_ids,
        :etiqueta_ids
      ]
      a[a.index(:anionac)] = :fechanac 
      return a
    end

    def atributos_show
      a = atributos_comunes
      if @registro.ultimoestatusmigratorio_id.to_i != 1
        a -= [:ppt]
      end
      return a
    end

    def atributos_index
      [ :id, 
        :nombres,
        :apellidos,
        :tdocumento_id,
        :numerodocumento,
        :fechanac,
        :sexo,
        :municipio,
        :actividad_ids,
        :actividadcasobeneficiario_ids,
        :detallefinanciero_ids,
        :etiqueta_ids
      ]
    end 

    def atributos_form
      a = atributos_comunes - [
        # :id,   NO quitamos id porque tiene un campo escondido
        :caso_ids, 
        :actividad_ids, 
        :actividadcasobeneficiario_ids,
        :detallefinanciero_ids, 
        :etiqueta_ids,
      ] + [
        :caracterizaciones
      ] + [
        :etiqueta_ids => []
      ]
      # Cambia fechanac por dia, mes, año
      p = a.index(:fechanac)
      a[p] = :anionac
      a.insert(p, :mesnac)
      a.insert(p, :dianac)

      return a
    end


    def vistas_manejadas
      ['Persona']
    end

    # Busca y lista persona(s)

    def index(c = nil)
      if c == nil
        c = Msip::Persona.all
      end
      if params[:term]
        term = Sivel2Gen::Caso.connection.quote_string(params[:term])
        consNomvic = term.downcase.strip #sin_tildes
        consNomvic.gsub!(/ +/, ":* & ")
        if consNomvic.length > 0
          consNomvic += ":*"
        end
        where = " persona.buscable @@ "\
          "to_tsquery('spanish', '#{consNomvic}')";

        partes = [
          'nombres',
          'apellidos',
          'COALESCE(numerodocumento::TEXT, \'\')'
        ]
        s = "";
        l = " persona.id ";
        seps = "";
        sepl = " || ';' || ";
        partes.each do |p|
          s += seps + p;
          l += sepl + "char_length(#{p})";
          seps = " || ' ' || ";
        end
        qstring = "SELECT TRIM(#{s}) AS value, #{l} AS id " +
          "FROM public.msip_persona AS persona " +
          "WHERE #{where} ORDER BY 1 LIMIT 20"
        r = ActiveRecord::Base.connection.select_all qstring
        respond_to do |format|
          format.json { render :json, inline: r.to_json }
          format.html { render :json, inline: 'No responde con parametro term' }
        end
      else
        super(c)
      end
    end

    # Están listas @persona, @victima, @personaant, @caso
    # Y está listo para salvar la nueva persona @persona en
    # @victima --remplazando @personaant.
    # Continúa si esta función retorna true, de lo contrario
    # se espera que la función haga render json con el error
    # y que retorne false.
    def remplazar_antes_salvar_v
      ce = Sivel2Sjr::Casosjr.where(contacto: @persona.id)
      if ce.count > 0
        render json: "Ya es contacto en el caso #{ce.take.caso_id}.",
          status: :unprocessable_entity
        return false
      end
      ve = Sivel2Sjr::Victimasjr.joins('JOIN sivel2_gen_victima ' +
                                       ' ON sivel2_gen_victima.id = sivel2_sjr_victimasjr.victima_id').
                                       where('sivel2_gen_victima.persona_id' => @persona.id).
                                       where(fechadesagregacion: nil)
      if ve.count > 0
        render json: "Está en núcleo familiar sin desagregar " +
          "en el caso #{ve.take.victima.caso_id}", 
          status: :unprocessable_entity
        return false
      end
      # Si se está remplazando el contacto, borra la persona
      # vacía que era contacto --y por lo mismo sólo permite 
      # cuando es un contacto vacío.
      if @caso.casosjr.contacto && @personaant &&
          @caso.casosjr.contacto_id == @personaant.id 
        eliminar_persona = false
        if @caso.casosjr.contacto.nombres == ""
          eliminar_persona = true
        end
        ppb=@caso.casosjr.contacto_id
        @caso.casosjr.contacto_id = nil
        @caso.casosjr.save!(validate: false)
        vic = @caso.victima.where(persona_id: ppb).take
        vic.persona_id=@persona.id
        vic.save(validate: false)
        @caso.casosjr.contacto_id = @persona.id
        @caso.casosjr.save!(validate: false)
        #redirect_to sivel2_gen.edit_caso_path(@caso)
        begin
          if eliminar_persona
            @personaant.destroy
          end
          render partial: '/msip/personas/remplazar', layout: false
        rescue
        end
        return false # buscar obligar el redirect_to
      end

      return true
    end

    def remplazar_despues_salvar_v
      if @caso.casosjr.contacto.id == @personaant.id
        @caso.casosjr.contacto = @persona
        @caso.casosjr.save
        if @caso.validate
          @caso.save
        end
      end
      return true
    end


    def datos
      return if !params[:persona_id] 
      @persona = Msip::Persona.find(params[:persona_id].to_i)
      authorize! :read, @persona
      oj = { 
        id: @persona.id,
        nombres: @persona.nombres,
        apellidos: @persona.apellidos,
        sexo: @persona.sexo,
        tdocumento: @persona.tdocumento ? @persona.tdocumento.sigla :
        '',
        numerodocumento: @persona.numerodocumento,
        dianac: @persona.dianac,
        mesnac: @persona.mesnac,
        anionac: @persona.anionac,
        ultimoestatusmigratorio_id: @persona.ultimoestatusmigratorio_id,
        ultimoperfilorgsocial_id: @persona.ultimoperfilorgsocial_id,
        ppt: @persona.ppt,
      }
      respond_to do |format|
        format.json { render json: oj, status: :ok }
        format.html { render inilne: oj.to_s, status: :ok }
      end
    end

    def atributos_html_encabezado_formulario
      {'data-controller': 'msip--sindocaut persona-ppt'}
    end

    def filtro_etiqueta(ide)
      joins(:msip_etiqueta_persona).where(etiqueta_id: ide)
    end

    def filtro_benef_fechas(benef, cfecha = 'msip_persona.created_at')
      pfid = ''
      if (params[:reporterepetido] && params[:reporterepetido][:fechaini] && 
          params[:reporterepetido][:fechaini] != '')
        pfi = params[:reporterepetido][:fechaini]
        pfid = Msip::FormatoFechaHelper.fecha_local_estandar pfi
      else
        # Comenzar en semestre anterior
        pfid = Msip::FormatoFechaHelper.inicio_semestre(Date.today).to_s
      end
      benef = benef.where("#{cfecha} >= ?", pfid)
      if(params[:reporterepetido] && params[:reporterepetido][:fechafin] && 
          params[:reporterepetido][:fechafin] != '')
        pff = params[:reporterepetido][:fechafin]
        pffd = Msip::FormatoFechaHelper.fecha_local_estandar pff
        if pffd
          benef = benef.where("#{cfecha} <= ?", pffd)
        end
      end
      return benef
    end



    def reporterepetidos

      @validaciones = []
      benef = Msip::Persona.all
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
        "     JOIN msip_persona AS p2 ON p2.id=asi.persona_id "\
        "       AND p2.id = ANY(sub2.identificaciones[2:]) "\
        "     JOIN cor1440_gen_actividad AS ac ON ac.id=asi.actividad_id "\
        "     JOIN msip_bitacora AS bit ON bit.modelo='Cor1440Gen::Actividad' "\
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
        "      LEFT JOIN msip_tdocumento as t ON t.id=tdocumento_id\n"\
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


      if params && params[:reporterepetido] && 
          params[:reporterepetido][:deduplicables_autom] == '1'
        arr = ActiveRecord::Base.connection.select_all(
          Jos19::UnificarHelper.consulta_casos_por_arreglar.select(
            ['id']).to_sql
        )
        @validaciones << {
          titulo: 'Casos parcialmente eliminados por arreglar (completar o eliminar)',
          encabezado: ['Id.'],
          cuerpo: arr 
        }


        arr = ActiveRecord::Base.connection.select_all(
          Jos19::UnificarHelper.consulta_casos_en_blanco.select(
            ['caso_id']).to_sql
        )
        @validaciones << {
          titulo: 'Casos en blanco por eliminar automaticamente',
          encabezado: ['Id.'],
          cuerpo: arr 
        }

        arr = ActiveRecord::Base.connection.select_all(
          Jos19::UnificarHelper.consulta_personas_en_blanco_por_eliminar.
          select(['id']).to_sql
        )
        @validaciones << {
          titulo: 'Personas en blanco por eliminar automaticamente',
          encabezado: ['Id.'],
          cuerpo: arr 
        }

        pares = Jos19::UnificarHelper.consulta_duplicados_autom
        vc = {
          titulo: 'Beneficarios por intentar deduplicar automaticamente',
          encabezado: [
            'T. Doc', 'Num. doc', 'Id1', 'Nombres', 'Apellidos',
            'Id2', 'Nombres', 'Apellidos'
          ],
          cuerpo: []
        }
        pares.each do |f|
          vc[:cuerpo] << [['sigla',f['sigla']], ['numerodocumento', f['numerodocumento']],
                          ['id1', f['id1']], ['nombres1', f['nombres1']], 
                          ['apellidos1', f['apellidos1']],
                          ['id2', f['id2']], ['nombres2', f['nombres2']], 
                          ['apellidos2', f['apellidos2']] ]
        end
        @validaciones << vc
      end

      rep= "SELECT t.sigla, p1.numerodocumento, "\
        "     p1.id AS id1, p1.nombres AS nombres1, p1.apellidos AS apellidos1,"\
        "     p2.id AS id2, p2.nombres AS nombres2, p2.apellidos AS apellidos2"\
        "   FROM msip_persona AS p1"\
        "   JOIN msip_persona AS p2 ON p1.id < p2.id "\
        "     AND p1.tdocumento_id=p2.tdocumento_id "\
        "     AND p1.numerodocumento=p2.numerodocumento "\
        "     AND p1.numerodocumento<>'' "\
        "   JOIN msip_tdocumento AS t ON p1.tdocumento_id=t.id"
      @idrep = ActiveRecord::Base.connection.select_all(rep) 

      render :reporterepetidos, layout: 'application'
    end

    def deduplicar
      if ENV.fetch('DEPURA_MIN', -1).to_i == -1 || 
          ENV.fetch('DEPURA_MAX', -1).to_i == -1
        @res_preparar_automaticamente = 
          Jos19::UnificarHelper::preparar_automaticamente
      end
      @res_deduplicar = Jos19::UnificarHelper::deduplicar_automaticamente(
        current_usuario)
      Msip::Persona.connection.execute <<-SQL
        REFRESH MATERIALIZED VIEW sivel2_gen_conscaso;
      SQL
      render :deduplicar, layout: 'application'
    end


    def unificar
      if params[:unificarpersonas]
        id1 = params[:unificarpersonas][:id1].to_i
        id2 = params[:unificarpersonas][:id2].to_i
      elsif params[:id1] && params[:id2]
        id1 = params[:id1].to_i
        id2 = params[:id2].to_i
      else
        flash[:error] = 'Faltaron identificaciones de personas a unificar'
        redirect_to Rails.configuration.relative_url_root
        return
      end

      r = Jos19::UnificarHelper.unificar_dos_beneficiarios(
        id1.dup, id2.dup, current_usuario.dup)
      m = r[0]
      p = r[1]
      if (m != "")
        flash[:error] = m
        redirect_to Rails.configuration.relative_url_root
        return
      end
      redirect_to msip.persona_path(p1)
    end



    def lista_params
      atributos_form + [
        :pais_id,
        :departamento_id,
        :municipio_id,
        :clase_id,
        :numerodocumento,
        :tdocumento_id,
        :ultimoperfilorgsocial_id,
        :ultimoestatusmigratorio_id,
        :ppt,
      ] +
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

    def identificacionsd
      pid = nil
      if params && params[:persona_id] && params[:persona_id] != ''
        pid = params[:persona_id].to_i
      end
      ndoc = Msip::PersonasController.
        nueva_persona_sd_posible_numerodocumento(pid)
      puts "OJO ndoc=#{ndoc}"
      respond_to do |format|
        format.json {
          render inline: ndoc
          return
        }
        format.html {
          render inline: ndoc
          return
        }
      end
    end

    # Retorna una propuesta para número de documento con base
    # en la id de la persona (no nil)
    def self.mejora_nuevo_numerodocumento_sindoc(persona_id)
      numerodocumento = persona_id
      while Msip::Persona.where(
          tdocumento_id: 11, numerodocumento: numerodocumento
      ).where('id<>?', persona_id).count > 0 do
        numerodocumento = numerodocumento.to_s
        if numerodocumento.length > 0 && numerodocumento[-1] >= 'A' && 
            numerodocumento[-1] < 'Z'
          ul = numerodocumento[-1].ord + 1
          numerodocumento = numerodocumento[0..-2] + ul.chr(Encoding::UTF_8)
        else
          numerodocumento += 'A'
        end
      end
      return numerodocumento
    end

    def self.nueva_persona_sd_posible_numerodocumento(persona_id)
      if persona_id.nil?
        ruid = Msip::Persona.connection.execute <<-SQL
        SELECT last_value FROM msip_persona_id_seq;
        SQL
        persona_id = ruid[0]['last_value'] + 1
      end
      numerodocumento = self.mejora_nuevo_numerodocumento_sindoc(persona_id)
      return numerodocumento
    end

    def self.nueva_persona_valores_predeterminados(menserror)
      numerodocumento = self.nueva_persona_sd_posible_numerodocumento(nil)
      persona = Msip::Persona.create(
        nombres: 'N',
        apellidos: 'N',
        sexo: 'S',
        tdocumento_id: 11, # SIN DOCUMENTO
        numerodocumento: numerodocumento
      )
      if !persona.save(validate: false)
        menserror << 'No pudo crear persona'
        return nil
      end
      return persona
    end

  end
end
