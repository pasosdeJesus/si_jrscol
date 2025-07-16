# frozen_string_literal: true

# require 'jos19/concerns/controllers/consbenefactcaso_controller'

class ConsbenefactcasoController < Heb412Gen::ModelosController
  load_and_authorize_resource class: ::Consbenefactcaso

  # include Jos19::Concerns::Controllers::ConsbenefactcasoController

  def clase
    "::Consbenefactcaso"
  end

  def atributos_index
    [
      :actividad_oficina_nombres,
      :persona_id,
      :persona_nombres,
      :persona_apellidos,
      :persona_tdocumento,
      :persona_numerodocumento,
      :persona_sexo,
      :persona_fechanac,
      :persona_edad_actual,
      :persona_paisnac,
      :persona_ultimoperfilorgsocial,
      :caso_id,
      :caso_fecharec,
      :caso_titular,
      :persona_telefono,
      :actividad_ids,
    ]
  end

  def atributos_filtro_antestabla
    [
      "actividad_fechaini",
      "actividad_fechafin",
      "actividad_oficina_id",
      "actividadpf",
      "proyectofinanciero",
    ]
  end

  def index_reordenar(c)
    c.reorder([:persona_nombres, :persona_apellidos])
  end

  def vistas_manejadas
    ["Consbenefactcaso"]
  end

  def index
    t = Benchmark.measure do
      contar_registros
    end
    puts "** Tiempo contar_registros: #{t.real}"

    t = Benchmark.measure do
      index_msip(::Consbenefactcaso.all)
    end
    puts "** Tiempo index_msip: #{t.real}"
  end

  def contar_registros
    # Parámetros
    @contarb_pfid = if params[:filtro] &&
        params[:filtro][:busproyectofinanciero]
      params[:filtro][:busproyectofinanciero].select { |i| i != "" }.map(&:to_i)
    else
      []
    end

    @contarb_actividadpfid = if params[:filtro] &&
        params[:filtro][:busactividadpf]
      params[:filtro][:busactividadpf].select { |i| i != "" }.map(&:to_i)
    else
      []
    end

    @contarb_oficinaid = if params[:filtro] &&
        params[:filtro][:busactividad_oficina_id] &&
        params[:filtro][:busactividad_oficina_id] != ""
      params[:filtro][:busactividad_oficina_id].select do |i|
        i != ""
      end.map(&:to_i)
    else
      []
    end

    @contarb_fechaini = nil
    if !params[:filtro] || !params[:filtro][:busactividad_fechaini] ||
        params[:filtro][:busactividad_fechaini] != ""
      @contarb_fechaini = if !params[:filtro] || !params[:filtro][:busactividad_fechaini]
        Msip::FormatoFechaHelper.inicio_semestre_ant
      else
        Msip::FormatoFechaHelper.fecha_local_estandar(
          params[:filtro][:busactividad_fechaini],
        )
      end
    end

    @contarb_fechafin = nil
    if !params[:filtro] || !params[:filtro][:busactividad_fechafin] ||
        params[:filtro][:busactividad_fechafin] != ""
      @contarb_fechafin = if !params[:filtro] || !params[:filtro][:busactividad_fechafin]
        Msip::FormatoFechaHelper.fin_semestre_ant
      else
        Msip::FormatoFechaHelper.fecha_local_estandar(
          params[:filtro][:busactividad_fechafin],
        )
      end
    end

    @contarb_actividad_ids = []
    if params[:filtro] && params[:filtro][:busactividad_ids]
      @contarb_actividad_ids = params[:filtro][:busactividad_ids].split(",")
        .map(&:to_i)
    end

    Consbenefactcaso.refrescar_consulta(
      nil,
      @contarb_pfid,
      @contarb_actividadpfid,
      @contarb_oficinaid,
      @contarb_fechaini,
      @contarb_fechafin,
      @contarb_actividad_ids,
      request.remote_ip,
      current_usuario.id,
      request.url,
      params,
    )
  end

  def self.index_reordenar(registros)
    registros.reorder([:persona_id])
  end

  def self.vista_listado(plant, ids, modelo, narch, parsimp, extension,
    campoid = :persona_id,
    params = nil, controlador = nil)
    registros = modelo.where(persona_id: ids)
    if respond_to?(:index_reordenar)
      registros = index_reordenar(registros)
    end
    case plant.id
    when 55
      registros = Consbenefactcaso.vista_reporte_excel(
        plant, registros, narch, parsimp, extension, params
      )

    end
    registros
  end

  def self.valor_campo_compuesto(registro, campo)
    puts "registro=#{registro}"
    puts "campo=#{campo}"
  end
end
