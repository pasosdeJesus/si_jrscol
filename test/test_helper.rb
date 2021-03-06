# encoding: utf-8

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


class ActiveSupport::TestCase

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

PRUEBA_TIPOORGSOCIAL = {
  id: 99,
  nombre: "Tipoorgsocial",
  fechacreacion: "2018-10-25",
  created_at: "2018-10-25",
}

PRUEBA_ORGSOCIAL = {
  grupoper_id: 1,
  tipoorgsocial_id: 99,
  created_at: '2021-08-27',
  updated_at: '2021-08-27'
}

#VARIABLES EN CONTROL DE ACCESO
# Usuario operador para ingresar y hacer pruebas
PRUEBA_USUARIO_OP = {
  nusuario: "operador",
  password: "sjrcol123",
  nombre: "operador",
  descripcion: "operador",
  rol: 5,
  oficina_id: 1,
  idioma: "es_CO",
  email: "operador@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}

# Usuario operador del grupo analista de casos 
# (debe agregarse al grupo analista de casos despu??s de creado)
PRUEBA_USUARIO_AN = {
  nusuario: "analista",
  password: "sjrcol123",
  nombre: "analista",
  descripcion: "operador en grupo analista de casos",
  rol: 5,
  oficina_id: 1,
  idioma: "es_CO",
  email: "analista@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}


PRUEBA_PERSONA = {
  nombres: 'Luis Alejandro',
  apellidos: 'Cruz Ordo??ez',
  sexo: 'M',
  numerodocumento: '1061769227' 
}

PRUEBA_UBICACIONPRE = {
  nombre: "BARRANCOMINAS / BARRANCOMINAS / GUAIN??A / COLOMBIA",
  pais_id: 170,
  departamento_id: 56,
  municipio_id: 594,
  clase_id: 13064,
  lugar: nil,
  sitio: nil,
  tsitio_id: nil,
  latitud: nil,
  longitud: nil,
  created_at: "2021-12-08",
  updated_at: "2021-12-08",
  nombre_sin_pais: "BARRANCOMINAS / BARRANCOMINAS / GUAIN??A"
}

PRUEBA_LUGARPRELIMINAR = {
  fecha: "2021-11-10",
  codigositio: "191030",
  created_at: "2021-11-06T19:39:08.247-05:00",
  updated_at: "2021-11-10T16:28:41.551-05:00",
  nombreusuario: "sivel2",
  organizacion: "organizacion ejemplo",
  ubicacionpre_id: nil,
  id_persona: 1,
  parentezco: "AB",
  grabacion: false,
  telefono: "35468489",
  tipotestigo_id: nil,
  otrotipotestigo: "",
  hechos: "",
  ubicaespecifica: "",
  disposicioncadaveres_id: nil,
  otradisposicioncadaveres: "",
  tipoentierro_id: nil,
  min_depositados: nil,
  max_depositados: nil,
  fechadis: nil,
  horadis: "1999-12-31T19:39:00.000-05:00",
  insitu: true,
  otrolubicacionpre_id: nil,
  detallesasesinato: "",
  nombrepropiedad: "",
  detallesdisposicion: "",
  nomcomoseconoce: "",
  elementopaisaje_id: nil,
  cobertura_id: nil,
  interatroprevias: "",
  interatroactuales: "",
  usoterprevios: "",
  usoteractuales: "",
  accesolugar: "",
  perfilestratigrafico: "",
  observaciones: "",
  procesoscul: "",
  desgenanomalia: "",
  evaluacionlugar: "",
  riesgosdanios: "",
  archivokml_id: nil
}
PRUEBA_CASO = {
  titulo: "Caso de prueba",
  fecha: "2021-09-11",
  memo: "Una descripci??n del caso de prueba"
}

PRUEBA_PROYECTOFINANCIERO = {
  id: 1,
  nombre: "Proyectofinanciero",
  fechacreacion: "2015-04-20",
  created_at: "2015-04-20"
}

PRUEBA_OBJETIVOPF = {
  id: 1,
  proyectofinanciero_id: 1,
  numero: 'O1',
  objetivo: 'Objetivo 1'
}

PRUEBA_RESULTADOPF = {
  id: 1,
  proyectofinanciero_id: 1,
  objetivopf_id: 1,
  numero: 'R1',
  resultado: 'Resultado 1'
}

PRUEBA_ACTIVIDADPF = {
  id: 1,
  proyectofinanciero_id: 1,
  nombrecorto:'actividadpf',
  titulo: 'titulo actividadpf',
  resultadopf_id: 1,
}

PRUEBA_ACTIVIDAD = {
  id: 1,
  nombre:'n',
  fecha:'2017-03-02',
  oficina_id:1,
  usuario_id:1
}

PRUEBA_DETALLEFINANCIERO = {
  id: 798,
  proyectofinanciero_id: 1,
  actividadpf_id: 1,
  actividad_id: 1,
  unidadayuda_id: 9,
  cantidad: 2,
  valorunitario: 20000,
  valortotal: 40000,
  mecanismodeentrega_id: 3,
  modalidadentrega_id: 2,
  tipotransferencia_id: 2,
  frecuenciaentrega_id: 4,
  numeromeses: 3,
  numeroasistencia: 1,
  created_at: "2020-07-12",
  updated_at: "2020-07-12"
}


