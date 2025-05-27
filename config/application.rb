# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

# Sistema de información del JRS-Colombia. Emplea la funcionalidad de los
# motores msip, mr519_gen, heb412_gen, sivel2_gen (interpretando caso como
# grupo familiar) y cor1440_gen.
# Agrega desplazamiento, migración y más a los casos de sivel2_gen.
module SiJrscol
  class Application < Rails::Application
    config.load_defaults(Rails::VERSION::STRING.to_f)

    config.autoload_lib(ignore: ["assets", "tasks"])

    # Las configuraciones de config/environments/* tienen precedencia
    # sobre las especifciadas aquí.
    #
    # La configuración de la aplicación debería ir en archivos en
    # config/initializers -- todos los archivos .rb de esa ruta
    # se cargan automáticamente

    # Establecer Time.zone a la zona por omisión y que Active Record se
    # convierta a esa zona.
    # ejecute "rake -D time" para ver tareas relacionadas con encontrar
    # nombres de zonas. Por omisión es UTC.
    config.time_zone = "America/Bogota"

    # El locale predeterminado es :en y se cargan todas las traducciones
    # de config/locales/*.rb,yml
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :es

    config.active_record.schema_format = :sql

    config.railties_order = [
      :main_app,
      Jos19::Engine,
      Cor1440Gen::Engine,
      Sivel2Gen::Engine,
      Heb412Gen::Engine,
      Mr519Gen::Engine,
      Msip::Engine,
      :all,
    ]

    puts "CONFIG_HOSTS=" + ENV.fetch("CONFIG_HOSTS", "defensor.info").to_s
    config.hosts.concat(
      ENV.fetch("CONFIG_HOSTS", "defensor.info").downcase.split(";"),
    )

    config.relative_url_root = ENV.fetch("RUTA_RELATIVA", "/")

    # msip
    config.x.formato_fecha = ENV.fetch("FORMATO_FECHA", "yyyy-mm-dd")

    config.x.msip_docid_obligatorio = true

    # heb412
    config.x.heb412_ruta = Pathname(
      ENV.fetch("HEB412_RUTA", Rails.public_path.join("heb412").to_s),
    )

    # sivel2
    config.x.sivel2_consulta_web_publica = ENV["SIVEL2_CONSWEB_PUBLICA"] &&
      ENV["SIVEL2_CONSWEB_PUBLICA"] != ""

    config.x.sivel2_consweb_max = ENV.fetch("SIVEL2_CONSWEB_MAX", 2000)

    config.x.sivel2_consweb_epilogo = ENV.fetch(
      "SIVEL2_CONSWEB_EPILOGO",
      "<br>Si requiere más puede suscribirse a SIVeL Pro",
    ).html_safe

    config.x.sivel2_mapaosm_diasatras = ENV.fetch(
      "SIVEL2_CONSWEB_EPILOGO", 182
    )

    # cor1440
    config.x.cor1440_permisos_por_oficina =
      (ENV["COR1440_PERMISOS_POR_OFICINA"] && ENV["COR1440_PERMISOS_POR_OFICINA"] != "")

    config.x.cor1440_edita_poblacion = false

    config.x.jos19_etiquetaunificadas = "BENEFICIARIOS UNIFICADOS"

    if ENV.fetch("WC_PERMISOS", "") != "" &&
        ENV.fetch("RAILS_ENV", "") == "development"
      config.web_console.permissions = ENV["WC_PERMISOS"]
    end

    config.action_mailer.raise_delivery_errors = true
  end
end
