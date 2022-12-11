require_dependency 'sivel2_sjr/concerns/controllers/casos_controller'
require_dependency 'heb412_gen/docs_controller'

module Sivel2Sjr
  class CasosController < Heb412Gen::ModelosController

    include Sivel2Sjr::Concerns::Controllers::CasosController

    before_action :set_caso, 
      only: [:show, :edit, :update, :destroy, :solicitar],
      exclude: [:poblacion_sexo_rangoedadac, :personas_casos]
    load_and_authorize_resource class: Sivel2Gen::Caso

    def vistas_manejadas
      ['Caso']
    end

    def atributos_show
      [
        # basicos
        :id,
        :fecharec,
        :oficina,
        :fecha,
        :memo,
        :created_at,
        :asesor,
        :asesorhistorico,
        :contacto,
        :direccion,
        :telefono,
        :atenciones,
        :listado_familiares,
        :listado_anexos,
        :solicitudes,
        :etiqueta_ids
      ]
    end

    # Campos en filtro
    def campos_filtro1
      [
        :apellidos, 
        :apellidossp, 
        :atenciones_fechaini,
        :atenciones_fechafin,
        :categoria_id,
        :codigo,
        :departamento_id,
        :descripcion,
        :expulsion_pais_id, 
        :expulsion_departamento_id, 
        :expulsion_municipio_id,
        :fechaini, 
        :fechafin, 
        :fecharecini, 
        :fecharecfin, 
        :llegada_pais_id, 
        :llegada_departamento_id, 
        :llegada_municipio_id,
        :nombressp, 
        :numerodocumento,
        :nombres, 
        :oficina_id, 
        :rangoedad_id, 
        :sexo, 
        :tdocumento, 
        :ultimaatencion_fechaini, 
        :ultimaatencion_fechafin,
        :usuario_id,
      ]
    end

    def registrar_en_bitacora
      true
    end

    # Campos por presentar en listado index
    def incluir_inicial
      return ['casoid', 'contacto', 'fecharec', 'oficina', 
              'nusuario', 'fecha', 'expulsion',
              'llegada', 'ultimaatencion_fecha', 'memo'
      ]
    end

    # Ordenamiento inicial por este campo
    def campoord_inicial
      'fecharec'
    end

    def asegura_camposdinamicos(registro, current_usuario_id)
    end


    # Responde con mensaje de error
    def resp_error(m)
      respond_to do |format|
        format.html { 
          render inline: m
        }
        format.json { 
          render json: m, status: :unprocessable_entity 
        }
      end
    end

    # Fución API que retorna personas de un caso
    def personas_casos
      authorize! :read, Msip::Persona
      res = []
      if params && params['caso_ids']
        puts "params es #{params.inspect}"
        params['caso_ids'].split(',').each do |cc|
          nc = cc.to_i
          if Sivel2Gen::Caso.where(id: nc).count == 0
            resp_error("No se encontró caso #{nc}")
            return
          end
          c = Sivel2Gen::Caso.find(nc)
          c.persona.each do |p|
            res.push({
              persona_id: p.id,
              nombres: p.nombres,
              apellidos: p.apellidos,
              tdocumento_sigla: p.tdocumento ? p.tdocumento.sigla : '',
              numerodocumento: p.numerodocumento
            })
          end
        end
      end

      resj = res.to_json
      respond_to do |format|
        format.js { render text: resj }
        format.json { render json: resj, status: :created }
        format.html { render inline: resj }
      end

    end

    def new
      @registro = @caso = Sivel2Gen::Caso.new
      @caso.current_usuario = current_usuario
      @caso.fecha = DateTime.now.strftime('%Y-%m-%d')
      @caso.memo = ''
      @caso.casosjr = Sivel2Sjr::Casosjr.new
      @caso.casosjr.fecharec = DateTime.now.strftime('%Y-%m-%d')
      @caso.casosjr.asesor = current_usuario.id
      @caso.casosjr.oficina_id= current_usuario.oficina_id.nil? ?  
        1 : current_usuario.oficina_id
      if params[:contacto] && 
          Msip::Persona.where(id: params[:contacto].to_i).count == 1
        per = Msip::Persona.find(params[:contacto])
      else
        per = Msip::Persona.new
        per.nombres = 'N'
        per.apellidos = 'N'
        per.sexo = 'S'
        per.tdocumento_id = 11
        per.save!(validate: false)
      end
      vic = Sivel2Gen::Victima.new
      vic.persona = per
      @caso.victima<<vic
      @caso.casosjr.contacto = per
      @caso.save!(validate: false)
      vic.id_caso = @caso.id
      vic.save!(validate: false)
      logger.debug "Victima salvada: #{vic.inspect}"
      #debugger
      vic.victimasjr = Sivel2Sjr::Victimasjr.new
      vic.victimasjr.id_victima = vic.id
      vic.victimasjr.save!(validate: false)
      cu = Sivel2Gen::CasoUsuario.new
      cu.id_usuario = current_usuario.id
      cu.id_caso = @caso.id
      cu.fechainicio = DateTime.now.strftime('%Y-%m-%d')
      cu.save!(validate: false)
      redirect_to edit_caso_path(@registro)
    end


    def filtrar_ca(conscaso)
      if current_usuario && current_usuario.rol == Ability::ROLINV
        aeu = current_usuario.etiqueta_usuario.map { |eu| eu.etiqueta_id }
        conscaso = conscaso.joins(
          'JOIN sivel2_gen_caso_etiqueta as cet ON cet.id_caso=id_caso')
        if aeu.count == 0
          conscaso = conscaso.where('FALSE')
        else
          conscaso = conscaso.where('cet.id_etiqueta IN [?]', aeu.join(','))
        end
      end
      return conscaso
    end

    # Tipo de reporte Resolución 1612
    def filtro_particular(conscaso, params_filtro)
      if (params_filtro['dispresenta'] == 'tabla1612') 
        @incluir =  [
          'casoid', 'tipificacion', 'victimas', 'fechadespemb', 
          'ubicaciones', 'presponsables', 'descripcion', 'memo1612'
        ]
        conscaso = conscaso.where('caso_id in (SELECT id_caso 
                                        FROM public.sivel2_gen_acto
                                        WHERE id_categoria = 3020
                                        OR id_categoria=3021)')
        @usa_consexpcaso = true
        Sivel2Gen::Consexpcaso.crea_consexpcaso(conscaso)

        @consexpcaso = Sivel2Gen::Consexpcaso.all
      end
      return conscaso
    end

    def validar_params
      # No se pone en persona para no afectar listado de asistencia
      # en actividad, ni beneficiarios
      # Se intento con una validación en el modelo de caso, pero 
      # en ocasiones valida con datos históricos y no con los
      # que recibía por parámetros.  Aquí aseguramos que se valida
      # lo recibido por parámetros.
      if !params || !params[:caso] || !params[:caso][:victima_attributes]
        return false
      end
      cuentaini = @caso.errors.count
      numper = 0
      params[:caso][:victima_attributes].each do |i,v|
        if v[:_destroy] != '1' && v[:persona_attributes]
          p=v[:persona_attributes]
          if numper == 0
            n="Contacto"
          else
            n="Integrante #{numper}"
          end
          if !p[:nombres] || p[:nombres].strip == '' || p[:nombres].strip == 'N'
            @caso.errors.add(:persona, "#{n} no tiene nombres")
          end
          if !p[:apellidos] || p[:apellidos].strip == '' || p[:apellidos].strip == 'N'
            @caso.errors.add(:persona, "#{n} no tiene apellidos")
          end

          if !p[:numerodocumento] || p[:numerodocumento].strip == '' || 
              p[:numerodocumento] == '0'
            @caso.errors.add(:persona, "#{n} no tiene número de documento")
          end
          if !p[:tdocumento_id] || p[:tdocumento_id].strip == ''
            @caso.errors.add(:persona, "#{n} no tiene tipo de documento")
          else
            pt = Msip::Tdocumento.where(id: p[:tdocumento_id].to_i)
            if pt.count != 1
              @caso.errors.add(:persona, 
                               "#{n} tiene tipo de documento desconocido")
            else
              pt = pt.take
              if pt.formatoregex != '' && 
                  !(p[:numerodocumento] =~ Regexp.new("^#{pt.formatoregex}$"))
                @caso.errors.add(:persona, 
                                 "#{n} tiene número de documento con formato errado. "\
                                 "#{pt.ayuda ? pt.ayuda : ''}")
              else
                idrep = Msip::Persona.where(numerodocumento: p[:numerodocumento]).
                  where(tdocumento_id: p[:tdocumento_id]).
                  where('id<>?', p[:id])
                if idrep.count > 0
                  @caso.errors.add(:persona, "#{n.capitalize} tiene identificación repetida con #{idrep.count} persona(s)")
                end
              end
            end
          end
          if !p[:sexo] || p[:sexo].strip == ''
            @caso.errors.add(:persona, "#{n.capitalize} no tiene sexo")
          elsif p[:sexo] == 'S'
            @caso.errors.add(:persona, "#{n.capitalize} tiene sexo 'S'")
          end
          if !p[:anionac] || p[:anionac].strip == ''
            @caso.errors.add(:persona, "#{n.capitalize} no tiene año de nacimiento")
          elsif p[:anionac].to_i < 1900
            @caso.errors.add(:persona, "#{n.capitalize} tiene año de nacimiento anterior a 1900")
          end
          if !p[:id_pais] || p[:id_pais].strip == ''
            @caso.errors.add(:persona, "#{n.capitalize} no tiene país de nacimiento")
          end
          numper += 1
        end
      end

      return cuentaini == @caso.errors.count
    end


    def cambiar_asesor
      ::Asesorhistorico.create(
        casosjr_id: @caso.casosjr.id, usuario_id: @caso.casosjr.asesor,
        fechainicio: @caso.casosjr.asesorfechaini,
        fechafin: Date.today.to_s,
        oficina_id: @caso.casosjr.oficina_id
      )
      @caso.casosjr.asesorfechaini = Date.today.to_s
      @caso.casosjr.asesor = params[:caso][:casosjr_attributes][:asesor].to_i
      @caso.save(validate: false)
      @caso.casosjr.oficina_id = @caso.casosjr.usuario.oficina_id
      @caso.save(validate: false)
      params[:caso][:casosjr_attributes][:oficina_id] = @caso.casosjr.oficina_id 
      cs = @caso.solicitud.where(
        solicitud: "Ser asesor del caso #{@caso.id}",
        usuario_id: @caso.casosjr.asesor,
        estadosol_id: Msip::Solicitud::PENDIENTE)
      if cs.count > 0
        cs.each do |csi| 
          csi.estadosol_id = Msip::Solicitud::RESUELTA
          csi.save
        end
      end
    end


    def update_sivel2_sjr
      @casovalido = true if @casovalido.nil? 
      # No deben venir validaciones en controlador
      respond_to do |format|
        if (!params[:caso][:caso_etiqueta_attributes].nil?)
          params[:caso][:caso_etiqueta_attributes].each {|k,v|
            if (v[:id_usuario].nil? || v[:id_usuario] == "") 
              v[:id_usuario] = current_usuario.id
            end
          }
        end
        if (!params[:caso][:respuesta_attributes].nil?)
          params[:caso][:respuesta_attributes].each {|k,v|
            if (v[:id_caso].nil?) 
              v[:id_caso] = @caso.id
            end
          }
        end
        @caso.current_usuario = current_usuario
        @caso.assign_attributes(caso_params)
        @casovalido &= @caso.valid?
        begin
          @caso.save(validate: false)
          if registrar_en_bitacora
            Msip::Bitacora.agregar_actualizar(
              request, :caso, :bitacora_cambio, 
              current_usuario.id, params, 'Sivel2Gen::Caso',
              @caso.id
            )
          end
        rescue
          puts "No pudo salvar caso"
          @casovalido = false
        end
        if validar_params && @casovalido 
          format.html { 
            if request.xhr?
              if request.params[:_msip_enviarautomatico_y_repintar] 
                render(action: 'edit', 
                       layout: 'application', 
                       notice: 'Caso actualizado.')
              else
                render(action: 'show', 
                       layout: 'application', 
                       notice: 'Caso actualizado.')
              end
            else
              redirect_to @caso, notice: 'Caso actualizado.'
            end
          }
          format.json { 
            head :no_content 
          }
          format.js   { 
            redirect_to @caso, notice: 'Caso actualizado.' 
          }
          Sivel2Gen::Conscaso.refresca_conscaso
        else
          format.html { render action: 'edit', layout: 'application' }
          format.json { render json: @caso.errors, status: :unprocessable_entity }
          format.js   { render action: 'edit' }
        end
      end
    end


    def update
      # Procesar ubicacionespre de migración
      (caso_params[:migracion_attributes] || []).each do |clave, mp|
        mi = Sivel2Sjr::Migracion.find(mp[:id].to_i)
        mi.salidaubicacionpre_id = Msip::Ubicacionpre::buscar_o_agregar(
          mp[:salida_pais_id], mp[:salida_departamento_id],
          mp[:salida_municipio_id], mp[:salida_clase_id],
          mp[:salida_lugar], mp[:salida_sitio], mp[:salida_tsitio_id],
          mp[:salida_latitud], mp[:salida_longitud]
        )
        mi.llegadaubicacionpre_id = Msip::Ubicacionpre::buscar_o_agregar(
          mp[:llegada_pais_id], mp[:llegada_departamento_id],
          mp[:llegada_municipio_id], mp[:llegada_clase_id],
          mp[:llegada_lugar], mp[:llegada_sitio], mp[:llegada_tsitio_id],
          mp[:llegada_latitud], mp[:llegada_longitud]
        )
        mi.destinoubicacionpre_id = Msip::Ubicacionpre::buscar_o_agregar(
          mp[:destino_pais_id], mp[:destino_departamento_id],
          mp[:destino_municipio_id], mp[:destino_clase_id],
          mp[:destino_lugar], mp[:destino_sitio], mp[:destino_tsitio_id],
          mp[:destino_latitud], mp[:destino_longitud]
        )
        mi.save!(validate: false)
      end

      (caso_params[:desplazamiento_attributes] || []).each do |clave, dp|
        de = Sivel2Sjr::Desplazamiento.find(dp[:id].to_i)
        de.expulsionubicacionpre_id = Msip::Ubicacionpre::buscar_o_agregar(
          dp[:expulsion_pais_id], dp[:expulsion_departamento_id],
          dp[:expulsion_municipio_id], dp[:expulsion_clase_id],
          dp[:expulsion_lugar], dp[:expulsion_sitio], dp[:expulsion_tsitio_id],
          dp[:expulsion_latitud], dp[:expulsion_longitud]
        )
        de.llegadaubicacionpre_id = Msip::Ubicacionpre::buscar_o_agregar(
          dp[:llegada_pais_id], dp[:llegada_departamento_id],
          dp[:llegada_municipio_id], dp[:llegada_clase_id],
          dp[:llegada_lugar], dp[:llegada_sitio], dp[:llegada_tsitio_id],
          dp[:llegada_latitud], dp[:llegada_longitud]
        )
        de.destinoubicacionpre_id = Msip::Ubicacionpre::buscar_o_agregar(
          dp[:destino_pais_id], dp[:destino_departamento_id],
          dp[:destino_municipio_id], dp[:destino_clase_id],
          dp[:destino_lugar], dp[:destino_sitio], dp[:destino_tsitio_id],
          dp[:destino_latitud], dp[:destino_longitud]
        )
        de.save!(validate: false)
      end

      if !@caso.casosjr.asesor.nil? && @caso.casosjr.asesor != params[:caso][:casosjr_attributes][:asesor].to_i
        if current_usuario.rol == Ability::ROLADMIN || 
          current_usuario.rol == Ability::ROLDIR
          if @caso.casosjr.asesorfechaini.nil? then
            @caso.casosjr.asesorfechaini = '2022-06-29'
          end
          cambiar_asesor
        #else
          #raise CanCan::AccessDenied.new("No autorizado!", :update, 
        #                                 Sivel2Gen::Caso)
        end

      end

      # Convertir valores de radios tri-estado, el valor 3 en el 
      # botón de radio es nil en la base de datos
      # Si falta poner id_victima
      if params && params[:caso] && params[:caso][:victima_attributes]
        params[:caso][:victima_attributes].each do |l, v|
          [:actualtrabajando, :asisteescuela, 
           :cabezafamilia, :tienesisben].each do |sym|
            if v[:victimasjr_attributes] && v[:victimasjr_attributes][sym] && v[:victimasjr_attributes][sym] == '3'
              v[:victimasjr_attributes][sym] = nil
            end
          end
          if v[:victimasjr_attributes] &&
              v[:victimasjr_attributes][:id_victima] &&
              v[:victimasjr_attributes][:id_victima] == ''
            v[:victimasjr_attributes][:id_victima] = v[:id]
          end
        end
      end

      update_sivel2_sjr
    end


    # DELETE /casos/1.json
    # Este método obligó a definir sivel2_gen_destroy en sivel2_gen/concerns/controllers/casos_controllers
    # y a repetir before_action :set_caso, only: [:show, :edit, :update, :destroy]
    # en el included do de este
    def sivel2_sjr_destroy
      if @caso.casosjr && @caso.casosjr.respuesta
        # No se logró hacer ni con dependente:destroy en
        # las relaciones ni borrando con delete 
        @caso.casosjr.respuesta.each do |r|
          Sivel2Sjr::AslegalRespuesta.where(id_respuesta: r.id).delete_all
          #r.aslegal_respuesta.delete
          Sivel2Sjr::AyudaestadoRespuesta.where(id_respuesta: r.id).delete_all
          #r.ayudaestado_respuesta.delete
          Sivel2Sjr::AyudasjrRespuesta.where(id_respuesta: r.id).delete_all
          #r.ayudasjr_respuesta.delete
          Sivel2Sjr::DerechoRespuesta.where(id_respuesta: r.id).delete_all
          #r.derecho_respuesta.delete
          Sivel2Sjr::MotivosjrRespuesta.where(id_respuesta: r.id).delete_all
          #r.motivosjr_respuesta.delete
          Sivel2Sjr::ProgestadoRespuesta.where(id_respuesta: r.id).delete_all
          #r.progestado_respuesta.delete
        end
        @caso.casosjr.respuesta.delete
        Sivel2Sjr::Respuesta.where(id_caso: @caso.id).delete_all
      end
      Sivel2Sjr::Casosjr.connection.execute <<-SQL
        DELETE FROM sivel2_sjr_actosjr 
          WHERE id_acto IN (SELECT id FROM sivel2_gen_acto 
            WHERE id_caso='#{@caso.id}');
        DELETE FROM sivel2_sjr_desplazamiento 
          WHERE id_caso = #{@caso.id};
        DELETE FROM sivel2_sjr_actividad_casosjr
          WHERE casosjr_id = #{@caso.id};
      SQL
      @caso.casosjr.destroy if @caso.casosjr
      if @caso.casosjr && @caso.casosjr.errors.present?
        mens = 'No puede borrar caso: ' + @caso.casosjr.errors.messages.values.flatten.join('; ')
        puts mens
        redirect_to caso_path(@caso), alert: mens
        return
      else
        sivel2_gen_destroy
        Sivel2Gen::Conscaso.refresca_conscaso
        # redirect_to casos_path
      end
    end


    def destroy
      if @caso.casosjr && @caso.casosjr.respuesta
        # No se logró hacer ni con dependente:destroy en
        # las relaciones ni borrando con delete 
        @caso.casosjr.respuesta.each do |r|
          Sivel2Sjr::AccionjuridicaRespuesta.where(respuesta_id: r.id).
            delete_all
        end
      end
      sivel2_sjr_destroy
    end

    def otros_params_respuesta
      [
        :accionjuridica_respuesta_attributes => [
          :accionjuridica_id,
          :favorable,
          :id,
          :_destroy
        ]
      ]
    end

    def otros_params_victimasjr 
      [ :actualtrabajando, :discapacidad_id ]
    end

    def otros_params_victima
      [:anexo_victima_attributes => [
        :fecha_localizada,
        :tipoanexo_id,
        :id, 
        :id_victima,
        :_destroy,
        :msip_anexo_attributes => [
          :adjunto, 
          :descripcion, 
          :id, 
          :_destroy
        ]
      ] ]
    end

    def otros_params
      [
        :migracion_attributes => [
          :actor_pago,
          :autoridadrefugio_id,
          :causaRefugio_id,
          :causamigracion_id,
          :concepto_pago,
          :destino_clase_id,
          :destino_departamento_id,
          :destino_municipio_id,
          :destino_pais_id,
          :destino_latitud,
          :destino_longitud,
          :destino_lugar,
          :destino_sitio,
          :destino_tsitio_id,
          :fechallegada,
          :fechaNpi,
          :fechaPep,
          :fechasalida,
          :fechaendestino,
          :id,
          :llegada_clase_id,
          :llegada_departamento_id,
          :llegada_municipio_id,
          :llegada_pais_id,
          :llegada_latitud,
          :llegada_longitud,
          :llegada_lugar,
          :llegada_sitio,
          :llegada_tsitio_id,
          :llegada_ubicacionpre_id,
          :miembrofamiliar_id,
          :migracontactopre_id,
          :numppt,
          :observacionesref,
          :otraagresion,
          :otraautoridad,
          :otracausa,
          :otromiembro,
          :otracausagrpais,
          :otracausaagresion,
          :otronpi,
          :pagoingreso_id,
          :pep,
          :perpeagresenpais,
          :perpetradoresagresion,
          :perfilmigracion_id,
          :proteccion_id,
          :salida_pais_id,
          :salida_departamento_id,
          :salida_municipio_id,
          :salida_clase_id,
          :salida_latitud,
          :salida_longitud,
          :salida_lugar,
          :salida_sitio,
          :salida_tsitio_id,
          :salida_ubicacionpre_id,
          :salvoNpi,
          :se_establece_en_sitio_llegada,
          :statusmigratorio_id,
          :tratoauto,
          :tratoresi,
          :tipopep,
          :tipoproteccion_id,
          :ubifamilia,
          :valor_pago,
          :viadeingreso_id,
          :_destroy,
          :agresionmigracion_ids => [],
          :agresionenpais_ids => [],
          :causaagresion_ids => [],
          :causaagrpais_ids => [],
          :dificultadmigracion_ids => []
        ],
      ]
    end

    def desplazamiento_params
      [
        :desplazamiento_attributes => [
          :acompestado, 
          :connacionaldeportado,
          :connacionalretorno,
          :declaracionruv_id,
          :declaro, 
          :descripcion, 
          :destino_clase_id,
          :destino_departamento_id,
          :destino_latitud,
          :destino_longitud,
          :destino_lugar,
          :destino_municipio_id,
          :destino_pais_id,
          :destino_sitio,
          :destino_tsitio_id,
          :expulsion_clase_id,
          :expulsion_departamento_id,
          :expulsion_latitud,
          :expulsion_longitud,
          :expulsion_lugar,
          :expulsion_municipio_id,
          :expulsion_pais_id,
          :expulsion_sitio,
          :expulsion_tsitio_id,
          :documentostierra,
          :establecerse,
          :fechadeclaracion,
          :fechadeclaracion_localizada,
          :fechaexpulsion, 
          :fechaexpulsion_localizada, 
          :fechallegada, 
          :fechallegada_localizada, 
          :hechosdeclarados,
          :id, 
          :id_acreditacion, 
          :id_clasifdesp, 
          :id_declaroante, 
          :id_expulsion, 
          :id_inclusion,
          :id_llegada, 
          :id_modalidadtierra,
          :id_tipodesp, 
          :inmaterialesperdidos,
          :llegada_clase_id,
          :llegada_departamento_id,
          :llegada_latitud,
          :llegada_longitud,
          :llegada_lugar,
          :llegada_municipio_id,
          :llegada_pais_id,
          :llegada_sitio,
          :llegada_tsitio_id,
          :materialesperdidos, 
          :protegiorupta, 
          :oficioantes, 
          :otrosdatos,
          :retornado,
          :reubicado, 
          :_destroy,
          :categoria_ids => [],
          :anexo_desplazamiento_attributes => [
              :fecha_localizada,
              :id, 
              :desplazamiento_id,
              :_destroy,
              :msip_anexo_attributes => [
                :adjunto, 
                :descripcion, 
                :id, 
                :_destroy
              ]
            ]
        ]
      ]
    end

    def importa_dato(datosent, datossal, menserror, registro = nil, 
                     opciones = {})
      importa_dato_gen(datosent, datossal, menserror, registro, opciones)
    end
  
    def establece_registro
      @registro = @basica = nil
      if !params || !params[:id] || 
          Sivel2Gen::Caso.where(id: params[:id]).count != 1
        return
      end
      Sivel2Gen::Conscaso.refresca_conscaso
      cc = Sivel2Gen::Conscaso.where(caso_id: params[:id])
      Sivel2Gen::Consexpcaso.crea_consexpcaso(cc, nil)
      @registro = @basica = Sivel2Gen::Consexpcaso.
        where(caso_id: params[:id]).take
    end


    def solicitar
      if @caso.nil?
       flash[:error] = 'No se creó solicitud. Falta caso'
      else
        merror = Sivel2Gen::CasoSolicitud::solicitar(
          current_usuario, 
          Sivel2Gen::CasoSolicitud::SER_ASESOR,
          @caso.id,
          Usuario.where(rol: Ability::ROLADMIN,
                        fechadeshabilitacion: nil)
        )
        if merror == ''
          flash[:notice] = "Solicitud para administradores creada y programando envío de correo."
          begin
            SolicitudMailer.with(
              objeto: 'el caso',
              id: @caso.id,
              solicitante: current_usuario.nusuario,
              cor_solicitante: current_usuario.email,
              solicitado_a: Usuario.where(
                rol: Ability::ROLADMIN,
                fechadeshabilitacion: nil
              ).map(&:nusuario),
              cor_solicitado_a: Usuario.where(
                rol: Ability::ROLADMIN,
                fechadeshabilitacion: nil
              ).map(&:email),
              solicitud: "Ser asesor del caso #{@caso.id}"
            ).solicitud.deliver_now
          rescue => e
            merror << " No se pudo enviar correo (#{e.to_s})."
            puts "*** No se pudo enviar correo (#{e.to_s})"
          end
        end

        if merror != ''
          flash[:error] = merror
        end
        redirect_to sivel2_gen.caso_path(@caso.id)
      end
    end


    def set_caso
      if Sivel2Gen::Caso.where(id: params[:id].to_i).count == 0
        redirect_to sivel2_gen.casos_path, 
          alert: "Ya no existe el caso #{params[:id].to_i}"
        return
      end
      @caso = Sivel2Gen::Caso.find(params[:id].to_i)
      @caso.current_usuario = current_usuario
      @registro = @caso
      pcs = Sivel2Sjr::Casosjr.where(id_caso: params[:id].to_i)
      @casosjr = nil
      if pcs.count > 0
        @casosjr = pcs.take
      end
    end



    def lista_params
      lp = [
        :bienes, 
        :duracion, 
        :fecha, 
        :fecha_localizada, 
        :grconfiabilidad, 
        :gresclarecimiento, 
        :grimpunidad, 
        :grinformacion, 
        :hora, 
        :id, 
        :id_intervalo, 
        :memo, 
        :titulo, 
        :casosjr_attributes => [
          :asesor, 
          :comosupo_id, 
          :contacto, 
          :concentimientosjr, 
          :concentimientobd,
          :categoriaref,
          :dependen, 
          :detcomosupo,
          :direccion, 
          :docrefugiado,
          :estatus_refugio,
          :estrato, 
          :fecharec, 
          :fecharec_localizada, 
          :fechadecrefugio,
          :fechadecrefugio_localizada,
          :fechallegada, 
          :fechallegada_localizada, 
          :fechallegadam, 
          :fechallegadam_localizada, 
          :fechasalida, 
          :fechasalida_localizada, 
          :fechasalidam, 
          :fechasalidam_localizada, 
          :gastos, 
          :ingresomensual, 
          :id, 
          :id_idioma,
          :id_llegada, 
          :id_llegadam, 
          :id_proteccion, 
          :id_salida, 
          :id_salidam, 
          :id_statusmigratorio,
          :leerescribir, 
          :memo1612,
          :motivom,
          :observacionesref,
          :oficina_id, 
          :sustento, 
          :telefono, 
          :_destroy
        ] + otros_params_casosjr, 
        :victima_attributes => [
          :anotaciones,
          :id, 
          :id_etnia, 
          :id_filiacion, 
          :id_iglesia, 
          :id_organizacion, 
          :id_persona, 
          :id_profesion, 
          :id_rangoedad, 
          :id_vinculoestado, 
          :orientacionsexual, 
          :_destroy 
        ] + otros_params_victima + [
          :persona_attributes => [
            :apellidos, 
            :anionac, 
            :dianac, 
            :id, 
            :id_pais, 
            :id_departamento, 
            :id_municipio, 
            :id_clase, 
            :mesnac, 
            :nacionalde, 
            :numerodocumento, 
            :nombres, 
            :ppt, 
            :sexo, 
            :tdocumento_id,
            :ultimoestatusmigratorio_id,
            :ultimoperfilorgsocial_id,
          ] + otros_params_persona,
          :victimasjr_attributes => [
            :asisteescuela, 
            :cabezafamilia, 
            :enfermedad, 
            :eps, 
            :fechadesagregacion,
            :fechadesagregacion_localizada,
            :id, 
            :id_victima, 
            :id_rolfamilia,
            :id_actividadoficio, 
            :id_escolaridad,
            :id_estadocivil, 
            :id_maternidad, 
            :id_regimensalud, 
            :ndiscapacidad, 
            :sindocumento, 
            :tienesisben
          ] + otros_params_victimasjr 
        ], 
        :ubicacion_attributes => [
          :id, 
          :id_clase, 
          :id_departamento, 
          :id_municipio, 
          :id_pais, 
          :id_tsitio, 
          :latitud, 
          :longitud, 
          :lugar, 
          :sitio, 
          :_destroy
        ],
        :caso_presponsable_attributes => [
          :batallon, 
          :bloque, 
          :brigada, 
          :division, 
          :frente, 
          :id, 
          :id_presponsable, 
          :otro, 
          :tipo, 
          :_destroy
        ],
        :acto_attributes => [
          :id, 
          :id_categoria, 
          :id_presponsable, 
          :id_persona, 
          :_destroy,
          :actosjr_attributes => [
            :desplazamiento_id, 
            :fecha, 
            :fecha_localizada, 
            :id, 
            :id_acto, 
            :_destroy
          ]
        ],
        :respuesta_attributes => [
          :accionesder,
          :cantidadayes,
          :compromisos,
          :detalleal, 
          :detalleap, 
          :detalleem, 
          :detallemotivo, 
          :detallear, 
          :descatencion,
          :descamp, 
          :difobsprog,
          :efectividad, 
          :id,
          :id_personadesea, 
          :informacionder, 
          :institucionayes, 
          :fechaatencion, 
          :fechaatencion_localizada, 
          :fechaultima, 
          :fechaultima_localizada, 
          :gestionessjr, 
          :lugar, 
          :lugarultima, 
          :montoal,
          :montoap,
          :montoar,
          :montoem,
          :montoprorrogas,
          :numprorrogas, 
          :observaciones,
          :orientaciones, 
          :remision,  
          :turno,
          :verifcsjr, 
          :verifcper,
          :_destroy, 
          :aslegal_ids => [],
          :aspsicosocial_ids => [],
          :ayudaestado_ids => [],
          :ayudasjr_ids => [],
          :derecho_ids => [],
          :emprendimiento_ids => [],
          :motivosjr_ids => [],
          :progestado_ids => [],
        ] + otros_params_respuesta,
        :anexo_caso_attributes => [
          :fecha_localizada,
          :id, 
          :id_caso,
          :_destroy,
          :msip_anexo_attributes => [
            :adjunto, 
            :descripcion, 
            :id, 
            :_destroy
          ]
        ],
        :caso_etiqueta_attributes => [
          :fecha, 
          :id, 
          :id_etiqueta, 
          :id_usuario, 
          :observaciones, 
          :_destroy
        ]
      ] + otros_params  + desplazamiento_params

      lp
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def caso_params
      lp = lista_params 
      params.require(:caso).permit(lp)
    end

  end
end
