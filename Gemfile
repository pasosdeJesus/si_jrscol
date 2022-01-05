source 'https://rubygems.org'

gem 'bcrypt'

gem 'bootsnap', '>=1.1.0', require: false

gem 'bootstrap-datepicker-rails'

gem 'cancancan'

gem 'caxlsx'

gem 'chartkick'

gem 'cocoon',
  git: 'https://github.com/vtamara/cocoon.git', branch: 'new_id_with_ajax' # Formularios anidados (algunos con ajax)

gem 'coffee-rails' # CoffeeScript para recuersos .js.coffee y vistas

gem 'colorize' # Colores en terminal

gem 'devise' # Autenticación y roles

gem 'devise-i18n'

gem 'execjs'

gem 'jbuilder' # API JSON facil. Ver: https://github.com/rails/jbuilder

gem 'jquery-ui-rails'

gem 'kt-paperclip',                 # Anexos
  git: 'https://github.com/kreeti/kt-paperclip.git'

gem 'libxml-ruby'

gem 'nokogiri', '>=1.11.1'

gem 'odf-report' # Genera ODT

gem 'parslet'

gem 'pg'#, '~> 0.21' # Postgresql

gem 'pick-a-color-rails' # Facilita elegir colores en tema

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

gem 'sprockets-rails', '3.3.0'

gem 'tiny-color-rails'

gem 'twitter_cldr' # ICU con CLDR

gem 'tzinfo' # Zonas horarias

gem 'webpacker', '6.0.0.rc.1'

gem 'will_paginate' # Listados en páginas


#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento
# lógico y no alfabetico como las gemas anteriores)

gem 'sip', # Motor generico
  git: 'https://github.com/pasosdeJesus/sip.git', branch: :rails7jses
  #path: '../sip'

gem 'mr519_gen', # Motor de gestion de formularios y encuestas
  git: 'https://github.com/pasosdeJesus/mr519_gen.git', branch: :rails7jses
  #path: '../mr519_gen'

gem 'heb412_gen',  # Motor de nube y llenado de plantillas
  git: 'https://github.com/pasosdeJesus/heb412_gen.git', branch: :rails7jses
  #path: '../heb412_gen'

# Motor Cor1440_gen
gem 'cor1440_gen',
  git: 'https://github.com/pasosdeJesus/cor1440_gen.git', branch: :rails7jses
  #path: '../cor1440_gen'

# Motor Sal7711_gen
gem 'sal7711_gen',
  git: 'https://github.com/pasosdeJesus/sal7711_gen.git', branch: :rails7jses
  #path: '../sal7711_gen'

# Motor Sal7711_web
gem 'sal7711_web',
  git: 'https://github.com/pasosdeJesus/sal7711_web.git', branch: :rails7jses
  #path: '../sal7711_web'

# Motor de SIVeL 2
gem 'sivel2_gen',
  git: 'https://github.com/pasosdeJesus/sivel2_gen.git', branch: :rails7jses
  #path: '../sivel2_gen'

# Motor de SIVeL 2 - SJR
gem 'sivel2_sjr',
  git: 'https://github.com/pasosdeJesus/sivel2_sjr.git', branch: :rails7jses
  #path: '../sivel2_sjr'

group :development, :test do
  gem 'debug' # Depurar

  gem 'dotenv-rails'
end


group :development do

  gem 'puma' , '>= 4.3.3' # Servidor web

  gem 'rails-erd'

  gem 'web-console' # Consola irb en páginas

end


group :test do

  gem 'capybara'

  gem 'rails-controller-testing'

  gem 'selenium-webdriver' # Pruebas de regresión que no requieren javascript

  gem 'simplecov'

end


group :production do

  gem 'unicorn' # Para despliegue

end
