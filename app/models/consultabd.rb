# frozen_string_literal: true

# Consulta BD
class Consultabd < ActiveRecord::Base
  include Msip::Modelo

  def presenta(atr)
    puts "** ::Consultabd.rb atr=#{atr.to_s.parameterize}"

    if respond_to?("#{atr.to_s.parameterize}")
      return send("#{atr.to_s.parameterize}")
    end

    atr.to_s
  end # presenta

  CONSULTA = "consultabd"

  # econsultasql es consulta segura
  def self.crea_consulta(econsultasql)
    if ARGV.include?("db:migrate")
      return
    end

    if ActiveRecord::Base.connection.data_source_exists?(CONSULTA)
      ActiveRecord::Base.connection.execute(
        "DROP MATERIALIZED VIEW IF EXISTS #{CONSULTA}",
      )
    end
    w = ""
    # if ordenar_por
    #  w += ' ORDER BY ' + self.interpreta_ordenar_por(ordenar_por)
    # else
    #  w += ' ORDER BY ' + self.interpreta_ordenar_por('fechadesc')
    # end
    ActiveRecord::Base.connection.execute("CREATE
              MATERIALIZED VIEW #{CONSULTA} AS
              SELECT row_number() OVER () AS numfila,
              * FROM (
              #{econsultasql}
              #{w} ) AS s ;")
    Consultabd.reset_column_information
  end # def crea_consulta

  # `consultasql` debe ser consulta segura --tras análisis con reconocedor
  def self.refresca_consulta(consultasql, ip_remota, usuario_id, url, params)
    forzar_crear = false

    # Evitamos borrar la consulta si la última hecha es esa misma
    maxid = Msip::Bitacora.where(modelo: "Consultabd").maximum(:id)
    if maxid.nil?
      forzar_crear = true
    else
      maxcons = Msip::Bitacora.find(maxid)
      detalle_reg = JSON.parse(maxcons.detalle)
      if detalle_reg["consultasql"] != consultasql
        forzar_crear = true
      end
    end
    if forzar_crear ||
        !ActiveRecord::Base.connection.data_source_exists?("#{CONSULTA}")
      d = { consultasql: consultasql }
      Msip::Bitacora.a(
        ip_remota,
        usuario_id,
        url,
        params,
        "Consultabd",
        0,
        "listar",
        d.to_json,
      )
      crea_consulta(consultasql)
      ActiveRecord::Base.connection.execute(
        "CREATE UNIQUE INDEX on #{CONSULTA} (numfila);",
      )
    else
      ActiveRecord::Base.connection.execute(
        "REFRESH MATERIALIZED VIEW #{CONSULTA}",
      )
    end
  end
end
