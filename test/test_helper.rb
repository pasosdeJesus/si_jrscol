# encoding: utf-8

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'




class ActiveSupport::TestCase

  fixtures :all
 
  if Sip::Tclase.all.count == 0
    load "#{Rails.root}/db/seeds.rb"
    Sivel2Sjrcol::Application.load_tasks
    Rake::Task['sip:indices'].invoke
  end

  protected
  def load_seeds
    load "#{Rails.root}/db/seeds.rb"
  end
end

# Usuario para ingresar y hacer pruebas
PRUEBA_USUARIO = {
  nusuario: "admin",
  password: "sjrven123",
  nombre: "admin",
  descripcion: "admin",
  rol: 1,
  idioma: "es_CO",
  email: "usuario1@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2014-08-05",
  fechadeshabilitacion: nil,
  oficina_id: nil
}

# Usuario operador para ingresar y hacer pruebas
PRUEBA_USUARIO_ANALI = {
  nusuario: "analista",
  password: "sjrcol123",
  nombre: "analista",
  oficina_id: 1,
  descripcion: "analista",
  rol: 5, # Analista
  idioma: "es_CO",
  email: "analista@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}

# Usuario sistematizador para ingresar y hacer pruebas
PRUEBA_USUARIO_SIST = {
  nusuario: "sistematiza",
  password: "sjrcol123",
  nombre: "sistematiza",
  oficina_id: 1,
  descripcion: "sistematiza",
  rol: 5, # Analista
  idioma: "es_CO",
  email: "sistematiza@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}

# Usuario analista de prensa para ingresar y hacer pruebas
PRUEBA_USUARIO_AP= {
  nusuario: "ap",
  password: "sjrcol123",
  nombre: "ap",
  oficina_id: 1,
  descripcion: "ap",
  rol: 7, # Analista
  idioma: "es_CO",
  email: "ap@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}

# Usuario invitado para ingresar y hacer pruebas
PRUEBA_USUARIO_INV = {
  nusuario: "inv",
  password: "sjrcol123",
  nombre: "inv",
  oficina_id: nil,
  descripcion: "inv",
  rol: 2, # Analista
  idioma: "es_CO",
  email: "inv@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}


# Usuario coordinador para ingresar y hacer pruebas
PRUEBA_USUARIO_COORD = {
  nusuario: "coord",
  password: "sjrcol123",
  nombre: "coord",
  oficina_id: 1,
  descripcion: "coord",
  rol: 4, # Coordinador
  idioma: "es_CO",
  email: "coord@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}


PRUEBA_GRUPOPER = {
  id: 1,
  nombre: 'grupoper1'
}

PRUEBA_ORGSOCIAL = {
  id: 1,
  grupoper_id: 1,
  tipoorgsocial_id: 1,
  created_at: '2021-08-27',
  updated_at: '2021-08-27'
}

