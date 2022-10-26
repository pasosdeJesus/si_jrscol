require_dependency "cor1440_gen/concerns/controllers/actividades_controller"

module Cor1440Gen
  class ActividadesController < Heb412Gen::ModelosController

    #no más include Sivel2Sjr::Concerns::Controllers::ActividadesController
    include Cor1440Gen::Concerns::Controllers::ActividadesController

    before_action :set_actividad, 
      only: [:show, :edit, :update, :destroy],
      exclude: [:contar, :poblacion_sexo_rangoedadac, :contar_beneficiarios]
    load_and_authorize_resource class: Cor1440Gen::Actividad

    Cor1440Gen.actividadg1 = "Funcionarias del SJR"
    Cor1440Gen.actividadg3 = "Funcionarios del SJR"

    def self.posibles_nuevaresp
      return {
        ahumanitaria: ['Asistencia humanitaria', 116],
        ojuridica: ['Orientación jurídica', 118],
        ajuridica: ['Accion Jurídica', 125],
        oservicios: ['Otros servicios y asesorias', 126],
        apsicosocial: ['Acompañamiento psicosocial', 70],
        capsemilla: ['Entrega de Capital Semilla', 45],
        formacion: ['Formación o Capacitación', 51],
        siniciativa: ['Seguimiento a Iniciativa', 156],
      } 
    end

    # Retorna datos por enviar a nuevo de este controlador
    # desde javascript cuando se añade una respuesta a un caso
    def self.datos_nuevaresp(caso, controller)
      return {
        nombre: "Seguimiento/Respuesta a caso #{caso.id}",
        oficina_id: caso.casosjr.oficina_id,
        caso_id: caso.id, 
        proyecto_id: 101,
        usuario_id: controller.current_usuario.id 
      } 
    end

    def self.pf_planest_id
      10
    end
    
    def self.actividadpf_segcas_id
      62
    end

    def self.filtramas(par, ac, current_usuario)
      @busactividadtipo = param_escapa(par, 'busactividadtipo')
      if @busactividadtipo != '' then
        ac = ac.joins(:actividad_actividadtipo).where(
          "cor1440_gen_actividad_actividadtipo.actividadtipo_id = ?",
          @busactividadtipo.to_i
        ) 
      end
      return ac
    end


    def atributos_show
      [ :id, 
        :nombre, 
        :fecha_localizada, 
        :lugar, 
        :oficina, 
        :proyectofinanciero, 
        :proyectos,
        :actividadareas, 
        :responsable,
        :corresponsables,
        :actividadpf, 
        :respuestafor,
        :objetivo,
        :resultado, 
        :listadocasosjr,
        :orgsocial,
        :listadoasistencia,
        :poblacion,
        :anexos
      ]
    end

    def atributos_index
      [ :id,
        :fecha_localizada,
        :oficina,
        :responsable,
        :nombre,
        :proyecto,
        :actividadareas,
        :proyectofinanciero,
        :actividadpf,
        :objetivo,
        :ubicacion,
        :poblacion_mujeres_r,
        :poblacion_hombres_r,
        :poblacion_sinsexo,
        :anexos
      ]
    end

    def atributos_form
      atributos_show - [:id, :poblacion] + [:observaciones]
    end

    # Elementos de la presentacion de una actividad
    def atributos_presenta
      [ 
        :id, 
        :fecha, 
        :oficina, 
        :responsable,
        :nombre, 
        :actividadtipos, 
        :proyectos,
        :actividadareas, 
        :proyectosfinancieros, 
        :objetivo
      ]
    end


    def vistas_manejadas
      ['Actividad', 'Benefactividadpf']
    end

    def index_plantillas
      l = index_plantillas_heb412
      l << ['Beneficiarios por Actividad de Marco Lógico (Excel)', 50]
      return l
    end

    def new_ac_sivel2_sjr
      new_cor1440_gen
      @registro.fecha = Date.today
      if params['usuario_id'] && 
          ::Usuario.where(id: params['usuario_id'].to_i).count == 1
        @registro.usuario_id = params['usuario_id'].to_i
      end
      if params['oficina_id'] && 
          Sip::Oficina.where(id: params['oficina_id'].to_i).count == 1
        @registro.oficina_id = params['oficina_id'].to_i
      end
      if params['proyecto_id'] && 
          Cor1440Gen::Proyecto.where(id: params['proyecto_id'].to_i).count == 1
        @registro.proyecto_ids = [params['proyecto_id'].to_i]
      end
      if params['nsegresp_proyectofinanciero_id'] && 
          Cor1440Gen::Proyectofinanciero.where(
            id: params['nsegresp_proyectofinanciero_id'].to_i).count == 1
      @registro.proyectofinanciero_ids |= [params[
        'nsegresp_proyectofinanciero_id'].to_i]
      end
      if params['nombre'] 
        @registro.nombre = params['nombre']
      end
      @registro.actividadpf_ids = []
      @registro.save!(validate: false)

      if params['caso_id'] && 
          Sivel2Sjr::Casosjr.where(id_caso: params['caso_id'].to_i).
          count == 1
        personas = Sivel2Gen::Victima.where(id_caso: params['caso_id'].to_i).
          joins(:victimasjr).
          where('sivel2_sjr_victimasjr.fechadesagregacion IS NULL').
          pluck(:id_persona)
        personas.each do |p|
          Cor1440Gen::Asistencia.create!(
            persona_id: p,
            actividad_id: @registro.id,
            externo: false,
            orgsocial_id: nil,
            perfilorgsocial_id: nil
          )
        end
      end

      @registro.proyectofinanciero_ids += 
        [Cor1440Gen::ActividadesController.pf_planest_id]
      Cor1440Gen::ActividadesController.posibles_nuevaresp.
        each do |s, lnumacpf|
          if params[s] && params[s] == "true"
            @registro.actividadpf_ids |= 
              [Cor1440Gen::ActividadesController.actividadpf_segcas_id,
               lnumacpf[1]]
            tipo = Cor1440Gen::Actividadpf.
              find(lnumacpf[1]).actividadtipo_id
            if tipo
              presente_otros = Cor1440Gen::Actividadpf.
                where(actividadtipo_id: tipo).
                where(proyectofinanciero_id: Cor1440Gen::ActividadesController.pf_planest_id)  # Limitamos a proyecto de tipos de actividades comunes
              @registro.actividadpf_ids |= presente_otros.pluck(:id).uniq
            end
          end
        end
      @registro.save!(validate: false)
    end

    def new
      new_ac_sivel2_sjr

      redirect_to cor1440_gen.edit_actividad_path(@registro)
    end

    # Genera conteo de beneficiarios por actividad de marco lógico desde 
    # desde actividad
    def programa_generacion_listado_int50(params, extension, campoid, 
                                          pl, narch)
      contarb_pfid = [] # Homologar con filtro de actividad
      contarb_oficinaid = []
      contarb_fechaini = nil
      contarb_fechafin = nil
      contarb_actividad_ids = @registros.map(&:id)

      Cor1440Gen::Benefactividadpf.crea_consulta(
        nil, contarb_pfid, contarb_oficinaid, contarb_fechaini, 
        contarb_fechafin, contarb_actividad_ids
      )
      registros = Cor1440Gen::Benefactividadpf.where(
        actividad_id: contarb_actividad_ids)
      ids = registros.map(&:persona_id)

      parsimp = {}
      cparams=params
      cparams.permit!
      Heb412Gen::GeneralistadoJob.perform_later(
        pl.id, 
        'Cor1440Gen::Benefactividadpf',
        'Cor1440Gen::BenefactividadpfController',
        ids, narch, parsimp, extension, 
        'persona_id', cparams)
    end

    def registrar_en_bitacora
      true
    end

    # GET /actividades/1/edit
    def edit
      edit_cor1440_gen
      @listadoasistencia = true
      render layout: 'application'
    end


    # Responde a DELETE
    def destroy_si_jrscol
      Detallefinanciero.where(actividad_id: @registro.id).
        where(proyectofinanciero_id: nil).delete_all
      ['Cor1440Gen::ActividadareasActividad',
       'Cor1440Gen::ActividadActividadpf',
       'Cor1440Gen::ActividadActividadtipo',
       'Sivel2Sjr::ActividadCasosjr',
       'Cor1440Gen::ActividadOrgsocial',
       'Cor1440Gen::ActividadProyecto',
       'Cor1440Gen::ActividadProyectofinanciero',
       'Cor1440Gen::ActividadRangoedadac',
       'Cor1440Gen::ActividadRespuestafor',
       'Cor1440Gen::ActividadSipAnexo',
       'Cor1440Gen::ActividadUsuario',
       'Cor1440Gen::Asistencia'
      ].each do |relac|
        r = relac.constantize.where(actividad_id: @registro.id)
        r.delete_all if r.count > 0
      end

      rpb = @registro.respuestafor_ids
      puts "** OJO por borrar respuestafor: #{rpb}"
      if rpb.count > 0
        Cor1440Gen::ActividadRespuestafor.connection.execute <<-EOF
          DELETE FROM cor1440_gen_actividad_respuestafor 
          WHERE actividad_id=#{@registro.id};
          DELETE FROM mr519_gen_valorcampo 
          WHERE respuestafor_id IN (#{rpb.join(',')});
          DELETE FROM mr519_gen_respuestafor 
          WHERE id IN (#{rpb.join(',')});
        EOF
      end

      destroy_gen
    end

    def destroy
      destroy_si_jrscol
    end


    def filtra_contar_control_acceso
      @contar_pfid = 10  # Plan Estrategico 1
    end


    def revisaben_detalle
      pfapf = params[:pf]
      beneficiarios = params[:ben_ids].map{|b| b.to_i}
      pf = Cor1440Gen::Proyectofinanciero.where(nombre: pfapf.split(" - ")[0])[0]
      apf = Cor1440Gen::Actividadpf.where(titulo: pfapf.split(" - ")[1])[0]
      dfs = Detallefinanciero.where(proyectofinanciero_id: pf.id).where(actividadpf_id: apf.id)
      respuesta = false
      nm = 0
      na = []
      dfs.each do |df|
        if df.persona.pluck(:id) == beneficiarios
          respuesta = true
          nm = df.numeromeses if df.numeromeses > nm
          na.push(df.numeroasistencia)
        end
      end
      opna = [*1..nm] - na
      opsna = opna.map{|op| {"id": op, "nombre": op}}
      respond_to do |format|
        format.json { render json: {respuesta: respuesta, numeromeses: nm, asistencias: opsna} }
      end
    end

    # Restringe más para conteo por beneficiario
    def filtra_contarb_actividad_por_parametros(contarb_actividad)
      @contarb_oficinaid = nil
      if params && params[:filtro] && params[:filtro][:oficina_id] && 
          params[:filtro][:oficina_id] != ''
        @contarb_oficinaid = params[:filtro][:oficina_id].to_i
        contarb_actividad.where('cor1440_gen_actividad.oficina_id=?',
                                @contarb_oficinaid)
      else
        contarb_actividad
      end
    end

    # Sobrecarga de modelos_controller para sanear parámetros
    # Pero usaremos para sanear datos cuando hay nuevas
    # filas en listado de asistencia
    def filtra_contenido_params
      if !params || !params[:actividad] 
        return
      end

      # Deben eliminarse asistentes creados con AJAX
      if params[:actividad][:asistencia_attributes]
        porelim = []
        params[:actividad][:asistencia_attributes].each do |l, v|
          if Cor1440Gen::Asistencia.where(id: v[:id].to_i).count == 0 ||
              !v[:persona_attributes] || 
              !v[:persona_attributes][:id] || v[:persona_attributes][:id] == '' ||
              Sip::Persona.where(id: v[:persona_attributes][:id].to_i).count == 0
            next
          end
          asi = Cor1440Gen::Asistencia.find(v[:id].to_i)
          #Solo esto al eliminar asistencia que existia produce:
          #Couldn't find Cor1440Gen::Asistencia with ID=84 for Cor1440Gen::Actividad with ID=287
          if v['_destroy'] == "1" || v['_destroy'] == "true"
            asi.actividad.asistencia_ids -= [asi.id]
            asi.actividad.save(validate: false)
            asi.destroy
            # Quitar de los parámetros
            porelim.push(l)  
            next
          end
          per = Sip::Persona.find(v[:persona_attributes][:id].to_i)
          if asi.persona_id != per.id && asi.persona.nombres == 'N' && 
              asi.persona.apellidos == 'N'
            # Era nueva asistencia cuya nueva persona se remplazó tras 
            # autocompletar. Dejar asignada la remplazada y borrar la vacia
            op = asi.persona
            asi.persona_id = per.id
            asi.save
            op.destroy
          end
        end
        porelim.each do |l|
          params[:actividad][:asistencia_attributes].delete(l)
        end
      end

      # Deben eliminarse detalles financieros creados con AJAX
      if params[:actividad][:detallefinanciero_attributes]
        porelimd = []
        params[:actividad][:detallefinanciero_attributes].each do |l, v|
          det = ::Detallefinanciero.find(v[:id].to_i)
          if v['_destroy'] == "1" || v['_destroy'] == "true"
            det.persona_ids = []
            det.actividad.detallefinanciero_ids -= [det.id]
            det.actividad.save(validate: false)
            det.destroy
            # Quitar de los parámetros
            porelimd.push(l)  
          end
        end
        porelimd.each do |l|
          params[:actividad][:detallefinanciero_attributes].delete(l)
        end
      end


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

    # Responde a requerimiento AJAX generado por cocoon creando una
    # nueva persona como nuevo asistente para la actividad que recibe 
    # por parámetro  params[:actividad_id].  
    # Pone valores simples en los campos requeridos
    # Como crea personas que podrían ser remplazadas por otras por 
    # autocompletación debería ejecutarse con periodicidad un proceso que
    # elimine todas las personas de nombres N, apellidos N, sexo N, que
    # no este en listado de asistencia ni en casos
    def nueva_asistencia
      authorize! :new, Sip::Persona
      if params[:actividad_id].nil?
        resp_error 'Falta parámetro actividad_id'
        return
      end
      puts "** cuenta: #{Cor1440Gen::Actividad.where(id: params[:actividad_id].to_i).count.to_s}"
      if Cor1440Gen::Actividad.where(id: params[:actividad_id].to_i).count == 0
        reps_error 'No se encontró actividad ' + 
          params[:actividad_id].to_i.to_s
        return
      end
      act = Cor1440Gen::Actividad.find(params[:actividad_id].to_i)
      @persona = Sip::Persona.create(
        nombres: 'N',
        apellidos: 'N',
        sexo: 'S',
        tdocumento_id: 11,
        numerodocumento: 'AAA'
      )
      if !@persona.save
        resp_error 'No pudo crear persona' 
        return
      end
      @persona.numerodocumento = @persona.id
      @persona.save
      @asistencia = Cor1440Gen::Asistencia.create(
        actividad_id: act.id,
        persona_id: @persona.id
      )
      if !@asistencia.save
        resp_error 'No pudo crear asistencia' 
        @persona.destroy
        return
      end
      res = {
        'asistencia': @asistencia.id.to_s,
        'persona': @persona.id.to_s
      }.to_json
      respond_to do |format|
        format.js { render text: res }
        format.json { render json: res,
                      status: :created }
        format.html { render inline: res }
      end
    end # def nueva_asistencia

    def update
      @pf_respaldo = {}
      # para no perder proyectos financieros sin actividad de marco lógico
      # en caso de errores de validación
      if actividad_params && actividad_params[:actividad_proyectofinanciero_attributes]
        actividad_params[:actividad_proyectofinanciero_attributes].each do |l,v|
          if v[:_destroy] == 'false' && v[:proyectofinanciero_id].to_i > 0
            @pf_respaldo[v[:proyectofinanciero_id].to_i] = v[:actividadpf_ids]
          end
        end
      end

      update_cor1440_gen

      if @registro.valid?
        # Tras arreglar proyecto financiero que no tenía actividad de marco
        # lógico y que no esté en base suele no almacenar la actividad 
        # así que la agregamos
        ar = @pf_respaldo.values.flatten.select {|x| x != ''}.
          map(&:to_i).uniq.sort
        ag = @registro.actividadpf_ids.uniq.sort
        if ar != ag 
          f = ar - ag
          f.each do |apfid|
            p = Cor1440Gen::ActividadActividadpf.new(
              actividad_id: @registro.id,
              actividadpf_id: apfid)
            p.save!(validate: false)
          end
        end
      end
    end


    def otros_impedimentos_para_borrar_persona_ex_asistente(a)
      # Si la persona está en un caso no se puede eliminar
      if Sivel2Gen::Victima.where(id_persona: a.persona_id).count > 0
        return true
      end
      return false
    end


    def lista_params
      lista_params_cor1440_gen  + 
        [:ubicacionpre_id, :covid] + [ 
          :detallefinanciero_attributes => [
          'cantidad',
          'convenioactividad',
          'frecuenciaentrega_id',
          'id',
          'mecanismodeentrega_id',
          'modalidadentrega_id',
          'numeromeses',
          'numeroasistencia'
        ] + [persona_ids: []] + [
          'tipotransferencia_id',
          'unidadayuda_id',
          'valorunitario',
          'valortotal',
          '_destroy'
        ]
      ]
    end

    def actividad_params
      params.require(:actividad).permit(lista_params)
    end

  end
end
