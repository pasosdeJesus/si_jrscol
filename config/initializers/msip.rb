# frozen_string_literal: true

require "jos19/version"
Msip.setup do |config|
  config.ruta_anexos = ENV.fetch(
    "MSIP_RUTA_ANEXOS",
    "#{Rails.root.join("archivos/anexos")}",
  )
  config.ruta_volcados = ENV.fetch(
    "MSIP_RUTA_VOLCADOS",
    "#{Rails.root.join("archivos/bd")}",
  )
  # En heroku los anexos son super-temporales
  unless ENV["HEROKU_POSTGRESQL_GREEN_URL"].nil?
    config.ruta_anexos = "#{Rails.root.join("tmp/")}"
  end
  config.titulo = "SI-JRSCOL #{Jos19::VERSION}"
end
