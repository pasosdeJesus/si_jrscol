source 'https://rubygems.org'

gem 'apexcharts',
  git: 'https://github.com/styd/apexcharts.rb.git', branch: :master

gem 'babel-transpiler'

gem 'bcrypt'

gem 'bootsnap', '>=1.1.0', require: false

gem 'cancancan'

gem 'caxlsx'

gem 'cocoon',
  git: 'https://github.com/vtamara/cocoon.git', branch: 'new_id_with_ajax' # Formularios anidados (algunos con ajax)

gem 'coffee-rails' # CoffeeScript para recuersos .js.coffee y vistas

gem 'colorize' # Colores en terminal

gem 'devise' # Autenticación y roles

gem 'devise-i18n'

gem 'jbuilder' # API JSON facil. Ver: https://github.com/rails/jbuilder

gem 'jsbundling-rails'

gem 'kt-paperclip',                 # Anexos
  git: 'https://github.com/kreeti/kt-paperclip.git'

gem 'libxml-ruby'

gem 'nokogiri', '>=1.11.1'

gem 'odf-report' # Genera ODT

gem 'parslet'

gem 'pg'#, '~> 0.21' # Postgresql

gem 'prawn' # Generación de PDF

gem 'prawnto_2', '>= 0.3.1', :require => 'prawnto'

gem 'prawn-table'

gem 'rails', '~> 7.0'

gem 'rails-i18n'

gem 'redcarpet'

gem 'rspreadsheet' # Plantilla ODS

gem 'rubyzip', '>=2.0.0'

gem 'sassc-rails'

gem 'simple_form'

gem 'sprockets-rails'

gem 'stimulus-rails'

gem 'turbo-rails', '~> 1.0'

gem 'twitter_cldr' # ICU con CLDR

gem 'tzinfo' # Zonas horarias


gem 'will_paginate' # Listados en páginas


#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento
# lógico y no alfabetico como las gemas anteriores)

gem 'msip', # Motor generico
  git: 'https://gitlab.com/pasosdeJesus/msip.git', branch: 'main'
  #ref: "76a5fc04d1c6d26e52d4f15e1e0c68b499f96db2" 
  #path: '../msip'

gem 'mr519_gen', # Motor de gestion de formularios y encuestas
  git: 'https://gitlab.com/pasosdeJesus/mr519_gen.git', branch: 'main'
  #path: '../mr519_gen'

gem 'heb412_gen',  # Motor de nube y llenado de plantillas
  git: 'https://gitlab.com/pasosdeJesus/heb412_gen.git', branch: 'main'
  #path: '../heb412_gen'

# Motor Cor1440_gen
gem 'cor1440_gen',
  git: 'https://gitlab.com/pasosdeJesus/cor1440_gen.git', branch: 'main'
  #path: '../cor1440_gen'

# Motor de SIVeL 2
gem 'sivel2_gen',
  git: 'https://gitlab.com/pasosdeJesus/sivel2_gen.git', branch: 'main'
  #path: '../sivel2_gen'

# Motor de SIVeL 2 - SJR
gem 'sivel2_sjr',
  git: 'https://gitlab.com/pasosdeJesus/sivel2_sjr.git', branch: 'main'
  #path: '../sivel2_sjr'

gem 'jos19',
  git: 'https://gitlab.com/pasosdeJesus/jos19.git', branch: 'main'
  #path: '../jos19'

  gem 'debug' # Depurar
group :development, :test do

  gem 'dotenv-rails'
end


group :development do

  gem 'puma' , '>= 4.3.3' # Servidor web

  gem 'rails-erd'

  gem 'web-console' # Consola irb en páginas

end


group :test do
  gem 'capybara'

  gem 'cuprite'

  gem 'rails-controller-testing'

  gem 'selenium-webdriver' # Pruebas de regresión que no requieren javascript

  gem 'simplecov'

end


group :production do

  gem 'unicorn' # Para despliegue

end
