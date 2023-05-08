class ConsgifmmExp < ActiveRecord::Base
  include Msip::Modelo

  belongs_to :consgifmm, 
    optional: false

  belongs_to :proyectofinanciero, 
    class_name: 'Cor1440Gen::Proyectofinanciero', 
    foreign_key: 'proyectofinanciero_id', optional: false

  belongs_to :actividadpf, 
    class_name: 'Cor1440Gen::Actividadpf', 
    foreign_key: 'actividadpf_id', optional: false

  belongs_to :actividad,
    class_name: 'Cor1440Gen::Actividad', 
    foreign_key: 'actividad_id', optional: false


  def presenta(atr)
    self.consgifmm.presenta(atr)
  end # presenta

  CONSULTA='consgifmm_exp'

  def self.interpreta_ordenar_por(campo)
    critord = ""
    case campo.to_s
    when /^fechadesc/
      critord = "fecha desc"
    when /^fecha/
      critord = "fecha asc"
    else
      raise(ArgumentError, "Ordenamiento invalido: #{ campo.inspect }")
    end
    critord += ", actividad_id"
    return critord
  end

  def self.consulta
    "SELECT consgifmm.id AS consgifmm_id,
	    detallefinanciero.id as detallefinanciero_id,
      cor1440_gen_actividad.id AS actividad_id,
      cor1440_gen_actividadpf.proyectofinanciero_id,
      cor1440_gen_actividadpf.id AS actividadpf_id,
      detallefinanciero.unidadayuda_id,
      detallefinanciero.cantidad,
      detallefinanciero.valorunitario,
      detallefinanciero.valortotal,
      detallefinanciero.mecanismodeentrega_id,
      detallefinanciero.modalidadentrega_id,
      detallefinanciero.tipotransferencia_id,
      detallefinanciero.frecuenciaentrega_id,
      detallefinanciero.numeromeses,
      detallefinanciero.numeroasistencia,
      CASE WHEN detallefinanciero.id IS NULL THEN
        ARRAY(SELECT DISTINCT persona_id FROM
        (SELECT persona_id FROM cor1440_gen_asistencia 
          WHERE cor1440_gen_asistencia.actividad_id=cor1440_gen_actividad.id
        ) AS subpersona_ids)
      ELSE
        ARRAY(SELECT persona_id FROM detallefinanciero_persona WHERE
        detallefinanciero_persona.detallefinanciero_id=detallefinanciero.id)
      END AS persona_ids,
      cor1440_gen_actividad.objetivo AS actividad_objetivo,
      cor1440_gen_actividad.fecha AS fecha,
      cor1440_gen_proyectofinanciero.nombre AS conveniofinanciado_nombre,
      cor1440_gen_actividadpf.titulo AS actividadmarcologico_nombre,
      depgifmm.nombre AS departamento_gifmm,
      mungifmm.nombre AS municipio_gifmm,
      (SELECT nombre FROM msip_oficina WHERE id=cor1440_gen_actividad.oficina_id LIMIT 1) AS oficina,
      cor1440_gen_actividad.nombre AS actividad_nombre
      FROM consgifmm
      JOIN cor1440_gen_actividad ON
        cor1440_gen_actividad.id=consgifmm.actividad_id
      JOIN cor1440_gen_actividad_actividadpf ON
        cor1440_gen_actividad.id=cor1440_gen_actividad_actividadpf.actividad_id
      JOIN cor1440_gen_actividadpf ON
        cor1440_gen_actividadpf.id=cor1440_gen_actividad_actividadpf.actividadpf_id
      JOIN cor1440_gen_proyectofinanciero ON
        cor1440_gen_actividadpf.proyectofinanciero_id=cor1440_gen_proyectofinanciero.id
      LEFT JOIN detallefinanciero ON
        detallefinanciero.actividad_id=cor1440_gen_actividad.id
      LEFT JOIN msip_ubicacionpre ON
        cor1440_gen_actividad.ubicacionpre_id=msip_ubicacionpre.id
      LEFT JOIN msip_departamento ON
        msip_ubicacionpre.departamento_id=msip_departamento.id
      LEFT JOIN depgifmm ON
        msip_departamento.deplocal_cod=depgifmm.id
      LEFT JOIN msip_municipio ON
        msip_ubicacionpre.municipio_id=msip_municipio.id
      LEFT JOIN mungifmm ON
        (msip_departamento.deplocal_cod*1000+msip_municipio.munlocal_cod)=
          mungifmm.id
      WHERE cor1440_gen_actividadpf.indicadorgifmm_id IS NOT NULL
      AND (detallefinanciero.proyectofinanciero_id IS NULL OR
        detallefinanciero.proyectofinanciero_id=cor1440_gen_actividadpf.proyectofinanciero_id)
      AND (detallefinanciero.actividadpf_id IS NULL OR
        detallefinanciero.actividadpf_id=cor1440_gen_actividadpf.id)
    "
  end


  def self.crea_consulta(ordenar_por = nil, ids)
    if ARGV.include?("db:migrate")
      return
    end
    if ActiveRecord::Base.connection.data_source_exists? CONSULTA
      ActiveRecord::Base.connection.execute(
        "DROP MATERIALIZED VIEW IF EXISTS #{CONSULTA}")
    end
    debugger
    w = 'AND consgifmm.id IN (' + 
      (ids.map {|sid| "'#{sid}'"}).join(',') + ') '
    if ordenar_por
      w += ' ORDER BY ' + self.interpreta_ordenar_por(ordenar_por)
    else
      w += ' ORDER BY ' + self.interpreta_ordenar_por('fechadesc')
    end
    ActiveRecord::Base.connection.execute("CREATE 
              MATERIALIZED VIEW #{CONSULTA} AS
              #{self.consulta}
              #{w} ;")
  end # def crea_consulta


  def self.refresca_consulta(ordenar_por = nil, ids)
    #if !ActiveRecord::Base.connection.data_source_exists? "#{CONSULTA}"
      crea_consulta(ordenar_por = nil, ids)
    #else
    #  ActiveRecord::Base.connection.execute(
    #    "REFRESH MATERIALIZED VIEW #{CONSULTA}")
    #end
  end

end

