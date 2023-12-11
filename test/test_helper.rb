# encoding: utf-8

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


class ActiveSupport::TestCase

  if Msip::Tcentropoblado.all.count == 0
    load "#{Rails.root}/db/seeds.rb"
    SiJrscol::Application.load_tasks
    Rake::Task['msip:indices'].invoke
  end

  protected
  def load_seeds
    load "#{Rails.root}/db/seeds.rb"
  end
end


PRUEBA_ACTIVIDAD = {
  id: 1,
  nombre:'n',
  fecha:'2017-03-02',
  oficina_id:1,
  usuario_id:1,
  ubicacionpre_id: 1,
  resultado: 'x'
}

PRUEBA_ACTIVIDADPF = {
  id: 1,
  proyectofinanciero_id: 1,
  nombrecorto:'actividadpf',
  titulo: 'titulo actividadpf',
  resultadopf_id: 1,
}

PRUEBA_ACTONINO = {
  caso_id: 1,
  persona_id: 1,
  fecha: '2020-06-15',
  ubicacionpre_id: 1, # Colombia
  presponsable_id: 8, # GAULA
  categoria_id: 40 # ASESINATO
}

PRUEBA_AREA = {
  id: 1,
  nombre: 'A',
  fechacreacion: "2018-10-25",
  created_at: "2018-10-25"
}

PRUEBA_ASESORHISTORICO = {
  casosjr_id: 1,
  usuario_id: 1,
  oficina_id: 1,
  fechainicio: '2022-06-22',
  fechafin: '2022-06-23'
}

PRUEBA_CASO = {
  titulo: "Caso de prueba",
  fecha: "2021-09-11",
  memo: "Una descripción del caso de prueba"
}

PRUEBA_CASOSJR = {
  caso_id: 0, # por llenar
  contacto_id: 0, # por llenar
  fecharec: "2021-04-14",
  asesor: 1,
  created_at: "2021-04-14",
}

PRUEBA_CATEGORIA= {
  id: 1000, 
  nombre: "Categoria",
  supracategoria_id: 1,
  fechacreacion: "2014-09-09",
  created_at: "2014-09-09"
}

