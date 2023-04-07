require 'sivel2_sjr/concerns/controllers/conteos_controller'

class Sivel2Sjr::ConteosController < ApplicationController

  include Sivel2Sjr::Concerns::Controllers::ConteosController

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
    q2="CREATE VIEW #{cons2} AS SELECT respuesta_id, derecho_id as derecho_id, id_#{pContar}
        FROM public.sivel2_sjr_#{pContar}_respuesta AS ar, 
          public.sivel2_sjr_#{pContar}_derecho AS ad 
        WHERE 
          ar.id_#{pContar}=ad.#{pContar}_id "
    puts "q2 es #{q2}"
    ActiveRecord::Base.connection.execute q2

    que3 = []
    tablas3 = cons1
    where3 = ''

    tablas3 = "public.sivel2_sjr_derecho AS derecho, public.cvp1 LEFT OUTER JOIN public.cvp2 ON 
    (cvp1.respuesta_id=cvp2.respuesta_id AND cvp1.derecho_id=cvp2.derecho_id)"
    where3 = consulta_and_sinap(where3, "cvp1.derecho_id", "derecho.id")
    que3 << ["derecho.nombre AS derecho", "Derecho"]
    que3 << ["(SELECT nombre FROM public.sivel2_sjr_#{pContar} WHERE id=id_#{pContar}) AS atendido", 
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
    ubicacion.clase_id, clase.nombre AS clase_nombre, 
    ultimodesplazamiento.fechaexpulsion FROM
    #{personas_cons1} LEFT JOIN public.ultimodesplazamiento ON
    (#{personas_cons1}.caso_id = ultimodesplazamiento.caso_id)
    LEFT JOIN msip_ubicacionpre AS ubicacion ON 
      (ultimodesplazamiento.expulsionubicacionpre_id = ubicacion.id) 
    LEFT JOIN msip_departamento AS departamento ON 
      (ubicacion.departamento_id=departamento.id) 
    LEFT JOIN msip_municipio AS municipio ON 
      (ubicacion.municipio_id=municipio.id)
    LEFT JOIN msip_clase AS clase ON 
      (ubicacion.clase_id=clase.id)
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
