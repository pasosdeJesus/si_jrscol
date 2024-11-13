# Consulta Niños Víctimas
class Consninovictima < ActiveRecord::Base
  include Msip::Modelo

  self.primary_key = "actonino_id"

  belongs_to :actonino,
    class_name: '::Actonino', 
    foreign_key: 'actonino_id',
    optional: false

  belongs_to :caso,
    class_name: 'Sivel2Gen::Caso', 
    foreign_key: 'caso_id',
    optional: false

  belongs_to :categoria,
    class_name: 'Sivel2Gen::Categoria', 
    foreign_key: 'categoria_id',
    optional: false

  belongs_to :municipio,
    class_name: 'Msip::Municipio', 
    foreign_key: 'municipio_id',
    optional: false

  belongs_to :oficina,
    class_name: 'Msip::Oficina', 
    foreign_key: 'oficina_id',
    optional: false

  belongs_to :persona,
    class_name: 'Msip::Persona', 
    foreign_key: 'persona_id',
    optional: false

  belongs_to :presponsable,
    class_name: 'Sivel2Gen::Presponsable', 
    foreign_key: 'presponsable_id',
    optional: false

  belongs_to :victima,
    class_name: 'Sivel2Gen::Victima', 
    foreign_key: 'victima_id',
    optional: false

  belongs_to :victimasjr,
    class_name: 'Sivel2Sjr::Victimasjr', 
    foreign_key: 'victimasjr_id',
    optional: false

#  scope :filtro_caso_id, lambda { |f|
#    where(caso_id: f)
#  }
#
#  scope :filtro_persona_apellidos, lambda { |d|
#    where("persona_apellidos ILIKE '%" +
#          ActiveRecord::Base.connection.quote_string(d) + "%'")
#  }
#
#  scope :filtro_persona_id, lambda { |d|
#    ds = d.split(/ |,/).map(&:to_i)
#    where("persona_id IN (?)", ds)
#  }
#
#  scope :filtro_persona_nombres, lambda { |d|
#    where("persona_nombres ILIKE '%" +
#          ActiveRecord::Base.connection.quote_string(d) + "%'")
#  }
#
#  scope :filtro_persona_numerodocumento, lambda { |n|
#    where("persona_numerodocumento ILIKE '%" +
#          ActiveRecord::Base.connection.quote_string(n) + "%'")
#
#  }
#
#  scope :filtro_persona_tdocumento, lambda { |f|
#    where(persona_tdocumento: f)
#  }

  # Genera consulta
  # @params ordenar_por Criterio de ordenamiento
  # @params oficina_ids Lista con identificación de las oficina o []
  # @params fechaini Fecha inicial en formato estándar o nil
  # @params fechafin Fecha final en formato estándar o nil
  # @params caso_ids Lista de casos a los cuales limitar
  #
  def self.crea_consulta(ordenar_por = nil, oficina_ids, 
                         fechaini, fechafin, caso_ids)
    if ARGV.include?("db:migrate")
      return
    end

    wherebe = "TRUE" 
    if oficina_ids && oficina_ids.count > 0
      wherebe << " AND oficina_id IN "\
        "(#{oficina_ids.map(&:to_i).join(',')})"
    end
    if fechaini
      wherebe << " AND fecha >= "\
        "'#{Msip::SqlHelper.escapar(fechaini)}'"
    end
    if fechafin
      wherebe << " AND fecha <= "\
        "'#{Msip::SqlHelper.escapar(fechafin)}'"
    end
    if caso_ids.count > 0
      wherebe << " AND caso_id IN (#{caso_ids.join(',')})"
    end

    consulta = <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS consninovictima;
      CREATE MATERIALIZED VIEW consninovictima AS 
      SELECT actonino.id AS actonino_id,
        actonino.caso_id AS caso_id,
        casosjr.oficina_id AS oficina_id,
        casosjr.fecharec AS fecharec,
        persona.id AS persona_id,
        persona.nombres AS persona_nombres,
        persona.apellidos AS persona_apellidos,
        (COALESCE(persona.anionac::text, '') || '-' ||
          COALESCE(persona.mesnac::text, '') || '-' ||
          COALESCE(persona.dianac::text, '')) AS persona_fechanac,
        msip_edad_de_fechanac_fecharef(persona.anionac,
          persona.mesnac, persona.dianac,
          extract(year from actonino.fecha)::integer,
          extract(month from actonino.fecha)::integer,
          extract(day from actonino.fecha)::integer
        ) as persona_edad_hecho,
        persona.sexo AS persona_sexo,
        actonino.fecha,
        ubicacionpre.municipio_id,
        municipio.nombre || ' / ' || departamento.nombre AS municipio_departamento,
        actonino.categoria_id,
        actonino.presponsable_id
        FROM actonino
        JOIN msip_persona AS persona ON actonino.persona_id=persona.id
        JOIN sivel2_gen_caso AS caso ON actonino.caso_id=caso.id
        JOIN sivel2_sjr_casosjr AS casosjr ON casosjr.caso_id=caso.id
        JOIN sivel2_gen_categoria AS categoria 
          ON actonino.categoria_id=categoria.id
        JOIN sivel2_gen_presponsable AS presponsable 
          ON actonino.presponsable_id=presponsable.id
        JOIN msip_ubicacionpre AS ubicacionpre
          ON actonino.ubicacionpre_id=ubicacionpre.id
        JOIN msip_municipio AS municipio
          ON ubicacionpre.municipio_id=municipio.id
        JOIN msip_departamento AS departamento
          ON municipio.departamento_id=departamento.id
        ORDER BY persona_nombres, persona_apellidos
    SQL

    Consbenefactcaso.connection.execute consulta

    Consbenefactcaso.reset_column_information
  end # def crea_consulta

  def presenta(atr)
    case atr.to_s
    when 'personas_ids'
      self.persona.id
    else
      presenta_gen(atr)
    end
  end

  def municpio_departamento
    municipio.presenta_nombre_con_departamento
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
      hoja.add_row ['VIOLENCIAS EN CONTRA DE NNA EN EL MARCO DEL CONFLICTO ARMADO'], 
        height: 30, style: estilo_titulo
      hoja.add_row []
