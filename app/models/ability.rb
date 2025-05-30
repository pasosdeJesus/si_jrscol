# frozen_string_literal: true

# Permisos
class Ability < Sivel2Gen::Ability
  ROLADMIN  = 1
  ROLINV    = 2
  ROLDIR    = 3
  ROLCOOR   = 4
  ROLANALI  = 5
  ROLSIST   = 6
  ROLANALIPRENSA = 7
  ROLOFICIALPF = 8
  ROLGESTIONHUMANA = 9
  ROLLECTURA = 10

  ROLES = [
    ["Administrador", ROLADMIN],
    ["Invitado Nacional", ROLINV],
    ["Director Nacional", ROLDIR],
    ["Coordinador territorial", ROLCOOR],
    ["Analista", ROLANALI],
    ["Sistematizador", ROLSIST],
    ["Analista de Prensa", ROLANALIPRENSA],
    ["Oficial de Proyectos", ROLOFICIALPF],
    ["Gestión Humana", ROLGESTIONHUMANA],
    ["Solo lectura", ROLLECTURA],
  ]

  ROLES_CA = [
    "Realizar conteos de casos. " +
      "Admministrar casos de todas las territoriales. " +
      "Administrar actividades de todas las territoriales. " +
      "Administrar usuarios. " +
      "Administrar documentos en nube. " +
      "Administrar tablas básicas. ", # ROLADMIN

    "Realizar conteos de casos. " +
      "Buscar casos y ver casos con etiqueta de compartidos. ", # ROLINV

    "Realizar conteos de casos. " +
      "Admministrar casos de todas las territoriales. " +
      "Administrar actividades de todas las territoriales. " +
      "Administrar usuarios. " +
      "Administrar documentos en nube. " +
      "Administrar tablas básicas. ", # ROLDIR

    "Realizar conteos de casos. " +
      "Ver casos de todas las territoriales, crear casos, editar los de su territorial y poner etiquetas de compartir. " +
      "Ver actividades e informes de actividades de todas las territoriales y editar los de su territorial. " +
      "Ver documentos en nube. ", # ROLCOOR

    "Realizar conteos de casos. " +
      "Ver casos de todas las territoriales, crear casos y editar los de su territorial. " +
      "Ver actividades e informes de actividades de todas las territoriales y editar los de su territorial. " +
      "Ver documentos en nube. ", # ROLANALI

    "Realizar conteos de casos. " +
      "Ver casos de todas las territoriales, crear casos y editar sólo sus casos. " +
      "Ver actividades e informes de actividades de todas las territoriales y editar los de su territorial. " +
      "Ver documentos en nube. ", # ROLSIST

    "Realizar conteos de casos. " +
      "Ver actividades e informes de actividades de todas las territoriales y editar los de su territorial. " +
      "Ver documentos en nube. ", # ROLANALIPRENSA

    "Editar casos de todas las territoriales. " +
      "Editar actividades de todas las territoriales y editar cualquier proyecto. " +
      "Editar cualquier beneficiario. " +
      "Ver documentos en nube. ", # ROLOFICIALPF
    "Administrar usuarios. " +
      "Ver todas las actividades y proyectos. " +
      "Ver beneficiarios. " +
      "Ver documentos en nube. ", # ROLGESTIONHUMANA
    "Ver casos, actividades, proyectos y beneficiarios, " +
      "todos los reportes de estos y " +
      "descargar anexos pero no escribir ", # ROLLECTURA
  ]

  BASICAS_PROPIAS = [
    ["Sivel2Sjr", "accionjuridica"],
    ["Sivel2Sjr", "acreditacion"],
    ["Sivel2Sjr", "aslegal"],
    ["Sivel2Sjr", "aspsicosocial"],
    ["Sivel2Sjr", "ayudaestado"],
    ["Sivel2Sjr", "ayudasjr"],
    ["Sivel2Sjr", "clasifdesp"],
    ["Sivel2Sjr", "comosupo"],
    ["Sivel2Sjr", "declaroante"],
    ["Sivel2Sjr", "derecho"],
    ["Sivel2Sjr", "idioma"],
    ["Sivel2Sjr", "inclusion"],
    ["Sivel2Sjr", "modalidadtierra"],
    ["Sivel2Sjr", "motivosjr"],
    ["Sivel2Sjr", "personadesea"],
    ["Sivel2Sjr", "proteccion"],
    ["Sivel2Sjr", "progestado"],
    ["Sivel2Sjr", "regimensalud"],
    ["Sivel2Sjr", "rolfamilia"],
    ["Sivel2Sjr", "statusmigratorio"],
    ["Sivel2Sjr", "tipodesp"],
    ["Msip", "lineaorgsocial"],
    ["Msip", "tipoanexo"],
    ["Msip", "tipoorgsocial"],
    ["", "agresionmigracion"],
    ["", "autoridadrefugio"],
    ["", "causaagresion"],
    ["", "causamigracion"],
    ["", "depgifmm"],
    ["", "declaracionruv"],
    ["", "dificultadmigracion"],
    ["", "discapacidad"],
    ["", "espaciopart"],
    ["", "indicadorgifmm"],
    ["", "frecuenciaentrega"],
    ["", "mecanismodeentrega"],
    ["", "miembrofamiliar"],
    ["", "migracontactopre"],
    ["", "modalidadentrega"],
    ["", "mungifmm"],
    ["", "perfilmigracion"],
    ["", "sectorgifmm"],
    ["", "territorial"],
    ["", "tipoproteccion"],
    ["", "tipotransferencia"],
    ["", "trivalentepositiva"],
    ["", "unidadayuda"],
    ["", "viadeingreso"],
  ]

  def tablasbasicas
    Msip::Ability::BASICAS_PROPIAS +
      Cor1440Gen::Ability::BASICAS_PROPIAS +
      Sivel2Gen::Ability::BASICAS_PROPIAS +
      BASICAS_PROPIAS - [
        ["Msip", "grupo"],
        ["Sivel2Gen", "filiacion"],
        ["Sivel2Gen", "frontera"],
        ["Sivel2Gen", "iglesia"],
        ["Sivel2Gen", "intervalo"],
        ["Sivel2Gen", "organizacion"],
        ["Sivel2Gen", "pconsolidado"],
        ["Sivel2Gen", "region"],
        ["Sivel2Gen", "sectorsocial"],
        ["Sivel2Gen", "vinculoestado"],
        ["Sivel2Sjr", "idioma"],
        ["Sivel2Sjr", "clasifdesps"],
      ]
  end

  def basicas_id_noauto
    Msip::Ability::BASICAS_ID_NOAUTO +
      Sivel2Gen::Ability::BASICAS_ID_NOAUTO +
      Cor1440Gen::Ability::BASICAS_ID_NOAUTO
  end

  def nobasicas_indice_seq_con_id
    Msip::Ability::NOBASICAS_INDSEQID +
      Sivel2Gen::Ability::NOBASICAS_INDSEQID +
      Cor1440Gen::Ability::NOBASICAS_INDSEQID
  end

  def tablasbasicas_prio
    Msip::Ability::BASICAS_PRIO +
      Sivel2Gen::Ability::BASICAS_PRIO +
      [
        ["Sivel2Sjr", "regimensalud"],
        ["Sivel2Sjr", "acreditacion"],
        ["Sivel2Sjr", "clasifdesp"],
        ["Sivel2Sjr", "declaroante"],
        ["Sivel2Sjr", "inclusion"],
        ["Sivel2Sjr", "modalidadtierra"],
        ["Sivel2Sjr", "tipodesp"],
        ["Sivel2Sjr", "personadesea"],
        ["Sivel2Sjr", "ayudaestado"],
        ["Sivel2Sjr", "derecho"],
        ["Sivel2Sjr", "progestado"],
        ["Sivel2Sjr", "motivosjr"],
        ["", "sectorgifmm"],
      ]
  end

  if !ActiveRecord::Base.connection.data_source_exists?(
    "sivel2_gen_consexpcaso",
  ) &&
      ActiveRecord::Base.connection.data_source_exists?("sivel2_gen_caso") &&
      (!Rake || !defined?(Rake.application) || !Rake.application.top_level_tasks == ["db:migrate"])
    Sivel2Gen::Consexpcaso.crea_consexpcaso(nil)
  end

  # CAMPOS PARA EXPORTAR DESDE CASOS

  PREFIJOS_PERSONAS_CAMPOS = [
    "contacto",
    "familiar1",
    "familiar2",
    "familiar3",
    "familiar4",
    "familiar5",
  ]

  CAMPOS_PERSONAVIC = [
    "nombres",
    "actividadoficio",
    "actualtrabajando",
    "apellidos",
    "asisteescuela",
    "anionac",
    "cabezafamilia",
    "dianac",
    "discapacidad",
    "edad_fecha_recepcion",
    "edad_ultimaatencion",
    "estadocivil",
    "escolaridad",
    "filiacion",
    "identificacion",
    "pais",
    "departamento",
    "municipio",
    "centropoblado",
    "mesnac",
    "maternidad",
    "numeroanexos",
    "numeroanexosconsen",
    "numerodocumento",
    "organizacion",
    "profesion",
    "regimensalud",
    "sexo",
    "etnia",
    "orientacionsexual",
    "rolfamilia",
    "tdocumento",
    "tienesisben",
    "vinculoestado",
  ]

  PREFIJOS_UBICACIONES_CAMPOS = ["ubicacion1", "ubicacion2", "ubicacion3"]

  CAMPOS_UBICACIONES = [
    "pais",
    "departamento",
    "municipio",
    "centropoblado",
    "longitud",
    "latitud",
    "lugar",
    "sitio",
    "tsitio",
  ]

  CAMPOS_MIGRA_SIMPLES = [
    "fechasalida",
    "fechallegada",
    "ubifamilia",
    "valor_pago",
    "concepto_pago",
    "actor_pago",
    "perpetradoresagresion",
    "perpeagresenpais",
    "observacionesref",
    "fechaNpi",
    "salvoNpi",
    "tiempoenpais",
  ]
  CAMPOS_MIGRA_RELA = [
    "salida_pais",
    "salida_departamento",
    "salida_municipio",
    "salida_centropoblado",
    "llegada_pais",
    "llegada_departamento",
    "llegada_municipio",
    "llegada_centropoblado",
    "viadeingreso",
    "causamigracion",
    "pagoingreso",
    "perfilmigracion",
    "migracontactopre",
    "estatus_migratorio",
    "proteccion",
    "autoridadrefugio",
    "causaRefugio",
    "miembrofamiliar",
    "tipoproteccion",
  ]
  CAMPOS_MIGRA_MULTI = [
    "dificultadmigracion",
    "agresionmigracion",
    "causaagresion",
    "agresionenpais",
    "causaagrpais",
  ]
  CAMPOS_DESPLAZA_SIMPLES = [
    "fechaexpulsion",
    "fechallegada",
    "descripcion",
    "otrosdatos",
    "declaro",
    "hechosdeclarados",
    "fechadeclaracion",
    "oficioantes",
    "materialesperdidos",
    "inmaterialesperdidos",
    "documentostierra",
  ]
  CAMPOS_DESPLAZA_RELA = [
    "clasifdesp",
    "tipodesp",
    "declaroante",
    "inclusion",
    "acreditacion",
    "modalidadtierra",
  ]
  CAMPOS_DESPLAZA_MULTI = [
    "categoria",
  ]
  CAMPOS_DESPLAZA_ESPECIALES = [
    "expulsion",
    "llegada",
    "modalidadgeo",
    "submodalidadgeo",
  ]
  CAMPOS_DESPLAZA_BOOL = [
    "retornado",
    "reubicado",
    "connacionalretorno",
    "acompestado",
    "connacionaldeportado",
    "protegiorupta",
  ]

  PREFIJOS_PRESPONSABLES_CAMPOS = [
    "presponsable1",
    "presponsable2",
    "presponsable3",
  ]
  CAMPOS_CASOPRESPONSABLES = [
    "presponsable",
    "tipo",
    "bloque",
    "frente",
    "brigada",
    "batallon",
    "division",
    "otro",
  ]

  PREFIJOS_ACTOS_CAMPOS = ["acto1", "acto2", "acto3", "acto4", "acto5"]

  CAMPOS_ACTOS = [
    "presponsable",
    "categoria",
    "persona",
    "fecha",
    "desplazamiento",
  ]

  PREFIJOS_RESPUESTAS_CAMPOS = [
    "respuesta1",
    "respuesta2",
    "respuesta3",
    "respuesta4",
    "respuesta5",
  ]

  CAMPOS_RESPUESTAS = [
    "actividad",
    "fecha",
    "proyectofinanciero",
    "actividadpf",
  ]

  PREFIJOS_ETIQUETAS_CAMPOS = [
    "etiqueta1",
    "etiqueta2",
    "etiqueta3",
    "etiqueta4",
    "etiqueta5",
  ]

  CAMPOS_ETIQUETAS = [
    "etiqueta",
    "fecha",
    "usuario",
    "observaciones",
  ]

  CAMPOS_PROYECTOS_FINANCIEROS_BAS = [
    "id",
    "nombres",
    "financiador",
    "fechainicio",
    "fechacierre",
    "responsable",
    "compromisos",
    "observaciones",
    "monto",
    "area",
    "equipotrabajo",
    "objetivos",
    "obj1_cod",
    "obj1_texto",
    "obj2_cod",
    "obj2_texto",
    "indicadores_obj",
    "resultados",
    "indicadoresres",
    "actividadespf",
  ]

  CAMPOS_INDICADORES_OBJ = [
    "refobj",
    "codigo",
    "nombre",
    "tipo",
  ]
  CAMPOS_RESULTADOS = [
    "refobj",
    "codigo",
    "resultado",
  ]
  CAMPOS_INDICADORES_RES = [
    "refres",
    "codigo",
    "tipo",
    "indicador",
  ]
  CAMPOS_ACTIVIDADESPF = [
    "refresultado",
    "codigo",
    "tipo",
    "actividad",
    "descripcion",
    "indicadoresgifmm",
  ]
  CAMPOS_PERSONAS_CASOS = []
  PREFIJOS_PERSONAS_CAMPOS.each do |pp|
    CAMPOS_PERSONAVIC.each do |campo|
      CAMPOS_PERSONAS_CASOS.push((pp + "_" + campo).to_sym)
    end
  end

  CAMPOS_UBICACIONES_CASOS = []
  PREFIJOS_UBICACIONES_CAMPOS.each do |pu|
    CAMPOS_UBICACIONES.each do |campo|
      CAMPOS_UBICACIONES_CASOS.push((pu + "_" + campo).to_sym)
    end
  end

  CAMPOS_RESPUESTAS_CASOS = []
  PREFIJOS_RESPUESTAS_CAMPOS.each do |res|
    CAMPOS_RESPUESTAS.each do |campo|
      CAMPOS_RESPUESTAS_CASOS.push((res + "_" + campo).to_sym)
    end
  end

  CAMPOS_PRESPONSABLES_CASOS = []
  PREFIJOS_PRESPONSABLES_CAMPOS.each do |pr|
    CAMPOS_CASOPRESPONSABLES.each do |campo|
      CAMPOS_UBICACIONES_CASOS.push((pr + "_" + campo).to_sym)
    end
  end

  CAMPOS_ACTOS_CASOS = []
  PREFIJOS_ACTOS_CAMPOS.each do |pac|
    CAMPOS_ACTOS.each do |campo|
      CAMPOS_ACTOS_CASOS.push((pac + "_" + campo).to_sym)
    end
  end

  CAMPOS_ETIQUETAS_CASOS = []
  PREFIJOS_ETIQUETAS_CAMPOS.each do |et|
    CAMPOS_ETIQUETAS.each do |campo|
      CAMPOS_ETIQUETAS_CASOS.push((et + "_" + campo).to_sym)
    end
  end

  PREFIJOS_CAMPOS_INDICADORES_OBJ = ["indicadorobj1", "indicadorobj2", "indicadorobj3", "indicadorobj4"]
  CAMPOS_INDICADORES_OBJ_T = []
  PREFIJOS_CAMPOS_INDICADORES_OBJ.each do |cod|
    CAMPOS_INDICADORES_OBJ.each do |campo|
      CAMPOS_INDICADORES_OBJ_T.push((cod + "_" + campo).to_sym)
    end
  end

  PREFIJOS_CAMPOS_RESULTADOS = ["resultado1", "resultado2", "resultado3", "resultado4"]
  CAMPOS_RESULTADOS_T = []
  PREFIJOS_CAMPOS_RESULTADOS.each do |cod|
    CAMPOS_RESULTADOS.each do |campo|
      CAMPOS_RESULTADOS_T.push((cod + "_" + campo).to_sym)
    end
  end

  PREFIJOS_CAMPOS_INDICADORES_RES = ["indicadorres1", "indicadorres2", "indicadorres3", "indicadorres4", "indicadorres5", "indicadorres6"]
  CAMPOS_INDICADORES_RES_T = []
  PREFIJOS_CAMPOS_INDICADORES_RES.each do |cod|
    CAMPOS_INDICADORES_RES.each do |campo|
      CAMPOS_INDICADORES_RES_T.push((cod + "_" + campo).to_sym)
    end
  end

  PREFIJOS_CAMPOS_ACTIVIDADESPF = ["actividadpf1", "actividadpf2", "actividadpf3", "actividadpf4", "actividadpf5", "actividadpf6", "actividadpf7", "actividadpf8"]
  CAMPOS_ACTIVIDADESPF_T = []
  PREFIJOS_CAMPOS_ACTIVIDADESPF.each do |cod|
    CAMPOS_ACTIVIDADESPF.each do |campo|
      CAMPOS_ACTIVIDADESPF_T.push((cod + "_" + campo).to_sym)
    end
  end

  CAMPOS_PLANTILLAS_PROPIAS = {
    "Actividad" => {
      campos: [
        Cor1440Gen::Actividad.human_attribute_name(
          :actividadareas,
        ).downcase.gsub(" ", "_"),
        Cor1440Gen::Actividad.human_attribute_name(
          :actividadpf,
        ).downcase.gsub(" ", "_"),
        "actualizacion",
        "anexo_1_desc",
        "anexo_2_desc",
        "anexo_3_desc",
        "anexo_4_desc",
        "anexo_5_desc",
        "anexos_ids",
        "campos_dinamicos",
        "casos_asociados",
        "corresponsables",
        "covid19",
        "creacion",
        "departamento",
        "departamento_altas_bajas",
        "detalles_financieros_ids",
        "fecha",
        "fecha_localizada",
        "id",
        "listado_casos_ids",
        "lugar",
        "mes",
        "municipio",
        "municipio_altas_bajas",
        "nombre",
        "numero_anexos",
        "numero_detalles_financieros",
        "objetivo",
        "observaciones",
        "objetivo_convenio_financiero",
        "oficina",
        "organizaciones_sociales",
        "organizaciones_sociales_ids",
        "poblacion",
        "poblacion_com_acogida",
        "poblacion_ids",
        "poblacion_hombres_adultos",
        "poblacion_hombres_adultos_ids",
        "poblacion_hombres_l",
        "poblacion_hombres_l_g1",
        "poblacion_hombres_l_g2",
        "poblacion_hombres_l_g3",
        "poblacion_hombres_l_g4",
        "poblacion_hombres_l_g5",
        "poblacion_hombres_l_g6",
        "poblacion_hombres_l_g7",
        "poblacion_hombres_r",
        "poblacion_hombres_r_g1",
        "poblacion_hombres_r_g1_ids",
        "poblacion_hombres_r_g2",
        "poblacion_hombres_r_g2_ids",
        "poblacion_hombres_r_g3",
        "poblacion_hombres_r_g3_ids",
        "poblacion_hombres_r_g4",
        "poblacion_hombres_r_g4_ids",
        "poblacion_hombres_r_g5",
        "poblacion_hombres_r_g5_ids",
        "poblacion_hombres_r_g6",
        "poblacion_hombres_r_g6_ids",
        "poblacion_hombres_r_g7",
        "poblacion_hombres_r_g7_ids",
        "poblacion_intersexuales",
        "poblacion_intersexuales_adultos",
        "poblacion_intersexuales_adultos_ids",
        "poblacion_intersexuales_g1",
        "poblacion_intersexuales_g1_ids",
        "poblacion_intersexuales_g2",
        "poblacion_intersexuales_g2_ids",
        "poblacion_intersexuales_g3",
        "poblacion_intersexuales_g3_ids",
        "poblacion_intersexuales_g4",
        "poblacion_intersexuales_g4_ids",
        "poblacion_intersexuales_g5",
        "poblacion_intersexuales_g5_ids",
        "poblacion_intersexuales_g6",
        "poblacion_intersexuales_g6_ids",
        "poblacion_intersexuales_g7",
        "poblacion_intersexuales_g7_ids",
        "poblacion_mujeres_adultas",
        "poblacion_mujeres_adultas_ids",
        "poblacion_mujeres_l",
        "poblacion_mujeres_l_g1",
        "poblacion_mujeres_l_g2",
        "poblacion_mujeres_l_g3",
        "poblacion_mujeres_l_g4",
        "poblacion_mujeres_l_g5",
        "poblacion_mujeres_l_g6",
        "poblacion_mujeres_l_g7",
        "poblacion_mujeres_r",
        "poblacion_mujeres_r_g1",
        "poblacion_mujeres_r_g1_ids",
        "poblacion_mujeres_r_g2",
        "poblacion_mujeres_r_g2_ids",
        "poblacion_mujeres_r_g3",
        "poblacion_mujeres_r_g3_ids",
        "poblacion_mujeres_r_g4",
        "poblacion_mujeres_r_g4_ids",
        "poblacion_mujeres_r_g5",
        "poblacion_mujeres_r_g5_ids",
        "poblacion_mujeres_r_g6",
        "poblacion_mujeres_r_g6_ids",
        "poblacion_mujeres_r_g7",
        "poblacion_mujeres_r_g7_ids",
        "poblacion_niñas_adolescentes_y_se",
        "poblacion_niñas_adolescentes_y_se_ids",
        "poblacion_niños_adolescentes_y_se",
        "poblacion_niños_adolescentes_y_se_ids",
        "poblacion_sinsexo",
        "poblacion_sinsexo_adultos",
        "poblacion_sinsexo_adultos_ids",
        "poblacion_sinsexo_g1",
        "poblacion_sinsexo_g1_ids",
        "poblacion_sinsexo_g2",
        "poblacion_sinsexo_g2_ids",
        "poblacion_sinsexo_g3",
        "poblacion_sinsexo_g3_ids",
        "poblacion_sinsexo_g4",
        "poblacion_sinsexo_g4_ids",
        "poblacion_sinsexo_g5",
        "poblacion_sinsexo_g5_ids",
        "poblacion_sinsexo_g6",
        "poblacion_sinsexo_g6_ids",
        "poblacion_sinsexo_g7",
        "poblacion_sinsexo_g7_ids",
        Cor1440Gen::Actividad.human_attribute_name(
          :proyectofinanciero,
        ).downcase.gsub(" ", "_"),
        Cor1440Gen::Actividad.human_attribute_name(
          :proyectos,
        ).downcase.gsub(" ", "_"),
        "responsable",
        "resultado",
      ],
      controlador: "Cor1440Gen::ActividadesController",
      ruta: "/actividades",
    },

    "Orgsocial" => {
      campos: [
        "actualización",
        "anotaciones",
        "creación",
        "departamento",
        "dirección",
        "email",
        "fax",
        "id",
        "municipio",
        "nit",
        "nombre",
        "país",
        "población_relacionada",
        "teléfono",
        "tipo",
        "web",
      ],
      controlador: "Msip::Orgsocial",
      ruta: "/orgsocial",
    },

    "Benefactividadpf" => {
      campos: [
        :persona_nombres,
        :persona_apellidos,
        :edad_en_ultact,
        :persona_tipodocumento,
        :persona_numerodocumento,
        :persona_sexo,
        :rangoedadac_ultact,
      ],
      controlador: "Cor1440Gen::BenefactividadpfController",
      ruta: "/conteos/benefactividadpf",
      solo_multiple: true,
      clase_modelo: "Cor1440Gen::Benefactividadpf",
    },

    "Caso" => {
      campos:
      CAMPOS_PERSONAS_CASOS +
        CAMPOS_UBICACIONES_CASOS +
        CAMPOS_MIGRA_SIMPLES +
        CAMPOS_MIGRA_RELA +
        CAMPOS_MIGRA_MULTI +
        CAMPOS_DESPLAZA_SIMPLES +
        CAMPOS_DESPLAZA_RELA +
        CAMPOS_DESPLAZA_MULTI +
        CAMPOS_DESPLAZA_BOOL +
        CAMPOS_DESPLAZA_ESPECIALES +
        CAMPOS_RESPUESTAS_CASOS +
        CAMPOS_PRESPONSABLES_CASOS +
        CAMPOS_ACTOS_CASOS +
        CAMPOS_ETIQUETAS_CASOS +
        [
          :actividades_departamentos,
          :actividades_municipios,
          :actividades_perfiles,
          :actividades_a_humanitaria_tipos_de_ayuda,
          :actividades_a_humanitaria_valor_de_ayuda,
          :actividades_a_humanitaria_modalidades_entrega,
          :actividades_a_humanitarias_convenios_financiados,
          :actividad_asesorias_juridicas,
          :actividades_as_juridicas_convenios_financiados,
          :actividades_acompañamientos_psicosociales,
          :actividades_a_psicosociales_convenios_financiados,

          :asesor,

          :beneficiarias_0_5_fecha_recepcion,
          :beneficiarias_6_12_fecha_recepcion,
          :beneficiarias_13_17_fecha_recepcion,
          :beneficiarias_18_26_fecha_recepcion,
          :beneficiarias_27_59_fecha_recepcion,
          :beneficiarias_60m_fecha_recepcion,
          :beneficiarias_se_fecha_recepcion,
          :beneficiarios_0_5_fecha_recepcion,
          :beneficiarios_6_12_fecha_recepcion,
          :beneficiarios_13_17_fecha_recepcion,
          :beneficiarios_18_26_fecha_recepcion,
          :beneficiarios_27_59_fecha_recepcion,
          :beneficiarios_60m_fecha_recepcion,
          :beneficiarios_se_fecha_recepcion,
          :beneficiarios_ss_0_5_fecha_recepcion,
          :beneficiarios_ss_6_12_fecha_recepcion,
          :beneficiarios_ss_13_17_fecha_recepcion,
          :beneficiarios_ss_18_26_fecha_recepcion,
          :beneficiarios_ss_27_59_fecha_recepcion,
          :beneficiarios_ss_60m_fecha_recepcion,
          :beneficiarios_ss_se_fecha_recepcion,
          :beneficiarios_os_0_5_fecha_recepcion,
          :beneficiarios_os_6_12_fecha_recepcion,
          :beneficiarios_os_13_17_fecha_recepcion,
          :beneficiarios_os_18_26_fecha_recepcion,
          :beneficiarios_os_27_59_fecha_recepcion,
          :beneficiarios_os_60m_fecha_recepcion,
          :beneficiarios_os_se_fecha_recepcion,

          :beneficiarias_0_5_fecha_salida,
          :beneficiarias_6_12_fecha_salida,
          :beneficiarias_13_17_fecha_salida,
          :beneficiarias_18_26_fecha_salida,
          :beneficiarias_27_59_fecha_salida,
          :beneficiarias_60m_fecha_salida,
          :beneficiarias_se_fecha_salida,
          :beneficiarios_0_5_fecha_salida,
          :beneficiarios_6_12_fecha_salida,
          :beneficiarios_13_17_fecha_salida,
          :beneficiarios_18_26_fecha_salida,
          :beneficiarios_27_59_fecha_salida,
          :beneficiarios_60m_fecha_salida,
          :beneficiarios_se_fecha_salida,
          :beneficiarios_ss_0_5_fecha_salida,
          :beneficiarios_ss_6_12_fecha_salida,
          :beneficiarios_ss_13_17_fecha_salida,
          :beneficiarios_ss_18_26_fecha_salida,
          :beneficiarios_ss_27_59_fecha_salida,
          :beneficiarios_ss_60m_fecha_salida,
          :beneficiarios_ss_se_fecha_salida,
          :beneficiarios_os_0_5_fecha_salida,
          :beneficiarios_os_6_12_fecha_salida,
          :beneficiarios_os_13_17_fecha_salida,
          :beneficiarios_os_18_26_fecha_salida,
          :beneficiarios_os_27_59_fecha_salida,
          :beneficiarios_os_60m_fecha_salida,
          :beneficiarios_os_se_fecha_salida,

          :caso_id,
          :contacto_comosupo,
          :contacto_consentimientosjr,
          :contacto_consentimientobd,
          :contacto_edad_fecha_salida,
          :contacto_rangoedad_fecha_recepcion,
          :contacto_rangoedad_fecha_salida,
          :contacto_rangoedad_ultimaatencion,
          :contacto,
          :direccion,
          :expulsion,
          :fechadespemb,
          :fecharecepcion,
          :hora,
          :llegada,
          :memo,
          :memo1612,
          :numeroanexos,
          :numero_beneficiarios,
          :numero_madres_gestantes,
          :oficina,
          :presponsables,
          :tipificacion,
          :telefono,
          :ubicaciones,
          :ultimaatencion_actividad_id,
          :ultimaatencion_ac_juridica,
          :ultimaatencion_as_humanitaria,
          :ultimaatencion_as_juridica,
          :ultimaatencion_beneficiarios_0_5,
          :ultimaatencion_beneficiarios_6_12,
          :ultimaatencion_beneficiarios_13_17,
          :ultimaatencion_beneficiarios_18_26,
          :ultimaatencion_beneficiarios_27_59,
          :ultimaatencion_beneficiarios_60m,
          :ultimaatencion_beneficiarios_se,
          :ultimaatencion_beneficiarias_0_5,
          :ultimaatencion_beneficiarias_6_12,
          :ultimaatencion_beneficiarias_13_17,
          :ultimaatencion_beneficiarias_18_26,
          :ultimaatencion_beneficiarias_27_59,
          :ultimaatencion_beneficiarias_60m,
          :ultimaatencion_beneficiarias_se,
          :ultimaatencion_beneficiarios_ss_0_5,
          :ultimaatencion_beneficiarios_ss_6_12,
          :ultimaatencion_beneficiarios_ss_13_17,
          :ultimaatencion_beneficiarios_ss_18_26,
          :ultimaatencion_beneficiarios_ss_27_59,
          :ultimaatencion_beneficiarios_ss_60m,
          :ultimaatencion_beneficiarios_ss_se,
          :ultimaatencion_beneficiarios_os_0_5,
          :ultimaatencion_beneficiarios_os_6_12,
          :ultimaatencion_beneficiarios_os_13_17,
          :ultimaatencion_beneficiarios_os_18_26,
          :ultimaatencion_beneficiarios_os_27_59,
          :ultimaatencion_beneficiarios_os_60m,
          :ultimaatencion_beneficiarios_os_se,

          :ultimaatencion_derechosvul,
          :ultimaatencion_fecha,
          :ultimaatencion_mes,
          :ultimaatencion_objetivo,
          :ultimaatencion_otros_ser_as,
          :victimas,
        ],
      controlador: "Sivel2Sjr::CasosController",
      ruta: "/casos",
    },

    "Consbenefactcaso" => {
      solo_multiple: true,
      campos: [
        "id",
        "persona_nombres",
        "persona_apellidos",
        "persona_tdocumento",
        "persona_numerodocumento",
        "persona_sexo",
        "persona_fechanac",
        "persona_edad_actual",
        "persona_paisnac",
        "persona_ultimoperfilorgsocial",
        "victima_id",
        "caso_id",
        "caso_fecharec",
        "caso_titular",
        "caso_telefono",
        "actividad_ids",
        "actividad_oficina_nombres",
        "actividad_max_fecha",
        "actividad_min_fecha",
        "actividad_proyectofinanciero_ids",
        "actividad_actividadpf_ids",
      ],
      controlador: "::Consbenefactcaso",
      ruta: "/beneficiarios/caso_y_actividades",
    },

    "Consgifmm" => {
      solo_multiple: true,
      campos: [
        "actividad_id",
        "actividad_nombre",
        "actividad_objetivo",
        "actividad_observaciones",
        "actividad_responsable",
        "actividad_resultado",
        "actividadmarcologico_nombre",
        "beneficiarias_niñas_adolescentes_y_se",
        "beneficiarias_mujeres_adultas",
        "beneficiarios_afrodescendientes",
        "beneficiarios_colombianos_retornados",
        "beneficiarios_comunidades_de_acogida",
        "beneficiarios_con_discapacidad",
        "beneficiarios_en_transito",
        "beneficiarios_indigenas",
        "beneficiarios_lgbti",
        "beneficiarias_nuevas_niñas_adolescentes_y_se",
        "beneficiarias_nuevas_mujeres_adultas",
        "beneficiarias_nuevas_mujeres_0_5",
        "beneficiarias_nuevas_mujeres_6_12",
        "beneficiarias_nuevas_mujeres_13_17",
        "beneficiarias_nuevas_mujeres_18_59",
        "beneficiarias_nuevas_mujeres_60_o_mas",
        "beneficiarios",
        "beneficiarios_nuevos_afrodescendientes",
        "beneficiarios_nuevos_colombianos_retornados",
        "beneficiarios_nuevos_comunidades_de_acogida",
        "beneficiarios_nuevos_con_discapacidad",
        "beneficiarios_nuevos_en_transito",
        "beneficiarios_nuevos_hombres_adultos",
        "beneficiarios_hombres_adultos",
        "beneficiarios_nuevos_hombres_0_5",
        "beneficiarios_nuevos_hombres_6_12",
        "beneficiarios_nuevos_hombres_13_17",
        "beneficiarios_nuevos_hombres_18_59",
        "beneficiarios_nuevos_hombres_60_o_mas",
        "beneficiarios_nuevos_indigenas",
        "beneficiarios_nuevos_lgbti",
        "beneficiarios_nuevos_mes",
        "beneficiarios_nuevos_niños_adolescentes_y_se",
        "beneficiarios_nuevos_otra_etnia",
        "beneficiarios_nuevos_pendulares",
        "beneficiarios_nuevos_sinperfilepoblacional_adultos",
        "beneficiarios_nuevos_sinsexo_adultos",
        "beneficiarios_nuevos_sinsexo_menores_y_se",
        "beneficiarios_nuevos_victimas",
        "beneficiarios_nuevos_victimasdobleafectacion",
        "beneficiarios_nuevos_vocacion_permanencia",
        "beneficiarios_niños_adolescentes_y_se",
        "beneficiarios_otra_etnia",
        "beneficiarios_pendulares",
        "beneficiarios_sinperfilepoblacional_adultos",
        "beneficiarios_sinsexo_adultos",
        "beneficiarios_sinsexo_menores_y_se",
        "beneficiarios_victimas",
        "beneficiarios_victimasdobleafectacion",
        "beneficiarios_vocacion_permanencia",
        "conveniofinanciado_nombre",
        "covid19",
        "departamento_gifmm",
        "detalleah_unidad",
        "detalleah_cantidad",
        "detalleah_modalidad",
        "detalleah_tipo_transferencia",
        "detalleah_mecanismo_entrega",
        "detalleah_frecuencia_entrega",
        "detalleah_monto_por_persona",
        "detalleah_numero_meses_cobertura",
        "estado",
        "fecha",
        "indicador_gifmm",
        "mes",
        "municipio_gifmm",
        "oficina",
        "parte_rmrp",
        "sector_gifmm",
        "socio_implementador",
        "socio_principal",
        "tipo_implementacion",
      ],
      controlador: "::Consgifmm",
      ruta: "/consgifmm",
    },

    "Consninovictima" => {
      solo_multiple: true,
      campos: [
        "caso_id",
      ],
      controlador: "::Consninovictima",
      ruta: "/ninosvictimas",
    },

    "Consultabd" => {
      solo_multiple: true,
      campos: [
        "numfila",
      ],
      controlador: "::Consultabd",
      ruta: "/consultabd",
    },

    "Proyecto" => {
      campos:
        CAMPOS_PROYECTOS_FINANCIEROS_BAS +
          CAMPOS_INDICADORES_OBJ_T +
          CAMPOS_RESULTADOS_T +
          CAMPOS_INDICADORES_RES_T +
          CAMPOS_ACTIVIDADESPF_T,
      controlador: "Cor1440Gen::Proyectofinanciero",
      ruta: "/proyectosfinancieros",
    },

  }

  def campos_plantillas
    Heb412Gen::Ability::CAMPOS_PLANTILLAS_PROPIAS.clone
      .merge(Cor1440Gen::Ability::CAMPOS_PLANTILLAS_PROPIAS.clone)
      .merge(Jos19::Ability::CAMPOS_PLANTILLAS_PROPIAS.clone)
      .merge(CAMPOS_PLANTILLAS_PROPIAS.clone)
  end

  def initialize(usuario = nil)
    can(:read, [Msip::Pais, Msip::Departamento, Msip::Municipio, Msip::Centropoblado])
    if !usuario || usuario.fechadeshabilitacion
      return
    end

    can(:descarga_anexo, Msip::Anexo)
    can(:contar, Msip::Ubicacion)
    can(:nuevo, Msip::Ubicacion)

    can(:contar, Cor1440Gen::Actividad)
    can(:contar_beneficiarios, Cor1440Gen::Actividad)
    can(:contar, Sivel2Gen::Caso)
    can(:buscar, Sivel2Gen::Caso)
    can(:busca, Sivel2Gen::Caso)
    can(:lista, Sivel2Gen::Caso)
    can(:personas_casos, Sivel2Gen::Caso)
    can(:poblacion_sexo_rangoedadac, Sivel2Gen::Caso)

    can(:nuevo, Sivel2Gen::Presponsable)
    can(:nuevo, Sivel2Gen::Victima)

    can(:nuevo, Sivel2Sjr::Desplazamiento)
    can(:nuevo, Sivel2Sjr::Migracion)
    can(:nuevo, Sivel2Sjr::Respuesta)

    if !usuario.nil? && !usuario.rol.nil?
      can(:read, Msip::Oficina)
      can(:read, Msip::Ability.lista_modelos_persona)
      can(:read, Msip::Tdocumento)

      can(:read, Heb412Gen::Plantilladoc)
      can(:read, Heb412Gen::Plantillahcm)
      can(:read, Heb412Gen::Plantillahcr)

      can(:read, Msip::Ubicacionpre)
      can(:mundep, Msip::Ubicacionpre)

      can(:manage, Sivel2Gen::AnexoCaso)

      case usuario.rol
      when Ability::ROLINV
        # cannot :buscar, Sivel2Gen::Caso
        can(
          [:read, :index],
          Sivel2Gen::Caso,
          etiqueta: { id: usuario.etiqueta.map(&:id) },
        )

      when Ability::ROLANALIPRENSA
        can(
          :manage,
          Cor1440Gen::Actividad,
          territorial_id: [1, usuario.territorial_id],
        )
        can(:manage, Cor1440Gen::Asistencia)
        can([:read, :new], Cor1440Gen::Actividad)
        can([:read, :new], Cor1440Gen::Actividadpf)
        can(:read, Cor1440Gen::Informe)
        can(:read, [
          Cor1440Gen::AnexoProyectofinanciero,
          Cor1440Gen::Desembolso,
          Cor1440Gen::Informeauditoria,
          Cor1440Gen::Informefinanciero,
          Cor1440Gen::Informenarrativo,
          Cor1440Gen::Proyectofinanciero,
          Cor1440Gen::ProyectofinancieroUsuario,
        ])

        can(:read, Heb412Gen::Doc)
        can(:create, Heb412Gen::Doc)

      when Ability::ROLSIST

        can([:new, :read], Cor1440Gen::Actividad)
        can([:new, :read], Cor1440Gen::Actividadpf)
        can(
          :manage,
          Cor1440Gen::Actividad,
          territorial_id: [1, usuario.territorial_id],
        )
        can(:manage, Cor1440Gen::Asistencia)
        can(:read, Cor1440Gen::Benefactividadpf)
        can(:read, [
          Cor1440Gen::AnexoProyectofinanciero,
          Cor1440Gen::Desembolso,
          Cor1440Gen::Informeauditoria,
          Cor1440Gen::Informefinanciero,
          Cor1440Gen::Informenarrativo,
          Cor1440Gen::Proyectofinanciero,
          Cor1440Gen::ProyectofinancieroUsuario,
        ])
        can([:index, :read], Cor1440Gen::Rangoedadac)

        can(:read, Heb412Gen::Doc)
        can(:create, Heb412Gen::Doc)

        can(:read, ::Territorial)
        can([:read, :index], Msip::Orgsocial)
        can(:manage, Msip::Ability.lista_modelos_persona)
        can(:manage, ::Docidsecundario)
        can(:manage, Msip::Ubicacionpre)

        can(:manage, [Sivel2Gen::Acto, ::Actonino])
        can(
          :read,
          Sivel2Gen::Caso,
          casosjr: { territorial_id: [1, usuario.territorial_id] },
        )
        can(
          [:update, :create, :destroy],
          Sivel2Gen::Caso,
          casosjr: {
            asesor: usuario.id,
            territorial_id: [1, usuario.territorial_id],
          },
        )
        can([:new, :solicitar], Sivel2Gen::Caso)

        can(:read, Jos19::Consactividadcaso)
        can(:read, [::Consbenefactcaso, ::Consgifmm, ::Consninovictima])

      when Ability::ROLANALI

        can(
          :manage,
          Cor1440Gen::Actividad,
          territorial_id: [1, usuario.territorial_id],
        )
        can([:read, :new], Cor1440Gen::Actividad)
        can([:read, :new], Cor1440Gen::Actividadpf)
        can(:manage, Cor1440Gen::Asistencia)
        can(:read, Cor1440Gen::Benefactividadpf)
        can(:read, Cor1440Gen::Informe)
        can(:index, Cor1440Gen::Mindicadorpf)
        can(:read, [
          Cor1440Gen::AnexoProyectofinanciero,
          Cor1440Gen::Desembolso,
          Cor1440Gen::Informeauditoria,
          Cor1440Gen::Informefinanciero,
          Cor1440Gen::Informenarrativo,
          Cor1440Gen::Proyectofinanciero,
          Cor1440Gen::ProyectofinancieroUsuario,
        ])
        can([:index, :read], Cor1440Gen::Rangoedadac)

        can(:read, Heb412Gen::Doc)
        can(:create, Heb412Gen::Doc)

        can(:read, ::Territorial)
        can([:read, :index], Msip::Orgsocial)
        can(:manage, Msip::Ability.lista_modelos_persona)
        can(:manage, ::Docidsecundario)
        can(:manage, Msip::Ubicacionpre)

        can(:manage, [Sivel2Gen::Acto, ::Actonino])
        can([:fichaimp, :ficahpdf, :read], Sivel2Gen::Caso)
        can([:new, :solicitar], Sivel2Gen::Caso)
        can(
          [:update, :create, :destroy, :edit],
          Sivel2Gen::Caso,
          casosjr: { territorial_id: [1, usuario.territorial_id] },
        )

        can(:read, Jos19::Consactividadcaso)
        can(:read, [::Consbenefactcaso, ::Consgifmm, ::Consninovictima])

      when Ability::ROLCOOR
        can([:read, :new], Cor1440Gen::Actividad)
        can([:read, :new], Cor1440Gen::Actividadpf)
        can(
          :manage,
          Cor1440Gen::Actividad,
          territorial_id: [1, usuario.territorial_id],
        )
        can(:manage, Cor1440Gen::Asistencia)
        can(:read, Cor1440Gen::Benefactividadpf)
        can(:manage, Cor1440Gen::Informe)
        can(:index, Cor1440Gen::Mindicadorpf)
        can(:read, [
          Cor1440Gen::AnexoProyectofinanciero,
          Cor1440Gen::Desembolso,
          Cor1440Gen::Informeauditoria,
          Cor1440Gen::Informefinanciero,
          Cor1440Gen::Informenarrativo,
          Cor1440Gen::Proyectofinanciero,
          Cor1440Gen::ProyectofinancieroUsuario,
        ])
        can([:index, :read], Cor1440Gen::Rangoedadac)

        can(:read, Heb412Gen::Doc)
        can(:create, Heb412Gen::Doc)

        can(:read, ::Territorial)
        can([:new, :create, :read, :index, :edit, :update], Msip::Orgsocial)
        can(:manage, Msip::Ability.lista_modelos_persona)
        can(:manage, ::Docidsecundario)
        can(:manage, Msip::Ubicacionpre)

        can(:manage, [Sivel2Gen::Acto, ::Actonino])
        can([:fichaimp, :ficahpdf, :read], Sivel2Gen::Caso)
        can([:new, :solicitar], Sivel2Gen::Caso)
        can(
          [:update, :create, :destroy, :poneretcomp],
          Sivel2Gen::Caso,
          casosjr: { territorial_id: [1, usuario.territorial_id] },
        )

        can(:read, Jos19::Consactividadcaso)
        can(:read, [::Consbenefactcaso, ::Consgifmm, ::Consninovictima])

      when Ability::ROLOFICIALPF
        can(:read, Cor1440Gen::Benefactividadpf)
        can(:manage, [
          Cor1440Gen::Actividad,
          Cor1440Gen::Asistencia,
          Cor1440Gen::Actividadpf,
          Cor1440Gen::AnexoProyectofinanciero,
          Cor1440Gen::Desembolso,
          Cor1440Gen::Efecto,
          Cor1440Gen::Financiador,
          Cor1440Gen::FormularioTipoindicador,
          Cor1440Gen::Indicadorpf,
          Cor1440Gen::Informe,
          Cor1440Gen::Informeauditoria,
          Cor1440Gen::Informefinanciero,
          Cor1440Gen::Informenarrativo,
          Cor1440Gen::Mindicadorpf,
          Cor1440Gen::Objetivopf,
          Cor1440Gen::Pmindicadorpf,
          Cor1440Gen::Proyectofinanciero,
          Cor1440Gen::ProyectofinancieroUsuario,
          Cor1440Gen::Resultadopf,
          Cor1440Gen::Tipoindicador,

          Heb412Gen::Doc,
          Heb412Gen::Plantilladoc,
          Heb412Gen::Plantillahcm,
          Heb412Gen::Plantillahcr,

          Mr519Gen::Campo,
          Mr519Gen::Formulario,
          Mr519Gen::Encuestausuario,

          Msip::Orgsocial,
          Msip::Sectororgsocial,
          Msip::Ubicacionpre,

          Sivel2Gen::Caso,
          Sivel2Gen::Acto,
          ::Actonino,
          ::Docidsecundario,
        ])

        can(:manage, Msip::Ability.lista_modelos_persona)

        can(:read, Jos19::Consactividadcaso)
        can(:read, [::Consbenefactcaso, ::Consgifmm, ::Consninovictima])

      when Ability::ROLGESTIONHUMANA
        can(:read, Cor1440Gen::Actividad)
        can(:read, Cor1440Gen::Actividadpf)
        can(:read, Cor1440Gen::Benefactividadpf)
        can(:manage, Cor1440Gen::Asistencia)
        can(:read, Cor1440Gen::Mindicadorpf)
        can(:read, [
          Cor1440Gen::AnexoProyectofinanciero,
          Cor1440Gen::Desembolso,
          Cor1440Gen::Informeauditoria,
          Cor1440Gen::Informefinanciero,
          Cor1440Gen::Informenarrativo,
          Cor1440Gen::Proyectofinanciero,
          Cor1440Gen::ProyectofinancieroUsuario,
        ])

        can(:read, Heb412Gen::Doc)
        can(:read, Heb412Gen::Plantilladoc)
        can(:read, Heb412Gen::Plantillahcm)
        can(:read, Heb412Gen::Plantillahcr)

        can(:read, Mr519Gen::Formulario)
        can(:read, Mr519Gen::Encuestausuario)

        can(:read, Msip::Orgsocial)
        can(:read, Msip::Sectororgsocial)
        can(:read, Msip::Ability.lista_modelos_persona)
        can(:read, ::Docidsecundario)
        can(:read, Msip::Ubicacionpre)

        can(:read, Sivel2Gen::Caso)
        can(:read, [Sivel2Gen::Acto, ::Actonino])

        can(:read, Jos19::Consactividadcaso)
        can(:read, [::Consbenefactcaso, ::Consgifmm, ::Consninovictima])

        can([:create, :read, :write, :update], Usuario)
        cannot(:crearadmin, Usuario)

      when Ability::ROLLECTURA
        can(:read, Cor1440Gen::Actividad)
        can(:read, Cor1440Gen::Actividadpf)
        can(:read, Cor1440Gen::Benefactividadpf)
        can(:read, Cor1440Gen::Asistencia)
        can(:read, Cor1440Gen::Mindicadorpf)
        can(:read, [
          Cor1440Gen::AnexoProyectofinanciero,
          Cor1440Gen::Desembolso,
          Cor1440Gen::Informeauditoria,
          Cor1440Gen::Informefinanciero,
          Cor1440Gen::Informenarrativo,
          Cor1440Gen::Proyectofinanciero,
          Cor1440Gen::ProyectofinancieroUsuario,
        ])

        can(:read, Heb412Gen::Doc)
        can(:read, Heb412Gen::Plantilladoc)
        can(:read, Heb412Gen::Plantillahcm)
        can(:read, Heb412Gen::Plantillahcr)

        can(:read, Mr519Gen::Formulario)
        can(:read, Mr519Gen::Encuestausuario)

        can(:read, Msip::Orgsocial)
        can([:read, :reporterepetidos], Msip::Persona)
        can(:read, Msip::Sectororgsocial)
        can(:read, Msip::Ability.lista_modelos_persona)
        can(:read, ::Docidsecundario)
        can(:read, Msip::Ubicacionpre)

        can(:read, Sivel2Gen::Caso)
        can(:read, [Sivel2Gen::Acto, ::Actonino])

        can(:read, Jos19::Consactividadcaso)
        can(:read, [::Consbenefactcaso, ::Consgifmm, ::Consninovictima])

        can([:read], Usuario)

      when Ability::ROLADMIN, Ability::ROLDIR

        can(:read, Cor1440Gen::Benefactividadpf)
        can(:manage, [
          Cor1440Gen::Actividad,
          Cor1440Gen::Asistencia,
          Cor1440Gen::Actividadpf,
          Cor1440Gen::AnexoProyectofinanciero,
          Cor1440Gen::Desembolso,
          Cor1440Gen::Efecto,
          Cor1440Gen::Financiador,
          Cor1440Gen::FormularioTipoindicador,
          Cor1440Gen::Indicadorpf,
          Cor1440Gen::Informe,
          Cor1440Gen::Informeauditoria,
          Cor1440Gen::Informefinanciero,
          Cor1440Gen::Informenarrativo,
          Cor1440Gen::Mindicadorpf,
          Cor1440Gen::Objetivopf,
          Cor1440Gen::Pmindicadorpf,
          Cor1440Gen::Proyectofinanciero,
          Cor1440Gen::ProyectofinancieroUsuario,
          Cor1440Gen::Resultadopf,
          Cor1440Gen::Tipoindicador,
        ])

        can(:manage, Msip::Respaldo7z)
        can([:new, :create, :show, :index], Msip::Claverespaldo) # No editables

        can(:manage, [
          Heb412Gen::Carpetaexclusiva,
          Heb412Gen::Doc,
          Heb412Gen::Plantilladoc,
          Heb412Gen::Plantillahcm,
          Heb412Gen::Plantillahcr,
        ])

        can(:manage, [
          Mr519Gen::Campo,
          Mr519Gen::Encuestausuario,
          Mr519Gen::Formulario,
        ])

        can(:manage, [
          Msip::Orgsocial,
          Msip::Sectororgsocial,
          Msip::Ubicacionpre,
        ])
        can(:manage, Msip::Ability.lista_modelos_persona)
        can(:manage, ::Docidsecundario)

        can(:manage, [
          Sivel2Gen::Acto,
          Sivel2Gen::Caso,
          ::Actonino,
        ])

        can(:read, Jos19::Consactividadcaso)
        can(:read, [::Consbenefactcaso, ::Consgifmm, ::Consninovictima])

        can(:read, ::Consultabd)
        can([:read, :presentar], ::Diccionariodatos)
        can(:read, Msip::Bitacora)
        can(:manage, Usuario)

        can(:manage, :tablasbasicas)
        tablasbasicas.each do |t|
          c = Ability.tb_clase(t)
          can(:manage, c)
        end
      end
      cannot(:solocambiaretiquetas, Sivel2Gen::Caso)
      cannot(:graficar, Sivel2Gen::Caso)
    end
  end
end
