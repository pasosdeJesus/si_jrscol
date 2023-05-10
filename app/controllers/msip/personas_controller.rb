require 'jos19/concerns/controllers/personas_controller'

module Msip
  class PersonasController < Heb412Gen::ModelosController

    before_action :set_persona, only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: Msip::Persona

    include Jos19::Concerns::Controllers::PersonasController

    def atributos_comunes
      a = atributos_show_msip - [
        :mesnac, 
        :dianac,
        :familiares
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


    def datos_complementarios(oj)
      return oj.merge(
        ultimoestatusmigratorio_id: @persona.ultimoestatusmigratorio_id,
        ultimoperfilorgsocial_id: @persona.ultimoperfilorgsocial_id,
        ppt: @persona.ppt,
        caso_ids: Sivel2Gen::Victima.where(persona_id: @persona.id).map(&:caso_id)
      )
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

    # Unificar dos casos, eliminando el de código mayor y dejando
    # su información como etiqueta en el primero
    # @return caso_id donde unifica si lo logra o nil
    def unificar_dos_casos(c1_id, c2_id, current_usuario, menserror)
      tmenserror = ''
      if !c1_id || c1_id.to_i <= 0 ||
          Sivel2Gen::Caso.where(id: c1_id.to_i).count == 0
        tmenserror << "Primera identificación de caso no válida '#{c1_id.to_s}'.\n"
      end
      if !c2_id || c2_id.to_i <= 0 ||
          Sivel2Gen::Caso.where(id: c2_id.to_i).count == 0
        tmenserror << "Segunda identificación de caso no válida '#{c2_id.to_s}'.\n"
      end
      if c1_id.to_i == c2_id.to_i
        tmenserror << "Primera y segunda identificación son iguales, no unificando.\n"
      end

      if tmenserror != ""
        menserror << tmenserror
        return nil
      end

      c1 = Sivel2Gen::Caso.find([c1_id.to_i, c2_id.to_i].min)
      c2 = Sivel2Gen::Caso.find([c1_id.to_i, c2_id.to_i].max)

      eunif = Msip::Etiqueta.where(
        nombre: Rails.configuration.x.jos19_etiquetaunificadas).take
        if !eunif
          tmenserror << "No se encontró etiqueta "\
            "#{Rails.configuration.x.jos19_etiquetaunificadas}.\n"
        end

        if tmenserror != ""
          menserror << tmenserror
          return nil
        end

        ep = Sivel2Gen::CasoEtiqueta.new(
          caso_id: c1.id,
          etiqueta_id: eunif.id,
          usuario_id: current_usuario.id,
          fecha: Date.today(),
          observaciones: ""
        )

        Sivel2Sjr::ActividadCasosjr.where(casosjr_id: c2.id).each do |ac|
          ac.casosjr_id = c1.id
          ac.save
          ep.observaciones << "Cambiado caso beneficiario en actividad #{ac.id}\n"
        end

        ep.observaciones = ep.observaciones[0..9999]
        ep.save
        cc = Sivel2Sjr::CasosController.new
        c2rep = Jos19::UnificarHelper.reporte_md_contenido_objeto("Caso #{c1.id}", cc.lista_params, c1, 0)
        c2id = c2.id
        if eliminar_caso(c2, tmenserror)
          ep.observaciones << "Se unificó y eliminó el registro de caso #{c2id}\n" +
            ep.observaciones << c2rep
        else
          ep.observaciones << "No se logró eliminar el caso #{c2id}, pero si se unficó en el #{c1.id}\n" +
            tmenserror << "No se logró eliminar el caso #{c2id}\n"
        end
        ep.observaciones = ep.observaciones[0..9999]
        begin
          ep.save!
        rescue Exception => e
          puts e.to_s
          debugger
        end


        if tmenserror != ""
          menserror << tmenserror
          return nil
        end

        return c1.id
    end

    # @param p1 Primera persona
    # @param p2 Segunda persona
    # @param ep Etiqueta para la persona que queda que se construye
    def unificar_dos_personas_en_casos(
      p1, p2, current_usuario, cadpersona, ep, menserror
    )
      debugger
      loop do
        cc1 = Sivel2Sjr::Casosjr.where(contacto_id: p1.id).pluck(:caso_id)
        cc2 = Sivel2Sjr::Casosjr.where(contacto_id: p2.id).pluck(:caso_id)
        if cc1.count > 0 and cc2.count > 0
          cr = unificar_dos_casos(cc1[0], cc2[0], current_usuario, menserror)
          if !cr.nil?
            ep.observaciones << "Unificados casos #{cc1[0]} y #{cc2[0]} en #{cr}\n"
          else
            menserror << "Primer #{cadpersona} (#{p1.id} "\
              "#{p1.nombres.to_s} #{p1.apellidos.to_s}) es contacto "\
              "en caso #{cc1[0]} y segundo beneficiario (#{p2.id} "\
              "#{p2.nombres} #{p2.apellidos}) es contacto en caso "\
              "#{cc2[0]}. Se intentó sin éxito la unificación de "\
              "los dos casos.\n"
            return [menserror, nil]
          end
        end
        break if cc1.count == 0 || cc2.count == 0;
      end

      cp2  = Sivel2Gen::Victima.where(persona_id: p2.id).pluck(:caso_id)
      cp2.each do |cid|
        Sivel2Gen::Victima.where(
          caso_id: cid, persona_id: p2.id
        ).each do |vic|
          if Sivel2Gen::Victima.where(caso_id: cid, persona_id: p1.id).count == 0
            nv = vic.dup
            nv.persona_id = p1.id
            nv.save
            nvs = vic.victimasjr.dup
            if nvs
              nvs.victima_id = nv.id
              nvs.save
            end
            ep.observaciones << "Creada víctma en caso #{cid}\n"
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
            ep.observaciones << "Cambiado contacto en caso #{cid}\n"
          end
          ep.save
          Sivel2Gen::Acto.where(
            caso_id: cid, persona_id: p2.id
          ).each do |ac|
            ac.persona_id = p1.id
            ac.save!
            ep.observaciones << "Cambiado acto en caso #{cid}\n"
          end
          ep.save
          ep.observaciones << "Elimina #{cadpersona} "\
            "#{vic.persona_id} del caso #{cid}\n"
          vic.destroy
          ep.observaciones = ep.observaciones[0..4998]
          ep.save
        end
      end

      Cor1440Gen::Caracterizacionpersona.where(persona_id: p2.id).each do |cp|
        cp.persona_id = p1.id
        cp.save
        ep.observaciones << "Cambiada caracterizacíon #{cp.id}\n"
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
          ep.observaciones << "Cambiado beneficiario en convenio financiado #{pfid}\n"
        end
        Cor1440Gen::Beneficiariopf.connection.execute <<-SQL
               DELETE FROM cor1440_gen_beneficiariopf WHERE 
                 persona_id=#{p2.id} AND
                 proyectofinanciero_id=#{pfid};
        SQL
      end
      ::Detallefinanciero.joins(:persona).where(
        'msip_persona.id' => p2.id
      ).each do |bp|
        bp.persona_id = p1.id
        bp.save
        ep.observaciones << "Cambiado detalle financiero #{bp.detallefinanciero_id}\n"
      end
      #detallefinanciero_persona
    end

    # @param c Sivel2Gen::Caso
    # @param menserror Colchon para mensajes de error
    # @return true y menserror no es modificado o false y se agrega problema a menserror
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
              WHERE caso_id=#{c.id});"
        )
        ['sivel2_sjr_ayudasjr_respuesta', 
         'sivel2_sjr_ayudaestado_respuesta',
         'sivel2_sjr_derecho_respuesta', 
         'sivel2_sjr_aspsicosocial_respuesta', 
         'sivel2_sjr_motivosjr_respuesta', 
         'sivel2_sjr_progestado_respuesta'
        ].each do |trr|
          ord = "DELETE FROM #{trr}
           WHERE respuesta_id IN (SELECT id FROM sivel2_sjr_respuesta 
             WHERE caso_id=#{c.id});"
          #puts "OJO ord='#{ord}'"
          Sivel2Gen::Caso.connection.execute(ord)
        end
        Sivel2Gen::Caso.connection.execute(
          "DELETE FROM sivel2_sjr_accionjuridica_respuesta 
           WHERE respuesta_id IN (SELECT id FROM sivel2_sjr_respuesta 
             WHERE caso_id=#{c.id});"
        )

        Sivel2Gen::Caso.connection.execute("DELETE FROM sivel2_sjr_actosjr
        WHERE acto_id IN (SELECT id FROM sivel2_gen_acto
          WHERE caso_id=#{c.id});")

        Sivel2Gen::Caso.connection.execute("DELETE FROM sivel2_sjr_desplazamiento
        WHERE caso_id=#{c.id};")
        Sivel2Gen::Caso.connection.execute("UPDATE sivel2_gen_caso
        SET ubicacion_id=NULL
          WHERE id=#{c.id};")
        Sivel2Gen::Caso.connection.execute("UPDATE sivel2_sjr_casosjr
        SET llegada_id=NULL WHERE caso_id=#{c.id};")
        Sivel2Gen::Caso.connection.execute("UPDATE sivel2_sjr_casosjr
        SET salida_id=NULL WHERE caso_id=#{c.id};")
        Sivel2Gen::Caso.connection.execute("UPDATE sivel2_sjr_casosjr
        SET llegadam_id=NULL WHERE caso_id=#{c.id};")
        Sivel2Gen::Caso.connection.execute("UPDATE sivel2_sjr_casosjr
        SET salidam_id=NULL WHERE caso_id=#{c.id};")
        Sivel2Gen::Caso.connection.execute("DELETE FROM msip_ubicacion
        WHERE caso_id=#{c.id};")
        Sivel2Gen::Caso.connection.execute(
          "DELETE FROM sivel2_sjr_actividad_casosjr
        WHERE casosjr_id=#{c.id}")
        Sivel2Gen::Caso.connection.execute(
          "DELETE FROM sivel2_sjr_respuesta 
        WHERE caso_id=#{c.id}")
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
      #      WHERE caso_id=#{c.id};")
      #    Sivel2Gen::Caso.connection.execute("DELETE FROM sivel2_gen_caso
      #      WHERE id=#{c.id};")
      #    Sivel2Gen::Caso.connection.execute('COMMIT;')
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
        sexo: 'M',
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
