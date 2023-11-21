require 'sivel2_gen/concerns/controllers/conteos_controller'

class Sivel2Sjr::ConteosController < ApplicationController

  include Sivel2Gen::Concerns::Controllers::ConteosController

  def respuestas_que
    return [{ 
      'aslegal' => 'Asistencia Legal del SJR',
      'ayudasjr' => 'Ayuda Humanitaria del SJR',
    }, 'aslegal', 'Servicios Prestados']
  end

  def respuestas
    authorize! :contar, Sivel2Gen::Caso
    @pque, pContarDef, @titulo_respuesta = respuestas_que

    pFaini = escapar_param(params, [:filtro, 'fechaini'])
    pFafin = escapar_param(params, [:filtro, 'fechafin'])
    pContar = escapar_param(params, [:filtro, 'contar'])
    pOficina = escapar_param(params, [:filtro, 'oficina_id'])

    if (pContar == '') 
      pContar = pContarDef
    end

    personas_cons1 = 'cres1'
    # La estrategia es 
    # 1. Agrupar en la vista personas_cons1 respuesta con lo que se contará 
    #    restringiendo por filtros con códigos 
    # 2. Contar derechos/respuestas personas_cons1, cambiar códigos
    #    por información por desplegar

    # Para la vista personas_cons1 emplear que1, tablas1 y where1
    where1 = ""
    # Para la consulta final emplear arreglo que3, que tendrá parejas
    # (campo, titulo por presentar en tabla)
    que3 = []
    tablas3 = personas_cons1
    where3 = ''

    if (pFaini != '') 
      pfechaini = DateTime.strptime(pFaini, '%Y-%m-%d')
      @fechaini = pfechaini.strftime('%Y-%m-%d')
      where1 = consulta_and(
        where1, "sub.fecha", @fechaini, ">="
      )
    end
    if (pFafin != '') 
      pfechafin = DateTime.strptime(pFafin, '%Y-%m-%d')
      @fechafin = pfechafin.strftime('%Y-%m-%d')
      where1 = consulta_and(
        where1, "sub.fecha", @fechafin, "<="
      )
    end

    if (pOficina != '') 
      where1 = consulta_and(where1, "sub.oficina_id", pOficina)
    end

    id_basica = "#{pContar}_id"
    basica = "sivel2_sjr_#{pContar}"
    basica_id = "#{pContar}_id"
    tablas3 = agrega_tabla(tablas3, "public.sivel2_sjr_#{pContar} AS #{pContar}")
    where3 = consulta_and_sinap(where3, "#{basica_id}::integer", 
                                "#{pContar}.id")
    que3 << ["#{pContar}.nombre", @pque[pContar]]

    case (pContar) 
    when 'ayudasjr'
      campoid = 110
    when 'ayudaestado'
      campoid = 103
    when 'derecho'
      campoid = 100
    when 'motivosjr'
      campoid = 150
    when 'progestado'
      campoid = 106
    when 'aslegal'
      campoid = 130
    else
      basica = "loca"
      basica_id = "loca_id"
      tabla3 = "local"
      que3 = "loca"
      where3 = "loca"
      puts "opción desconocida #{pContar}"
    end
    where1 += ((where1 == "") ? "" : " AND ") + 
      "sub.#{basica_id} IS NOT NULL AND sub.#{basica_id}<>''"

    begin
      ActiveRecord::Base.connection.execute(
        "DROP MATERIALIZED VIEW  IF EXISTS #{personas_cons1}"
      )
    rescue 
      begin
        ActiveRecord::Base.connection.execute(
          "DROP VIEW  IF EXISTS #{personas_cons1}"
        )
      rescue 
      end
    end
    que1="sub.actividad_id, sub.fecha, sub.oficina_id, sub.#{basica_id}"
    tablas1="(SELECT DISTINCT a.id AS actividad_id, 
                a.fecha, a.oficina_id, 
                json_array_elements_text(v.valorjson) AS #{basica_id}
              FROM mr519_gen_valorcampo AS v 
              JOIN cor1440_gen_actividad_respuestafor AS ar 
                ON ar.respuestafor_id=v.respuestafor_id 
              JOIN cor1440_gen_actividad AS a
                ON a.id=ar.actividad_id
              WHERE campo_id=#{campoid}) AS sub"

    # Filtrar 
    q1="CREATE MATERIALIZED VIEW #{personas_cons1} AS 
              SELECT #{que1}
              FROM #{tablas1} 
              WHERE #{where1}
    "
    puts "q1 es #{q1}"
    ActiveRecord::Base.connection.execute q1

    #puts que3
    # Generamos 1,2,3 ...n para GROUP BY
    gb = sep = ""
    qc = ""
    i = 1
    que3.each do |t|
      if (t[1] != "") 
        gb += sep + i.to_s
        qc += t[0] + ", "
        sep = ", "
        i += 1
      end
    end

    @coltotales = [i-1, i]
    if (gb != "") 
      gb ="GROUP BY #{gb} ORDER BY #{i} DESC"
    end
    que3 << ["", "Cantidad atenciones"]
    twhere3 = where3 == "" ? "" : "WHERE " + where3
    q3 = "SELECT #{qc}
              COUNT(cast(#{personas_cons1}.actividad_id as text) || ' '
              || cast(#{personas_cons1}.fecha as text))
              FROM #{tablas3}
              #{twhere3}
              #{gb} 
    "
    @cuerpotabla = ActiveRecord::Base.connection.select_all(q3)

    @enctabla = []
    que3.each do |t|
      if (t[1] != "") 
        @enctabla << CGI.escapeHTML(t[1])
      end
    end

    respond_to do |format|
      format.html { }
      format.json { head :no_content }
      format.js   { render 'sivel2_sjr/conteos/resultado_respuestas' }
    end
  end # def respuesta

  def personas_cons1
    'public.mcben1'
  end

  def personas_cons2
    'public.mcben2'
  end


  def personas_filtros_especializados
    @filtrosegun = personas_arma_filtros()
    @opsegun =  [''] + @filtrosegun.keys
    @titulo_personas = 'Personas atendidas'
    @titulo_personas_fecha = 'Fecha de Recepción'
    @pOficina = escapar_param(params, [:filtro, 'oficina_id'])
  end

  def personas_arma_filtros_sivel2_sjr
    cmesesrecepcion = Sivel2Sjr::Casosjr.all.
      pluck('distinct fecharec').
      map { |f| "#{f.year}-#{f.month.to_s.rjust(2, '0')}"}.uniq.sort

    f = personas_arma_filtros_sivel2_gen
    g = {
      'ACTIVIDAD / OFICIO' => {
        nomfiltro: :actividadesoficios,
        coleccion: Sivel2Gen::Actividadoficio.all.order(:nombre),
        metodo_etiqueta: :nombre,
        metodo_id: :id,
        campocons: 'victimasjr.actividadoficio_id'
      },
      'AÑO DE NACIMIENTO' => f['AÑO DE NACIMIENTO'],
      'CABEZA DE HOGAR' => {
        nomfiltro: :cabezasdehogar,
        coleccion: [['SI', 't'],['NO', 'f']],
        metodo_etiqueta: false,
        metodo_id: false,
        campocons: 'victimasjr.cabezafamilia'
      },
      'ESTADO CIVIL' => {
        nomfiltro: :estadosciviles,
        coleccion: Sivel2Gen::Estadocivil.all.order(:nombre),
        metodo_etiqueta: :nombre,
        metodo_id: :id,
        campocons: 'victimasjr.estadocivil_id'
      },
      'ETNIA' => f['ETNIA'],
      'MES RECEPCIÓN' => {
        nomfiltro: :mesesrecepcion,
        coleccion: cmesesrecepcion.map {|m| [m, m]},
        metodo_etiqueta: false,
        metodo_id: false,
        campocons: "EXTRACT(YEAR FROM casosjr.fecharec)::text || "\
        "'-' || "\
        "LPAD(EXTRACT(MONTH FROM casosjr.fecharec)::text, 2, '0')"
      },
      'NIVEL ESCOLAR' => {
        nomfiltro: :nivelesescolares,
        coleccion: Sivel2Gen::Escolaridad.all.order(:nombre),
        metodo_etiqueta: :nombre,
        metodo_id: :id,
        campocons: 'victimasjr.escolaridad_id'
      },
      'RANGO DE EDAD' => f['RANGO DE EDAD'],
      'SEXO' => f['SEXO']
    }
    return g
  end

  def personas_arma_filtros
    return personas_arma_filtros_sivel2_sjr
  end

  def personas_fecha_inicial(where1)
    consulta_and(
      where1, "casosjr.fecharec", @fechaini, ">="
    )
  end

  def personas_fecha_final(where1)
    return consulta_and(
      where1, "casosjr.fecharec", @fechafin, "<="
    )
  end

  def personas_procesa_filtros(que1, tablas1, where1, que3, tablas3, where3)
    # 2. En vista personas_cons2 dejar lo mismo que en personas_cons1, pero añadiendo
    #    expulsión más reciente y su ubicacion si la hay.
    #    Al añadir info. geográfica no es claro
    #    cual poner, porque un caso debe tener varias ubicaciones 
    #    correspondientes a los sitios por donde ha pasado durante
    #    desplazamientos.  Estamos suponiendo que interesa
    #    el sitio de la ultima expulsion.
    # 3. Contar beneficiarios contactos sobre personas_cons2, cambiar códigos
    #    por información por desplegar
    # 4. Contar beneficiarios no contactos sobre personas_cons2, cambiar códigos
    #    por información por desplegar

    # Validaciones todo caso es casosjr y viceversa

    que1 = 'caso.id AS caso_id, victima.persona_id AS persona_id,
            CASE WHEN (casosjr.contacto_id=victima.persona_id) THEN 1 ELSE 0 END 
            AS contacto, 
            CASE WHEN (casosjr.contacto_id<>victima.persona_id) THEN 1 ELSE 0 END
            AS beneficiario, 
            1 as npersona'
    tablas1 = 'public.sivel2_gen_caso AS caso, ' +
    'public.sivel2_sjr_casosjr AS casosjr, ' +
    'public.sivel2_gen_victima AS victima, ' +
    'public.msip_persona AS persona, ' +
    'public.sivel2_sjr_victimasjr AS victimasjr'

    # Para la consulta final emplear arreglo que3, que tendrá parejas
    # (campo, titulo por presentar en tabla)
    que3 = []
    tablas3 = "#{personas_cons2}"
    where3 = ''

    #    consulta_and(where1, 'caso.id', GLOBALS['idbus'], '<>')
    where1 = consulta_and_sinap(where1, "caso.id", "casosjr.caso_id")
    where1 = consulta_and_sinap(where1, "caso.id", "victima.caso_id")
    where1 = consulta_and_sinap(where1, "persona.id", 
                                "victima.persona_id")
    where1 = consulta_and_sinap(where1, "victima.id", 
                                "victimasjr.victima_id")
    where1 = consulta_and_sinap(where1, "victimasjr.fechadesagregacion", 
                                "NULL", " IS ")
    puts "OJO where1=#{where1}"

    if (@pOficina != '') 
      where1 = consulta_and(where1, "casosjr.oficina_id", @pOficina)
    end

    que1, tablas1, where1, que3, tablas3, where3 = 
      personas_procesa_filtros_sivel2_gen(que1, tablas1, where1, 
                                          que3, tablas3, where3)

    return [que1, tablas1, where1, que3, tablas3, where3] 
  end

  # @param tabla es tabla sin prefijo sivel2_gen
  def personas_segun_tipico_sjr(tabla, nomtabla, que1, tablas1, where1, que3, tablas3, where3)
    que1 = agrega_tabla(
      que1, "victimasjr.#{tabla}_id AS #{tabla}_id")
    #              tablas1 = agrega_tabla(
    #                tablas1, 'public.sivel2_sjr_victimasjr AS victimasjr')
    #              where1 = consulta_and_sinap(
    #                where1, "victima.id", "victimasjr.victima_id")
    tablas3 = agrega_tabla(
      tablas3, "public.sivel2_gen_#{tabla} AS #{tabla}")
    where3 = consulta_and_sinap(
      where3, "#{tabla}_id", "#{tabla}.id")
    que3 << ["#{tabla}.nombre", nomtabla]
    return [que1, tablas1, where1, que3, tablas3, where3] 
  end


  def personas_procesa_segun_omsjr(que1, tablas1, where1, que3, tablas3, where3)
    #byebug
    case @pSegun
    when 'ACTIVIDAD / OFICIO'
      que1, tablas1, where1, que3, tablas3, where3 = 
        personas_segun_tipico_sjr(
          'actividadoficio', 'Actividad/Oficio', que1, tablas1, where1, 
          que3, tablas3, where3
        )
    when 'CABEZA DE HOGAR'
      que1 = agrega_tabla(
        que1, "CASE WHEN victimasjr.cabezafamilia THEN 
                  'SI'
                ELSE
                  'NO'
                END AS cabezafamilia")
      #              tablas1 = agrega_tabla(
      #                tablas1, 'public.sivel2_sjr_victimasjr AS victimasjr')
      #              where1 = consulta_and_sinap(
      #                where1, "victima.id", "victimasjr.victima_id")
      que3 << ["cabezafamilia", "Cabeza de Hogar"]

    when 'ESTADO CIVIL'
      que1, tablas1, where1, que3, tablas3, where3 = 
        personas_segun_tipico_sjr(
          'estadocivil', 'Estado Civil', que1, tablas1, where1,
          que3, tablas3, where3
        )

    when 'MES RECEPCIÓN'
      que1 = agrega_tabla(
        que1, "extract(year from fecharec) || '-' " +
        "|| lpad(cast(extract(month from fecharec) as text), 2, " +
        "cast('0' as text)) as mes")
      que3 << ["mes", "Mes"]

    when 'NIVEL ESCOLAR'
      que1, tablas1, where1, que3, tablas3, where3 = 
        personas_segun_tipico_sjr(
          'escolaridad', 'Nivel Escolar', que1, tablas1, where1,
          que3, tablas3, where3
        )

    when 'RÉGIMEN DE SALUD'
      que1 = agrega_tabla(
        que1, 'victimasjr.regimensalud_id AS regimensalud_id')
      #              tablas1 = agrega_tabla(
      #                tablas1, 'public.sivel2_sjr_victimasjr AS victimasjr')
      #              where1 = consulta_and_sinap(
      #                where1, "victima.id", "victimasjr.victima_id")
      tablas3 = agrega_tabla(
        tablas3, 'public.sivel2_sjr_regimensalud AS regimensalud')
      where3 = consulta_and_sinap(
        where3, "regimensalud_id", "regimensalud.id")
      que3 << ["regimensalud.nombre", "Régimen de Salud"]

    else
      que1, tablas1, where1, que3, tablas3, where3 =
        personas_procesa_segun_om(que1, tablas1, where1, que3, tablas3, where3)
    end
    return [que1, tablas1, where1, que3, tablas3, where3]
  end


  def personas_procesa_segun(que1, tablas1, where1, que3, tablas3, where3)
    return personas_procesa_segun_omsjr(que1, tablas1, where1, que3, tablas3, where3)
  end


  def personas_inicializa1(where1)
    que1 = 'caso.id AS caso_id, victima.id AS victima_id, ' +
      'victima.persona_id AS persona_id, 1 AS npersona'
    tablas1 = 'public.sivel2_gen_caso AS caso, ' +
      'public.sivel2_gen_victima AS victima ' 
    where1 = consulta_and_sinap(where1, "caso.id", "victima.caso_id")
    return que1, tablas1, where1
  end


  def personas_vista_geo(que3, tablas3, where3)
    ActiveRecord::Base.connection.execute(
      "CREATE OR REPLACE MATERIALIZED VIEW  ultimodesplazamiento AS 
            (SELECT sivel2_sjr_desplazamiento.id, s.caso_id, s.fechaexpulsion, 
              sivel2_sjr_desplazamiento.expulsion_id 
              FROM public.sivel2_sjr_desplazamiento, 
              (SELECT  caso_id, MAX(sivel2_sjr_desplazamiento.fechaexpulsion) 
               AS fechaexpulsion FROM public.sivel2_sjr_desplazamiento  GROUP BY 1) 
               AS s WHERE sivel2_sjr_desplazamiento.caso_id=s.caso_id and 
              sivel2_sjr_desplazamiento.fechaexpulsion=s.fechaexpulsion);")


    if (@pDepartamento == "1") 
      que3 << ["departamento_nombre", "Último Departamento Expulsor"]
    end
    if (@pMunicipio== "1") 
      que3 << ["municipio_nombre", "Último Municipio Expulsor"]
    end

    return ["CREATE OR REPLACE MATERIALIZED VIEW #{personas_cons2} AS SELECT #{personas_cons1}.*,
            ubicacion.departamento_id, 
            departamento.nombre AS departamento_nombre, 
            ubicacion.municipio_id, municipio.nombre AS municipio_nombre, 
            ubicacion.centropoblado_id, centropoblado.nombre AS centropoblado_nombre, 
            ultimodesplazamiento.fechaexpulsion FROM
            #{personas_cons1} LEFT JOIN public.ultimodesplazamiento ON
            (#{personas_cons1}.caso_id = ultimodesplazamiento.caso_id)
            LEFT JOIN msip_ubicacion AS ubicacion ON 
              (ultimodesplazamiento.expulsion_id = ubicacion.id) 
            LEFT JOIN msip_departamento AS departamento ON 
              (ubicacion.departamento_id=departamento.id) 
            LEFT JOIN msip_municipio AS municipio ON 
              (ubicacion.municipio_id=municipio.id)
            LEFT JOIN msip_centropoblado AS centropoblado ON 
              (ubicacion.centropoblado_id=centropoblado.id)
            ", que3, tablas3, where3]
  end

  def personas_consulta_final(i, que3, tablas3, where3, qc, gb)
    @coltotales = [i-1, i, i+1]
    que3 << ["", "Contactos"]
    que3 << ["", "Beneficiarios"]
    que3 << ["", "Total"]
    twhere3 = where3 == "" ? "" : "WHERE " + where3
    return "SELECT #{qc}
            SUM(#{personas_cons2}.contacto) AS contacto, 
            SUM(#{personas_cons2}.beneficiario) AS beneficiario,
            SUM(#{personas_cons2}.npersona) AS npersona
            FROM #{tablas3}
            #{twhere3}
            #{gb}"
  end

  # Vacíos de protección
  def vacios
    @pque = { 
      'ayudaestado' => 'Ayuda del Estado',
      'ayudasjr' => 'Ayuda Humanitaria del SJR',
      'motivosjr' => 'Servicio/Asesoria del SJR',
      'progestado' => 'Subsidio/Programa del Estado'
    }

    pFaini = escapar_param(params, [:filtro, 'fechaini'])
    pFafin = escapar_param(params, [:filtro, 'fechafin'])
    pOficina = escapar_param(params, [:filtro, 'oficina_id'])
    pContar = escapar_param(params, [:filtro, 'contar'])
    pDerecho = escapar_param(params, [:filtro, 'derecho'])

    if (pContar == '') 
      pContar = 'ayudaestado'
    end

    if (!@pque.has_key?(pContar)) then
      puts "opción desconocida #{pContar}"
      return
    end

    cons1 = 'cvp1'
    cons2 = 'cvp2'
    # La estrategia es 
    # 1. Agrupar en la vista cons1 respuesta con lo que se contará 
    #    restringiendo por filtros con códigos 
    # 2. Contar derechos/respuestas cons1, cambiar códigos
    #    por información por desplegar

    # Para la vista cons1 emplear que1, tablas1 y where1
    que1 = 'respuesta.id AS respuesta_id, ' +
      'derecho_respuesta.derecho_id AS derecho_id'
    tablas1 = 'public.sivel2_sjr_casosjr AS casosjr, ' +
      'public.sivel2_sjr_respuesta AS respuesta, ' +
      'public.sivel2_sjr_derecho_respuesta AS derecho_respuesta'
    where1 = ''

    # where1 = consulta_and(where1, 'caso.id', GLOBALS['idbus'], '<>')
    where1 = consulta_and_sinap(where1, "respuesta.caso_id", "casosjr.caso_id")
    where1 = consulta_and_sinap( 
                                where1, "derecho_respuesta.respuesta_id", "respuesta.id"
                               )

    if (pFaini != '') 
      pfechaini = DateTime.strptime(pFaini, '%Y-%m-%d')
      @fechaini = pfechaini.strftime('%Y-%m-%d')
      where1 = consulta_and(where1, "respuesta.fechaatencion", @fechaini, ">=") 
    end
    if (pFafin != '') 
      pfechafin = DateTime.strptime(pFafin, '%Y-%m-%d')
      @fechafin = pfechafin.strftime('%Y-%m-%d')
      where1 = consulta_and(where1, "respuesta.fechaatencion", @fechafin, "<=")
    end
    if (pOficina != '') 
      where1 = consulta_and(where1, "casosjr.oficina_id", pOficina)
    end
    if (pDerecho != '') 
      where1 = consulta_and(where1, "derecho_respuesta.derecho_id", 
                            pDerecho)
    end


    que1 = agrega_tabla(que1, "casosjr.oficina_id AS oficina_id")

    ActiveRecord::Base.connection.execute "DROP VIEW  IF EXISTS #{cons1}"
    ActiveRecord::Base.connection.execute "DROP VIEW  IF EXISTS #{cons2}"

    # Paso 1. Filtrar 
    q1="CREATE VIEW #{cons1} AS 
            SELECT #{que1}
            FROM #{tablas1} WHERE #{where1}"
    puts "q1 es #{q1}"
    ActiveRecord::Base.connection.execute q1

    # Paso 2
    # Otra consulta
    q2="CREATE VIEW #{cons2} AS SELECT respuesta_id, derecho_id as derecho_id, ar.#{pContar}_id
        FROM public.sivel2_sjr_#{pContar}_respuesta AS ar, 
          public.sivel2_sjr_#{pContar}_derecho AS ad 
        WHERE 
          ar.#{pContar}_id=ad.#{pContar}_id "
    puts "q2 es #{q2}"
    ActiveRecord::Base.connection.execute q2

    que3 = []
    tablas3 = cons1
    where3 = ''

    tablas3 = "public.sivel2_sjr_derecho AS derecho, public.cvp1 LEFT OUTER JOIN public.cvp2 ON 
    (cvp1.respuesta_id=cvp2.respuesta_id AND cvp1.derecho_id=cvp2.derecho_id)"
    where3 = consulta_and_sinap(where3, "cvp1.derecho_id", "derecho.id")
    que3 << ["derecho.nombre AS derecho", "Derecho"]
    que3 << ["(SELECT nombre FROM public.sivel2_sjr_#{pContar} WHERE id=#{pContar}_id) AS atendido", 
             @pque[pContar] ]

    #puts que3
    # Generamos 1,2,3 ...n para GROUP BY
    gb = sep = ""
    qc = ""
    i = 1
    que3.each do |t|
      if (t[1] != "") 
        gb += sep + i.to_s
        qc += t[0] + ", "
        sep = ", "
        i += 1
      end
    end

    @coltotales = [i-1, i]
    if (gb != "") 
      gb ="GROUP BY #{gb} ORDER BY 1, 2"
    end
    que3 << ["", "Atendidos"]
    que3 << ["", "Reportados"]
    twhere3 = where3 == "" ? "" : "WHERE " + where3
    q3 = "SELECT derecho, atendido, (CASE WHEN atendido IS NULL THEN 0 
            ELSE reportados END) AS atendidos, reportados 
          FROM (SELECT #{qc}
            COUNT(cvp1.respuesta_id) AS reportados
            FROM #{tablas3}
            #{twhere3}
            #{gb}) AS s
    "
    puts "q3 es #{q3}"
    @cuerpotabla = ActiveRecord::Base.connection.select_all(q3)

    puts "que3 es #{que3}"
    @enctabla = []
    que3.each do |t|
      if (t[1] != "") 
        @enctabla << CGI.escapeHTML(t[1])
      end
    end


    respond_to do |format|
      format.html { render 'vacios' }
      format.json { head :no_content }
      format.js   { render 'vacios' }
    end

  end

  def respuestas_que
    return [{ 
      'ayudaestado' => 'Ayuda del Estado',
      'ayudasjr' => 'Ayuda Humanitaria del SJR',
      'derecho' => 'Derecho vulnerado',
      'motivosjr' => 'Servicio/Asesoria del SJR',
      'progestado' => 'Subsidio/Programa del Estado'
    }, 'ayudaestado', 'Respuestas y Derechos vulnerados']

  end

  def personas_vista_geo(que3, tablas3, where3)
    ActiveRecord::Base.connection.execute(
      "CREATE OR REPLACE VIEW  ultimodesplazamiento AS 
    (SELECT sivel2_sjr_desplazamiento.id, s.caso_id, s.fechaexpulsion, 
      sivel2_sjr_desplazamiento.expulsionubicacionpre_id 
      FROM public.sivel2_sjr_desplazamiento, 
      (SELECT  caso_id, MAX(sivel2_sjr_desplazamiento.fechaexpulsion) 
       AS fechaexpulsion FROM public.sivel2_sjr_desplazamiento  GROUP BY 1) 
       AS s WHERE sivel2_sjr_desplazamiento.caso_id=s.caso_id and 
      sivel2_sjr_desplazamiento.fechaexpulsion=s.fechaexpulsion);")


    if (@pDepartamento == "1") 
      que3 << ["departamento_nombre", "Último Departamento Expulsor"]
    end
    if (@pMunicipio== "1") 
      que3 << ["municipio_nombre", "Último Municipio Expulsor"]
    end

    return ["CREATE VIEW #{personas_cons2} AS SELECT #{personas_cons1}.*,
    ubicacion.departamento_id, 
    departamento.nombre AS departamento_nombre, 
    ubicacion.municipio_id, municipio.nombre AS municipio_nombre, 
    ubicacion.centropoblado_id, centropoblado.nombre AS centropoblado_nombre, 
    ultimodesplazamiento.fechaexpulsion FROM
    #{personas_cons1} LEFT JOIN public.ultimodesplazamiento ON
    (#{personas_cons1}.caso_id = ultimodesplazamiento.caso_id)
    LEFT JOIN msip_ubicacionpre AS ubicacion ON 
      (ultimodesplazamiento.expulsionubicacionpre_id = ubicacion.id) 
    LEFT JOIN msip_departamento AS departamento ON 
      (ubicacion.departamento_id=departamento.id) 
    LEFT JOIN msip_municipio AS municipio ON 
      (ubicacion.municipio_id=municipio.id)
    LEFT JOIN msip_centropoblado AS centropoblado ON 
      (ubicacion.centropoblado_id=centropoblado.id)
            ", que3, tablas3, where3]
  end

  def personas_arma_filtros
    f = personas_arma_filtros_sivel2_sjr
    f['RÉGIMEN DE SALUD'] = {
      nomfiltro: :regimenesdesalud,
      coleccion: Sivel2Sjr::Regimensalud.all.order(:nombre),
      metodo_etiqueta: :nombre,
      metodo_id: :id,
      campocons: 'victimasjr.regimensalud_id'
    }
    return f.sort.to_h
  end

  def municipios
    authorize! :contar, Sivel2Gen::Caso

    pFaini = escapar_param(params, [:filtro, 'fechaini'])
    pFafin = escapar_param(params, [:filtro, 'fechafin'])
    pOficina = escapar_param(params, [:filtro, 'oficina_id'])

    where = ''
    where = consulta_and_sinap(
      where, 'casosjr.caso_id', 'desplazamiento.caso_id'
    )
    where = consulta_and_sinap(
      where, 'desplazamiento.caso_id', 'victima.caso_id'
    )

    if (pFaini != '') 
      pfechaini = DateTime.strptime(pFaini, '%Y-%m-%d')
      @fechaini = pfechaini.strftime('%Y-%m-%d')
      where = consulta_and(where, "fechaexpulsion", @fechaini, ">=")
    end

    if (pFafin != '') 
      pfechafin = DateTime.strptime(pFafin, '%Y-%m-%d')
      @fechafin = pfechafin.strftime('%Y-%m-%d')
      where = consulta_and(where, "fechaexpulsion", @fechafin, "<=")
    end

    if (pOficina != '')
      where = consulta_and(where, 'casosjr.oficina_id', pOficina)
    end

    whereex = consulta_and_sinap(
      where, 'expulsionubicacionpre_id', 'ubicacion.id'
    )
    cons1 = 'cmunex'
    # expulsores
    q1="CREATE OR REPLACE VIEW #{cons1} AS (
        SELECT (SELECT nombre FROM public.msip_pais WHERE id=pais_id) AS pais, 
        (SELECT nombre FROM public.msip_departamento
          WHERE id=ubicacion.departamento_id) AS departamento, 
        (SELECT nombre FROM public.msip_municipio
          WHERE id=ubicacion.municipio_id) AS municipio, 
        CASE WHEN (casosjr.contacto_id = victima.persona_id) THEN 1 ELSE 0 END
          AS contacto,
        CASE WHEN (casosjr.contacto_id<>victima.persona_id) THEN 1 ELSE 0 END
          AS beneficiario, 
        1 as npersona
        FROM public.sivel2_sjr_desplazamiento AS desplazamiento, 
          msip_ubicacionpre AS ubicacion, 
          sivel2_gen_victima AS victima,
          sivel2_sjr_casosjr AS casosjr
        WHERE #{whereex} 
        )
    "
    puts "q1 es #{q1}"
    ActiveRecord::Base.connection.execute q1


    @expulsores = ActiveRecord::Base.connection.select_all("
      SELECT pais, departamento, municipio, 
        SUM(contacto) AS contacto,
        SUM(beneficiario) AS beneficiario,
        SUM(npersona) AS npersona
      FROM #{cons1}
      GROUP BY 1,2,3 ORDER BY 6 desc;
                                                           ")


    # receptores
    wherel = consulta_and_sinap(
      where, 'desplazamiento.llegadaubicacionpre_id', 'ubicacion.id'
    )
    cons2 = 'cmunrec'
    q2="CREATE OR REPLACE VIEW #{cons2} AS (
      SELECT (SELECT nombre FROM public.msip_pais WHERE id=pais_id) AS pais, 
        (SELECT nombre FROM public.msip_departamento 
          WHERE id=departamento_id) AS departamento, 
        (SELECT nombre FROM public.msip_municipio 
        WHERE id=ubicacion.municipio_id) AS municipio, 
        CASE WHEN (casosjr.contacto_id = victima.persona_id) THEN 1 ELSE 0 END
          AS contacto,
        CASE WHEN (casosjr.contacto_id<>victima.persona_id) THEN 1 ELSE 0 END
          AS beneficiario, 
        1 as npersona
      FROM public.sivel2_sjr_desplazamiento AS desplazamiento, 
        msip_ubicacionpre AS ubicacion, 
        sivel2_gen_victima AS victima,
        sivel2_sjr_casosjr AS casosjr
      WHERE 
        #{wherel} 
    )
    "
    puts "q2 es #{q2}"
    ActiveRecord::Base.connection.execute q2

    @receptores = ActiveRecord::Base.connection.select_all("
      SELECT pais, departamento, municipio, 
        SUM(contacto) AS contacto,
        SUM(beneficiario) AS beneficiario,
        SUM(npersona) AS npersona
      FROM #{cons2}
      GROUP BY 1,2,3 ORDER BY 6 desc;
                                                           ")
    respond_to do |format|
      format.html { }
      format.json { head :no_content }
      format.js   { }
    end
  end


  def rutas
    authorize! :contar, Sivel2Gen::Caso

    pFaini = escapar_param(params, [:filtro, 'fechaini'])
    pFafin = escapar_param(params, [:filtro, 'fechafin'])
    pOficina = escapar_param(params, [:filtro, 'oficina_id'])

    where = ''
    where = consulta_and_sinap(where, 'casosjr.caso_id', 'd1.caso_id')

    if (pFaini != '') 
      pfechaini = DateTime.strptime(pFaini, '%Y-%m-%d')
      @fechaini = pfechaini.strftime('%Y-%m-%d')
      where = consulta_and(where, "casosjr.fecharec", @fechaini, ">=")
    end

    if (pFafin != '') 
      pfechafin = DateTime.strptime(pFafin, '%Y-%m-%d')
      @fechafin = pfechafin.strftime('%Y-%m-%d')
      where = consulta_and(where, "casosjr.fecharec", @fechafin, "<=")
    end

    if (pOficina != '')
      where = consulta_and(where, 'casosjr.oficina_id', pOficina)
    end


    # Retorna cadena correspondiente al municipio de una ubicación
    ActiveRecord::Base.connection.select_all("
      CREATE OR REPLACE FUNCTION municipioubicacion(int) RETURNS varchar AS
      $$
        SELECT (SELECT nombre FROM public.msip_pais WHERE id=ubicacion.pais_id) 
            || COALESCE((SELECT '/' || nombre FROM public.msip_departamento 
            WHERE msip_departamento.id = ubicacion.departamento_id),'') 
            || COALESCE((SELECT '/' || nombre FROM public.msip_municipio 
            WHERE msip_municipio.id = ubicacion.municipio_id),'') 
            FROM public.msip_ubicacionpre AS ubicacion 
            WHERE ubicacion.id=$1;
      $$ 
      LANGUAGE SQL
                                             ");

                                             @enctabla = ['Ruta', 'Desplazamientos de Grupos Familiares']
                                             @coltotales = []
                                             @cuerpotabla = ActiveRecord::Base.connection.select_all(
                                               "SELECT ruta, cuenta FROM ((SELECT municipioubicacion(d1.expulsionubicacionpre_id) || ' - ' 
        || municipioubicacion(d1.llegadaubicacionpre_id) AS ruta, 
        count(id) AS cuenta
      FROM public.sivel2_sjr_desplazamiento AS d1, sivel2_sjr_casosjr AS casosjr
      WHERE #{where}
      GROUP BY 1)
      UNION  
      (SELECT municipioubicacion(d1.expulsionubicacionpre_id) || ' - ' 
        || municipioubicacion(d1.llegadaubicacionpre_id) || ' - '
        || municipioubicacion(d2.llegadaubicacionpre_id) AS ruta, 
        count(d1.caso_id) AS cuenta
      FROM sivel2_sjr_casosjr AS casosjr,
        sivel2_sjr_desplazamiento AS d1, 
        msip_ubicacionpre AS l1, 
        sivel2_sjr_desplazamiento as d2,
        msip_ubicacionpre AS e2, msip_ubicacionpre AS l2
      WHERE #{where}
      AND d1.caso_id=d2.caso_id
      AND d1.fechaexpulsion < d2.fechaexpulsion
      AND d1.llegadaubicacionpre_id = l1.id
      AND d2.llegadaubicacionpre_id = l2.id
      AND d2.expulsionubicacionpre_id = e2.id
      GROUP BY 1)) as sub
      ORDER BY 2 DESC
                                               "
                                             )

                                             respond_to do |format|
                                               format.html { }
                                               format.json { head :no_content }
                                               format.js   { render 'sivel2_gen/conteos/resultado' }
                                             end

  end

  def desplazamientos
    authorize! :contar, Sivel2Gen::Caso

    @opOrdenar = ['N. DESPLAZAMIENTOS', 'EDAD', 'SEXO']
    pFaini = escapar_param(params, [:filtro, 'fechaini'])
    pFafin = escapar_param(params, [:filtro, 'fechafin'])
    pOficina = escapar_param(params, [:filtro, 'oficina_id'])
    pOrdenar = escapar_param(params, [:filtro, 'ordenar'])
    pSexo = escapar_param(params, [:filtro, 'bussexo'])
    pRangoedadId = escapar_param(params, [:filtro, 'busrangoedad_id'])

    if pOrdenar == 'SEXO'
      cord = "3, 5 DESC, 1"
    elsif pOrdenar == 'EDAD'
      cord = "4, 5 DESC, 1"
    else
      cord = "5 DESC, 1"
    end
    where = consulta_and_sinap(
      '', 'victima.caso_id', 'desplazamiento.caso_id'
    )
    where = consulta_and_sinap(where, 'victima.persona_id', 'persona.id')
    where = consulta_and_sinap(where, 'victima.rangoedad_id', 'rangoedad.id')
    where = consulta_and_sinap(where, 'casosjr.caso_id', 'desplazamiento.caso_id')

    if (pFaini != '') 
      pfechaini = DateTime.strptime(pFaini, '%Y-%m-%d')
      @fechaini = pfechaini.strftime('%Y-%m-%d')
      where = consulta_and(where, "casosjr.fecharec", @fechaini, ">=")
    end

    if (pFafin != '') 
      pfechafin = DateTime.strptime(pFafin, '%Y-%m-%d')
      @fechafin = pfechafin.strftime('%Y-%m-%d')
      where = consulta_and(where, "casosjr.fecharec", @fechafin, "<=")
    end

    if (pOficina != '')
      where = consulta_and(where, 'casosjr.oficina_id', pOficina)
    end

    if (pSexo != '')
      where = consulta_and(where, 'persona.sexo', pSexo)
    end

    if (pRangoedadId != '')
      where = consulta_and(where, 'victima.rangoedad_id', pRangoedadId.to_i)
    end



    @cuerpotabla = ActiveRecord::Base.connection.select_all(
      "SELECT victima.caso_id, persona.id AS persona, 
        persona.sexo, rangoedad.nombre as rangoedad,
        COUNT(desplazamiento.id) as cuenta
      FROM sivel2_gen_victima AS victima, 
        msip_persona AS persona, 
        sivel2_sjr_desplazamiento AS desplazamiento, 
        sivel2_gen_rangoedad AS rangoedad,
        sivel2_sjr_casosjr AS casosjr
      WHERE #{where}
      GROUP BY 1, 2, 3, 4 ORDER BY #{cord};
      "
    )
    @enctabla = ['Caso', 'Cod. Persona', 'Sexo', 'Rango de Edad', 'N. Desplazamientos']
    @coltotales = []
    @filtrostab = {
      'Sexo' => 'des_sexo',
      'Rango de Edad' => 'des_rangoedad_id'
    }

    respond_to do |format|
      format.html { }
      format.json { head :no_content }
      format.js   { render 'sivel2_gen/conteos/resultado' }
    end
  end

  def accionesjuridicas
    authorize! :contar, Sivel2Gen::Caso

    pFaini = escapar_param(params, [:filtro, 'fechaini'])
    pFafin = escapar_param(params, [:filtro, 'fechafin'])
    pOficina = escapar_param(params, [:filtro, 'oficina_id'])

    where = 'TRUE '
    if (pFaini != '') 
      pfechaini = DateTime.strptime(pFaini, '%Y-%m-%d')
      @fechaini = pfechaini.strftime('%Y-%m-%d')
      where = consulta_and(where, "casosjr.fecharec", @fechaini, ">=")
    end

    if (pFafin != '') 
      pfechafin = DateTime.strptime(pFafin, '%Y-%m-%d')
      @fechafin = pfechafin.strftime('%Y-%m-%d')
      where = consulta_and(where, "casosjr.fecharec", @fechafin, "<=")
    end

    if (pOficina != '')
      where = consulta_and(where, 'casosjr.oficina_id', pOficina)
    end

    c = ActiveRecord::Base.connection.select_all(
      "SELECT a.nombre, ar.favorable, count(r.id) as cuenta
        FROM public.sivel2_sjr_accionjuridica AS a 
        JOIN public.sivel2_sjr_accionjuridica_respuesta AS ar ON a.id=ar.accionjuridica_id 
        JOIN public.sivel2_sjr_respuesta AS r ON ar.respuesta_id=r.id 
        JOIN public.sivel2_sjr_casosjr AS casosjr ON r.caso_id=casosjr.caso_id
      WHERE #{where}
      GROUP BY 1, 2 ORDER BY 1,2;
      "
    )

    @enctabla = ['Acción jurídica', 'Respuesta Positiva', 'Respuesta Negativ', 'Sin respuesta']
    c2 = {}
    c.try(:each) do |f|
      if c2[f['nombre']] 
        c2[f['nombre']][f['favorable']] = f['cuenta']
      else
        c2[f['nombre']] = {}
        c2[f['nombre']][f['favorable']] = f['cuenta']
      end
    end
    @accionesjuridicas = []
    tt = 0
    tf = 0
    ts = 0
    c2.try(:each) do |i,v|
      t = v[true] ? v[true] : 0
      f = v[false] ? v[false] : 0
      s = v[nil] ? v[nil] : 0
      @accionesjuridicas << {'accionjuridica' => i,
                             'positivas' => t, 
                             'negativas' => f, 
                             'sinrespuesta' => s}
      tt += t
      tf += f
      ts += s
    end
    @coltotales = { 'positivas' => tt, 
                    'negativas' => tf, 
                    'sinrespuesta' => ts}

    respond_to do |format|
      format.html { }
      format.json { head :no_content }
      format.js   { render 'accionesjuridicas' }
    end

  end

end