PRUEBA_DESPLAZAMIENTO= {
  caso_id: 0, # por llenar
  fechaexpulsion: "2021-04-12",
  fechallegada: "2021-04-13",
  created_at: "2014-12-02",
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

PRUEBA_ETIQUETA = {
  id: 1000,
  nombre: "Eti",
  observaciones: "O",
  fechacreacion: "2014-09-04",
  created_at: "2014-09-04",
}

PRUEBA_GRUPOPER = {
  id: 1,
  nombre: 'grupoper1'
}

PRUEBA_FINANCIADOR = {
  id: 1000,
  nombre: "Cor1440_gen_financiador",
  nombregifmm: "Cor1440_gen_financiador",
  fechacreacion: "2015-04-20",
  created_at: "2015-04-20",
}


PRUEBA_LUGARPRELIMINAR = {
  fecha: "2021-11-10",
  codigositio: "191030",
  created_at: "2021-11-06T19:39:08.247-05:00",
  updated_at: "2021-11-10T16:28:41.551-05:00",
  nombreusuario: "sivel2",
  organizacion: "organizacion ejemplo",
  ubicacionpre_id: nil,
  persona_id: 1,
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

PRUEBA_OBJETIVOPF = {
  id: 1,
  proyectofinanciero_id: 1,
  numero: 'O1',
  objetivo: 'Objetivo 1'
}

PRUEBA_ORGSOCIAL = {
  grupoper_id: 1,
  tipoorgsocial_id: 99,
  created_at: '2021-08-27',
  updated_at: '2021-08-27'
}

PRUEBA_PERSONA = {
  nombres: 'Luis Alejandro',
  apellidos: 'Cruz Ordoñez',
  sexo: 'M',
  numerodocumento: '1061769227',
  tdocumento_id: 11,
  anionac: 1987,
  mesnac: 6,
  dianac: 15,
  ultimoperfilorgsocial_id: 13,
  ultimoestatusmigratorio_id: 7
}

PRUEBA_PERSONA2 = {
  nombres: 'x',
  apellidos: 'y',
  sexo: 'M',
  numerodocumento: '127935',
  tdocumento_id: 11,
  anionac: 1988,
  mesnac: 7,
  dianac: 16,
  ultimoperfilorgsocial_id: 13,
  ultimoestatusmigratorio_id: 2
}

PRUEBA_PROYECTOFINANCIERO = {
  id: 1,
  nombre: "Proyectofinanciero",
  fechacreacion: "2015-04-20",
  created_at: "2015-04-20"
}

PRUEBA_RESULTADOPF = {
  id: 1,
  proyectofinanciero_id: 1,
  objetivopf_id: 1,
  numero: 'R1',
  resultado: 'Resultado 1'
}

PRUEBA_SOLICITUD = {
  id: 1,
  usuario_id: 1,
  fecha: "2022-06-24",
  solicitud: "Especial",
  estadosol_id: 1,
  created_at: "2022-06-24",
  updated_at: "2022-06-24",
}

PRUEBA_TDOCUMENTO = {
  id: 1000,
  nombre: "Tdocumento",
  sigla: "TD",
  formatoregex: "[0-9]*",
  fechacreacion: "2014-09-22",
  created_at: "2014-09-22",
}

PRUEBA_TIPOORGSOCIAL = {
  id: 99,
  nombre: "Tipoorgsocial",
  fechacreacion: "2018-10-25",
  created_at: "2018-10-25",
}

PRUEBA_UBICACION = {
  tsitio_id: 1,
  pais_id: 862, # VENEZUELA
  departamento_id: 1, # DISTRITO CAPITAL
  municipio_id: 25, # BOLIVARIANO LIBERTADOR
  centropoblado_id: 217, # CARACAS
  created_at: "2014-11-06",
}

PRUEBA_UBICACIONPRE = {
  nombre: "BARRANCOMINAS / BARRANCOMINAS / GUAINÍA / COLOMBIA",
  pais_id: 170,
  departamento_id: 56,
  municipio_id: 594,
  centropoblado_id: 13064,
  lugar: nil,
  sitio: nil,
  tsitio_id: nil,
  latitud: nil,
  longitud: nil,
  created_at: "2021-12-08",
  updated_at: "2021-12-08",
  nombre_sin_pais: "BARRANCOMINAS / BARRANCOMINAS / GUAINÍA",
  fechacreacion: "2023-12-07"
}

PRUEBA_UBICACIONPRE2 = {
  pais_id: 100, # BULGARIA
  departamento_id: nil,
  municipio_id: nil,
  centropoblado_id: nil,
  lugar: "IMAGINA",
  nombre: "IMAGINA / BULGARIA",
  latitud: 0.1,
  longitud: 0.2,
  nombre_sin_pais: "IMAGINA",
  fechacreacion: "2023-12-07"
}

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
  territorial_id: nil
}

# Usuario operador para ingresar y hacer pruebas
PRUEBA_USUARIO_ANALI = {
  nusuario: "analista",
  password: "sjrcol123",
  nombre: "analista",
  territorial_id: 1,
  descripcion: "analista",
  rol: 5, # Analista
  idioma: "es_CO",
  email: "analista@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}

# Usuario operador del grupo analista de casos 
# (debe agregarse al grupo analista de casos después de creado)
PRUEBA_USUARIO_AN = {
  nusuario: "analista",
  password: "sjrcol123",
  nombre: "analista",
  descripcion: "operador en grupo analista de casos",
  rol: 5,
  territorial_id: 1,
  idioma: "es_CO",
  email: "analista@localhost",
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
  territorial_id: 1,
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
  territorial_id: nil,
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
  territorial_id: 1,
  descripcion: "coord",
  rol: 4, # Coordinador
  idioma: "es_CO",
  email: "coord@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}

# Usuario operador para ingresar y hacer pruebas
PRUEBA_USUARIO_OP = {
  nusuario: "operador",
  password: "sjrcol123",
  nombre: "operador",
  descripcion: "operador",
  rol: 5,
  territorial_id: 1,
  idioma: "es_CO",
  email: "operador@localhost",
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
  territorial_id: 1,
  descripcion: "sistematiza",
  rol: 5, # Analista
  idioma: "es_CO",
  email: "sistematiza@localhost",
  encrypted_password: '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  sign_in_count: 0,
  fechacreacion: "2021-08-27",
  fechadeshabilitacion: nil
}

PRUEBA_VICTIMA = {
  hijos: 0,
  profesion_id: 1,
  rangoedad_id: 1,
  filiacion_id: 1,
  sectorsocial_id: 1,
  organizacion_id: 1,
  vinculoestado_id: 1,
  organizacionarmada: 1,
  anotaciones: 'a',
  etnia_id: 1,
  iglesia_id: 1,
  orientacionsexual: 'H'
}

