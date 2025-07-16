# frozen_string_literal: true

# Consulta beneficiarios con actvidad y caso
class Consbenefactcaso < ActiveRecord::Base
  #    include Jos19::Concerns::Models::Consbenefactcaso
  include Msip::Modelo

  self.primary_key = "persona_id"

  belongs_to :caso,
    class_name: "Sivel2Gen::Caso",
    optional: false

  belongs_to :persona,
    class_name: "Msip::Persona",
    optional: false

  belongs_to :victima,
    class_name: "Sivel2Gen::Victima",
    optional: false

  scope :filtro_caso_id, lambda { |f|
    where(caso_id: f)
  }

  scope :filtro_persona_apellidos, lambda { |d|
    where("persona_apellidos ILIKE '%" +
          ActiveRecord::Base.connection.quote_string(d) + "%'")
  }

  scope :filtro_persona_id, lambda { |d|
    ds = d.split(/ |,/).map(&:to_i)
    where("persona_id IN (?)", ds)
  }

  scope :filtro_persona_nombres, lambda { |d|
    where("persona_nombres ILIKE '%" +
          ActiveRecord::Base.connection.quote_string(d) + "%'")
  }

  scope :filtro_persona_numerodocumento, lambda { |n|
    where("persona_numerodocumento ILIKE '%" +
          ActiveRecord::Base.connection.quote_string(n) + "%'")
  }

  scope :filtro_persona_tdocumento, lambda { |f|
    where(persona_tdocumento: f)
  }



  CONSULTA = "consbenefactcaso"

  # Refresca consulta
  # @params ordenar_por Criterio de ordenamiento
  # @params pf_ids Lista con identificaciones de proyectos financieros o []
  # @params actividadpf_ids Lista con identificaciones de actividads de pfs o []
  # @params oficina_ids Lista con identificación de las oficina o []
  # @params fechaini Fecha inicial en formato estándar o nil
  # @params fechafin Fecha final en formato estándar o nil
  # @params actividad_ids Lista de actividades a las cuales limitar
  # @params remote_ip
  # @params usuario_id
  # @params url
  # @params params
  #
  def self.refrescar_consulta(
    ordenar_por = nil, pf_ids, actividadpf_ids,
    oficina_ids, fechaini, fechafin, actividad_ids, 
    ip_remota, usuario_id, url, params
  )
    debugger
    if ARGV.include?("db:migrate")
      return
    end

    wherebe = "TRUE".dup
    if oficina_ids && oficina_ids.count > 0
      wherebe << " AND ac.oficina_id IN " \
        "(#{oficina_ids.map(&:to_i).join(",")})"
    end
    if pf_ids && pf_ids.count > 0
      wherebe << " AND apf.proyectofinanciero_id IN " \
        "(#{pf_ids.map(&:to_i).join(",")})"
    end
    if actividadpf_ids && actividadpf_ids.count > 0
      wherebe << " AND aapf.actividadpf_id IN " \
        "(#{actividadpf_ids.map(&:to_i).join(",")})"
    end
    if fechaini
      wherebe << " AND ac.fecha >= " \
        "'#{Msip::SqlHelper.escapar(fechaini)}'"
    end
    if fechafin
      wherebe << " AND ac.fecha <= " \
        "'#{Msip::SqlHelper.escapar(fechafin)}'"
    end
    if actividad_ids.count > 0
      wherebe << " AND ac.id IN (#{actividad_ids.join(",")})"
    end

    consultasql = <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS consbenefactcaso2 CASCADE;
      CREATE MATERIALIZED VIEW consbenefactcaso2 AS#{" "}
        SELECT c1.persona_id,
        ARRAY_AGG(DISTINCT c1.actividad_id) AS actividad_ids,
        ARRAY_AGG(DISTINCT c1.actividad_oficina_id) AS actividad_oficina_ids
        FROM (
          SELECT DISTINCT sub.persona_id,
            sub.actividad_id,
            sub.actividad_oficina_id
            FROM ( SELECT per.id AS persona_id,
              ac.id AS actividad_id,
              ac.fecha AS actividad_fecha,
              ac.oficina_id AS actividad_oficina_id,
              apf.proyectofinanciero_id AS actividad_proyectofinanciero_id,
              aapf.actividadpf_id AS actividad_actividadpf_id
              FROM msip_persona AS per
              LEFT JOIN cor1440_gen_asistencia asis ON per.id = asis.persona_id
              LEFT JOIN cor1440_gen_actividad ac ON ac.id = asis.actividad_id
              LEFT JOIN cor1440_gen_actividad_proyectofinanciero apf ON apf.actividad_id = ac.id
              LEFT JOIN cor1440_gen_actividad_actividadpf aapf ON aapf.actividad_id = ac.id
              LEFT JOIN cor1440_gen_actividadpf apf2 ON apf2.proyectofinanciero_id = apf.proyectofinanciero_id
              WHERE #{wherebe}
          ) AS sub
        ) AS c1
      GROUP BY 1;

      DROP MATERIALIZED VIEW IF EXISTS #{CONSULTA};
      CREATE MATERIALIZED VIEW #{CONSULTA} AS#{" "}
      SELECT c2.persona_id,
        persona.nombres AS persona_nombres,
        persona.apellidos AS persona_apellidos,
        tdocumento.sigla AS persona_tdocumento,
        persona.numerodocumento AS persona_numerodocumento,
        persona.sexo AS persona_sexo,
        (COALESCE(persona.anionac::text, '') || '-' ||
          COALESCE(persona.mesnac::text, '') || '-' ||
          COALESCE(persona.dianac::text, '')) AS persona_fechanac,
        msip_edad_de_fechanac_fecharef(persona.anionac,
          persona.mesnac, persona.dianac,
          extract(year from now())::integer,
          extract(month from now())::integer,
          extract(day from now())::integer
        ) as persona_edad_actual,
        pais.nombre AS persona_paisnac,
        COALESCE(perfilorgsocial.nombre) AS persona_ultimoperfilorgsocial,
        victima.id AS victima_id,
        caso.id AS caso_id,
        casosjr.fecharec AS caso_fecharec,
        CASE WHEN casosjr.contacto_id = persona.id
          THEN 'Si'
          ELSE 'No'
        END AS caso_titular,
        persona.telefono AS persona_telefono,
        c2.actividad_ids,
        c2.actividad_oficina_ids
        FROM consbenefactcaso2 AS c2
        JOIN msip_persona AS persona ON c2.persona_id=persona.id
        INNER JOIN msip_tdocumento AS tdocumento ON
          persona.tdocumento_id=tdocumento.id
        LEFT JOIN msip_pais AS pais ON
          persona.pais_id = pais.id
        LEFT JOIN msip_perfilorgsocial AS perfilorgsocial ON
          persona.ultimoperfilorgsocial_id = perfilorgsocial.id
        LEFT JOIN sivel2_gen_victima AS victima ON
          victima.persona_id = persona.id
        LEFT JOIN sivel2_sjr_victimasjr AS victimasjr ON
          victimasjr.victima_id = victima.id  AND
          victimasjr.fechadesagregacion IS NULL
        LEFT JOIN sivel2_gen_caso AS caso ON
          victima.caso_id = caso.id
        LEFT JOIN sivel2_sjr_casosjr AS casosjr ON
          casosjr.caso_id = caso.id
    SQL


    forzar_crear = false

    cuentapersonas = 0
    cuentapersonas_ant = -1
    # Evitamos borrar la consulta si la última hecha es esa misma
    maxid = Msip::Bitacora.where(modelo: "Consbenefactcaso").maximum(:id)
    if maxid.nil?
      forzar_crear = true
    else
      maxcons = Msip::Bitacora.find(maxid)
      detalle_reg = JSON.parse(maxcons.detalle)
      cuentapersonas_ant = detalle_reg["cuentapersonas"]
      if detalle_reg["consultasql"] != consultasql
        forzar_crear = true
      end
    end
    cuentapersonas = Msip::Persona.all.count
    if forzar_crear ||
        !ActiveRecord::Base.connection.data_source_exists?("#{CONSULTA}")
      d = { 
        consultasql: consultasql, 
        cuentapersonas: cuentapersonas
      }
      Msip::Bitacora.a(
        ip_remota,
        usuario_id,
        url,
        params,
        "Consbenefactcaso",
        0,
        "listar",
        d.to_json,
      )
      Consbenefactcaso.connection.execute(consultasql)
      ActiveRecord::Base.connection.execute(
        "CREATE UNIQUE INDEX on #{CONSULTA} (persona_id);",
      )
      Consbenefactcaso.reset_column_information
    else
      # Si la cuenta de personas almacenada cuando se creó la consulta
      # es igual a la actual no debe ser ni siquiera necesario ejecutar
      # REFRESH MATERIALIZED VIEW
      if cuentapersonas != cuentapersonas_ant
        debugger
        ActiveRecord::Base.connection.execute(
          "REFRESH MATERIALIZED VIEW #{CONSULTA}",
        )
      end
    end
  end
 
  def presenta(atr)
    if atr.to_s == "actividad_ids"
      # debugger
    end
    case atr
    when "actividad_oficina_nombres"
      r = actividad_oficina_ids
        .select { |i| !i.nil? }
        .map { |i| Msip::Oficina.find(i).presenta_nombre }
        .join(", ")
      r
    when "actividad_ids"
      actividad_ids.join(", ")
    else
      m = /^(.*)_enlace$/.match(atr.to_s)
      if m && !self[m[1]].nil? && !self[m[1] + "_ids"].nil?
        if self[m[1]].to_i == 0
          r = "0"
        else
          bids = self[m[1] + "_ids"].join(",")
          r = "<a href='#{Rails.application.routes.url_helpers.msip_path +
          "actividades?filtro[busid]=" + bids}' " \
          "target='_blank'>" \
          "#{self[m[1]]}" \
          "</a>".html_safe
        end
        r.html_safe
      else
        presenta_gen(atr)
      end
    end
  end

  def self.vista_reporte_excel(
    plant, registros, narch, parsimp, extension, params
  )
    p = Axlsx::Package.new
    lt = p.workbook
    e = lt.styles

    estilo_base = e.add_style(sz: 12)
    estilo_titulo = e.add_style(sz: 20)
    estilo_encabezado = e.add_style(sz: 12, b: true)
    # , fg_color: 'FF0000', bg_color: '00FF00'

    lt.add_worksheet do |hoja|
      hoja.add_row(
        ["Reporte de beneficiarios con casos y actividades"],
        height: 30,
        style: estilo_titulo,
      )
      hoja.add_row([])
      hoja.add_row(
        [
          "Fecha inicial de act.",
          params["filtro"]["busactividad_fechaini"],
          "Fecha final de act.",
          params["filtro"]["busactividad_fechafin"],
        ],
        style: estilo_base,
      )
      idof = if !params["filtro"] ||
          !params["filtro"]["busactividad_oficina_id"] ||
          params["filtro"]["busactividad_oficina_id"] == ""
        nil
      else
        params["filtro"]["busactividad_oficina_id"]
      end
      idpf = if !params["filtro"] ||
          !params["filtro"]["busproyectofinanciero"] ||
          params["filtro"]["busproyectofinanciero"] == ""
        nil
      else
        params["filtro"]["busproyectofinanciero"]
      end
      idaml = if !params["filtro"] ||
          !params["filtro"]["busactividadpf"] ||
          params["filtro"]["busactividadpf"] == ""
        nil
      else
        params["filtro"]["busactividadpf"]
      end
      nof = if idof.nil?
        ""
      else
        Msip::Oficina.where(id: idof)
          .pluck(:nombre).join("; ")
      end
      npf = if idpf.nil?
        ""
      else
        Cor1440Gen::Proyectofinanciero.where(id: idpf)
          .pluck(:nombre).join("; ")
      end
      naml = if idaml.nil?
        ""
      else
        Cor1440Gen::Actividadpf.where(id: idaml)
          .pluck(:titulo).join("; ")
      end

      hoja.add_row(
        [
          "Oficina",
          nof,
          "Convenio financiero",
          npf,
          "Actividad de marco lógico",
          naml,
        ],
        style: estilo_base,
      )
      hoja.add_row([])
      l = [
        "Oficina(s)",
        "Id. Persona",
        "Nombres",
        "Apellidos",
        "Tipo de documento",
        "Número de documento",
        "Sexo",
        "Fecha de nacimiento",
        "Edad actual",
        "País",
        "Último perfil",
        "Id. Caso",
        "Fecha de recepción",
        "Titular",
        "Teléfono",
        "Id. Actividades",
      ]
      numcol = l.length
      colfin = Heb412Gen::PlantillaHelper.numero_a_columna(numcol)

      hoja.merge_cells("A1:#{colfin}1")

      hoja.add_row(l, style: [estilo_encabezado] * numcol)

      registros.each do |reg|
        l = [
          reg.presenta("actividad_oficina_nombres"),
          reg.persona_id.to_s,
          reg.presenta("persona_nombres"),
          reg.presenta("persona_apellidos"),
          reg.presenta("persona_tdocumento"),
          reg.presenta("persona_numerodocumento"),
          reg.presenta("persona_sexo"),
          reg.presenta("persona_fechanac"),
          reg.presenta("persona_edad_actual"),
          reg.presenta("persona_paisnac"),
          reg.presenta("persona_ultimoperfilorgsocial"),
          reg.presenta("caso_id"),
          reg.presenta("caso_fecharec"),
          reg.presenta("caso_titular"),
          reg.presenta("persona_telefono"),
          reg.presenta("actividad_ids"),
        ]
        hoja.add_row(l, style: estilo_base)
      end
      anchos = [20] * numcol
      hoja.column_widths(*anchos)
      ultf = 0
      hoja.rows.last.tap do |row|
        ultf = row.row_index
      end
      if ultf > 0
        l = [nil] * numcol
        hoja.add_row(l)
      end
    end

    n = File.join("/tmp", File.basename(narch + ".xlsx"))
    p.serialize(n)
    FileUtils.rm(narch + "#{extension}-0")

    n
  end

  def self.interpreta_ordenar_por(campo)
    critord = ""
    case campo.to_s
    when /^fechadesc/
      critord = "conscaso.fecha desc"
    when /^fecha/
      critord = "conscaso.fecha asc"
    when /^ubicaciondesc/
      critord = "conscaso.ubicaciones desc"
    when /^ubicacion/
      critord = "conscaso.ubicaciones asc"
    when /^codigodesc/
      critord = "conscaso.caso_id desc"
    when /^codigo/
      critord = "conscaso.caso_id asc"
    else
      raise(ArgumentError, "Ordenamiento invalido: #{campo.inspect}")
    end
    critord += ", conscaso.caso_id"
    critord
  end
end