#      hoja.add_row [
#        'Fecha inicial de act.',
#        params['filtro']['busactividad_fechaini'],
#        'Fecha final de act.',
#        params['filtro']['busactividad_fechafin'] ], style: estilo_base
#      idof = (!params['filtro'] || 
#              !params['filtro']['busactividad_oficina_id'] || 
#              params['filtro']['busactividad_oficina_id'] == ''
#             ) ? nil : params['filtro']['busactividad_oficina_id']
#      idpf = (!params['filtro'] ||
#              !params['filtro']['busproyectofinanciero'] || 
#              params['filtro']['busproyectofinanciero'] == ''
#             ) ? nil : params['filtro']['busproyectofinanciero']
#      idaml = (!params['filtro'] || 
#               !params['filtro']['busactividadpf'] || 
#               params['filtro']['busactividadpf'] == ''
#              ) ? nil : params['filtro']['busactividadpf']
#      nof = idof.nil? ? '' :
#        Msip::Oficina.where(id: idof).
#        pluck(:nombre).join('; ')
#      npf = idpf.nil? ? '' :
#        Cor1440Gen::Proyectofinanciero.where(id: idpf).
#        pluck(:nombre).join('; ')
#      naml = idaml.nil? ? '' :
#        Cor1440Gen::Actividadpf.where(id: idaml).
#        pluck(:titulo).join('; ')

      #hoja.add_row [
      #  'Oficina', nof,
      #  'Convenio financiero', npf, 
      #  'Actividad de marco lógico', naml], style: estilo_base
        hoja.add_row []
        l = [
          "Fecha de ocurrencia",
          "Municipio de ocurrencia",
          "Edad al momento de ocurrencia",
          "Sexo",
          "Categoria",
          "Presunto Responsable",
          "Id NNA",
          "Id Caso"
        ]
        numcol = l.length
        colfin = Heb412Gen::PlantillaHelper.numero_a_columna(numcol)

        hoja.merge_cells("A1:#{colfin}1")

        hoja.add_row l, style: [estilo_encabezado] * numcol

        registros.each do |reg|
          l = [
            reg.presenta('fecha'),
            reg.presenta('municipio_departamento'),
            reg.presenta('persona_edad_hecho'),
            reg.presenta('persona_sexo'),
            reg.presenta('categoria'),
            reg.presenta('presponsable'),
            reg.persona_id,
            reg.presenta('caso_id')
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
