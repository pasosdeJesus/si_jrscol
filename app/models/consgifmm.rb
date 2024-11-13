# Consulta GIFMM
class Consgifmm < ActiveRecord::Base
  include Msip::Modelo

  self.primary_key = "id"

  belongs_to :detallefinanciero, 
    class_name: 'Detallefinanciero', 
    foreign_key: 'id', optional: false

  belongs_to :proyectofinanciero, 
    class_name: 'Cor1440Gen::Proyectofinanciero', 
    foreign_key: 'proyectofinanciero_id', optional: false

  belongs_to :actividadpf, 
    class_name: 'Cor1440Gen::Actividadpf', 
    foreign_key: 'actividadpf_id', optional: false

  belongs_to :actividad,
    class_name: 'Cor1440Gen::Actividad', 
    foreign_key: 'actividad_id', optional: false


  # Retorna el del primer proyecto y de la primera actividad o nil 
  def busca_indicador_gifmm
    if actividadpf
      actividadpf.indicadorgifmm_id
    else
      nil
    end
  end


  def indicador_gifmm
    idig = self.busca_indicador_gifmm
    if idig != nil
      ::Indicadorgifmm.find(idig).nombre
    else
      ''
    end
  end


  def sector_gifmm
    idig = self.busca_indicador_gifmm
    if idig != nil
      ::Indicadorgifmm.find(idig).sectorgifmm.nombre
    else
      ''
    end
  end


  def beneficiarios_nuevos_mes_ids
    bids = beneficiarios_ids
    idp = beneficiarios_ids.split(',').select {|pid|

      c = Cor1440Gen::Asistencia.joins(:actividad).joins(:persona).
        joins(
          'JOIN cor1440_gen_actividad_actividadpf '\
          'ON cor1440_gen_actividad_actividadpf.actividad_id=cor1440_gen_asistencia.actividad_id'\
          ' AND cor1440_gen_actividad_actividadpf.actividadpf_id='+self.actividadpf_id.to_s
        ).where(
          'cor1440_gen_actividad.fecha < ? ', 
          self.fecha.at_beginning_of_month
        ).where('msip_persona.id = ?', pid.to_i).
        where(
          'cor1440_gen_actividad.fecha >= ? ',
          self.fecha.at_beginning_of_year
        ) # Definicion de nuevo aumentada

      # Definicion de nuevo si usaran detalle financiero
      #c = ::Detallefinanciero.joins(:actividad).joins(:persona).where(
      #  proyectofinanciero_id: self.proyectofinanciero_id).where(
      #    actividadpf_id: self.actividadpf_id).where(
      #      'cor1440_gen_actividad.fecha < ? ' +
      #      'OR (cor1440_gen_actividad.fecha = ? '+
      #      'AND detallefinanciero.id < ?)', self.fecha, self.fecha, 
      #      self.detallefinanciero_id).
      #      where('msip_persona.id = ?', pid.to_i)
      c.count == 0
    }
    idp.sort.uniq.join(",")
  end


  def presenta(atr)
    puts "** ::Consgiffm.rb atr=#{atr.to_s.parameterize}"

    if respond_to?("#{atr.to_s.parameterize}")
      return send("#{atr.to_s.parameterize}")
    end

    m =/^beneficiari(.*)cuenta_y_enlaces$/.match(atr.to_s)
    if m && respond_to?("beneficiari#{m[1].parameterize}ids")
      bids = send("beneficiari#{m[1].parameterize}ids").split(',')
      enlaces = bids.map {|i|
        r="<a href='#{Rails.application.routes.url_helpers.msip_path + 
        'personas/' + i.to_s}' target='_blank'>#{i.to_s}</a>"
        r.html_safe
      }.join(", ".html_safe).html_safe
      return "#{bids.count} : #{enlaces}".html_safe
    end

    self.actividad.presenta(atr)
  end # presenta

  scope :filtro_actividad_id, lambda { |ida|
    where(actividad_id: ida.to_i)
  }

  scope :filtro_fechaini, lambda { |f|
    where('fecha >= ?', f)
  }

  scope :filtro_fechafin, lambda { |f|
    where('fecha <= ?', f)
  }

  scope :filtro_conveniofinanciado_nombre, lambda { |c|
    if !c.nil? && c != [""]
      where('proyectofinanciero_id IN (?)', c.map(&:to_i))
    end
  }

  scope :filtro_actividadmarcologico_nombre, lambda { |a|
    if !a.nil? && a != [""]
      where('actividadpf_id IN (?)', a.map(&:to_i))
    end
  }

  scope :filtro_departamento_gifmm, lambda { |d|
    where(departamento_gifmm: d)
  }

  CONSULTA='consgifmm'

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
    "SELECT (cor1440_gen_actividad.id::text || '-' || cor1440_gen_actividadpf.id::text || '-' || COALESCE(detallefinanciero.id::text, '')) AS id,
	    detallefinanciero.id as detallefinanciero_id,
      cor1440_gen_actividad.id AS actividad_id,
      cor1440_gen_actividadpf.proyectofinanciero_id,
      cor1440_gen_actividadpf.id AS actividadpf_id,
      cor1440_gen_actividad.objetivo AS actividad_objetivo,
      cor1440_gen_actividad.fecha AS fecha,
      cor1440_gen_proyectofinanciero.nombre AS conveniofinanciado_nombre,
      cor1440_gen_actividadpf.titulo AS actividadmarcologico_nombre,
      depgifmm.nombre AS departamento_gifmm,
      mungifmm.nombre AS municipio_gifmm,
      (SELECT nombre FROM msip_oficina WHERE id=cor1440_gen_actividad.oficina_id LIMIT 1) AS oficina,
      cor1440_gen_actividad.nombre AS actividad_nombre,
      simp.socio_principal,
      (CASE WHEN simp.socio_principal='SJR Col' THEN 'Directa'
      ELSE 'Indirecta'
      END) AS tipo_implementacion,
      (CASE WHEN simp.socio_principal='SJR Col' THEN ''
      ELSE 'SJR Col'
      END) AS socio_implementador,
      'En proceso' AS estado,
      ARRAY_TO_STRING(
        CASE WHEN detallefinanciero.id IS NULL THEN
         ARRAY(SELECT DISTINCT persona_id FROM
         (SELECT persona_id FROM cor1440_gen_asistencia 
           WHERE cor1440_gen_asistencia.actividad_id=cor1440_gen_actividad.id
          ) AS subpersona_ids)
        ELSE
          ARRAY(SELECT persona_id FROM detallefinanciero_persona WHERE
          detallefinanciero_persona.detallefinanciero_id=detallefinanciero.id)
        END, ','
      ) AS beneficiarios_ids

      FROM cor1440_gen_actividad
      JOIN cor1440_gen_actividad_actividadpf ON
        cor1440_gen_actividad.id=cor1440_gen_actividad_actividadpf.actividad_id
      JOIN cor1440_gen_actividadpf ON
        cor1440_gen_actividadpf.id=cor1440_gen_actividad_actividadpf.actividadpf_id
      JOIN cor1440_gen_proyectofinanciero ON
        cor1440_gen_actividadpf.proyectofinanciero_id=cor1440_gen_proyectofinanciero.id
      JOIN (SELECT pf.id AS proyectofinanciero_id, 
        (SELECT COALESCE(f.nombregifmm, f.nombre) 
          FROM cor1440_gen_financiador_proyectofinanciero AS fpf  
          JOIN cor1440_gen_financiador AS f ON f.id=fpf.financiador_id 
          WHERE fpf.proyectofinanciero_id=pf.id LIMIT 1) AS socio_principal
        FROM cor1440_gen_proyectofinanciero as pf) AS simp ON
        simp.proyectofinanciero_id=cor1440_gen_proyectofinanciero.id

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

  def self.crea_consulta(ordenar_por = nil)
    if ARGV.include?("db:migrate")
      return
    end
    if ActiveRecord::Base.connection.data_source_exists? CONSULTA
      ActiveRecord::Base.connection.execute(
        "DROP MATERIALIZED VIEW IF EXISTS #{CONSULTA}")
    end
    w = ''
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

  def self.refresca_consulta(ordenar_por = nil)
    if !ActiveRecord::Base.connection.data_source_exists? "#{CONSULTA}"
      crea_consulta(ordenar_por = nil)
      ActiveRecord::Base.connection.execute(
        "CREATE UNIQUE INDEX on #{CONSULTA} (id);")
    else
      ActiveRecord::Base.connection.execute(
        "REFRESH MATERIALIZED VIEW #{CONSULTA}")
    end
  end

end

