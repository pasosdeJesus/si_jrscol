-- Novedades a tablas basicas de sivel2_gen

      
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, pg_catalog;

UPDATE public.sivel2_gen_rangoedad SET fechadeshabilitacion='2014-11-28' WHERE nombre LIKE 'R%';
INSERT INTO public.sivel2_gen_rangoedad (id, nombre, limiteinferior, limitesuperior, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones)
 VALUES (7, 'DE 0 A 5 AÑOS', 0, 5, '2014-10-29', NULL, NULL, NULL, NULL); 
INSERT INTO public.sivel2_gen_rangoedad (id, nombre, limiteinferior, limitesuperior, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones)
 VALUES (8, 'DE 6 A 12 AÑOS', 6, 12, '2014-10-29', NULL, NULL, NULL, NULL); 
INSERT INTO public.sivel2_gen_rangoedad (id, nombre, limiteinferior, limitesuperior, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones)
 VALUES (9, 'DE 13 A 17 AÑOS', 13, 17, '2014-10-29', NULL, NULL, NULL, NULL); 
INSERT INTO public.sivel2_gen_rangoedad (id, nombre, limiteinferior, limitesuperior, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones)
 VALUES (11, 'DE 27 A 59 AÑOS', 27, 59, '2014-10-29', NULL, NULL, NULL, NULL); 
INSERT INTO public.sivel2_gen_rangoedad (id, nombre, limiteinferior, limitesuperior, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones)
 VALUES (12, 'DE 60 EN ADELANTE', 60, 180, '2014-10-29', NULL, NULL, NULL, NULL); 
INSERT INTO public.sivel2_gen_rangoedad (id, nombre, limiteinferior, limitesuperior, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones)
 VALUES (10, 'DE 18 A 26 AÑOS', 18, 26, '2014-10-29', NULL, NULL, NULL, NULL);


