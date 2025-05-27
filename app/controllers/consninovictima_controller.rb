# frozen_string_literal: true

class ConsninovictimaController < Heb412Gen::ModelosController
  load_and_authorize_resource class: ::Consninovictima

  def clase
    "::Consninovictima"
  end

  def atributos_index
    [
      :fecharec,
      :caso_id,
      :oficina,
      :fecha,
      :persona_id,
      :persona_nombres,
      :persona_apellidos,
      :persona_edad_hecho,
      :persona_sexo,
      :municipio_departamento,
      :categoria,
      :presponsable,
    ]
  end

  def atributos_filtro_antestabla
    [
      "fechaini",
      "fechafin",
      "oficina_id",
    ]
  end

  def index_reordenar(c)
    c.reorder([:persona_nombres, :persona_apellidos])
  end

  def vistas_manejadas
    ["Consninovictima"]
  end

  def index
    t = Benchmark.measure do
      contar_registros
    end
    puts "** Tiempo contar_registros: #{t.real}"

    t = Benchmark.measure do
      index_msip(::Consninovictima.all)
    end
    puts "** Tiempo index_msip: #{t.real}"
  end

  def contar_registros
    # Parámetros
    @contarb_oficinaid = if params[:filtro] &&
        params[:filtro][:busoficina_id] &&
        params[:filtro][:busoficina_id] != ""
      params[:filtro][:busoficina_id].select do |i|
        i != ""
      end.map(&:to_i)
    else
      []
    end

    @contarb_fechaini = nil
    if !params[:filtro] || !params[:filtro][:busfechaini] ||
        params[:filtro][:busfechaini] != ""
      @contarb_fechaini = if !params[:filtro] || !params[:filtro][:busfechaini]
        Msip::FormatoFechaHelper.inicio_semestre_ant
      else
        Msip::FormatoFechaHelper.fecha_local_estandar(
          params[:filtro][:busfechaini],
        )
      end
    end

    @contarb_fechafin = nil
    if !params[:filtro] || !params[:filtro][:busfechafin] ||
        params[:filtro][:busfechafin] != ""
      @contarb_fechafin = if !params[:filtro] || !params[:filtro][:busfechafin]
        Msip::FormatoFechaHelper.fin_semestre_ant
      else
        Msip::FormatoFechaHelper.fecha_local_estandar(
          params[:filtro][:busfechafin],
        )
      end
    end

    @contarb_caso_ids = []
    if params[:filtro] && params[:filtro][:buscaso_ids]
      @contarb_caso_ids = params[:filtro][:buscaso_ids].split(",")
        .map(&:to_i)
    end

    Consninovictima.crea_consulta(
      nil,
      @contarb_oficinaid,
      @contarb_fechaini,
      @contarb_fechafin,
      @contarb_caso_ids,
    )
  end

  def self.index_reordenar(registros)
    registros.reorder([:persona_nombres, :persona_apellidos])
  end

  def self.vista_listado(plant, ids, modelo, narch, parsimp, extension,
    campoid = :actonino_id,
    params = nil, controlador = nil)
    registros = modelo.where(actonino_id: ids)
    if respond_to?(:index_reordenar)
      registros = index_reordenar(registros)
    end
    case plant.id
    when 56
      registros = Consninovictima.vista_reporte_excel(
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
