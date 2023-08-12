#require 'jos19/concerns/models/consbenefactcaso'

class Consbenefactcaso < ActiveRecord::Base
  #    include Jos19::Concerns::Models::Consbenefactcaso
  include Msip::Modelo

  self.primary_key = "persona_id"

  belongs_to :caso,
    class_name: 'Sivel2Gen::Caso', foreign_key: 'caso_id',
    optional: false

  belongs_to :persona,
    class_name: 'Msip::Persona', foreign_key: 'persona_id',
    optional: false

  belongs_to :victima,
    class_name: 'Sivel2Gen::Victima', foreign_key: 'victima_id',
    optional: false



  scope :filtro_actividad_ids, lambda { |ids|
    nids =ids.split(/[ ,]/).select{|n| n != ''}
    if nids != []
      cond = "actividad_ids && ARRAY[#{nids.join(",")}]"
      where(cond)
    end
  }

  scope :filtro_actividad_fechaini, lambda { |f|
    where('actividad_max_fecha >= ?', f)
  }

  scope :filtro_actividad_fechafin, lambda { |f|
    where('actividad_min_fecha <= ?', f)
  }

  scope :filtro_actividad_oficina_id, lambda { |idof|
    nidof=idof.select{|n| n != ''}
    if nidof != []
      where(
        "actividad_oficina_nombres && "\
        " ARRAY(SELECT nombre FROM msip_oficina WHERE id IN (?))",
        nidof.map(&:to_i)
      )
    end
  }

  scope :filtro_actividadpf, lambda { |a|
    na =a.select{|n| n != ''}
    if na != []
      cond = "actividad_actividadpf_ids && ARRAY[#{na.join(",")}::bigint]"
      where(cond)
    end
  }

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

  scope :filtro_proyectofinanciero, lambda { |pf|
    cond = "actividad_proyectofinanciero_ids && ARRAY[#{pf.join(",")}]"
    puts "OJO cond=#{cond}"
    where(cond)
  }


  def presenta(atr)
    if atr.to_s == 'actividad_ids'
      #debugger
    end
    case atr
    when 'actividad_oficina_nombres'
      self.actividad_oficina_nombres.join(", ")
    when 'actividad_ids'
      self.actividad_ids.join(", ")
    else
      presenta_gen(atr)
    end
  end

  def self.consulta
    # Al renombrar persona_id por id se hacia lenta la generación
    "SELECT persona.id AS persona_id,
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
        casosjr.telefono AS caso_telefono,
        ARRAY(SELECT actividad_id FROM (
          SELECT DISTINCT actividad_id FROM cor1440_gen_asistencia
            WHERE persona_id=persona.id ORDER BY 1) AS subaf) AS actividad_ids,
        ARRAY(SELECT DISTINCT ofnombre FROM (
          SELECT DISTINCT actividad_id, ac.oficina_id, of.nombre AS ofnombre
            FROM cor1440_gen_asistencia AS asis
            JOIN cor1440_gen_actividad AS ac ON asis.actividad_id=ac.id
            JOIN msip_oficina AS of ON ac.oficina_id=of.id
            WHERE persona_id=persona.id ORDER BY 1) AS subaf)
          AS actividad_oficina_nombres,
        (SELECT MAX(acfecha) FROM (
          SELECT DISTINCT actividad_id, ac.fecha as acfecha
            FROM cor1440_gen_asistencia AS asis
            JOIN cor1440_gen_actividad AS ac ON asis.actividad_id=ac.id
            WHERE persona_id=persona.id ORDER BY 1) AS subaf)
          AS actividad_max_fecha,
        (SELECT MIN(acfecha) FROM (
          SELECT DISTINCT actividad_id, ac.fecha as acfecha
            FROM cor1440_gen_asistencia AS asis
            JOIN cor1440_gen_actividad AS ac ON asis.actividad_id=ac.id
            WHERE persona_id=persona.id ORDER BY 1) AS subaf)
          AS actividad_min_fecha,
        ARRAY(SELECT DISTINCT proyectofinanciero_id FROM (
          SELECT DISTINCT proyectofinanciero_id
            FROM cor1440_gen_asistencia AS asis
            JOIN cor1440_gen_actividad_proyectofinanciero AS apf
              ON apf.actividad_id=asis.actividad_id
            WHERE persona_id=persona.id ORDER BY 1) AS subaf)
          AS actividad_proyectofinanciero_ids,
        ARRAY(SELECT DISTINCT actividadpf_id FROM (
          SELECT DISTINCT actividadpf_id
            FROM cor1440_gen_asistencia AS asis
            JOIN cor1440_gen_actividad_actividadpf AS aaf
              ON aaf.actividad_id=asis.actividad_id
            WHERE persona_id=persona.id ORDER BY 1) AS subaf)
          AS actividad_actividadpf_ids

        FROM msip_persona AS persona
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
          ;
    "
  end

  def self.crea_consulta(ordenar_por = nil)
    if ARGV.include?("db:migrate")
      return
    end
    if ActiveRecord::Base.connection.data_source_exists?(
        'consbenefactcaso')
      ActiveRecord::Base.connection.execute(
        "DROP MATERIALIZED VIEW IF EXISTS consbenefactcaso")
    end
    if ordenar_por
      w += ' ORDER BY ' + self.interpreta_ordenar_por(ordenar_por)
    end
    c = "CREATE
              MATERIALIZED VIEW consbenefactcaso AS
              #{self.consulta}
              #{w} ;"
    ActiveRecord::Base.connection.execute(c)
  end #def crea_consulta


  def self.refresca_consulta(ordenar_por = nil)
    if !ActiveRecord::Base.connection.data_source_exists?(
        'consbenefactcaso')
      crea_consulta(ordenar_por = nil)
    else
      ActiveRecord::Base.connection.execute(
        "REFRESH MATERIALIZED VIEW consbenefactcaso")
    end
  end


  def self.vista_reporte_excel(
    plant, registros, narch, parsimp, extension, params)

    ruta = File.join(Rails.application.config.x.heb412_ruta, 
                     plant.ruta).to_s

    p = Axlsx::Package.new
    lt = p.workbook
    e = lt.styles

    estilo_base = e.add_style sz: 12
    estilo_titulo = e.add_style sz: 20
    estilo_encabezado = e.add_style sz: 12, b: true
    #, fg_color: 'FF0000', bg_color: '00FF00'

    lt.add_worksheet do |hoja|
      hoja.add_row ['Reporte de beneficiarios con casos y actividades'], 
        height: 30, style: estilo_titulo
      hoja.add_row []
      hoja.add_row [
        'Fecha inicial', params['filtro']['busactividad_fechaini'], 
        'Fecha final', params['filtro']['busactividad_fechafin'] ], style: estilo_base
      idof = (!params['filtro'] || 
              !params['filtro']['busactividad_oficina_id'] || 
              params['filtro']['busactividad_oficina_id'] == ''
             ) ? nil : params['filtro']['busactividad_oficina_id']
      idpf = (!params['filtro'] || 
              !params['filtro']['busproyectofinanciero'] || 
              params['filtro']['busproyectofinanciero'] == ''
             ) ? nil : params['filtro']['busproyectofinanciero']
      idaml = (!params['filtro'] || 
               !params['filtro']['busactividadpf'] || 
               params['filtro']['busactividadpf'] == ''
              ) ? nil : params['filtro']['busactividadpf']
      nof = idof.nil? ? '' :
        Msip::Oficina.where(id: idof).
        pluck(:nombre).join('; ')
      npf = idpf.nil? ? '' :
        Cor1440Gen::Proyectofinanciero.where(id: idpf).
        pluck(:nombre).join('; ')
      naml = idaml.nil? ? '' :
        Cor1440Gen::Actividadpf.where(id: idaml).
        pluck(:titulo).join('; ')

      hoja.add_row [
        'Oficina', nof,
        'Convenio financiero', npf, 
        'Actividad de marco lógico', naml], style: estilo_base
      hoja.add_row []
      l = [
        'Oficina(s)',
        'Id. Persona',
        'Nombres',
        'Apellidos',
        'Tipo de documento',
        'Número de documento',
        'Sexo',
        'Fecha de nacimiento',
        'Edad actual',
        'País',
        'Último perfil',
        'Id. Caso',
        'Fecha de recepción',
        'Titular',
        'Teléfono',
        'Id. Actividades'
      ]
      numcol = l.length
      colfin = Heb412Gen::PlantillaHelper.numero_a_columna(numcol)

      hoja.merge_cells("A1:#{colfin}1")

      hoja.add_row l, style: [estilo_encabezado] * numcol

      registros.each do |reg|
        l = [
          reg.presenta('actividad_oficina_nombres'),
          reg.persona_id.to_s,
          reg.presenta('persona_nombres'),
          reg.presenta('persona_apellidos'),
          reg.presenta('persona_tdocumento'),
          reg.presenta('persona_numerodocumento'),
          reg.presenta('persona_sexo'),
          reg.presenta('persona_fechanac'),
          reg.presenta('persona_edad_actual'),
          reg.presenta('persona_paisnac'),
          reg.presenta('persona_ultimoperfilorgsocial'),
          reg.presenta('caso_id'),
          reg.presenta('caso_fecharec'),
          reg.presenta('caso_titular'),
          reg.presenta('caso_telefono'),
          reg.presenta('actividad_ids')
        ]
        hoja.add_row l, style: estilo_base
      end
      anchos = [20] * numcol
      hoja.column_widths(*anchos)
      ultf = 0
      hoja.rows.last.tap do |row|
        ultf = row.row_index
      end
      if ultf>0
        l = [nil] * numcol
        hoja.add_row l
      end
    end

    n=File.join('/tmp', File.basename(narch + ".xlsx"))
    p.serialize n
    FileUtils.rm(narch + "#{extension}-0")

    return n
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
      raise(ArgumentError, "Ordenamiento invalido: #{ campo.inspect }")
    end
    critord += ", conscaso.caso_id"
    return critord
  end


end