UPDATE public.cor1440_gen_rangoedadac set nombre='DE 0 A 5', limiteinferior=0, limitesuperior=5 WHERE id=1;
UPDATE public.cor1440_gen_rangoedadac set nombre='DE 6 A 12', limiteinferior=6, limitesuperior=12 WHERE id=2;
UPDATE public.cor1440_gen_rangoedadac set nombre='DE 13 A 17', limiteinferior=13, limitesuperior=17 WHERE id=3;
UPDATE public.cor1440_gen_rangoedadac set nombre='DE 18 A 26', limiteinferior=18, limitesuperior=26 WHERE id=4;
UPDATE public.cor1440_gen_rangoedadac set nombre='DE 27 A 59', limiteinferior=27, limitesuperior=59 WHERE id=5;
UPDATE public.cor1440_gen_rangoedadac set nombre='DE 60 EN ADELANTE', limiteinferior=60, limitesuperior=NULL WHERE id=6;
--INSERT INTO public.cor1440_gen_rangoedadac (id, nombre, limiteinferior, limitesuperior, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (7, 'SIN INFORMACIÓN', -1, -1, '2019-09-28', NULL, '2019-09-28', '2019-09-28');



INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (6, 'Soacha', '2013-05-13', NULL, NULL, '2021-10-15 22:32:01.085637', '', 170, 27, 1216, 4758, 6);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (3, 'Barrancabermeja', '2013-05-13', NULL, NULL, NULL, NULL, 170, 43, 1319, 9899, 3);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (4, 'Cúcuta', '2013-05-13', NULL, NULL, '2016-05-13 21:36:35.029649', '', 170, 39, 32, 9041, 4);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (7, 'Bogotá', '2013-07-05', NULL, NULL, '2015-05-14 12:39:19.66094', NULL, 170, 4, 24, 238, 7);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (5, 'Pasto', '2013-05-13', NULL, NULL, NULL, NULL, 170, 38, 44, 7907, 5);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (2, 'Buenaventura', '2013-05-13', NULL, NULL, '2018-06-20 22:09:05.965897', '', NULL, NULL, NULL, NULL, 2);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (101, 'Pereira', '2023-03-17', NULL, '2023-03-17 17:31:33.722675', '2023-03-17 17:31:33.722675', '', 170, 42, 45, NULL, 101);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (102, 'Cartagena', '2023-03-17', NULL, '2023-03-17 17:32:04.066646', '2023-03-17 17:32:04.066646', '', 170, 7, 31, NULL, 102);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (8, 'Bucaramanga', '2023-10-09', NULL, '2023-10-09 00:00:00', '2023-10-09 00:00:00', '', 170, 43, 27, 9867, 8);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (9, 'Ibague', '2023-10-09', NULL, '2023-10-09 00:00:00', '2023-10-09 00:00:00', '', 170, 46, 34, 11103, 6);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (10, 'Santa Rosa del Sur', '2023-10-09', NULL, '2023-10-09 00:00:00', '2023-10-09 00:00:00', '', 170, 7, 1138, 788, 3);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (11, 'Tibú', '2023-10-09', NULL, '2023-10-09 00:00:00', '2023-10-09 00:00:00', '', 170, 39, 1320, 9427, 4);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (12, 'Ipiales', '2023-10-09', NULL, '2023-10-09 00:00:00', '2023-10-09 00:00:00', '', 170, 38, 611, 8302, 5);
INSERT INTO public.msip_oficina (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones, pais_id, departamento_id, municipio_id, centropoblado_id, territorial_id) VALUES (13, 'Palmira', '2023-10-09', NULL, '2023-10-09 00:00:00', '2023-10-09 00:00:00', '', 170, 47, 881, 12171, 2);
UPDATE msip_oficina SET territorial_id=1 WHERE id=1;


INSERT INTO msip_tdocumento (id, nombre, sigla, formatoregex, 
  fechacreacion, fechadeshabilitacion, created_at, 
  updated_at, observaciones, ayuda) VALUES (16, 'PERMISO POR PROTECCIÓN TEMPORAL', 'PPT', '[0-9]*', '2023-12-10', NULL, NULL, NULL, NULL, 'Solo dígitos. Por ejemplo 323948');

INSERT INTO public.msip_perfilorgsocial (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (13, 'COMUNIDAD DE ACOGIDA', 'Usado en reporte GIFMM', '2020-09-10', NULL, '2020-09-10 00:00:00', '2020-09-10 00:00:00');
INSERT INTO public.msip_perfilorgsocial (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (4, 'FAMILIAR DE DEFENSOR/A O DE LÍDER SOCIAL', NULL, '2009-09-11', '2022-11-22', '2018-07-24 00:00:00', '2018-07-24 00:00:00');
INSERT INTO public.msip_perfilorgsocial (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (10, 'MIGRANTE CON VOCACIÓN DE PERMANENCIA', 'Corresponde a un perfil de migración y es usado en reporte GIFMM', '2020-09-10', NULL, '2020-09-10 00:00:00', '2020-09-10 00:00:00');
INSERT INTO public.msip_perfilorgsocial (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (11, 'MIGRANTE EN TRÁNSITO', 'Corresponde a un perfil de migración y es usado en reporte GIFMM', '2020-09-10', NULL, '2020-09-10 00:00:00', '2020-09-10 00:00:00');
INSERT INTO public.msip_perfilorgsocial (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (12, 'MIGRANTE PENDULAR', 'Corresponde a un perfil de migración y es usado en reporte GIFMM', '2020-09-10', NULL, '2020-09-10 00:00:00', '2020-09-10 00:00:00');
INSERT INTO public.msip_perfilorgsocial (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (14, 'VÍCTIMA', NULL, '2022-11-22', NULL, '2022-11-25 12:20:10.570493', '2022-11-25 12:20:10.570493');
INSERT INTO public.msip_perfilorgsocial (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (15, 'VÍCTIMA DE DOBLE AFECTACIÓN', NULL, '2022-11-22', NULL, '2022-11-25 12:20:10.570493', '2022-11-25 12:20:10.570493');
INSERT INTO public.msip_perfilorgsocial (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (16, 'COLOMBIANO RETORNADO', NULL, '2022-11-22', NULL, '2022-11-25 12:20:10.570493', '2022-11-25 12:20:10.570493');



 INSERT INTO public.sivel2_sjr_regimensalud (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (0, 'SIN INFORMACIÓN', '2013-05-16', NULL, NULL, NULL);
 INSERT INTO public.sivel2_sjr_regimensalud (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (1, 'SUBSIDIADO', '2013-05-16', NULL, NULL, NULL);
 INSERT INTO public.sivel2_sjr_regimensalud (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (2, 'CONTRIBUTIVO', '2013-05-16', NULL, NULL, NULL);

UPDATE msip_tema SET
  fondo = '#f2f2ff',
  color_fuente = '#000000',
  nav_ini = '#5377a6',
  nav_fin = '#1f4e8c',
  nav_fuente = '#f2f2ff',
  fondo_lista = '#5377a6',
  btn_primario_fondo_ini = '#04c4d9',
  btn_primario_fondo_fin = '#1f4e8c',
  btn_primario_fuente = '#f2f2ff',
  btn_peligro_fondo_ini = '#ff1b30',
  btn_peligro_fondo_fin = '#ad0a0a',
  btn_peligro_fuente = '#f2f2ff',
  btn_accion_fondo_ini = '#f2f2ff',
  btn_accion_fondo_fin= '#d6d6f0',
  btn_accion_fuente = '#000000',
  alerta_exito_fondo = '#01a7d1',
  alerta_exito_fuente = '#1f4e8c',
  alerta_problema_fondo = '#f8d7da',
  alerta_problema_fuente = '#721c24'
WHERE id=1;


INSERT INTO sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (9, 'APATRIDA', '2020-01-04', NULL, NULL, NULL);
INSERT INTO sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (10, 'EN RIESGO DE APATRIDA', '2020-01-04', NULL, NULL, NULL);

UPDATE sivel2_sjr_proteccion SET nombre = 'REFUGIADO' WHERE ID=8; 


INSERT INTO sivel2_sjr_statusmigratorio (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (7, 'IRREGULAR', '2020-01-05', NULL, NULL, NULL);
INSERT INTO sivel2_sjr_statusmigratorio (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (8, 'EN PROCESO DE REGULARIZACIÓN', '2020-01-05', NULL, NULL, NULL);
UPDATE sivel2_sjr_statusmigratorio SET nombre = 'REGULAR MIGRANTE' WHERE ID=1;
UPDATE sivel2_sjr_statusmigratorio SET nombre = 'REGULAR NACIONAL POR NACIMIENTO' WHERE ID=5;
UPDATE sivel2_sjr_statusmigratorio SET nombre = 'REGULAR NACIONAL POR NATURALIZACIÓN' WHERE ID=6;

UPDATE sivel2_sjr_statusmigratorio SET formupersona='t' 
WHERE id in (1, 7, 8);

---- Plantilla listado de casos extra-completo


INSERT INTO public.heb412_gen_plantillahcm (id, ruta, fuente, licencia, vista, nombremenu, filainicial) VALUES (44, 'Plantillas/listado_extracompleto_de_casos.ods', 'PdJ', 'Dominio Publico', 'Caso', 'Listado extracompleto de casos', 5);

INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (600, 44, 'familiar2_nombres', 'BO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (601, 44, 'familiar2_apellidos', 'BP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (602, 44, 'familiar2_anionac', 'BQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (603, 44, 'familiar2_mesnac', 'BR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (604, 44, 'familiar2_dianac', 'BS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (605, 44, 'familiar2_tdocumento', 'BT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (606, 44, 'familiar2_numerodocumento', 'BU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (200, 44, 'caso_id', 'A');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (201, 44, 'contacto_nombres', 'B');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (202, 44, 'contacto_apellidos', 'C');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (203, 44, 'contacto_anionac', 'D');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (204, 44, 'contacto_mesnac', 'E');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (205, 44, 'contacto_dianac', 'F');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (206, 44, 'contacto_tdocumento', 'G');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (207, 44, 'contacto_numerodocumento', 'H');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (208, 44, 'contacto_sexo', 'I');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (209, 44, 'contacto_pais', 'J');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (210, 44, 'contacto_departamento', 'K');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (211, 44, 'contacto_municipio', 'L');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (212, 44, 'contacto_vinculoestado', 'AF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (213, 44, 'familiar1_profesion', 'BI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (214, 44, 'contacto_orientacionsexual', 'Q');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (215, 44, 'contacto_maternidad', 'R');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (216, 44, 'contacto_estadocivil', 'S');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (217, 44, 'contacto_comosupo', 'AG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (218, 44, 'familiar1_actividadoficio', 'BJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (220, 44, 'direccion', 'M');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (221, 44, 'telefono', 'N');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (222, 44, 'contacto_numeroanexos', 'O');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (223, 44, 'contacto_etnia', 'P');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (224, 44, 'contacto_discapacidad', 'T');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (225, 44, 'contacto_cabezafamilia', 'U');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (226, 44, 'contacto_rolfamilia', 'V');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (227, 44, 'contacto_tienesisben', 'W');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (228, 44, 'contacto_regimensalud', 'X');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (229, 44, 'contacto_asisteescuela', 'Y');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (230, 44, 'contacto_escolaridad', 'Z');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (231, 44, 'contacto_actualtrabajando', 'AA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (232, 44, 'contacto_profesion', 'AB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (233, 44, 'contacto_actividadoficio', 'AC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (234, 44, 'contacto_filiacion', 'AD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (235, 44, 'contacto_organizacion', 'AE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (236, 44, 'contacto_consentimientosjr', 'AH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (237, 44, 'contacto_consentimientobd', 'AI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (238, 44, 'contacto_numeroanexosconsen', 'AJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (239, 44, 'familiar1_nombres', 'AK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (240, 44, 'familiar1_apellidos', 'AL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (241, 44, 'familiar1_anionac', 'AM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (242, 44, 'familiar1_mesnac', 'AN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (243, 44, 'familiar1_dianac', 'AO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (244, 44, 'familiar1_tdocumento', 'AP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (245, 44, 'familiar1_numerodocumento', 'AQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (246, 44, 'familiar1_sexo', 'AR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (247, 44, 'familiar1_pais', 'AS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (248, 44, 'familiar1_departamento', 'AT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (249, 44, 'familiar1_municipio', 'AU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (250, 44, 'familiar1_numeroanexos', 'AV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (251, 44, 'familiar1_etnia', 'AW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (252, 44, 'familiar1_orientacionsexual', 'AX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (253, 44, 'familiar1_maternidad', 'AY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (254, 44, 'familiar1_estadocivil', 'AZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (255, 44, 'familiar1_discapacidad', 'BA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (256, 44, 'familiar1_cabezafamilia', 'BB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (257, 44, 'familiar1_rolfamilia', 'BC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (258, 44, 'familiar1_tienesisben', 'BD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (259, 44, 'familiar1_regimensalud', 'BE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (260, 44, 'familiar1_asisteescuela', 'BF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (261, 44, 'familiar1_escolaridad', 'BG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (262, 44, 'familiar1_actualtrabajando', 'BH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (263, 44, 'familiar1_filiacion', 'BK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (264, 44, 'familiar1_organizacion', 'BL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (265, 44, 'familiar1_vinculoestado', 'BM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (266, 44, 'familiar1_numeroanexosconsen', 'BN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (607, 44, 'familiar2_sexo', 'BV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (608, 44, 'familiar2_pais', 'BW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (609, 44, 'familiar2_departamento', 'BX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (610, 44, 'familiar2_municipio', 'BY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (611, 44, 'familiar2_numeroanexos', 'BZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (612, 44, 'familiar2_etnia', 'CA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (613, 44, 'familiar2_orientacionsexual', 'CB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (614, 44, 'familiar2_maternidad', 'CC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (615, 44, 'familiar2_estadocivil', 'CD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (616, 44, 'familiar2_discapacidad', 'CE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (617, 44, 'familiar2_cabezafamilia', 'CF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (618, 44, 'familiar2_rolfamilia', 'CG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (619, 44, 'familiar2_tienesisben', 'CH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (620, 44, 'familiar2_regimensalud', 'CI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (621, 44, 'familiar2_asisteescuela', 'CJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (622, 44, 'familiar2_escolaridad', 'CK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (623, 44, 'familiar2_actualtrabajando', 'CL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (624, 44, 'familiar2_profesion', 'CM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (625, 44, 'familiar2_actividadoficio', 'CN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (626, 44, 'familiar2_filiacion', 'CO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (627, 44, 'familiar2_organizacion', 'CP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (628, 44, 'familiar2_vinculoestado', 'CQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (629, 44, 'familiar2_numeroanexosconsen', 'CR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (630, 44, 'familiar3_nombres', 'CS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (631, 44, 'familiar3_apellidos', 'CT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (632, 44, 'familiar3_anionac', 'CU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (633, 44, 'familiar3_mesnac', 'CV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (634, 44, 'familiar3_dianac', 'CW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (635, 44, 'familiar3_tdocumento', 'CX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (636, 44, 'familiar3_numerodocumento', 'CY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (637, 44, 'familiar3_sexo', 'CZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (638, 44, 'familiar3_pais', 'DA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (639, 44, 'familiar3_departamento', 'DB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (640, 44, 'familiar3_municipio', 'DC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (641, 44, 'familiar3_numeroanexos', 'DD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (642, 44, 'familiar3_etnia', 'DE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (643, 44, 'familiar3_orientacionsexual', 'DF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (644, 44, 'familiar3_maternidad', 'DG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (645, 44, 'familiar3_estadocivil', 'DH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (646, 44, 'familiar3_discapacidad', 'DI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (647, 44, 'familiar3_cabezafamilia', 'DJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (648, 44, 'familiar3_rolfamilia', 'DK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (649, 44, 'familiar3_tienesisben', 'DL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (650, 44, 'familiar3_regimensalud', 'DM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (651, 44, 'familiar3_asisteescuela', 'DN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (652, 44, 'familiar3_escolaridad', 'DO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (653, 44, 'familiar3_actualtrabajando', 'DP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (654, 44, 'familiar3_profesion', 'DQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (655, 44, 'familiar3_actividadoficio', 'DR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (656, 44, 'familiar3_filiacion', 'DS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (657, 44, 'familiar3_organizacion', 'DT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (658, 44, 'familiar3_vinculoestado', 'DU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (659, 44, 'familiar3_numeroanexosconsen', 'DV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (660, 44, 'familiar4_nombres', 'DW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (661, 44, 'familiar4_apellidos', 'DX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (662, 44, 'familiar4_anionac', 'DY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (663, 44, 'familiar4_mesnac', 'DZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (664, 44, 'familiar4_dianac', 'EA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (665, 44, 'familiar4_tdocumento', 'EB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (666, 44, 'familiar4_numerodocumento', 'EC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (667, 44, 'familiar4_sexo', 'ED');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (668, 44, 'familiar4_pais', 'EE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (669, 44, 'familiar4_departamento', 'EF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (670, 44, 'familiar4_municipio', 'EG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (671, 44, 'familiar4_numeroanexos', 'EH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (672, 44, 'familiar4_etnia', 'EI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (673, 44, 'familiar4_orientacionsexual', 'EJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (674, 44, 'familiar4_maternidad', 'EK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (675, 44, 'familiar4_estadocivil', 'EL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (676, 44, 'familiar4_discapacidad', 'EM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (677, 44, 'familiar4_cabezafamilia', 'EN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (678, 44, 'familiar4_rolfamilia', 'EO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (679, 44, 'familiar4_tienesisben', 'EP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (680, 44, 'familiar4_regimensalud', 'EQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (681, 44, 'familiar4_asisteescuela', 'ER');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (682, 44, 'familiar4_escolaridad', 'ES');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (683, 44, 'familiar4_actualtrabajando', 'ET');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (684, 44, 'familiar4_profesion', 'EU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (685, 44, 'familiar4_actividadoficio', 'EV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (686, 44, 'familiar4_filiacion', 'EW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (687, 44, 'familiar4_organizacion', 'EX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (688, 44, 'familiar4_vinculoestado', 'EY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (689, 44, 'familiar4_numeroanexosconsen', 'EZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (690, 44, 'familiar5_nombres', 'FA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (691, 44, 'familiar5_apellidos', 'FB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (692, 44, 'familiar5_anionac', 'FC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (693, 44, 'familiar5_mesnac', 'FD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (694, 44, 'familiar5_dianac', 'FE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (695, 44, 'familiar5_tdocumento', 'FF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (696, 44, 'familiar5_numerodocumento', 'FG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (697, 44, 'familiar5_sexo', 'FH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (698, 44, 'familiar5_pais', 'FI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (699, 44, 'familiar5_departamento', 'FJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (700, 44, 'familiar5_municipio', 'FK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (701, 44, 'familiar5_numeroanexos', 'FL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (284, 44, 'fechasalida', 'GE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (702, 44, 'familiar5_etnia', 'FM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (703, 44, 'familiar5_orientacionsexual', 'FN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (704, 44, 'familiar5_maternidad', 'FO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (705, 44, 'familiar5_estadocivil', 'FP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (706, 44, 'familiar5_discapacidad', 'FQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (707, 44, 'familiar5_cabezafamilia', 'FR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (708, 44, 'familiar5_rolfamilia', 'FS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (709, 44, 'familiar5_tienesisben', 'FT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (710, 44, 'familiar5_regimensalud', 'FU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (711, 44, 'familiar5_asisteescuela', 'FV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (712, 44, 'familiar5_escolaridad', 'FW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (713, 44, 'familiar5_actualtrabajando', 'FX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (714, 44, 'familiar5_profesion', 'FY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (715, 44, 'familiar5_actividadoficio', 'FZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (716, 44, 'familiar5_filiacion', 'GA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (717, 44, 'familiar5_organizacion', 'GB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (718, 44, 'familiar5_vinculoestado', 'GC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (719, 44, 'familiar5_numeroanexosconsen', 'GD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (285, 44, 'salida_pais', 'GF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (292, 44, 'salida_departamento', 'GG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (286, 44, 'salida_municipio', 'GH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (287, 44, 'salida_centropoblado', 'GI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (288, 44, 'viadeingreso', 'GJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (289, 44, 'causamigracion', 'GK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (290, 44, 'pagoingreso', 'GL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (291, 44, 'valor_pago', 'GM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (293, 44, 'concepto_pago', 'GN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (294, 44, 'actor_pago', 'GO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (295, 44, 'ubifamilia', 'GP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (296, 44, 'dificultadmigracion', 'GQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (297, 44, 'agresionmigracion', 'GR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (298, 44, 'perpetradoresagresion', 'GS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (299, 44, 'causaagresion', 'GT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (300, 44, 'fechallegada', 'GU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (301, 44, 'llegada_pais', 'GV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (302, 44, 'llegada_departamento', 'GW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (303, 44, 'llegada_municipio', 'GX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (304, 44, 'llegada_centropoblado', 'GY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (305, 44, 'tiempoenpais', 'GZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (306, 44, 'perfilmigracion', 'HA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (307, 44, 'migracontactopre', 'HB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (308, 44, 'estatus_migratorio', 'HC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (309, 44, 'agresionenpais', 'HD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (317, 44, 'perpeagresenpais', 'HE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (925, 44, 'respuesta4_actividadpf', 'KY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (381, 44, 'acto3_fecha', 'KY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (354, 44, 'presponsable2_presponsable', 'KY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (327, 44, 'tipodesp', 'KY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (926, 44, 'respuesta5_actividad', 'KZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (382, 44, 'acto3_desplazamiento', 'KZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (355, 44, 'presponsable2_bloque', 'KZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (328, 44, 'categoria', 'KZ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (927, 44, 'respuesta5_fecha', 'LA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (383, 44, 'acto4_presponsable', 'LA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (356, 44, 'presponsable2_frente', 'LA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (329, 44, 'otrosdatos', 'LA');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (928, 44, 'respuesta5_proyectofinanciero', 'LB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (384, 44, 'acto4_categoria', 'LB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (357, 44, 'presponsable2_brigada', 'LB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (330, 44, 'declaro', 'LB');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (929, 44, 'respuesta5_actividadpf', 'LC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (385, 44, 'acto4_persona', 'LC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (358, 44, 'presponsable2_batallon', 'LC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (331, 44, 'hechosdeclarados', 'LC');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (520, 44, 'memo', 'LD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (386, 44, 'acto4_fecha', 'LD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (359, 44, 'presponsable2_division', 'LD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (332, 44, 'fechadeclaracion', 'LD');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (521, 44, 'numeroanexos', 'LE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (387, 44, 'acto4_desplazamiento', 'LE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (360, 44, 'presponsable2_otro', 'LE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (333, 44, 'declaroante', 'LE');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (930, 44, 'etiqueta1_etiqueta', 'LF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (388, 44, 'acto5_presponsable', 'LF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (361, 44, 'presponsable3_presponsable', 'LF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (334, 44, 'inclusion', 'LF');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (931, 44, 'etiqueta1_fecha', 'LG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (389, 44, 'acto5_categoria', 'LG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (362, 44, 'presponsable3_bloque', 'LG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (335, 44, 'acreditacion', 'LG');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (932, 44, 'etiqueta1_usuario', 'LH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (390, 44, 'acto5_persona', 'LH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (363, 44, 'presponsable3_frente', 'LH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (336, 44, 'retornado', 'LH');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (933, 44, 'etiqueta1_observaciones', 'LI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (391, 44, 'acto5_fecha', 'LI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (364, 44, 'presponsable3_brigada', 'LI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (337, 44, 'reubicado', 'LI');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (934, 44, 'etiqueta2_etiqueta', 'LJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (392, 44, 'acto5_desplazamiento', 'LJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (365, 44, 'presponsable3_batallon', 'LJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (319, 44, 'causaagrpais', 'LJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (338, 44, 'connacionalretorno', 'LJ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (935, 44, 'etiqueta2_fecha', 'LK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (910, 44, 'respuesta1_actividad', 'LK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (366, 44, 'presponsable3_division', 'LK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (339, 44, 'acompestado', 'LK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (310, 44, 'proteccion', 'LK');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (936, 44, 'etiqueta2_usuario', 'LL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (911, 44, 'respuesta1_fecha', 'LL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (367, 44, 'presponsable3_otro', 'LL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (340, 44, 'connacionaldeportado', 'LL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (318, 44, 'fechaNpi', 'LL');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (937, 44, 'etiqueta2_observaciones', 'LM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (912, 44, 'respuesta1_proyectofinanciero', 'LM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (368, 44, 'acto1_presponsable', 'LM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (341, 44, 'oficioantes', 'LM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (311, 44, 'autoridadrefugio', 'LM');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (938, 44, 'etiqueta3_etiqueta', 'LN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (913, 44, 'respuesta1_actividadpf', 'LN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (369, 44, 'acto1_categoria', 'LN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (342, 44, 'modalidadtierra', 'LN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (312, 44, 'salvoNpi', 'LN');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (939, 44, 'etiqueta3_fecha', 'LO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (914, 44, 'respuesta2_actividad', 'LO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (370, 44, 'acto1_persona', 'LO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (343, 44, 'materialesperdidos', 'LO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (313, 44, 'causaRefugio', 'LO');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (940, 44, 'etiqueta3_usuario', 'LP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (915, 44, 'respuesta2_fecha', 'LP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (371, 44, 'acto1_fecha', 'LP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (344, 44, 'inmaterialesperdidos', 'LP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (314, 44, 'tipoproteccion', 'LP');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (941, 44, 'etiqueta3_observaciones', 'LQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (916, 44, 'respuesta2_proyectofinanciero', 'LQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (372, 44, 'acto1_desplazamiento', 'LQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (345, 44, 'protegiorupta', 'LQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (315, 44, 'miembrofamiliar', 'LQ');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (942, 44, 'etiqueta4_etiqueta', 'LR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (917, 44, 'respuesta2_actividadpf', 'LR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (373, 44, 'acto2_presponsable', 'LR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (346, 44, 'documentostierra', 'LR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (316, 44, 'observacionesref', 'LR');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (943, 44, 'etiqueta4_fecha', 'LS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (918, 44, 'respuesta3_actividad', 'LS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (374, 44, 'acto2_categoria', 'LS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (347, 44, 'presponsable1_presponsable', 'LS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (320, 44, 'fechaexpulsion', 'LS');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (944, 44, 'etiqueta4_usuario', 'LT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (919, 44, 'respuesta3_fecha', 'LT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (375, 44, 'acto2_persona', 'LT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (348, 44, 'presponsable1_bloque', 'LT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (321, 44, 'expulsion', 'LT');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (945, 44, 'etiqueta4_observaciones', 'LU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (920, 44, 'respuesta3_proyectofinanciero', 'LU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (376, 44, 'acto2_fecha', 'LU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (349, 44, 'presponsable1_frente', 'LU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (322, 44, 'fechallegada', 'LU');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (946, 44, 'etiqueta5_etiqueta', 'LV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (921, 44, 'respuesta3_actividadpf', 'LV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (377, 44, 'acto2_desplazamiento', 'LV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (350, 44, 'presponsable1_brigada', 'LV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (323, 44, 'llegada', 'LV');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (947, 44, 'etiqueta5_fecha', 'LW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (922, 44, 'respuesta4_actividad', 'LW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (378, 44, 'acto3_presponsable', 'LW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (351, 44, 'presponsable1_batallon', 'LW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (324, 44, 'descripcion', 'LW');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (948, 44, 'etiqueta5_usuario', 'LX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (923, 44, 'respuesta4_fecha', 'LX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (379, 44, 'acto3_categoria', 'LX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (352, 44, 'presponsable1_division', 'LX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (325, 44, 'modalidadgeo', 'LX');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (949, 44, 'etiqueta5_observaciones', 'LY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (924, 44, 'respuesta4_proyectofinanciero', 'LY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (380, 44, 'acto3_persona', 'LY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (353, 44, 'presponsable1_otro', 'LY');
INSERT INTO public.heb412_gen_campoplantillahcm (id, plantillahcm_id, nombrecampo, columna) VALUES (326, 44, 'submodalidadgeo', 'LY');



INSERT INTO public.cor1440_gen_proyectofinanciero (id, nombre, observaciones, fechainicio, fechacierre, responsable_id, fechacreacion, fechadeshabilitacion, created_at, updated_at, compromisos, monto, sectorapc_id, titulo, poromision, fechaformulacion, fechaaprobacion, fechaliquidacion, estado, dificultad, tipomoneda_id, saldoaejecutarp, centrocosto, tasaej, montoej, aportepropioej, aporteotrosej, presupuestototalej) VALUES (10, 'PLAN ESTRATÉGICO 1', 'Para homologar tipos de actividad anterior a 2018 como actividades de este convenio', '2014-10-01', NULL, NULL, '2018-05-31', NULL, '2018-05-31 00:00:00', '2020-04-23 16:26:48.95047', 'Acompañar, servir y defender a la población en situación de refugio y desplazamiento', 1, NULL, 'PLAN ESTRATÉGICO 1', NULL, NULL, NULL, NULL, 'E', 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);


INSERT INTO public.cor1440_gen_objetivopf (id, proyectofinanciero_id, numero, objetivo) VALUES (15, 10, 'OG.', 'Acompañar, servir y defender a la población en situación de refugio y desplazamiento');
INSERT INTO public.cor1440_gen_objetivopf (id, proyectofinanciero_id, numero, objetivo) VALUES (90, 10, 'O1.', 'Acción humanitaria');
INSERT INTO public.cor1440_gen_objetivopf (id, proyectofinanciero_id, numero, objetivo) VALUES (91, 10, 'O2.', 'Integración local');


INSERT INTO public.cor1440_gen_resultadopf (id, proyectofinanciero_id, objetivopf_id, numero, resultado) VALUES (15, 10, 90, 'R1', 'Acompañamiento jurídico');
INSERT INTO public.cor1440_gen_resultadopf (id, proyectofinanciero_id, objetivopf_id, numero, resultado) VALUES (91, 10, 15, 'R4.', 'Incidencia y comunicaciones');
INSERT INTO public.cor1440_gen_resultadopf (id, proyectofinanciero_id, objetivopf_id, numero, resultado) VALUES (92, 10, 15, 'R5.', 'Gestión del conocimiento y M&E');
INSERT INTO public.cor1440_gen_resultadopf (id, proyectofinanciero_id, objetivopf_id, numero, resultado) VALUES (93, 10, 15, 'R6.', 'Sostebilidad económica');
INSERT INTO public.cor1440_gen_resultadopf (id, proyectofinanciero_id, objetivopf_id, numero, resultado) VALUES (94, 10, 15, 'R7.', 'Gestión contable, administrativa y financiera');
INSERT INTO public.cor1440_gen_resultadopf (id, proyectofinanciero_id, objetivopf_id, numero, resultado) VALUES (95, 10, 15, 'R8.', 'Gestión de la comunicación interna');
INSERT INTO public.cor1440_gen_resultadopf (id, proyectofinanciero_id, objetivopf_id, numero, resultado) VALUES (96, 10, 15, 'R9.', 'Gestión Humana');
INSERT INTO public.cor1440_gen_resultadopf (id, proyectofinanciero_id, objetivopf_id, numero, resultado) VALUES (89, 10, 90, 'R2.', 'Acompañamiento psicosocial');
INSERT INTO public.cor1440_gen_resultadopf (id, proyectofinanciero_id, objetivopf_id, numero, resultado) VALUES (90, 10, 90, 'R3.', 'Ayuda humanitaria');


INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (60, 10, 'ORGCAM', 'ORGANIZACIÓN DE CAMPAÑA', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (61, 10, 'MISHUM', 'MISIÓN HUMANITARIA', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (64, 10, 'SEGPRO', 'SEGUIMIENTO A PROYECTO', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (53, 10, 'PARREU', 'PARTICIPACIÓN EN REUNIÓN', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (55, 10, 'PREPON', 'PRESENTACIÓN DE PONENCIA EN EVENTO', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (56, 10, 'MON', 'MONITOREO, SUPERVISIÓN, EVALUACIÓN', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (57, 10, 'ORGEV', 'ORGANIZACIÓN DE EVENTO', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (58, 10, 'RESINF', 'RESPUESTA A SOLICITUD DE INFORMACIÓN', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (67, 10, 'ACCCOL', 'ACCIÓN COLECTIVA', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (152, 10, 'INFO', 'ELABORACIÓN DE INFORME/DOCUMENTO', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (155, 10, 'REPACO', 'EJERCICIO DE RÉPLICA / ACOMPAÑAMIENTO', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (151, 10, 'TALLER', 'TALLER / ENCUENTRO', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (157, 10, 'CONV', 'CONVERSATORIO', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (65, 10, 'MOV', 'MOVILIZACIÓN', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (69, 10, 'INFORI', 'INFORMACIÓN Y ORIENTACIÓN', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (158, 10, 'SISINF', 'SISTEMA DE INFORMACIÓN', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (159, 10, 'DIADIS', 'DIAGRAMACIÓN - DISEÑO DE PUBLICACIONES Y MATERIAL INSTITUCIONAL', 'COMUNICACIONES', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (162, 10, 'COMCAM', 'COMPONENTE COMUNICACIÓN DE CAMPAÑAS DE DIFUSIÓN, SENSIBILIZACIÓN Y DIVULGACIÓN', 'COMUNICACIONES', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (160, 10, 'ACOCOM', 'ACOMPAÑAMIENTO EN COMUNICACIÓN COMUNITARIA', 'COMUNICACIONES', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (161, 10, 'DISPRO', 'DISEÑO, PRODUCCIÓN Y DIFUSIÓN DE MATERIAL COMUNICATIVO E INFORMATIVO', 'COMUNICACIONES', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (163, 10, 'COMVIS', 'COMPONENTE DE COMUNICACIÓN A ACCIONES DE VISIBILIZACIÓN', 'COMUNICACIONES', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (66, 10, 'ATECAS', 'ATENCIÓN A CASO NUEVO', 'Deshabilitada por solicitud de Coordinadores, pues también existe esta clasificación en Subárea de Actividad', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (154, 10, 'ATEREC', 'ATENCIÓN A CASO POR RE-CONSULTA', 'Deshabilitada por solicitud de Coordinadores, pues también existe esta clasificación en Subárea de Actividad', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (68, 10, 'ATEJUR', 'ATENCIÓN JURÍDICA', 'Deshabilitada por solicitud de Coordinadores, pues también existe esta clasificación en Subárea de Actividad', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (59, 10, 'ACTCUL', 'ORGANIZACIÓN DE ACTIVIDAD COMUNITARIA, CULTURAL/ARTÍSTICA', '', 15, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (62, 10, 'SEGCAS', 'SEGUIMIENTO A CASO', '', 15, NULL, NULL, NULL, NULL); --formulario_id era 10
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (393, 10, 'Autocuidado', 'Reuniones mensuales de autocuidado', '', 96, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (45, 10, 'CAPSEM', 'ENTREGA DE CAPITAL SEMILLA', '', 90, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (118, 10, 'ASJUR', 'ASESORÍA JURÍDICA', '', 15, NULL, NULL, NULL, NULL);--formulario_id era 13
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (125, 10, 'ACJUR', 'ACCIÓN JURÍDICA', '', 15, NULL, NULL, NULL, NULL); --formulario_id era 14
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (126, 10, 'OTSERC', 'OTROS SERVICIOS Y ASESORÍAS PARA UN CASO', '', 15, NULL, NULL, NULL, NULL); --formulario_id era 15
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (116, 10, 'ASHUM', 'ASISTENCIA HUMANITARIA', '', 90, NULL, NULL, NULL, NULL); -- formulario_id era 11
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (70, 10, 'ATEPSI', 'ATENCIÓN PSICOSOCIAL', '', 89, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (51, 10, 'ORGFOR', 'ORGANIZACIÓN DE ACTIVIDAD DE FORMACIÓN/CAPACITACÍON', '', 90, NULL, NULL, NULL, NULL);
INSERT INTO public.cor1440_gen_actividadpf (id, proyectofinanciero_id, nombrecorto, titulo, descripcion, resultadopf_id, actividadtipo_id, indicadorgifmm_id, formulario_id, heredade_id) VALUES (156, 10, 'ASIPRO', 'ASISTENCIA/SEGUIMIENTO TÉCNICO A INICIATIVA PRODUCTIVA', 'RURAL O URBANA', 90, NULL, NULL, NULL, NULL);


-- Novedades a tablas basicas de sivel2_gen

      
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, pg_catalog;


INSERT INTO public.sivel2_gen_tviolencia (id, nombre, nomcorto, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES ('R', 'DERECHO INTERNACIONAL REFUGIO', 'REF', '2014-06-19', NULL, '2014-06-19 13:20:35.26809', '2014-06-19 13:20:35.26809');
INSERT INTO public.sivel2_gen_tviolencia (id, nombre, nomcorto, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES ('S', 'SJR', 'SJR', '2013-06-25', NULL, NULL, NULL);

INSERT INTO public.sivel2_gen_supracategoria (codigo, id, nombre, fechacreacion, fechadeshabilitacion, tviolencia_id, created_at, updated_at) VALUES (100,100, 'SJR', '2013-06-25', NULL, 'S', NULL, NULL);
INSERT INTO public.sivel2_gen_supracategoria (codigo, id, nombre, fechacreacion, fechadeshabilitacion, tviolencia_id, created_at, updated_at) VALUES (200, 200, 'CONVENCIÓN 1951', '2014-06-19', NULL, 'R', '2014-06-19 13:21:34.529277', '2014-06-19 13:21:34.529277');
INSERT INTO public.sivel2_gen_supracategoria (codigo, id, nombre, fechacreacion, fechadeshabilitacion, tviolencia_id, created_at, updated_at) VALUES (201, 201, 'DECLARACIÓN DE CARTAGENA', '2014-06-19', NULL, 'R', '2014-06-19 13:22:02.263703', '2014-06-19 13:22:02.263703');
INSERT INTO public.sivel2_gen_supracategoria (codigo, id, nombre, fechacreacion, fechadeshabilitacion, tviolencia_id, created_at, updated_at) VALUES (202, 202, 'PACTO DE SAN JOSÉ', '2014-06-19', NULL, 'R', '2014-06-19 13:22:21.815264', '2014-06-19 13:22:21.815264');
INSERT INTO public.sivel2_gen_supracategoria (codigo, id, nombre, fechacreacion, fechadeshabilitacion, tviolencia_id, created_at, updated_at) VALUES (203, 203, 'ACNUR', '2014-06-19', NULL, 'R', '2014-06-19 13:22:39.94622', '2014-06-19 13:22:39.94622');

INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10002, 'AMENAZAS INDIRECTAS', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10003, 'AMETRALLAMIENTOS/BOMBARDEO', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10006, 'CAMPOS MINADOS/MUNICIONES SIN DETONAR', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10007, 'CONFRONTACIONES POR ACTORES ARMADOS', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10011, 'ERRADICACIÓN Y FUMIGACIONES', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10013, 'PRESENCIA GUERRILLERA', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10014, 'PARAMILITARIZACIÓN', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10015, 'MILITARIZACIÓN', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10017, 'MEGAPROYECTO DE MINERÍA', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10018, 'MEGAPROYECTO DE PALMA', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10019, 'MEGAPROYECTO DE PUERTOS', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10020, 'ORIENTACIÓN SEXUAL', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10021, 'RECLUTAMIENTO Y VINCULACIÓN DE NNAJ', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10022, 'POR PERTENECER A UN GRUPO SOCIAL', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10025, 'CONFINAMIENTO', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (10026, 'TEMOR FUNDADO', '2013-06-25', NULL, 100, NULL, NULL, 'I', NULL, NULL);

INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2000, 'RAZA', '2014-06-19', NULL, 200, NULL, NULL, 'I', '2014-06-19 13:24:33.302509', '2014-06-19 13:24:33.302509');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2001, 'RELIGIÓN', '2014-06-19', NULL, 200, NULL, NULL, 'I', '2014-06-19 13:25:07.240997', '2014-06-19 13:25:07.240997');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2002, 'NACIONALIDAD', '2014-06-19', NULL, 200, NULL, NULL, 'I', '2014-06-19 13:25:45.892889', '2014-06-19 13:25:45.892889');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2003, 'PERTENENCIA A GRUPO SOCIAL', '2014-06-19', NULL, 200, NULL, NULL, 'I', '2014-06-19 13:27:12.030191', '2014-06-19 13:27:12.030191');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2004, 'OPINIÓN POLÍTICA', '2014-06-19', NULL, 200, NULL, NULL, 'I', '2014-06-19 13:27:36.467502', '2014-06-19 13:27:36.467502');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2010, 'VIOLENCIA GENERALIZADA', '2014-06-19', NULL, 201, NULL, NULL, 'I', '2014-06-19 13:28:32.228075', '2014-06-19 13:28:32.228075');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2011, 'DESASTRES NATURALES', '2014-06-19', NULL, 201, NULL, NULL, 'I', '2014-06-19 13:29:04.757464', '2014-06-19 13:29:04.757464');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2012, 'AGRESIÓN EXTRANJERA', '2014-06-19', NULL, 201, NULL, NULL, 'I', '2014-06-19 13:29:43.926042', '2014-06-19 13:29:43.926042');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2013, 'CONFLICTOS INTERNOS', '2014-06-19', NULL, 201, NULL, NULL, 'I', '2014-06-19 13:30:15.105941', '2014-06-19 13:30:15.105941');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2014, 'VIOLACIÓN MASIVA DE DERECHOS HUMANOS', '2014-06-19', NULL, 201, NULL, NULL, 'I', '2014-06-19 13:30:42.503981', '2014-06-19 13:30:42.503981');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2015, 'CIRCUNSTANCIAS QUE HAYAN PERTURBADO GRAVEMENTE EL ORDEN PÚBLICO', '2014-06-19', NULL, 201, NULL, NULL, 'I', '2014-06-19 13:31:13.421844', '2014-06-19 13:31:13.421844');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2020, 'GENERO', '2014-06-19', NULL, 202, NULL, NULL, 'I', '2014-06-19 13:32:21.608943', '2014-06-19 13:33:36.90906');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2021, 'CAUSAS ECONÓMICAS', '2014-06-19', NULL, 202, NULL, NULL, 'I', '2014-06-19 13:32:52.432009', '2014-06-19 13:33:27.82717');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2022, 'GRUPOS ÉTNICOS', '2014-06-19', NULL, 202, NULL, NULL, 'I', '2014-06-19 13:33:15.710791', '2014-06-19 13:33:15.710791');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2030, 'PERSECUCIÓN', '2014-06-19', NULL, 203, NULL, NULL, 'I', '2014-06-19 13:34:24.889437', '2014-06-19 13:34:24.889437');
INSERT INTO public.sivel2_gen_categoria (id, nombre, fechacreacion, fechadeshabilitacion, supracategoria_id, pconsolidado_id, contadaen, tipocat, created_at, updated_at) VALUES (2031, 'ORIENTACIÓN SEXUAL', '2014-06-19', NULL, 203, NULL, NULL, 'I', '2014-06-19 13:34:58.178604', '2014-06-19 13:34:58.178604');

INSERT INTO public.msip_etiqueta (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (11, 'COMPARTIR CON SJR COLOMBIA', '', '2001-01-01', NULL, NULL, NULL);
INSERT INTO public.msip_etiqueta (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (12, 'COMPARTIR CON SJR LATINOAMÉRICA', '', '2001-01-01', NULL, NULL, NULL);
INSERT INTO public.msip_etiqueta (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (13, 'COMPARTIR CON BANCO DE DATOS CINEP COLOMBIA', '', '2001-01-01', NULL, NULL, NULL);



---- Provenientes de sivel2_sjr


-- Volcado de tablas basicas

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_acreditacion; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_acreditacion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_acreditacion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'CARTA', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_acreditacion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'DESPRENDIBLE', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_acreditacion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'CÓDIGO', '2013-05-24', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_clasifdesp; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_clasifdesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_clasifdesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'INTER-MUNICIPAL', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_clasifdesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'INTRA-URBANO', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_clasifdesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'INTER-VEREDAL', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_clasifdesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (6, 'URBANO', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_clasifdesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (7, 'TRANSFRONTERIZO', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_clasifdesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (8, 'INTERDEPARTAMENTAL', '2013-05-24', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_declaroante; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_declaroante (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_declaroante (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'PERSONERIA MUNICIPAL', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_declaroante (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'DEFENSORIA REGIONAL', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_declaroante (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'ROCURADURIA REGIONAL', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_declaroante (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'PROCURADURIA PROVINCIAL ', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_declaroante (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'OTRO', '2013-05-24', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_inclusion; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_inclusion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_inclusion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'SIN RESPUESTA', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_inclusion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'INCLUIDO', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_inclusion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'NO INCLUIDO', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_inclusion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'EN VALORACIÓN', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_inclusion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'EXCLUIDO', '2013-05-24', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_modalidadtierra; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_modalidadtierra (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_modalidadtierra (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'TENEDOR', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_modalidadtierra (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'COLONO', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_modalidadtierra (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'NO DEJÓ', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_modalidadtierra (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'POSEEDOR', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_modalidadtierra (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'PROPIETARIO', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_modalidadtierra (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (6, 'RESGUARDO', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_modalidadtierra (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (7, 'CONSEJO COMUNITARIO', '2013-05-24', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_tipodesp; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_tipodesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_tipodesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'GOTA A GOTA', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_tipodesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'MASIVO', '2013-05-24', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_tipodesp (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'FAMILIAR', '2013-05-24', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_personadesea; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_personadesea (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_personadesea (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'PERMANECER', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_personadesea (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'REUBICARSE', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_personadesea (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'RETORNAR', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_personadesea (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'SALIR DEL  PAÍS', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_personadesea (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'REGRESAR AL PAÌS', '2013-06-17', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_ayudaestado; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_ayudaestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_ayudaestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'ALIMENTACIÓN', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_ayudaestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'ALOJAMIENTO', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_ayudaestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'APOYO A PROYECTO PRODUCTIVO', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_ayudaestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'ATENCIÓN PSICOLÓGICA O PSICOSOCIAL', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_ayudaestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'DOCUMENTACIÓN', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_ayudaestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (6, 'AYUDAS ECONÓMICAS', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_ayudaestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (7, 'KIT HÁBITAT', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_ayudaestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (8, 'SALUD', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_ayudaestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (9, 'VESTUARIO', '2013-06-16', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_derecho; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'DERECHO A LA INTEGRIDAD PERSONAL', '2013-06-12', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (10, 'DERECHO A LA VERDAD, A A LA JUSTCIA Y A LA REPARACIÓN  ', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (11, 'DERECHO A LA ALIMENTACIÓN', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (12, 'DERECHO A LA IDENTIDAD', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (13, 'DERECHO AL TRABAJO', '2013-06-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'DERECHO A LA IGUALDAD Y A LA NO DISCRIMINACIÓN', '2013-06-12', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'DERECHO A LA LIBERTAD', '2013-06-12', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'DERECHO A LA LIBRE CIRCULACIÓN Y RESIDENCIA', '2013-06-12', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'DERECHO A LA LIBRE OPINIÓN Y A LA EXPRESIÓN', '2013-06-12', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (6, 'DERECHO A LA SALUD', '2013-06-12', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (7, 'DERECHO A LA EDUCACIÓN', '2013-06-12', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (8, 'DERECHO A LA VIVIENDA', '2013-06-12', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_derecho (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (9, 'N/A  ', '2013-06-12', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_progestado; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_progestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_progestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'EN ACCIÓN', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_progestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'RED JUNTOS', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_progestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'VIVIENDA', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_progestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'TERCERA EDAD', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_progestado (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'OTROS ¿CUÁL?', '2013-06-17', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_motivosjr; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (11, 'ASESORÍA PARA EL INGRESO EN PROGRAMAS DE EDUCACIÓN', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (12, 'ASESORÍA PARA EL INGRESO EN PROGRAMAS DE VIVIENDA', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (13, 'ASESORÍA PARA EL INGRESO AL SISTEMA DE LEY DE VÍCTIMAS', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (14, 'INFORMACIÓN SOBRE LEY DE VÍCTIMAS', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (15, 'ASESORÍA SOSBRE PROGRAMA DE GENERACIÓN DE INGRESOS', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (16, 'SOLICITUD DE PROTECCIÓN', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (17, 'ACOMPAÑAMIENTO PSICOSOCIAL / APOYO PSICOLÓGICO', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (18, 'APOYO Y/ O SOLICITUD DE INFORMACIÓN PARA REFUGIO', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (19, 'TRÁMITE DE DOCUMENTACIÓN', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (20, 'VERIFICACIÓN', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_motivosjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (21, 'ASESORÍA JURÍDICA', '2013-06-17', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_aslegal; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2014-02-14', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'RENUNCIA AL PROCEDIMIENTO DE SOLICITUD DE REFUGIO: TIPO Y MOTIVOS', '2014-02-14', NULL, NULL, '2014-08-04 14:29:09.190492', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (10, 'ASESORÍA SOBRE TRÁMITES DE NATURALIZACIÓN', '2014-02-14', NULL, NULL, '2014-08-04 14:27:04.064535', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (11, 'APERTURA EXPEDIENTE SOLICITUD DE REFUGIO', '2014-02-14', NULL, NULL, '2014-08-04 14:26:02.056113', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (12, 'INFORMACIÓN DERECHOS, DEBERES Y CONDICIÓN PROCEDIMIENTO DE REFUGIO', '2014-02-14', NULL, NULL, '2014-08-04 14:28:13.313206', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (13, 'GESTIONES PARA TRÁMITES DE DOCUMENTACIÓN ANTE CNR Y SAIME', '2014-02-14', NULL, NULL, '2014-08-04 14:27:31.736931', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (14, 'PERMISO DE TRABAJO', '2014-02-14', NULL, NULL, '2014-08-04 14:28:40.275613', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (16, 'ACCIONES DE EXIGIBILIDAD DE DERECHOS ANTE CUALQUIER ORGANISMO', '2014-02-14', NULL, NULL, '2014-08-04 14:25:38.610317', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (17, 'TRATA Y TRÁFICO', '2014-02-14', NULL, NULL, '2014-08-04 14:29:54.891343', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'ASESORÍA DECISIÓN REFUGIO NEGATIVA', '2014-02-14', NULL, NULL, '2014-08-04 14:26:26.746522', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'CAMBIO DE DOMICILIO PERMANENTE', '2014-02-14', NULL, NULL, '2014-08-04 14:27:19.07573', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'NOTIFICACIONES DE TRASLADO TEMPORAL', '2014-02-14', NULL, NULL, '2014-08-04 14:28:24.132981', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (6, 'REMISIÓN DE CASOS', '2014-02-14', NULL, NULL, '2014-08-04 14:29:41.030037', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (7, 'ASESORÍA DECISIÓN REFUGIO POSITIVA', '2014-02-14', NULL, NULL, '2014-08-04 14:26:47.864887', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (8, 'REDACCIÓN RECURSO DE RECONSIDERACIÓN', '2014-02-14', NULL, NULL, '2014-08-04 14:29:27.012877', NULL);
INSERT INTO public.sivel2_sjr_aslegal (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (9, 'GESTIÓN DE OTROS TRÁMITES LEGALES VARIOS', '2014-02-14', NULL, NULL, '2014-08-04 14:28:00.09363', NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_ayudasjr; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-06-17', NULL, NULL, '2014-08-04 14:21:44.383232', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'PAGO DE HOSPEDAJE', '2013-06-17', NULL, NULL, '2014-08-04 14:21:44.383232', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (10, 'OTROS ¿CUÁL(ES)?', '2013-06-17', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (102, 'ENTREGA DE ÚTILES ESCOLARES', '2014-07-01', NULL, '2014-07-01 15:27:43.631626', '2014-08-04 14:19:42.62921', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (103, 'ENTREGA DE UNIFORMES ESCOLARES', '2014-07-01', NULL, '2014-07-01 15:27:59.911423', '2014-08-04 14:19:07.049705', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (104, 'PAGO INSCRIPCIÓN EN PLANTEL EDUCATIVO', '2014-07-01', NULL, '2014-07-01 15:28:42.197196', '2014-08-04 14:21:04.024083', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (105, 'PAGO APOSTILLADO DE NOTAS', '2014-07-01', NULL, '2014-07-01 15:28:55.999941', '2014-08-04 14:20:45.72678', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (106, 'ENTREGA DE MEDICINAS', '2014-07-01', NULL, '2014-07-01 15:29:08.956856', '2014-08-04 14:19:18.988686', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (107, 'EXÁMENES MÉDICOS', '2014-07-01', NULL, '2014-07-01 15:29:40.038096', '2014-08-04 14:20:03.712523', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (108, 'PAGO DE CONSULTAS MÉDICAS', '2014-07-01', NULL, '2014-07-01 15:29:51.357703', '2014-08-04 14:21:29.28461', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (109, 'PAGO DE CIRUGÍAS', '2014-07-01', NULL, '2014-07-01 15:30:07.515231', '2014-08-04 14:21:16.523225', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (110, 'TRASLADO POR SALUD', '2014-07-01', NULL, '2014-07-01 15:31:12.113929', '2014-08-04 14:23:42.559446', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (111, 'TRASLADO A LA CNR NACIONAL', '2014-07-01', NULL, '2014-07-01 15:33:37.101959', '2014-08-04 14:22:25.983894', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (112, 'TRASLADO POR CONDICIONES DE SEGURIDAD', '2014-07-01', NULL, '2014-07-01 15:35:01.239923', '2014-08-04 14:23:07.502688', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (113, 'TRASLADO POR REUBICACIÓN', '2014-07-01', NULL, '2014-07-01 15:35:24.569466', '2014-08-04 14:23:19.752371', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'TRASLADO A OTRA INSTANCIA PÚBLICA', '2013-06-17', NULL, NULL, '2014-08-04 14:22:53.842404', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'KIT DE HIGIENE', '2013-06-17', NULL, NULL, '2014-08-04 14:20:14.474407', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'KIT DE INSTALACIÓN DE HOGAR', '2013-06-17', NULL, NULL, '2014-08-04 14:20:30.727496', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'KIT DE ALIMENTACIÓN', '2013-06-17', NULL, NULL, '2014-08-04 14:23:58.632278', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (6, 'PAGO DE DOCUMENTOS (PASAPORTE Y OTROS)', '2013-06-17', NULL, NULL, '2014-08-04 14:22:01.510619', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (7, 'SERVICIO DE COMIDAS', '2013-06-17', NULL, NULL, '2014-08-04 14:22:12.664614', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (8, 'ENTREGA DE DINERO', '2013-06-17', NULL, NULL, '2014-08-04 14:19:29.612823', NULL);
INSERT INTO public.sivel2_sjr_ayudasjr (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (9, 'TRASLADO A LA CNR LOCAL', '2013-06-17', NULL, NULL, '2014-08-04 14:22:41.281503', NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_comosupo; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (1, 'SIN INFORMACIÓN', NULL, '2014-08-04', NULL, '2014-08-04 19:53:39.287255', '2014-08-04 19:53:39.287255');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (10, 'REDES COMUNITARIAS O VECINALES', NULL, '2014-08-04', NULL, '2014-08-04 19:58:00.813473', '2014-08-04 19:58:00.813473');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (11, 'RADIO', NULL, '2014-08-04', NULL, '2014-08-04 19:58:18.1238', '2014-08-04 19:58:18.1238');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (12, 'INSTITUCIONES EDUCATIVAS', NULL, '2014-08-04', NULL, '2014-08-04 19:58:46.06298', '2014-08-04 19:58:46.06298');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (13, 'REMISIÓN DE LA CNR', NULL, '2014-08-04', NULL, '2014-08-04 19:59:03.341518', '2014-08-04 19:59:03.341518');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (14, 'CONTACTO DIRECTO.', NULL, '2014-08-04', NULL, '2014-08-04 19:59:23.737069', '2014-08-04 19:59:23.737069');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (2, 'ONG', NULL, '2014-08-04', NULL, '2014-08-04 19:53:54.781026', '2014-08-04 19:54:13.259093');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (3, 'PAGINA DE INTERNET DEL SJR U OTRAS REDES SOCIALES', NULL, '2014-08-04', NULL, '2014-08-04 19:55:21.719879', '2014-08-04 19:55:21.719879');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (4, 'OTRAS AGENCIAS HUMANITARIAS', NULL, '2014-08-04', NULL, '2014-08-04 19:55:41.977827', '2014-08-04 19:55:41.977827');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (5, 'IGLESIA – AGENTE PARROQUIAL', NULL, '2014-08-04', NULL, '2014-08-04 19:56:02.298318', '2014-08-04 19:56:02.298318');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (6, 'OTROS SOLICITANTES O DESPLAZADOS', NULL, '2014-08-04', NULL, '2014-08-04 19:56:34.93592', '2014-08-04 19:56:34.93592');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (7, 'COMUNIDAD DE ACOGIDA', NULL, '2014-08-04', NULL, '2014-08-04 19:56:52.496091', '2014-08-04 19:56:52.496091');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (8, 'CONSEJO COMUNAL', NULL, '2014-08-04', NULL, '2014-08-04 19:57:11.1354', '2014-08-04 19:57:11.1354');
INSERT INTO public.sivel2_sjr_comosupo (id, nombre, observaciones, fechacreacion, fechadeshabilitacion, created_at, updated_at) VALUES (9, 'FAMILIARES O AMIGOS', NULL, '2014-08-04', NULL, '2014-08-04 19:57:33.115672', '2014-08-04 19:57:33.115672');


--
-- Name: sivel2_sjr_comosupo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('sivel2_sjr_comosupo_id_seq', 100, true);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_idioma; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2014-02-18', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'ESPAÑOL', '2014-02-18', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (10, 'OTRO', '2014-02-18', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'INGLÉS', '2014-02-18', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'FRANCÉS', '2014-02-18', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'ARABE', '2014-02-18', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'ALEMÁN', '2014-02-18', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (6, 'PORTUGUES', '2014-02-18', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (7, 'JAPONES', '2014-02-18', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (8, 'CHINO', '2014-02-18', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_idioma (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (9, 'AFRIKAN', '2014-02-18', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_proteccion; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'SOLICITANTE DE REFUGIO', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'PROTECCIÓN TEMPORAL HUMANITARIA', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'TRATA Y TRÁFICO', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'NO RECONOCIDOS', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'NO ESPECÍFICA', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (6, 'PERSONA CON NECESIDAD DE PROTECCIÓN TEMPORAL', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (7, 'OTRO', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_proteccion (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (8, 'PERSONA EN SITUACIÓN DE REFUGIO', '2014-03-10', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_rolfamilia; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2013-06-20', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'PADRE - MADRE', '2013-06-20', NULL, NULL, '2014-08-04 14:06:23.593142', NULL);
INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (101, 'PADRASTRO - MADRASTRA', '2014-07-01', NULL, '2014-07-01 16:17:33.798486', '2014-07-01 16:17:33.798486', NULL);
INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (102, 'YERNO - NUERA', '2014-07-26', NULL, '2014-07-27 00:50:19.492556', '2014-08-04 14:06:38.788713', NULL);
INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (103, 'CUÑADO(A)', '2014-07-26', NULL, '2014-07-27 00:50:31.271452', '2014-08-04 14:07:05.805427', NULL);
INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (3, 'HIJO(A)', '2013-06-20', NULL, NULL, '2014-08-04 14:07:14.804963', NULL);
INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'OTRO', '2013-06-20', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'ABUELO(A)', '2013-07-05', NULL, NULL, '2014-08-04 14:06:54.968667', NULL);
INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (6, 'TIO(A)', '2013-07-05', NULL, NULL, '2014-08-04 14:07:44.084696', NULL);
INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (7, 'SOBRINO(A)', '2014-03-07', NULL, NULL, '2014-08-04 14:07:34.806731', NULL);
INSERT INTO public.sivel2_sjr_rolfamilia (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (8, 'PRIMO(A)', '2014-03-07', NULL, NULL, '2014-08-04 14:07:26.504936', NULL);


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Data for Name: sivel2_sjr_statusmigratorio; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sivel2_sjr_statusmigratorio (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (0, 'SIN INFORMACIÓN', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_statusmigratorio (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (1, 'MIGRANTE', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_statusmigratorio (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (2, 'REFUGIADO', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_statusmigratorio (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (4, 'APÁTRIDA', '2014-02-16', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_statusmigratorio (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (5, 'NACIONAL POR NACIMIENTO', '2014-03-10', NULL, NULL, NULL, NULL);
INSERT INTO public.sivel2_sjr_statusmigratorio (id, nombre, fechacreacion, fechadeshabilitacion, created_at, updated_at, observaciones) VALUES (6, 'NACIONAL POR NATURALIZACIÓN', '2014-03-10', NULL, NULL, NULL, NULL);


--
-- PostgreSQL database dump complete
--

