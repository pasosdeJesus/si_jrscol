# frozen_string_literal: true

require_dependency "cor1440_gen/concerns/controllers/actividades_controller"

module Cor1440Gen
  class ActividadesController < Heb412Gen::ModelosController
    # no más include Sivel2Sjr::Concerns::Controllers::ActividadesController
    include Cor1440Gen::Concerns::Controllers::ActividadesController

    before_action :set_actividad,
      only: [:show, :edit, :update, :destroy],
      exclude: [:contar, :poblacion_sexo_rangoedadac, :contar_beneficiarios]
    load_and_authorize_resource class: Cor1440Gen::Actividad

    Cor1440Gen.actividadg1 = "Funcionarias del SJR"
    Cor1440Gen.actividadg3 = "Funcionarios del SJR"
    Cor1440Gen.actividadg6 = "Externos otro sexo"

    def self.posibles_nuevaresp
      {
        ahumanitaria: ["Asistencia humanitaria", 116],
        ojuridica: ["Orientación jurídica", 118],
        ajuridica: ["Accion Jurídica", 125],
        oservicios: ["Otros servicios y asesorias", 126],
        apsicosocial: ["Acompañamiento psicosocial", 70],
        capsemilla: ["Entrega de Capital Semilla", 45],
        formacion: ["Formación o Capacitación", 51],
        siniciativa: ["Seguimiento a Iniciativa", 156],
      }
    end

    # Retorna datos por enviar a nuevo de este controlador
    # desde javascript cuando se añade una respuesta a un caso
    def self.datos_nuevaresp(caso, controller)
      {
        nombre: "Seguimiento/Respuesta a caso #{caso.id}",
        oficina_id: caso.casosjr.oficina_id,
        caso_id: caso.id,
        proyecto_id: 101,
        usuario_id: controller.current_usuario.id,
      }
    end

    def self.pf_planest_id
      10
    end

    def self.actividadpf_segcas_id
      62
    end

    def self.filtramas(par, ac, current_usuario)
      @busactividadtipo = param_escapa(par, "busactividadtipo")
      if @busactividadtipo != ""
        ac = ac.joins(:actividad_actividadtipo).where(
          "cor1440_gen_actividad_actividadtipo.actividadtipo_id = ?",
          @busactividadtipo.to_i,
        )
      end
      ac
    end

    def atributos_show
      [
        :id,
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
        :anexos,
      ]
    end

    def atributos_index
      [
        :id,
        :fecha_localizada,
        :territorial,
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
        :poblacion_intersexuales,
        :anexos,
      ]
    end

    def atributos_form
      a = atributos_show - [:id, :poblacion] + [:observaciones]
      a.map do |e|
        e == :fecha_localizada ? :fecha : e
      end
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
        :objetivo,
      ]
    end

    def vistas_manejadas
      ["Actividad", "Benefactividadpf"]
    end

    def index_plantillas
      l = index_plantillas_heb412
      l
    end

    def new_ac_sivel2_sjr
      new_cor1440_gen
      @registro.fecha = Date.today
      if params["usuario_id"] &&
          ::Usuario.where(id: params["usuario_id"].to_i).count == 1
        @registro.usuario_id = params["usuario_id"].to_i
      end
      if params["oficina_id"] &&
          Msip::Oficina.where(id: params["oficina_id"].to_i).count == 1
        @registro.oficina_id = params["oficina_id"].to_i
      end
      if params["proyecto_id"] &&
          Cor1440Gen::Proyecto.where(id: params["proyecto_id"].to_i).count == 1
        @registro.proyecto_ids = [params["proyecto_id"].to_i]
      end
      if params["nsegresp_proyectofinanciero_id"] &&
          Cor1440Gen::Proyectofinanciero.where(
            id: params["nsegresp_proyectofinanciero_id"].to_i,
          ).count == 1
        @registro.proyectofinanciero_ids |= [params[
          "nsegresp_proyectofinanciero_id"].to_i]
      end
      if params["nombre"]
        @registro.nombre = params["nombre"]
      end
      @registro.actividadpf_ids = []
      @registro.save!(validate: false)

      parpers = params.keys.select { |p| p[0..7] == "persona-" }
      if parpers.count > 0
        parpers.each do |pp|
          pid = pp[8..].to_i
          next unless pid > 0 && params[pp] == "true" &&
            Msip::Persona.where(id: pid).count == 1

          op = Msip::Persona.find(pid)
          vs = Sivel2Gen::Victima.find_by(persona_id: op.id).victimasjr
          nr = Cor1440Gen::Asistencia.create(
            persona_id: pid,
            actividad_id: @registro.id,
            externo: false,
            orgsocial_id: nil,
            perfilorgsocial_id: op.ultimoperfilorgsocial_id,
            discapacidad: vs.discapacidad_id != 6,
            telefono: op.telefono,
          )
          nr.save(validate: false)
        end
      elsif params["caso_id"] &&
          Sivel2Sjr::Casosjr.where(caso_id: params["caso_id"].to_i)
              .count == 1
        personas = Sivel2Gen::Victima.where(caso_id: params["caso_id"].to_i)
          .joins(:victimasjr)
          .where("sivel2_sjr_victimasjr.fechadesagregacion IS NULL")
          .pluck(:persona_id)
        personas.each do |p|
          op = Msip::Persona.find(p)
          vs = Sivel2Gen::Victima.find_by(persona_id: p).victimasjr
          nr = Cor1440Gen::Asistencia.create(
            persona_id: p,
            actividad_id: @registro.id,
            externo: false,
            orgsocial_id: nil,
            perfilorgsocial_id: op.ultimoperfilorgsocial_id,
            discapacidad: vs.discapacidad_id != 6,
            telefono: op.telefono,
          )
          nr.save(validate: false)
        end
      end

      @registro.proyectofinanciero_ids +=
        [Cor1440Gen::ActividadesController.pf_planest_id]
      Cor1440Gen::ActividadesController.posibles_nuevaresp
        .each do |s, lnumacpf|
          next unless params[s] && params[s] == "true"

          @registro.actividadpf_ids |=
            [
              Cor1440Gen::ActividadesController.actividadpf_segcas_id,
              lnumacpf[1],
            ]
          tipo = Cor1440Gen::Actividadpf
            .find(lnumacpf[1]).actividadtipo_id
          next unless tipo

          presente_otros = Cor1440Gen::Actividadpf
            .where(actividadtipo_id: tipo)
            .where(proyectofinanciero_id: Cor1440Gen::ActividadesController.pf_planest_id) # Limitamos a proyecto de tipos de actividades comunes
          @registro.actividadpf_ids |= presente_otros.pluck(:id).uniq
        end
      @registro.save!(validate: false)
    end

    def new
      new_ac_sivel2_sjr

      redirect_to(cor1440_gen.edit_actividad_path(@registro))
    end

    def nuevo_asistente_antes_de_actualizar(asistente, atr_asistente)
      if asistente.persona.ultimoperfilorgsocial_id.nil? &&
          atr_asistente[:perfilorgsocial_id].to_i > 0
        asistente.persona.ultimoperfilorgsocial_id = atr_asistente[:perfilorgsocial_id].to_i
        asistente.persona.save(validate: false)
      end
      if asistente.persona.telefono.nil? &&
          atr_asistente[:telefono].to_s != ""
        asistente.persona.telefono = atr_asistente[:telefono].to_s
        asistente.persona.save(validate: false)
      end
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
        nil,
        contarb_pfid,
        contarb_oficinaid,
        contarb_fechaini,
        contarb_fechafin,
        contarb_actividad_ids,
      )
      registros = Cor1440Gen::Benefactividadpf.where(
        actividad_id: contarb_actividad_ids,
      )
      ids = registros.map(&:persona_id)

      parsimp = {}
      cparams = params
      cparams.permit!
      Heb412Gen::GeneralistadoJob.perform_later(
        pl.id,
        "Cor1440Gen::Benefactividadpf",
        "Cor1440Gen::BenefactividadpfController",
        ids,
        narch,
        parsimp,
        extension,
        "persona_id",
        cparams,
      )
    end

    def registrar_en_bitacora
      true
    end

    # def nueva_asistencia_completa_persona
    #  @persona.ultimoperfilorgsocial_id = 10;
    #  @persona.ultimoestatusmigratorio_id = 8;
    # end

    # def nueva_asistencia_completa_asistencia
    #  @asistencia.perfilorgsocial_id=10;
    # end

    # GET /actividades/1/edit
    def edit
      edit_cor1440_gen
      @listadoasistencia = true
      render(layout: "application")
    end

    def update
      update_cor1440_gen

      if @registro.valid?
        # Actualizar último perfil cuando corresponda y se pueda
        @registro.asistencia.each do |asi|
          mf = Cor1440Gen::Asistencia.joins(:actividad)
            .where(persona_id: asi.persona_id).maximum(:fecha)
          salvar = false
          next unless mf.nil? || asi.actividad.fecha >= mf

          if asi.persona.ultimoperfilorgsocial_id.to_i != asi.perfilorgsocial_id.to_i
            asi.persona.ultimoperfilorgsocial_id = asi.perfilorgsocial_id
            salvar = true
          end
          if asi.persona.telefono.to_s != asi.telefono.to_s
            asi.persona.telefono = asi.telefono.to_s
            salvar = true
          end
          if salvar && asi.persona.valid?
            asi.persona.save
          end
        end
      end
    end

    # Responde a DELETE
    def destroy
      Detallefinanciero.where(actividad_id: @registro.id)
        .where(proyectofinanciero_id: nil).delete_all
      [
        "Cor1440Gen::ActividadareasActividad",
        "Cor1440Gen::ActividadActividadpf",
        "Cor1440Gen::ActividadActividadtipo",
        "Sivel2Sjr::ActividadCasosjr",
        "Cor1440Gen::ActividadOrgsocial",
        "Cor1440Gen::ActividadProyecto",
        "Cor1440Gen::ActividadProyectofinanciero",
        "Cor1440Gen::ActividadRangoedadac",
        "Cor1440Gen::ActividadRespuestafor",
        "Cor1440Gen::ActividadAnexo",
        "Cor1440Gen::ActividadUsuario",
        "Cor1440Gen::Asistencia",
        "Detallefinanciero",
      ].each do |relac|
        r = relac.constantize.where(actividad_id: @registro.id)
        r.delete_all if r.count > 0
      end

      rpb = @registro.respuestafor_ids
      puts "** OJO por borrar respuestafor: #{rpb}"
      if rpb.count > 0
        Cor1440Gen::ActividadRespuestafor.connection.execute(<<-EOF)
          DELETE FROM cor1440_gen_actividad_respuestafor#{" "}
          WHERE actividad_id=#{@registro.id};
          DELETE FROM mr519_gen_valorcampo#{" "}
          WHERE respuestafor_id IN (#{rpb.join(",")});
          DELETE FROM mr519_gen_respuestafor#{" "}
          WHERE id IN (#{rpb.join(",")});
        EOF
      end

      destroy_gen
    end

    def filtra_contar_control_acceso
      @contar_pfid = 10 # Plan Estrategico 1
    end

    def revisaben_detalle
      pfapf = params[:pf]
      beneficiarios = params[:ben_ids].map { |b| b.to_i }
      pf = Cor1440Gen::Proyectofinanciero.where(nombre: pfapf.split(" - ")[0])[0]
      apf = Cor1440Gen::Actividadpf.where(titulo: pfapf.split(" - ")[1])[0]
      dfs = Detallefinanciero.where(proyectofinanciero_id: pf.id).where(actividadpf_id: apf.id)
      respuesta = false
      nm = 0
      na = []
      dfs.each do |df|
        next unless df.persona.pluck(:id) == beneficiarios

        respuesta = true
        nm = df.numeromeses if df.numeromeses > nm
        na.push(df.numeroasistencia)
      end
      opna = [*1..nm] - na
      opsna = opna.map { |op| { "id": op, "nombre": op } }
      respond_to do |format|
        format.json { render(json: { respuesta: respuesta, numeromeses: nm, asistencias: opsna }) }
      end
    end

    # Restringe más para conteo por beneficiario
    def filtra_contarb_actividad_por_parametros(contarb_actividad)
      @contarb_oficinaid = nil
      if params && params[:filtro] && params[:filtro][:oficina_id] &&
          params[:filtro][:oficina_id] != ""
        @contarb_oficinaid = params[:filtro][:oficina_id].to_i
        contarb_actividad.where(
          "cor1440_gen_actividad.oficina_id=?",
          @contarb_oficinaid,
        )
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

      # Si un asistente no tiene ultimoperfilsocial ponerle
      # el de la asistencia
      if params[:actividad][:asistencia_attributes]
        params[:actividad][:asistencia_attributes].each do |l, a|
          next unless a && a[:persona_attributes]

          if a[:persona_attributes][:id] == "" ||
              Msip::Persona.where(
                id: a[:persona_attributes][:id].to_i,
                ultimoperfilorgsocial_id: nil,
              ).count == 1

            params[:actividad][:asistencia_attributes][l.to_s][:persona_attributes][:ultimoperfilorgsocial_id] =
              a[:perfilorgsocial_id]
          end
          next unless a[:persona_attributes][:id] == "" ||
            Msip::Persona.where(
              id: a[:persona_attributes][:id].to_i,
              telefono: nil,
            ).count == 1

          params[:actividad][:asistencia_attributes][l.to_s][:persona_attributes][:telefono] =
            a[:telefono]
        end
      end

      # Deben eliminarse detalles financieros creados con AJAX
      if params[:actividad][:detallefinanciero_attributes]
        porelimd = []
        params[:actividad][:detallefinanciero_attributes].each do |l, v|
          next unless ::Detallefinanciero.where(id: v[:id].to_i).count == 1

          det = ::Detallefinanciero.find(v[:id].to_i)
          next unless v["_destroy"] == "1" || v["_destroy"] == "true"

          det.persona_ids = []
          det.actividad.detallefinanciero_ids -= [det.id]
          det.actividad.save(validate: false)
          det.destroy
          # Quitar de los parámetros
          porelimd.push(l)
        end
        porelimd.each do |l|
          params[:actividad][:detallefinanciero_attributes].delete(l)
        end
      end
    end

    # Responde con mensaje de error
    def resp_error(m)
      respond_to do |format|
        format.html do
          render(inline: m)
        end
        format.json do
          render(json: m, status: :unprocessable_entity)
        end
      end
    end

    # Hace validaciones y retornar listado de beneficiarios de un caso
    # que no estén en el listado de asistencia
    # Recibe params[:actividad_id] y params[:caso_id]
    def rapido_benef_caso_posibles_asistentes
      authorize!(:new, Msip::Persona)
      if params[:actividad_id].nil?
        resp_error("Falta parámetro actividad_id")
        return
      end
      if params[:caso_id].nil?
        resp_error("Falta parámetro caso_id")
        return
      end
      pids = if params[:persona_ids].nil?
        nil
      else
        params[:persona_ids].split(",").map(&:to_i)
      end

      puts "** cuenta: #{Cor1440Gen::Actividad.where(id: params[:actividad_id].to_i).count}"
      if Cor1440Gen::Actividad.where(id: params[:actividad_id].to_i).count == 0
        reps_error("No se encontró actividad " +
          params[:actividad_id].to_i.to_s)
        return
      end
      act = Cor1440Gen::Actividad.find(params[:actividad_id].to_i)
      if Sivel2Gen::Caso.where(id: params[:caso_id].to_i).count == 0
        resp_error("No se encontró caso #{params[:caso_id].to_i}")
        return
      end
      caso = Sivel2Gen::Caso.find(params[:caso_id].to_i)
      vics = caso.victimasjr.where(fechadesagregacion: nil)
      listaret = []
      vics.each do |v|
        next unless Cor1440Gen::Asistencia.where(
          actividad_id: act.id,
          persona_id: v.victima.persona_id,
        ).count == 0 && (pids.nil? || pids.include?(v.victima.persona_id))

        listaret << {
          id: v.victima.persona_id,
          nombre: v.victima.persona.presenta_nombre,
          ultimoperfilorgsocial_id: v.victima.persona.ultimoperfilorgsocial_id,
          discapacidad_en_casos: v.discapacidad_id != 6,
          telefono: v.victima.persona.telefono,
        }
      end
      [act, listaret]
    end # def rapido_benef_caso_posibles_asistentes

    # Retorna lista de beneficiarios proveniente de un caso
    # que no están en el listado de asistencia de una actividad
    def lista_benef_caso_asistencia
      rb = rapido_benef_caso_posibles_asistentes
      listap = rb[1]
      if listap.nil?
        return
      end

      respond_to do |format|
        format.js do # Usa este
          render(inline: listap.to_json)
        end
        format.json do
          render(json: listap.to_json, status: :created)
        end
        format.html do
          render(inline: listap.to_json)
        end
      end
    end

    # Añade todos los beneficiarios de un caso al listado de asistencia.
    #
    # Recibe params[:actividad_id] y params[:caso_id]
    def rapido_benef_caso
      rb = rapido_benef_caso_posibles_asistentes
      if rb.nil? || rb.count == 0
        return
      end

      act = rb[0]
      listap = rb[1]
      if listap.nil?
        return
      end

      res = []
      listap.each do |dp|
        asistencia = Cor1440Gen::Asistencia.create(
          actividad_id: act.id,
          persona_id: dp[:id],
          perfilorgsocial_id: dp[:ultimoperfilorgsocial_id],
          discapacidad: dp[:discapacidad_en_casos],
          telefono: dp[:telefono],
        )
        unless asistencia.save(validate: false)
          resp_error("No pudo crear asistencia")
          return
        end
        res << dp[:id]
      end

      respond_to do |format|
        format.js do # Usa este
          render(inline: res.to_json)
        end
        format.json do
          render(json: res.to_json, status: :created)
        end
        format.html do
          render(inline: res.to_json)
        end
      end
    end # def rapido_benef_caso

    def otros_impedimentos_para_borrar_persona_ex_asistente(a)
      # Si la persona está en un caso no se puede eliminar
      if Sivel2Gen::Victima.where(persona_id: a.persona_id).count > 0
        return true
      end

      false
    end

    def lista_params
      l = lista_params_cor1440_gen
      l[-1][:asistencia_attributes][-1][:persona_attributes] << :ultimoperfilorgsocial_id
      l[-1][:asistencia_attributes][-1][:persona_attributes] << :telefono
      l[-1][:asistencia_attributes].insert(0, :telefono)
      l[-1][:asistencia_attributes].insert(0, :discapacidad)
      l +
        [
          :covid,
          :rapidobenefcaso_id,
          :ubicacionpre_id,
        ] + [
          detallefinanciero_attributes: [
            "cantidad",
            "convenioactividad",
            "frecuenciaentrega_id",
            "id",
            "mecanismodeentrega_id",
            "modalidadentrega_id",
            "numeromeses",
            "numeroasistencia",
          ] + [persona_ids: []] + [
            "tipotransferencia_id",
            "unidadayuda_id",
            "valorunitario",
            "valortotal",
            "_destroy",
          ],
        ]
    end

    def actividad_params
      params.require(:actividad).permit(lista_params)
    end

    def self.vista_listado(plant, ids, modelo, narch, parsimp, extension,
      campoid = :id, params = nil, controlador = nil)
      registros = modelo.where(campoid => ids)
      if respond_to?(:index_reordenar)
        registros = index_reordenar(registros)
      end
      case plant.id
      when 52
        registros = Cor1440Gen::Actividad.vista_reporte_completo_excel(
          plant, registros, narch, parsimp, extension, params
        )
      when 53
        registros = Cor1440Gen::Actividad.vista_reporte_psu_excel(
          plant, registros, narch, parsimp, extension, params
        )
      when 54
        registros = Cor1440Gen::Actividad.vista_reporte_extracompleto_excel(
          plant, registros, narch, parsimp, extension, params
        )

      end
      registros
    end
  end
end
