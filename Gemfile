source "https://rubygems.org"

gem "apexcharts",
  git: "https://github.com/styd/apexcharts.rb.git", branch: :master

gem "bcrypt"

gem "bootsnap", ">=1.1.0", require: false

gem "cancancan"

gem "caxlsx"

gem "cocoon",
  git: "https://github.com/vtamara/cocoon.git", branch: "new_id_with_ajax" # Formularios anidados (algunos con ajax)

gem "colorize" # Colores en terminal

gem "csv"

gem "cssbundling-rails"

gem "devise" # Autenticación y roles

gem "devise-i18n"

gem "jbuilder" # API JSON facil. Ver: https://github.com/rails/jbuilder

gem "jsbundling-rails"

gem "kt-paperclip",                 # Anexos
  git: "https://github.com/kreeti/kt-paperclip.git"

gem "libxml-ruby"

gem "nokogiri", ">=1.11.1"

gem "odf-report" # Genera ODT

gem "parslet"

gem "pg"#, "~> 0.21" # Postgresql

gem "pg_query" 
# Mientras sale version posterior a 6.0.0 clonar rama sintema de
# de "https://github.com/pganalyze/pg_query.git"
# construir (com gem build) e instalar manualmente en 
# /var/www/bundler/ruby/3.4 (cono gem install --install-dir ...

gem "prawn" # Generación de PDF

gem "prawnto_2", ">= 0.3.1", :require => "prawnto"

gem "prawn-table"

gem "prism"

gem "propshaft"

gem "rack", "~> 2"

gem "rails", "~> 8.0"

gem "rails-i18n"

gem "redcarpet"

gem "rspreadsheet" # Plantilla ODS

gem "rubyzip", ">=2.0.0"

gem "simple_form"

gem "stimulus-rails"

gem "turbo-rails"

gem "twitter_cldr" # ICU con CLDR

gem "tzinfo" # Zonas horarias

gem "will_paginate" # Listados en páginas


#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento
# lógico y no alfabetico como las gemas anteriores)

gem "msip", # Motor generico
  git: "https://gitlab.com/pasosdeJesus/msip.git", branch: "sintema"
  #ref: "76a5fc04d1c6d26e52d4f15e1e0c68b499f96db2" 
  #path: "../msip-2.2"

gem "mr519_gen", # Motor de gestion de formularios y encuestas
  git: "https://gitlab.com/pasosdeJesus/mr519_gen.git", branch: "sintema"
  #path: "../mr519_gen-2.2"

gem "heb412_gen",  # Motor de nube y llenado de plantillas
  git: "https://gitlab.com/pasosdeJesus/heb412_gen.git", branch: "sintema"
  #path: "../heb412_gen-2.2"

# Motor Cor1440_gen
gem "cor1440_gen",
  git: "https://gitlab.com/pasosdeJesus/cor1440_gen.git", branch: "sintema"
  #path: "~/comp/rails/cor1440_gen-2.2"

# Motor de SIVeL 2
gem "sivel2_gen",
  git: "https://gitlab.com/pasosdeJesus/sivel2_gen.git", branch: "sintema"
  #path: "../sivel2_gen-2.2"

gem "jos19",
  git: "https://gitlab.com/pasosdeJesus/jos19.git", branch: "sintema"
  #path: "../jos19-2.2"

  gem "debug" # Depurar
group :development, :test do

  gem "dotenv-rails"
end


group :development do

  gem "puma" , ">= 4.3.3" # Servidor web

  gem "rails-erd"

  gem "web-console" # Consola irb en páginas

end


group :test do
  gem "capybara"

  gem "cuprite"

  gem "rails-controller-testing"

  gem "simplecov"

end


group :production do

  gem "unicorn" # Para despliegue

end
