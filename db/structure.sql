SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: es_co_utf_8; Type: COLLATION; Schema: public; Owner: -
--

CREATE COLLATION public.es_co_utf_8 (provider = libc, locale = 'es_CO.UTF-8');


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: nomcod; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.nomcod AS (
	nombre character varying(100),
	caso integer
);


--
-- Name: campointro(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.campointro(character varying, character varying) RETURNS character varying
    LANGUAGE sql IMMUTABLE
    AS $_$SELECT CASE 
               WHEN $2 IS NULL OR TRIM($2) = '' THEN '' 
               ELSE ' ' || $1 || ': ' || $2 
             END
        $_$;


--
-- Name: completa_obs(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.completa_obs(obs character varying, nuevaobs character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
      BEGIN
        RETURN CASE WHEN obs IS NULL THEN nuevaobs
          WHEN obs='' THEN nuevaobs
          WHEN RIGHT(obs, 1)='.' THEN obs || ' ' || nuevaobs
          ELSE obs || '. ' || nuevaobs
        END;
      END; $$;


--
-- Name: cor1440_gen_actividad_cambiada(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cor1440_gen_actividad_cambiada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            ASSERT(TG_OP = 'UPDATE');
            ASSERT(NEW.id = OLD.id);
            CALL cor1440_gen_recalcular_poblacion_actividad(NEW.id);
            RETURN NULL;
          END ;
        $$;


--
-- Name: cor1440_gen_asistencia_cambiada_creada_eliminada(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cor1440_gen_asistencia_cambiada_creada_eliminada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            CASE
              WHEN (TG_OP = 'UPDATE') THEN
                ASSERT(NEW.id = OLD.id);
                CALL cor1440_gen_recalcular_poblacion_actividad(NEW.actividad_id);
              WHEN (TG_OP = 'INSERT') THEN
                CALL cor1440_gen_recalcular_poblacion_actividad(NEW.actividad_id);
              ELSE -- DELETE
                CALL cor1440_gen_recalcular_poblacion_actividad(OLD.actividad_id);
            END CASE;
            RETURN NULL;
          END;
        $$;


--
-- Name: cor1440_gen_persona_cambiada(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cor1440_gen_persona_cambiada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
          aid INTEGER;
        BEGIN
          ASSERT(TG_OP = 'UPDATE');
          ASSERT(NEW.id = OLD.id);
          FOR aid IN 
            SELECT actividad_id FROM cor1440_gen_asistencia 
              WHERE persona_id=NEW.id
          LOOP
            CALL cor1440_gen_recalcular_poblacion_actividad(aid);
          END LOOP;
          RETURN NULL;
        END ;
        $$;


--
-- Name: cor1440_gen_recalcular_poblacion_actividad(bigint); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.cor1440_gen_recalcular_poblacion_actividad(IN par_actividad_id bigint)
    LANGUAGE plpgsql
    AS $$
      DECLARE
        rangos INTEGER ARRAY;
        idrangos INTEGER ARRAY;
        a_dia INTEGER;
        a_mes INTEGER;
        a_anio INTEGER;
        asistente RECORD;

        edad INTEGER;
        rango_id INTEGER;
      BEGIN
        RAISE NOTICE 'actividad_id es %', par_actividad_id;
        SELECT EXTRACT(DAY FROM fecha) INTO a_dia FROM cor1440_gen_actividad
          WHERE id=par_actividad_id LIMIT 1;
        RAISE NOTICE 'a_dia es %', a_dia;
        SELECT EXTRACT(MONTH FROM fecha) INTO a_mes FROM cor1440_gen_actividad
          WHERE id=par_actividad_id;
        RAISE NOTICE 'a_mes es %', a_mes;
        SELECT EXTRACT(YEAR FROM fecha) INTO a_anio FROM cor1440_gen_actividad
          WHERE id=par_actividad_id;
        RAISE NOTICE 'a_anio es %', a_anio;

        DELETE FROM cor1440_gen_actividad_rangoedadac
          WHERE actividad_id=par_actividad_id
        ;

        FOR rango_id IN SELECT id FROM cor1440_gen_rangoedadac
          WHERE fechadeshabilitacion IS NULL
        LOOP
          INSERT INTO cor1440_gen_actividad_rangoedadac
            (actividad_id, rangoedadac_id, mr, fr, s, i, created_at, updated_at)
            (SELECT par_actividad_id, rango_id, 0, 0, 0, 0, NOW(), NOW());
        END LOOP;

        FOR asistente IN SELECT p.id, p.anionac, p.mesnac, p.dianac, p.sexo
          FROM cor1440_gen_asistencia AS asi
          JOIN cor1440_gen_actividad AS ac ON ac.id=asi.actividad_id
          JOIN msip_persona AS p ON p.id=asi.persona_id
          WHERE ac.id=par_actividad_id
        LOOP
          RAISE NOTICE 'persona_id es %', asistente.id;
          edad = msip_edad_de_fechanac_fecharef(asistente.anionac, asistente.mesnac,
            asistente.dianac, a_anio, a_mes, a_dia);
          RAISE NOTICE 'edad es %', edad;
          SELECT id INTO rango_id FROM cor1440_gen_rangoedadac WHERE
            fechadeshabilitacion IS NULL AND
            limiteinferior <= edad AND
              (limitesuperior IS NULL OR edad <= limitesuperior) LIMIT 1;
          IF rango_id IS NULL THEN
            rango_id := 7;
          END IF;
          RAISE NOTICE 'rango_id es %', rango_id;

          CASE asistente.sexo
            WHEN 'M' THEN
              UPDATE cor1440_gen_actividad_rangoedadac SET fr = fr + 1
                WHERE actividad_id=par_actividad_id
                AND rangoedadac_id=rango_id;
            WHEN 'H' THEN
              UPDATE cor1440_gen_actividad_rangoedadac SET mr = mr + 1
                WHERE actividad_id=par_actividad_id
                AND rangoedadac_id=rango_id;
            WHEN 'O' THEN
              UPDATE cor1440_gen_actividad_rangoedadac SET i = i + 1
                WHERE actividad_id=par_actividad_id
                AND rangoedadac_id=rango_id;
            ELSE
              UPDATE cor1440_gen_actividad_rangoedadac SET s = s + 1
                WHERE actividad_id=par_actividad_id
                AND rangoedadac_id=rango_id;
          END CASE;
        END LOOP;

        DELETE FROM cor1440_gen_actividad_rangoedadac
          WHERE actividad_id = par_actividad_id
          AND mr = 0 AND fr = 0 AND i = 0 AND s = 0
        ;
        RETURN;
      END;
      $$;


--
-- Name: divarr(anyarray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.divarr(in_array anyarray) RETURNS SETOF text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT ($1)[s] FROM generate_series(1,array_upper($1, 1)) AS s;
$_$;


--
-- Name: divarr_concod(anyarray, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.divarr_concod(in_array anyarray, in_integer integer) RETURNS SETOF public.nomcod
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT ($1)[s],$2 FROM generate_series(1,array_upper($1, 1)) AS s;
$_$;


--
-- Name: docidsecundario_actualiza_buscable_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.docidsecundario_actualiza_buscable_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        begin
          UPDATE msip_persona SET
            numerodocumento = numerodocumento 
            WHERE id = new.persona_id; -- Lanza otro trigger
          RETURN new;
        end
        $$;


--
-- Name: docidsecundario_elimina_buscable_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.docidsecundario_elimina_buscable_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        begin
          UPDATE msip_persona SET
            numerodocumento = numerodocumento 
            WHERE id = old.persona_id; -- Lanza otro trigger
          RETURN old;
        end
        $$;


--
-- Name: es_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.es_unaccent(cadena text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
          select unaccent($1);
        $_$;


--
-- Name: f_unaccent(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
      SELECT public.unaccent('public.unaccent', $1)  
      $_$;


--
-- Name: msip_agregar_o_remplazar_familiar_inverso(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_agregar_o_remplazar_familiar_inverso() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        num2 INTEGER;
        rinv CHAR(2);
        rexistente CHAR(2);
      BEGIN
        ASSERT(TG_OP = 'INSERT' OR TG_OP = 'UPDATE');
        RAISE NOTICE 'Insertando o actualizando en msip_persona_trelacion';
        RAISE NOTICE 'TG_OP = %', TG_OP;
        RAISE NOTICE 'NEW.id = %', NEW.id;
        RAISE NOTICE 'NEW.persona1 = %', NEW.persona1;
        RAISE NOTICE 'NEW.persona2 = %', NEW.persona2;
        RAISE NOTICE 'NEW.trelacion_id = %', NEW.trelacion_id;
        RAISE NOTICE 'NEW.observaciones = %', NEW.observaciones;

        SELECT COUNT(*) INTO num2 FROM msip_persona_trelacion
          WHERE persona1 = NEW.persona2 AND persona2=NEW.persona1;
        RAISE NOTICE 'num2 = %', num2;
        ASSERT(num2 < 2);
        SELECT inverso INTO rinv FROM msip_trelacion 
          WHERE id = NEW.trelacion_id;
        RAISE NOTICE 'rinv = %', rinv;
        ASSERT(rinv IS NOT NULL);
        CASE num2
          WHEN 0 THEN
            INSERT INTO msip_persona_trelacion 
            (persona1, persona2, trelacion_id, observaciones, created_at, updated_at)
            VALUES (NEW.persona2, NEW.persona1, rinv, 'Inverso agregado automaticamente', NOW(), NOW());
          ELSE -- num2 = 1
            SELECT trelacion_id INTO rexistente FROM msip_persona_trelacion
              WHERE persona1=NEW.persona2 AND persona2=NEW.persona1;
            RAISE NOTICE 'rexistente = %', rexistente;
            IF rinv <> rexistente THEN
              UPDATE msip_persona_trelacion 
                SET trelacion_id = rinv,
                 observaciones = 'Inverso cambiado automaticamente (era ' ||
                   rexistente || '). ' || COALESCE(observaciones, ''),
                 updated_at = NOW()
                WHERE persona1=NEW.persona2 AND persona2=NEW.persona1;
            END IF;
        END CASE;
        RETURN NULL;
      END ;
      $$;


--
-- Name: msip_edad_de_fechanac_fecharef(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_edad_de_fechanac_fecharef(anionac integer, mesnac integer, dianac integer, anioref integer, mesref integer, diaref integer) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$
            SELECT CASE 
              WHEN anionac IS NULL THEN NULL
              WHEN anioref IS NULL THEN NULL
              WHEN anioref < anionac THEN -1
              WHEN mesnac IS NOT NULL AND mesnac > 0 
                AND mesref IS NOT NULL AND mesref > 0 
                AND mesnac >= mesref THEN
                CASE 
                  WHEN mesnac > mesref OR (dianac IS NOT NULL 
                    AND dianac > 0 AND diaref IS NOT NULL 
                    AND diaref > 0 AND dianac > diaref) THEN 
                    anioref-anionac-1
                  ELSE 
                    anioref-anionac
                END
              ELSE
                anioref-anionac
            END 
          $$;


--
-- Name: msip_eliminar_familiar_inverso(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_eliminar_familiar_inverso() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        num2 INTEGER;
      BEGIN
        ASSERT(TG_OP = 'DELETE');
        RAISE NOTICE 'Eliminando inverso de msip_persona_trelacion';
        SELECT COUNT(*) INTO num2 FROM msip_persona_trelacion
          WHERE persona1 = OLD.persona2 AND persona2=OLD.persona1;
        RAISE NOTICE 'num2 = %', num2;
        ASSERT(num2 < 2);
        IF num2 = 1 THEN
            DELETE FROM msip_persona_trelacion 
            WHERE persona1 = OLD.persona2 AND persona2 = OLD.persona1;
        END IF;
        RETURN NULL;
      END ;
      $$;


--
-- Name: msip_nombre_vereda(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_nombre_vereda() RETURNS character varying
    LANGUAGE sql
    AS $$
        SELECT 'Vereda '
      $$;


--
-- Name: msip_persona_buscable_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_persona_buscable_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        begin
          new.buscable := to_tsvector('spanish', 
            es_unaccent(new.nombres) ||
            ' ' || es_unaccent(new.apellidos) || 
            ' ' || new.numerodocumento::TEXT ||
            ' ' || ARRAY_TO_STRING(ARRAY(SELECT d2.numero::TEXT
              FROM docidsecundario AS d2 WHERE d2.persona_id=new.id), ' ')
            );
          return new;
        end
        $$;


--
-- Name: msip_ubicacionpre_id_rtablabasica(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_id_rtablabasica() RETURNS integer
    LANGUAGE sql
    AS $$
        SELECT min(id+1) FROM msip_ubicacionpre WHERE 
          (id+1) NOT IN (SELECT id FROM msip_ubicacionpre) AND 
          id<10000000
      $$;


--
-- Name: msip_ubicacionpre_nomenclatura(character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.msip_ubicacionpre_nomenclatura(pais character varying, departamento character varying, municipio character varying, vereda character varying, centropoblado character varying, lugar character varying, sitio character varying) RETURNS text[]
    LANGUAGE sql
    AS $$
        SELECT CASE
        WHEN pais IS NULL OR pais = '' THEN
          array[NULL, NULL]
        WHEN departamento IS NULL OR departamento = '' THEN
          array[pais, NULL]
        WHEN municipio IS NULL OR municipio = '' THEN
          array[departamento || ' / ' || pais, departamento]
        WHEN (vereda IS NULL OR vereda = '') AND 
          (centropoblado IS NULL OR centropoblado = '') THEN
          array[ municipio || ' / ' || departamento || ' / ' || pais,
            municipio || ' / ' || departamento ]
        WHEN (vereda IS NULL OR vereda = '') AND 
          (lugar IS NULL OR lugar = '') THEN
          array[ centropoblado || ' / ' || municipio || ' / ' || 
            departamento || ' / ' || pais,
            centropoblado || ' / ' || municipio || ' / ' || 
            departamento ]
        WHEN (lugar IS NULL OR lugar = '') THEN
          array[ msip_nombre_vereda() || vereda || ' / ' || 
            municipio || ' / ' ||
            departamento || ' / ' || pais,
            msip_nombre_vereda() || vereda || ' / ' || 
            municipio || ' / ' || departamento]
        WHEN (vereda IS NULL OR vereda = '') AND 
          (sitio IS NULL OR sitio = '') THEN
          array[ lugar || ' / ' || centropoblado || ' / ' ||
            municipio || ' / ' || departamento || ' / ' || pais,
            lugar || ' / ' || centropoblado || ' / ' ||
            municipio || ' / ' || departamento]
        WHEN (sitio IS NULL OR sitio = '') THEN
          array[ lugar || ' / ' || 
            msip_nombre_vereda() || vereda || ' / ' ||
            municipio || ' / ' || departamento || ' / ' || pais,
            lugar || ' / ' || 
            msip_nombre_vereda() || vereda || ' / ' ||
            municipio || ' / ' || departamento]
        WHEN (vereda IS NULL OR vereda = '') THEN
          array[ sitio || ' / ' || lugar || ' / ' ||
            centropoblado || ' / ' || 
            municipio || ' / ' ||
            departamento || ' / ' || pais,
            sitio || ' / ' || lugar || ' / ' ||
            centropoblado || ' / ' || 
            municipio || ' / ' ||
            departamento ]
        ELSE
          array[ sitio || ' / ' || lugar || ' / ' ||
            msip_nombre_vereda() || vereda || ' / ' ||
            municipio || ' / ' ||
            departamento || ' / ' || pais,
            sitio || ' / ' || lugar || ' / ' ||
            msip_nombre_vereda() || vereda || ' / ' ||
            municipio || ' / ' ||
            departamento ]
         END
      $$;


--
-- Name: municipioubicacion(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.municipioubicacion(integer) RETURNS character varying
    LANGUAGE sql
    AS $_$
        SELECT (SELECT nombre FROM public.msip_pais WHERE id=ubicacion.pais_id) 
            || COALESCE((SELECT '/' || nombre FROM public.msip_departamento 
            WHERE msip_departamento.id = ubicacion.departamento_id),'') 
            || COALESCE((SELECT '/' || nombre FROM public.msip_municipio 
            WHERE msip_municipio.id = ubicacion.municipio_id),'') 
            FROM public.msip_ubicacionpre AS ubicacion 
            WHERE ubicacion.id=$1;
      $_$;


--
-- Name: probapellido(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probapellido(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT sum(ppar) FROM (SELECT p, probcadap(p) AS ppar FROM (
		SELECT p FROM divarr(string_to_array(trim($1), ' ')) AS p) 
		AS s) AS s2;
$_$;


--
-- Name: probcadap(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probcadap(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT CASE WHEN (SELECT SUM(frec) FROM napellidos)=0 THEN 0
        WHEN (SELECT COUNT(*) FROM napellidos WHERE apellido=$1)=0 THEN 0
        ELSE (SELECT frec/(SELECT SUM(frec) FROM napellidos) 
            FROM napellidos WHERE apellido=$1)
        END
$_$;


--
-- Name: probcadh(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probcadh(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT CASE WHEN (SELECT SUM(frec) FROM nhombres)=0 THEN 0
		WHEN (SELECT COUNT(*) FROM nhombres WHERE nombre=$1)=0 THEN 0
		ELSE (SELECT frec/(SELECT SUM(frec) FROM nhombres) 
			FROM nhombres WHERE nombre=$1)
		END
$_$;


--
-- Name: probcadm(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probcadm(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT CASE WHEN (SELECT SUM(frec) FROM nmujeres)=0 THEN 0
		WHEN (SELECT COUNT(*) FROM nmujeres WHERE nombre=$1)=0 THEN 0
		ELSE (SELECT frec/(SELECT SUM(frec) FROM nmujeres) 
			FROM nmujeres WHERE nombre=$1)
		END
$_$;


--
-- Name: probhombre(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probhombre(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT sum(ppar) FROM (SELECT p, peso*probcadh(p) AS ppar FROM (
		SELECT p, CASE WHEN rnum=1 THEN 100 ELSE 1 END AS peso 
		FROM (SELECT p, row_number() OVER () AS rnum FROM 
			divarr(string_to_array(trim($1), ' ')) AS p) 
		AS s) AS s2) AS s3;
$_$;


--
-- Name: probmujer(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.probmujer(in_text text) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
	SELECT sum(ppar) FROM (SELECT p, peso*probcadm(p) AS ppar FROM (
		SELECT p, CASE WHEN rnum=1 THEN 100 ELSE 1 END AS peso 
		FROM (SELECT p, row_number() OVER () AS rnum FROM 
			divarr(string_to_array(trim($1), ' ')) AS p) 
		AS s) AS s2) AS s3;
$_$;


--
-- Name: sivel2_gen_polo_id(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sivel2_gen_polo_id(presponsable_id integer) RETURNS integer
    LANGUAGE sql
    AS $$
        WITH RECURSIVE des AS (
          SELECT id, nombre, papa_id 
          FROM sivel2_gen_presponsable WHERE id=presponsable_id 
          UNION SELECT e.id, e.nombre, e.papa_id 
          FROM sivel2_gen_presponsable e INNER JOIN des d ON d.papa_id=e.id) 
        SELECT id FROM des WHERE papa_id IS NULL;
      $$;


--
-- Name: sivel2_gen_polo_nombre(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sivel2_gen_polo_nombre(presponsable_id integer) RETURNS character varying
    LANGUAGE sql
    AS $$
        SELECT CASE 
          WHEN fechadeshabilitacion IS NULL THEN nombre
          ELSE nombre || '(DESHABILITADO)' 
        END 
        FROM sivel2_gen_presponsable 
        WHERE id=sivel2_gen_polo_id(presponsable_id)
      $$;


--
-- Name: soundexesp(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soundexesp(entrada text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
      DECLARE
      	soundex text='';	
      	-- para determinar la primera letra
      	pri_letra text;
      	resto text;
      	sustituida text ='';
      	-- para quitar adyacentes
      	anterior text;
      	actual text;
      	corregido text;
      BEGIN
        --raise notice 'entrada=%', entrada;
        -- devolver null si recibi un string en blanco o con espacios en blanco
        IF length(trim(entrada))= 0 then
              RETURN NULL;
        END IF;


      	-- 1: LIMPIEZA:
      		-- pasar a mayuscula, eliminar la letra "H" inicial, los acentos y la enie
      		-- 'holá coñó' => 'OLA CONO'
      		entrada=translate(ltrim(trim(upper(entrada)),'H'),'ÑÁÉÍÓÚÀÈÌÒÙÜ','NAEIOUAEIOUU');

        IF array_upper(regexp_split_to_array(entrada, '[^a-zA-Z]'), 1) > 1 THEN
          RAISE NOTICE 'Esta función sólo maneja una palabra y no ''%''. Use más bien soundexespm', entrada;
      		RETURN NULL;
        END IF;

      	-- 2: PRIMERA LETRA ES IMPORTANTE, DEBO ASOCIAR LAS SIMILARES
      	--  'vaca' se convierte en 'baca'  y 'zapote' se convierte en 'sapote'
      	-- un fenomeno importante es GE y GI se vuelven JE y JI; CA se vuelve KA, etc
      	pri_letra =substr(entrada,1,1);
      	resto =substr(entrada,2);
      	CASE
      		when pri_letra IN ('V') then
      			sustituida='B';
      		when pri_letra IN ('Z','X') then
      			sustituida='S';
      		when pri_letra IN ('G') AND substr(entrada,2,1) IN ('E','I') then
      			sustituida='J';
      		when pri_letra IN('C') AND substr(entrada,2,1) NOT IN ('H','E','I') then
      			sustituida='K';
      		else
      			sustituida=pri_letra;

      	end case;
      	--corregir el parámetro con las consonantes sustituidas:
      	entrada=sustituida || resto;		
        --raise notice 'entrada tras cambios en primera letra %', entrada;

      	-- 3: corregir "letras compuestas" y volverlas una sola
      	entrada=REPLACE(entrada,'CH','V');
      	entrada=REPLACE(entrada,'QU','K');
      	entrada=REPLACE(entrada,'LL','J');
      	entrada=REPLACE(entrada,'CE','S');
      	entrada=REPLACE(entrada,'CI','S');
      	entrada=REPLACE(entrada,'YA','J');
      	entrada=REPLACE(entrada,'YE','J');
      	entrada=REPLACE(entrada,'YI','J');
      	entrada=REPLACE(entrada,'YO','J');
      	entrada=REPLACE(entrada,'YU','J');
      	entrada=REPLACE(entrada,'GE','J');
      	entrada=REPLACE(entrada,'GI','J');
      	entrada=REPLACE(entrada,'NY','N');
      	-- para debug:    --return entrada;
        --raise notice 'entrada tras cambiar letras compuestas %', entrada;

      	-- EMPIEZA EL CALCULO DEL SOUNDEX
      	-- 4: OBTENER PRIMERA letra
      	pri_letra=substr(entrada,1,1);

      	-- 5: retener el resto del string
      	resto=substr(entrada,2);

      	--6: en el resto del string, quitar vocales y vocales fonéticas
      	resto=translate(resto,'@AEIOUHWY','@');

      	--7: convertir las letras foneticamente equivalentes a numeros  (esto hace que B sea equivalente a V, C con S y Z, etc.)
      	resto=translate(resto, 'BPFVCGKSXZDTLMNRQJ', '111122222233455677');
      	-- así va quedando la cosa
      	soundex=pri_letra || resto;

      	--8: eliminar números iguales adyacentes (A11233 se vuelve A123)
      	anterior=substr(soundex,1,1);
      	corregido=anterior;

      	FOR i IN 2 .. length(soundex) LOOP
      		actual = substr(soundex, i, 1);
      		IF actual <> anterior THEN
      			corregido=corregido || actual;
      			anterior=actual;			
      		END IF;
      	END LOOP;
      	-- así va la cosa
      	soundex=corregido;

      	-- 9: siempre retornar un string de 4 posiciones
      	soundex=rpad(soundex,4,'0');
      	soundex=substr(soundex,1,4);		

      	-- YA ESTUVO
      	RETURN soundex;	
      END;	
      $$;


--
-- Name: soundexespm(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soundexespm(entrada text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
      DECLARE
        soundex text = '' ;
        partes text[];
        sep text = '';
        se text = '';
      BEGIN
        entrada=translate(ltrim(trim(upper(entrada)),'H'),'ÑÁÉÍÓÚÀÈÌÒÙÜ','NAEIOUAEIOUU');
        partes=regexp_split_to_array(entrada, '[^a-zA-Z]');

        --raise notice 'partes=%', partes;
        FOR i IN 1 .. array_upper(partes, 1) LOOP
          se = soundexesp(partes[i]);
          IF length(se) > 0 THEN
            soundex = soundex || sep || se;
            sep = ' ';
            --raise notice 'i=% . soundexesp=%', i, se;
          END IF;
        END LOOP;

      	RETURN soundex;	
      END;	
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actonino; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actonino (
    id bigint NOT NULL,
    caso_id integer NOT NULL,
    fecha date NOT NULL,
    ubicacionpre_id integer NOT NULL,
    presponsable_id integer NOT NULL,
    categoria_id integer NOT NULL,
    persona_id integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: actonino_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.actonino_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actonino_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.actonino_id_seq OWNED BY public.actonino.id;


--
-- Name: agresionmigracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agresionmigracion (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: agresionmigracion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.agresionmigracion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agresionmigracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.agresionmigracion_id_seq OWNED BY public.agresionmigracion.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: asesorhistorico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asesorhistorico (
    id bigint NOT NULL,
    casosjr_id integer NOT NULL,
    fechainicio date NOT NULL,
    fechafin date NOT NULL,
    usuario_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    oficina_id integer
);


--
-- Name: asesorhistorico_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asesorhistorico_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asesorhistorico_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asesorhistorico_id_seq OWNED BY public.asesorhistorico.id;


--
-- Name: autoridadrefugio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.autoridadrefugio (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: autoridadrefugio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.autoridadrefugio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autoridadrefugio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.autoridadrefugio_id_seq OWNED BY public.autoridadrefugio.id;


--
-- Name: causaagresion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.causaagresion (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: causaagresion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.causaagresion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: causaagresion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.causaagresion_id_seq OWNED BY public.causaagresion.id;


--
-- Name: causamigracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.causamigracion (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: causamigracion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.causamigracion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: causamigracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.causamigracion_id_seq OWNED BY public.causamigracion.id;


--
-- Name: causaref_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.causaref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_departamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_departamento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_departamento (
    deplocal_cod integer,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pais_id integer NOT NULL,
    id integer DEFAULT nextval('public.msip_departamento_id_seq'::regclass) NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    codiso character varying(6),
    catiso character varying(64),
    codreg integer,
    ultvigenciaini date,
    ultvigenciafin date,
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision,
    CONSTRAINT departamento_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_municipio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_municipio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_municipio (
    munlocal_cod integer,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    departamento_id integer,
    id integer DEFAULT nextval('public.msip_municipio_id_seq'::regclass) NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    codreg integer,
    ultvigenciaini date,
    ultvigenciafin date,
    tipomun character varying(32),
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision,
    CONSTRAINT municipio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_pais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_pais (
    id integer NOT NULL,
    nombre character varying(200) COLLATE public.es_co_utf_8,
    nombreiso_espanol character varying(200),
    latitud double precision,
    longitud double precision,
    alfa2 character varying(2),
    alfa3 character varying(3),
    codiso integer,
    div1 character varying(100),
    div2 character varying(100),
    div3 character varying(100),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    nombreiso_ingles character varying(512),
    nombreiso_frances character varying(512),
    ultvigenciaini date,
    ultvigenciafin date,
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision
);


--
-- Name: msip_ubicacionpre; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_ubicacionpre (
    id bigint NOT NULL,
    nombre character varying(2000) NOT NULL COLLATE public.es_co_utf_8,
    pais_id integer NOT NULL,
    departamento_id integer,
    municipio_id integer,
    centropoblado_id integer,
    lugar character varying(500),
    sitio character varying(500),
    tsitio_id integer,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nombre_sin_pais character varying(500),
    vereda_id integer,
    observaciones character varying(5000),
    fechacreacion date DEFAULT now() NOT NULL,
    fechadeshabilitacion date
);


--
-- Name: sivel2_gen_victima_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_victima_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_victima (
    persona_id integer NOT NULL,
    caso_id integer NOT NULL,
    hijos integer,
    profesion_id integer DEFAULT 22 NOT NULL,
    rangoedad_id integer DEFAULT 6 NOT NULL,
    filiacion_id integer DEFAULT 10 NOT NULL,
    sectorsocial_id integer DEFAULT 15 NOT NULL,
    organizacion_id integer DEFAULT 16 NOT NULL,
    vinculoestado_id integer DEFAULT 38 NOT NULL,
    organizacionarmada integer DEFAULT 35 NOT NULL,
    anotaciones character varying(1000),
    iglesia_id integer DEFAULT 1,
    orientacionsexual character(1) DEFAULT 'S'::bpchar NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_victima_id_seq'::regclass) NOT NULL,
    CONSTRAINT victima_hijos_check CHECK (((hijos IS NULL) OR ((hijos >= 0) AND (hijos <= 100)))),
    CONSTRAINT victima_orientacionsexual_check CHECK (((orientacionsexual = 'B'::bpchar) OR (orientacionsexual = 'G'::bpchar) OR (orientacionsexual = 'H'::bpchar) OR (orientacionsexual = 'I'::bpchar) OR (orientacionsexual = 'L'::bpchar) OR (orientacionsexual = 'O'::bpchar) OR (orientacionsexual = 'S'::bpchar) OR (orientacionsexual = 'T'::bpchar)))
);


--
-- Name: sivel2_sjr_casosjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_casosjr (
    caso_id integer NOT NULL,
    fecharec date NOT NULL,
    asesor integer NOT NULL,
    oficina_id integer DEFAULT 1,
    direccion character varying(1000),
    detcomosupo character varying(5000),
    contacto_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    comosupo_id integer DEFAULT 1,
    fechasalida date,
    salida_id integer,
    fechallegada date,
    llegada_id integer,
    categoriaref integer,
    observacionesref character varying(5000),
    concentimientosjr boolean,
    concentimientobd boolean,
    proteccion_id integer,
    estatusmigratorio_id integer DEFAULT 0,
    memo1612 character varying(5000),
    estatus_refugio character varying(5000),
    fechadecrefugio date,
    docrefugiado character varying(128),
    fechasalidam date,
    salidam_id integer,
    fechallegadam date,
    llegadam_id integer,
    motivom character varying(5000),
    asesorfechaini date,
    ninosdelconflicto boolean
);


--
-- Name: sivel2_sjr_desplazamiento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_desplazamiento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_desplazamiento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_desplazamiento (
    caso_id integer NOT NULL,
    fechaexpulsion date NOT NULL,
    fechallegada date NOT NULL,
    clasifdesp_id integer DEFAULT 0 NOT NULL,
    tipodesp_id integer DEFAULT 0 NOT NULL,
    descripcion character varying(5000),
    otrosdatos character varying(1000),
    declaro character(1),
    hechosdeclarados character varying(5000),
    fechadeclaracion date,
    departamentodecl integer,
    municipiodecl integer,
    declaroante_id integer DEFAULT 0,
    inclusion_id integer DEFAULT 1,
    acreditacion_id integer DEFAULT 0,
    retornado boolean,
    reubicado boolean,
    connacionalretorno boolean,
    acompestado boolean,
    connacionaldeportado boolean,
    oficioantes character varying(5000),
    modalidadtierra_id integer DEFAULT 0,
    materialesperdidos character varying(5000),
    inmaterialesperdidos character varying(5000),
    protegiorupta boolean,
    documentostierra character varying(5000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_sjr_desplazamiento_id_seq'::regclass) NOT NULL,
    expulsionubicacionpre_id integer,
    llegadaubicacionpre_id integer,
    establecerse boolean,
    destinoubicacionpre_id integer,
    declaracionruv_id integer,
    CONSTRAINT desplazamiento_declaro_check CHECK (((declaro = 'S'::bpchar) OR (declaro = 'N'::bpchar) OR (declaro = 'R'::bpchar)))
);


--
-- Name: cmunex; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cmunex AS
 SELECT ( SELECT msip_pais.nombre
           FROM public.msip_pais
          WHERE (msip_pais.id = ubicacion.pais_id)) AS pais,
    ( SELECT msip_departamento.nombre
           FROM public.msip_departamento
          WHERE (msip_departamento.id = ubicacion.departamento_id)) AS departamento,
    ( SELECT msip_municipio.nombre
           FROM public.msip_municipio
          WHERE (msip_municipio.id = ubicacion.municipio_id)) AS municipio,
        CASE
            WHEN (casosjr.contacto_id = victima.persona_id) THEN 1
            ELSE 0
        END AS contacto,
        CASE
            WHEN (casosjr.contacto_id <> victima.persona_id) THEN 1
            ELSE 0
        END AS beneficiario,
    1 AS npersona
   FROM public.sivel2_sjr_desplazamiento desplazamiento,
    public.msip_ubicacionpre ubicacion,
    public.sivel2_gen_victima victima,
    public.sivel2_sjr_casosjr casosjr
  WHERE ((casosjr.caso_id = desplazamiento.caso_id) AND (desplazamiento.caso_id = victima.caso_id) AND (desplazamiento.expulsionubicacionpre_id = ubicacion.id));


--
-- Name: cmunrec; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cmunrec AS
 SELECT ( SELECT msip_pais.nombre
           FROM public.msip_pais
          WHERE (msip_pais.id = ubicacion.pais_id)) AS pais,
    ( SELECT msip_departamento.nombre
           FROM public.msip_departamento
          WHERE (msip_departamento.id = ubicacion.departamento_id)) AS departamento,
    ( SELECT msip_municipio.nombre
           FROM public.msip_municipio
          WHERE (msip_municipio.id = ubicacion.municipio_id)) AS municipio,
        CASE
            WHEN (casosjr.contacto_id = victima.persona_id) THEN 1
            ELSE 0
        END AS contacto,
        CASE
            WHEN (casosjr.contacto_id <> victima.persona_id) THEN 1
            ELSE 0
        END AS beneficiario,
    1 AS npersona
   FROM public.sivel2_sjr_desplazamiento desplazamiento,
    public.msip_ubicacionpre ubicacion,
    public.sivel2_gen_victima victima,
    public.sivel2_sjr_casosjr casosjr
  WHERE ((casosjr.caso_id = desplazamiento.caso_id) AND (desplazamiento.caso_id = victima.caso_id) AND (desplazamiento.llegadaubicacionpre_id = ubicacion.id));


--
-- Name: cor1440_gen_actividad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad (
    id integer NOT NULL,
    minutos integer,
    nombre character varying(500),
    objetivo character varying(5000),
    resultado character varying(5000),
    fecha date NOT NULL,
    observaciones character varying(5000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    oficina_id integer NOT NULL,
    usuario_id integer NOT NULL,
    lugar character varying(500),
    ubicacionpre_id integer,
    covid boolean
);


--
-- Name: cor1440_gen_actividad_actividadpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_actividadpf (
    actividad_id bigint NOT NULL,
    actividadpf_id bigint NOT NULL
);


--
-- Name: cor1440_gen_actividad_proyectofinanciero_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_proyectofinanciero_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_proyectofinanciero (
    actividad_id integer NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    id integer DEFAULT nextval('public.cor1440_gen_actividad_proyectofinanciero_id_seq'::regclass) NOT NULL
);


--
-- Name: cor1440_gen_actividadpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadpf (
    id integer NOT NULL,
    proyectofinanciero_id integer,
    nombrecorto character varying(15),
    titulo character varying(255),
    descripcion character varying(5000),
    resultadopf_id integer,
    actividadtipo_id integer,
    indicadorgifmm_id integer,
    formulario_id integer,
    heredade_id integer
);


--
-- Name: cor1440_gen_asistencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_asistencia (
    id bigint NOT NULL,
    actividad_id integer NOT NULL,
    persona_id integer NOT NULL,
    rangoedadac_id integer,
    externo boolean,
    orgsocial_id integer,
    perfilorgsocial_id integer,
    discapacidad boolean DEFAULT false,
    telefono character varying(127)
);


--
-- Name: msip_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_persona (
    id integer DEFAULT nextval('public.msip_persona_id_seq'::regclass) NOT NULL,
    nombres character varying(100) NOT NULL COLLATE public.es_co_utf_8,
    apellidos character varying(100) NOT NULL COLLATE public.es_co_utf_8,
    anionac integer,
    mesnac integer,
    dianac integer,
    sexo character(1) DEFAULT 'S'::bpchar NOT NULL,
    numerodocumento character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pais_id integer,
    nacionalde integer,
    tdocumento_id integer NOT NULL,
    departamento_id integer,
    municipio_id integer,
    centropoblado_id integer,
    buscable tsvector,
    ultimoperfilorgsocial_id integer,
    ultimoestatusmigratorio_id integer,
    ppt_obsoleto character varying(32),
    etnia_id integer DEFAULT 1 NOT NULL,
    ultimadiscapacidad_id integer DEFAULT 7 NOT NULL,
    telefono character varying(127),
    CONSTRAINT persona_check CHECK (((dianac IS NULL) OR (((dianac >= 1) AND (((mesnac = 1) OR (mesnac = 3) OR (mesnac = 5) OR (mesnac = 7) OR (mesnac = 8) OR (mesnac = 10) OR (mesnac = 12)) AND (dianac <= 31))) OR (((mesnac = 4) OR (mesnac = 6) OR (mesnac = 9) OR (mesnac = 11)) AND (dianac <= 30)) OR ((mesnac = 2) AND (dianac <= 29))))),
    CONSTRAINT persona_mesnac_check CHECK (((mesnac IS NULL) OR ((mesnac >= 1) AND (mesnac <= 12)))),
    CONSTRAINT persona_sexo_check CHECK (('MHSO'::text ~~ (('%'::text || (sexo)::text) || '%'::text)))
);


--
-- Name: consbenefactcaso2; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.consbenefactcaso2 AS
 SELECT persona_id,
    array_agg(DISTINCT actividad_id) AS actividad_ids,
    array_agg(DISTINCT actividad_oficina_id) AS actividad_oficina_ids
   FROM ( SELECT DISTINCT sub.persona_id,
            sub.actividad_id,
            sub.actividad_oficina_id
           FROM ( SELECT per.id AS persona_id,
                    ac.id AS actividad_id,
                    ac.fecha AS actividad_fecha,
                    ac.oficina_id AS actividad_oficina_id,
                    apf.proyectofinanciero_id AS actividad_proyectofinanciero_id,
                    aapf.actividadpf_id AS actividad_actividadpf_id
                   FROM (((((public.msip_persona per
                     LEFT JOIN public.cor1440_gen_asistencia asis ON ((per.id = asis.persona_id)))
                     LEFT JOIN public.cor1440_gen_actividad ac ON ((ac.id = asis.actividad_id)))
                     LEFT JOIN public.cor1440_gen_actividad_proyectofinanciero apf ON ((apf.actividad_id = ac.id)))
                     LEFT JOIN public.cor1440_gen_actividad_actividadpf aapf ON ((aapf.actividad_id = ac.id)))
                     LEFT JOIN public.cor1440_gen_actividadpf apf2 ON ((apf2.proyectofinanciero_id = apf.proyectofinanciero_id)))
                  WHERE (true AND (ac.fecha >= '2024-01-01'::date) AND (ac.fecha <= '2024-06-30'::date))) sub) c1
  GROUP BY persona_id
  WITH NO DATA;


--
-- Name: msip_perfilorgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_perfilorgsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_tdocumento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tdocumento (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    sigla character varying(500) NOT NULL,
    formatoregex character varying(500),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    ayuda character varying(1000)
);


--
-- Name: sivel2_gen_caso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso (
    id integer DEFAULT nextval('public.sivel2_gen_caso_id_seq'::regclass) NOT NULL,
    titulo character varying(50),
    fecha date NOT NULL,
    hora character varying(10),
    duracion character varying(10),
    memo text NOT NULL,
    grconfiabilidad character varying(5),
    gresclarecimiento character varying(5),
    grimpunidad character varying(8),
    grinformacion character varying(8),
    bienes text,
    intervalo_id integer DEFAULT 5,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ubicacion_id integer
);


--
-- Name: sivel2_sjr_victimasjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_victimasjr (
    sindocumento boolean,
    estadocivil_id integer DEFAULT 0,
    rolfamilia_id integer DEFAULT 0 NOT NULL,
    cabezafamilia boolean,
    maternidad_id integer DEFAULT 0,
    discapacitado boolean,
    actividadoficio_id integer DEFAULT 0,
    escolaridad_id integer DEFAULT 0,
    asisteescuela boolean,
    tienesisben boolean,
    departamento_id integer,
    municipio_id integer,
    nivelsisben integer,
    regimensalud_id integer DEFAULT 0,
    eps character varying(1000),
    libretamilitar boolean,
    distrito integer,
    progadultomayor boolean,
    fechadesagregacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    victima_id integer NOT NULL,
    actualtrabajando boolean,
    discapacidad_id integer
);


--
-- Name: consbenefactcaso; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.consbenefactcaso AS
 SELECT c2.persona_id,
    persona.nombres AS persona_nombres,
    persona.apellidos AS persona_apellidos,
    tdocumento.sigla AS persona_tdocumento,
    persona.numerodocumento AS persona_numerodocumento,
    persona.sexo AS persona_sexo,
    ((((COALESCE((persona.anionac)::text, ''::text) || '-'::text) || COALESCE((persona.mesnac)::text, ''::text)) || '-'::text) || COALESCE((persona.dianac)::text, ''::text)) AS persona_fechanac,
    public.msip_edad_de_fechanac_fecharef(persona.anionac, persona.mesnac, persona.dianac, (EXTRACT(year FROM now()))::integer, (EXTRACT(month FROM now()))::integer, (EXTRACT(day FROM now()))::integer) AS persona_edad_actual,
    pais.nombre AS persona_paisnac,
    COALESCE(perfilorgsocial.nombre) AS persona_ultimoperfilorgsocial,
    victima.id AS victima_id,
    caso.id AS caso_id,
    casosjr.fecharec AS caso_fecharec,
        CASE
            WHEN (casosjr.contacto_id = persona.id) THEN 'Si'::text
            ELSE 'No'::text
        END AS caso_titular,
    persona.telefono AS persona_telefono,
    c2.actividad_ids,
    c2.actividad_oficina_ids
   FROM ((((((((public.consbenefactcaso2 c2
     JOIN public.msip_persona persona ON ((c2.persona_id = persona.id)))
     JOIN public.msip_tdocumento tdocumento ON ((persona.tdocumento_id = tdocumento.id)))
     LEFT JOIN public.msip_pais pais ON ((persona.pais_id = pais.id)))
     LEFT JOIN public.msip_perfilorgsocial perfilorgsocial ON ((persona.ultimoperfilorgsocial_id = perfilorgsocial.id)))
     LEFT JOIN public.sivel2_gen_victima victima ON ((victima.persona_id = persona.id)))
     LEFT JOIN public.sivel2_sjr_victimasjr victimasjr ON (((victimasjr.victima_id = victima.id) AND (victimasjr.fechadesagregacion IS NULL))))
     LEFT JOIN public.sivel2_gen_caso caso ON ((victima.caso_id = caso.id)))
     LEFT JOIN public.sivel2_sjr_casosjr casosjr ON ((casosjr.caso_id = caso.id)))
  WITH NO DATA;


--
-- Name: cor1440_gen_financiador; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_financiador (
    id integer NOT NULL,
    nombre character varying(1000),
    observaciones character varying(5000),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    nombregifmm character varying(256)
);


--
-- Name: cor1440_gen_financiador_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_financiador_proyectofinanciero (
    financiador_id integer NOT NULL,
    proyectofinanciero_id integer NOT NULL
);


--
-- Name: cor1440_gen_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_proyectofinanciero (
    id integer NOT NULL,
    nombre character varying(1000),
    observaciones character varying(5000),
    fechainicio date,
    fechacierre date,
    responsable_id integer,
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    compromisos character varying(5000),
    monto numeric,
    sectorapc_id integer,
    titulo character varying(1000),
    poromision boolean,
    fechaformulacion date,
    fechaaprobacion date,
    fechaliquidacion date,
    estado character varying(1) DEFAULT 'E'::character varying,
    dificultad character varying(1) DEFAULT 'N'::character varying,
    tipomoneda_id integer,
    saldoaejecutarp numeric(20,2),
    centrocosto character varying(500),
    tasaej double precision,
    montoej double precision,
    aportepropioej double precision,
    aporteotrosej double precision,
    presupuestototalej double precision
);


--
-- Name: depgifmm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.depgifmm (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: detallefinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.detallefinanciero (
    id bigint NOT NULL,
    actividad_id integer NOT NULL,
    proyectofinanciero_id integer,
    actividadpf_id integer,
    unidadayuda_id integer,
    cantidad integer,
    valorunitario integer,
    valortotal integer,
    mecanismodeentrega_id integer,
    modalidadentrega_id integer,
    tipotransferencia_id integer,
    frecuenciaentrega_id integer,
    numeromeses integer,
    numeroasistencia integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: detallefinanciero_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.detallefinanciero_persona (
    detallefinanciero_id integer NOT NULL,
    persona_id integer
);


--
-- Name: msip_oficina_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_oficina_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_oficina; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_oficina (
    id integer DEFAULT nextval('public.msip_oficina_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    pais_id integer,
    departamento_id integer,
    municipio_id integer,
    centropoblado_id integer,
    territorial_id integer,
    CONSTRAINT msip_oficina_fechadeshabilitacion_chequeo CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: mungifmm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mungifmm (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: consgifmm; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.consgifmm AS
 SELECT (((((cor1440_gen_actividad.id)::text || '-'::text) || (cor1440_gen_actividadpf.id)::text) || '-'::text) || COALESCE((detallefinanciero.id)::text, ''::text)) AS id,
    detallefinanciero.id AS detallefinanciero_id,
    cor1440_gen_actividad.id AS actividad_id,
    cor1440_gen_actividadpf.proyectofinanciero_id,
    cor1440_gen_actividadpf.id AS actividadpf_id,
    cor1440_gen_actividad.objetivo AS actividad_objetivo,
    cor1440_gen_actividad.fecha,
    cor1440_gen_proyectofinanciero.nombre AS conveniofinanciado_nombre,
    cor1440_gen_actividadpf.titulo AS actividadmarcologico_nombre,
    depgifmm.nombre AS departamento_gifmm,
    mungifmm.nombre AS municipio_gifmm,
    ( SELECT msip_oficina.nombre
           FROM public.msip_oficina
          WHERE (msip_oficina.id = cor1440_gen_actividad.oficina_id)
         LIMIT 1) AS oficina,
    cor1440_gen_actividad.nombre AS actividad_nombre,
    simp.socio_principal,
        CASE
            WHEN ((simp.socio_principal)::text = 'SJR Col'::text) THEN 'Directa'::text
            ELSE 'Indirecta'::text
        END AS tipo_implementacion,
        CASE
            WHEN ((simp.socio_principal)::text = 'SJR Col'::text) THEN ''::text
            ELSE 'SJR Col'::text
        END AS socio_implementador,
    'En proceso'::text AS estado,
    array_to_string(
        CASE
            WHEN (detallefinanciero.id IS NULL) THEN ARRAY( SELECT DISTINCT subpersona_ids.persona_id
               FROM ( SELECT cor1440_gen_asistencia.persona_id
                       FROM public.cor1440_gen_asistencia
                      WHERE (cor1440_gen_asistencia.actividad_id = cor1440_gen_actividad.id)) subpersona_ids)
            ELSE ARRAY( SELECT detallefinanciero_persona.persona_id
               FROM public.detallefinanciero_persona
              WHERE (detallefinanciero_persona.detallefinanciero_id = detallefinanciero.id))
        END, ','::text) AS beneficiarios_ids
   FROM ((((((((((public.cor1440_gen_actividad
     JOIN public.cor1440_gen_actividad_actividadpf ON ((cor1440_gen_actividad.id = cor1440_gen_actividad_actividadpf.actividad_id)))
     JOIN public.cor1440_gen_actividadpf ON ((cor1440_gen_actividadpf.id = cor1440_gen_actividad_actividadpf.actividadpf_id)))
     JOIN public.cor1440_gen_proyectofinanciero ON ((cor1440_gen_actividadpf.proyectofinanciero_id = cor1440_gen_proyectofinanciero.id)))
     JOIN ( SELECT pf.id AS proyectofinanciero_id,
            ( SELECT COALESCE(f.nombregifmm, f.nombre) AS "coalesce"
                   FROM (public.cor1440_gen_financiador_proyectofinanciero fpf
                     JOIN public.cor1440_gen_financiador f ON ((f.id = fpf.financiador_id)))
                  WHERE (fpf.proyectofinanciero_id = pf.id)
                 LIMIT 1) AS socio_principal
           FROM public.cor1440_gen_proyectofinanciero pf) simp ON ((simp.proyectofinanciero_id = cor1440_gen_proyectofinanciero.id)))
     LEFT JOIN public.detallefinanciero ON ((detallefinanciero.actividad_id = cor1440_gen_actividad.id)))
     LEFT JOIN public.msip_ubicacionpre ON ((cor1440_gen_actividad.ubicacionpre_id = msip_ubicacionpre.id)))
     LEFT JOIN public.msip_departamento ON ((msip_ubicacionpre.departamento_id = msip_departamento.id)))
     LEFT JOIN public.depgifmm ON ((msip_departamento.deplocal_cod = depgifmm.id)))
     LEFT JOIN public.msip_municipio ON ((msip_ubicacionpre.municipio_id = msip_municipio.id)))
     LEFT JOIN public.mungifmm ON ((((msip_departamento.deplocal_cod * 1000) + msip_municipio.munlocal_cod) = mungifmm.id)))
  WHERE ((cor1440_gen_actividadpf.indicadorgifmm_id IS NOT NULL) AND ((detallefinanciero.proyectofinanciero_id IS NULL) OR (detallefinanciero.proyectofinanciero_id = cor1440_gen_actividadpf.proyectofinanciero_id)) AND ((detallefinanciero.actividadpf_id IS NULL) OR (detallefinanciero.actividadpf_id = cor1440_gen_actividadpf.id)))
  ORDER BY cor1440_gen_actividad.fecha DESC, cor1440_gen_actividad.id
  WITH NO DATA;


--
-- Name: consgifmm_exp; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.consgifmm_exp AS
 SELECT consgifmm.id AS consgifmm_id,
    consgifmm.beneficiarios_ids,
    detallefinanciero.id AS detallefinanciero_id,
    cor1440_gen_actividad.id AS actividad_id,
    cor1440_gen_actividadpf.proyectofinanciero_id,
    cor1440_gen_actividadpf.id AS actividadpf_id,
    detallefinanciero.unidadayuda_id,
    detallefinanciero.cantidad,
    detallefinanciero.valorunitario,
    detallefinanciero.valortotal,
    detallefinanciero.mecanismodeentrega_id,
    detallefinanciero.modalidadentrega_id,
    detallefinanciero.tipotransferencia_id,
    detallefinanciero.frecuenciaentrega_id,
    detallefinanciero.numeromeses,
    detallefinanciero.numeroasistencia,
        CASE
            WHEN (detallefinanciero.id IS NULL) THEN ARRAY( SELECT DISTINCT subpersona_ids.persona_id
               FROM ( SELECT cor1440_gen_asistencia.persona_id
                       FROM public.cor1440_gen_asistencia
                      WHERE (cor1440_gen_asistencia.actividad_id = cor1440_gen_actividad.id)) subpersona_ids)
            ELSE ARRAY( SELECT detallefinanciero_persona.persona_id
               FROM public.detallefinanciero_persona
              WHERE (detallefinanciero_persona.detallefinanciero_id = detallefinanciero.id))
        END AS persona_ids,
    cor1440_gen_actividad.objetivo AS actividad_objetivo,
    cor1440_gen_actividad.fecha,
    cor1440_gen_proyectofinanciero.nombre AS conveniofinanciado_nombre,
    cor1440_gen_actividadpf.titulo AS actividadmarcologico_nombre,
    depgifmm.nombre AS departamento_gifmm,
    mungifmm.nombre AS municipio_gifmm,
    ( SELECT msip_oficina.nombre
           FROM public.msip_oficina
          WHERE (msip_oficina.id = cor1440_gen_actividad.oficina_id)
         LIMIT 1) AS oficina,
    cor1440_gen_actividad.nombre AS actividad_nombre
   FROM ((((((((((public.consgifmm
     JOIN public.cor1440_gen_actividad ON ((consgifmm.actividad_id = cor1440_gen_actividad.id)))
     JOIN public.cor1440_gen_actividad_actividadpf ON (((consgifmm.actividadpf_id = cor1440_gen_actividad_actividadpf.actividadpf_id) AND (cor1440_gen_actividad.id = cor1440_gen_actividad_actividadpf.actividad_id))))
     JOIN public.cor1440_gen_actividadpf ON ((cor1440_gen_actividadpf.id = cor1440_gen_actividad_actividadpf.actividadpf_id)))
     JOIN public.cor1440_gen_proyectofinanciero ON ((cor1440_gen_actividadpf.proyectofinanciero_id = cor1440_gen_proyectofinanciero.id)))
     LEFT JOIN public.detallefinanciero ON (((consgifmm.detallefinanciero_id = cor1440_gen_actividad.id) AND (detallefinanciero.actividad_id = cor1440_gen_actividad.id))))
     LEFT JOIN public.msip_ubicacionpre ON ((cor1440_gen_actividad.ubicacionpre_id = msip_ubicacionpre.id)))
     LEFT JOIN public.msip_departamento ON ((msip_ubicacionpre.departamento_id = msip_departamento.id)))
     LEFT JOIN public.depgifmm ON ((msip_departamento.deplocal_cod = depgifmm.id)))
     LEFT JOIN public.msip_municipio ON ((msip_ubicacionpre.municipio_id = msip_municipio.id)))
     LEFT JOIN public.mungifmm ON ((((msip_departamento.deplocal_cod * 1000) + msip_municipio.munlocal_cod) = mungifmm.id)))
  WHERE ((cor1440_gen_actividadpf.indicadorgifmm_id IS NOT NULL) AND ((detallefinanciero.proyectofinanciero_id IS NULL) OR (detallefinanciero.proyectofinanciero_id = cor1440_gen_actividadpf.proyectofinanciero_id)) AND ((detallefinanciero.actividadpf_id IS NULL) OR (detallefinanciero.actividadpf_id = cor1440_gen_actividadpf.id)) AND (consgifmm.id = ANY (ARRAY['57356-1121-'::text, '57371-1273-'::text, '57379-1273-'::text, '57380-1273-'::text, '57381-1273-'::text, '57384-1273-'::text, '57405-1273-'::text, '57410-1252-'::text, '57414-1276-'::text, '57418-1288-'::text, '57387-1276-'::text, '57376-1264-'::text, '57385-1279-'::text, '57385-1281-'::text, '57417-1281-'::text, '57417-1279-'::text, '57367-1275-'::text])))
  ORDER BY cor1440_gen_actividad.fecha DESC, cor1440_gen_actividad.id
  WITH NO DATA;


--
-- Name: sivel2_gen_categoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_categoria (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    pconsolidado_id integer,
    contadaen integer,
    tipocat character(1) DEFAULT 'I'::bpchar,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    supracategoria_id integer,
    nombre_res1612 character varying(128),
    CONSTRAINT categoria_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion))),
    CONSTRAINT categoria_tipocat_check CHECK (((tipocat = 'I'::bpchar) OR (tipocat = 'C'::bpchar) OR (tipocat = 'O'::bpchar)))
);


--
-- Name: sivel2_gen_presponsable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_presponsable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_presponsable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_presponsable (
    id integer DEFAULT nextval('public.sivel2_gen_presponsable_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    papa_id integer,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    nombre_res1612 character varying(128),
    CONSTRAINT presponsable_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: consninovictima; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.consninovictima AS
 SELECT actonino.id AS actonino_id,
    actonino.caso_id,
    casosjr.oficina_id,
    casosjr.fecharec,
    persona.id AS persona_id,
    persona.nombres AS persona_nombres,
    persona.apellidos AS persona_apellidos,
    ((((COALESCE((persona.anionac)::text, ''::text) || '-'::text) || COALESCE((persona.mesnac)::text, ''::text)) || '-'::text) || COALESCE((persona.dianac)::text, ''::text)) AS persona_fechanac,
    public.msip_edad_de_fechanac_fecharef(persona.anionac, persona.mesnac, persona.dianac, (EXTRACT(year FROM actonino.fecha))::integer, (EXTRACT(month FROM actonino.fecha))::integer, (EXTRACT(day FROM actonino.fecha))::integer) AS persona_edad_hecho,
    persona.sexo AS persona_sexo,
    actonino.fecha,
    ubicacionpre.municipio_id,
    (((municipio.nombre)::text || ' / '::text) || (departamento.nombre)::text) AS municipio_departamento,
    actonino.categoria_id,
    actonino.presponsable_id
   FROM ((((((((public.actonino
     JOIN public.msip_persona persona ON ((actonino.persona_id = persona.id)))
     JOIN public.sivel2_gen_caso caso ON ((actonino.caso_id = caso.id)))
     JOIN public.sivel2_sjr_casosjr casosjr ON ((casosjr.caso_id = caso.id)))
     JOIN public.sivel2_gen_categoria categoria ON ((actonino.categoria_id = categoria.id)))
     JOIN public.sivel2_gen_presponsable presponsable ON ((actonino.presponsable_id = presponsable.id)))
     JOIN public.msip_ubicacionpre ubicacionpre ON ((actonino.ubicacionpre_id = ubicacionpre.id)))
     JOIN public.msip_municipio municipio ON ((ubicacionpre.municipio_id = municipio.id)))
     JOIN public.msip_departamento departamento ON ((municipio.departamento_id = departamento.id)))
  ORDER BY persona.nombres, persona.apellidos
  WITH NO DATA;


--
-- Name: consultabd; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.consultabd AS
 SELECT row_number() OVER () AS numfila,
    id,
    nombres,
    apellidos,
    anionac,
    mesnac,
    dianac,
    sexo,
    numerodocumento,
    created_at,
    updated_at,
    pais_id,
    nacionalde,
    tdocumento_id,
    departamento_id,
    municipio_id,
    centropoblado_id,
    buscable,
    ultimoperfilorgsocial_id,
    ultimoestatusmigratorio_id,
    ppt_obsoleto,
    etnia_id,
    ultimadiscapacidad_id
   FROM ( SELECT msip_persona.id,
            msip_persona.nombres,
            msip_persona.apellidos,
            msip_persona.anionac,
            msip_persona.mesnac,
            msip_persona.dianac,
            msip_persona.sexo,
            msip_persona.numerodocumento,
            msip_persona.created_at,
            msip_persona.updated_at,
            msip_persona.pais_id,
            msip_persona.nacionalde,
            msip_persona.tdocumento_id,
            msip_persona.departamento_id,
            msip_persona.municipio_id,
            msip_persona.centropoblado_id,
            msip_persona.buscable,
            msip_persona.ultimoperfilorgsocial_id,
            msip_persona.ultimoestatusmigratorio_id,
            msip_persona.ppt_obsoleto,
            msip_persona.etnia_id,
            msip_persona.ultimadiscapacidad_id
           FROM public.msip_persona) s
  WITH NO DATA;


--
-- Name: cor1440_gen_actividad_actividadtipo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_actividadtipo (
    actividad_id integer,
    actividadtipo_id integer
);


--
-- Name: cor1440_gen_actividad_anexo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_anexo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_anexo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_anexo (
    actividad_id integer NOT NULL,
    anexo_id integer NOT NULL,
    id integer DEFAULT nextval('public.cor1440_gen_actividad_anexo_id_seq'::regclass) NOT NULL
);


--
-- Name: cor1440_gen_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividad_id_seq OWNED BY public.cor1440_gen_actividad.id;


--
-- Name: cor1440_gen_actividad_orgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_orgsocial (
    actividad_id bigint NOT NULL,
    orgsocial_id bigint NOT NULL
);


--
-- Name: cor1440_gen_actividad_proyecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_proyecto (
    id integer NOT NULL,
    actividad_id integer,
    proyecto_id integer
);


--
-- Name: cor1440_gen_actividad_proyecto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_proyecto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_proyecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividad_proyecto_id_seq OWNED BY public.cor1440_gen_actividad_proyecto.id;


--
-- Name: cor1440_gen_actividad_rangoedadac; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_rangoedadac (
    id integer NOT NULL,
    actividad_id integer,
    rangoedadac_id integer,
    ml integer,
    mr integer,
    fl integer,
    fr integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    s integer,
    i integer
);


--
-- Name: cor1440_gen_actividad_rangoedadac_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividad_rangoedadac_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividad_rangoedadac_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividad_rangoedadac_id_seq OWNED BY public.cor1440_gen_actividad_rangoedadac.id;


--
-- Name: cor1440_gen_actividad_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_respuestafor (
    actividad_id integer NOT NULL,
    respuestafor_id integer NOT NULL
);


--
-- Name: cor1440_gen_actividad_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividad_usuario (
    actividad_id integer NOT NULL,
    usuario_id integer NOT NULL
);


--
-- Name: cor1440_gen_actividadarea; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadarea (
    id integer NOT NULL,
    nombre character varying(500),
    observaciones character varying(5000),
    fechacreacion date DEFAULT ('now'::text)::date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cor1440_gen_actividadarea_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividadarea_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividadarea_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividadarea_id_seq OWNED BY public.cor1440_gen_actividadarea.id;


--
-- Name: cor1440_gen_actividadareas_actividad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadareas_actividad (
    id integer NOT NULL,
    actividad_id integer,
    actividadarea_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cor1440_gen_actividadareas_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividadareas_actividad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividadareas_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividadareas_actividad_id_seq OWNED BY public.cor1440_gen_actividadareas_actividad.id;


--
-- Name: cor1440_gen_actividadpf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividadpf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividadpf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividadpf_id_seq OWNED BY public.cor1440_gen_actividadpf.id;


--
-- Name: cor1440_gen_actividadpf_mindicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadpf_mindicadorpf (
    actividadpf_id integer,
    mindicadorpf_id integer
);


--
-- Name: cor1440_gen_actividadtipo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadtipo (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    listadoasistencia boolean
);


--
-- Name: cor1440_gen_actividadtipo_formulario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_actividadtipo_formulario (
    actividadtipo_id integer NOT NULL,
    formulario_id integer NOT NULL
);


--
-- Name: cor1440_gen_actividadtipo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_actividadtipo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_actividadtipo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_actividadtipo_id_seq OWNED BY public.cor1440_gen_actividadtipo.id;


--
-- Name: cor1440_gen_anexo_efecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_anexo_efecto (
    id bigint NOT NULL,
    efecto_id integer,
    anexo_id integer
);


--
-- Name: cor1440_gen_anexo_efecto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_anexo_efecto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_anexo_efecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_anexo_efecto_id_seq OWNED BY public.cor1440_gen_anexo_efecto.id;


--
-- Name: cor1440_gen_anexo_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_anexo_proyectofinanciero (
    id bigint NOT NULL,
    anexo_id integer,
    proyectofinanciero_id integer
);


--
-- Name: cor1440_gen_anexo_proyectofinanciero_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_anexo_proyectofinanciero_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_anexo_proyectofinanciero_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_anexo_proyectofinanciero_id_seq OWNED BY public.cor1440_gen_anexo_proyectofinanciero.id;


--
-- Name: cor1440_gen_asistencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_asistencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_asistencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_asistencia_id_seq OWNED BY public.cor1440_gen_asistencia.id;


--
-- Name: cor1440_gen_benefext; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cor1440_gen_benefext AS
 SELECT DISTINCT actividad_id,
    persona_id,
    persona_actividad_perfil
   FROM ( SELECT ac.id AS actividad_id,
            asis.persona_id,
            COALESCE(porg.nombre) AS persona_actividad_perfil
           FROM ((public.cor1440_gen_actividad ac
             JOIN public.cor1440_gen_asistencia asis ON ((asis.actividad_id = ac.id)))
             LEFT JOIN public.msip_perfilorgsocial porg ON ((porg.id = asis.perfilorgsocial_id)))) sub;


--
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    nusuario character varying(15) NOT NULL,
    password character varying(64) DEFAULT ''::character varying NOT NULL,
    nombre character varying(50) COLLATE public.es_co_utf_8,
    descripcion character varying(50),
    rol integer DEFAULT 4,
    idioma character varying(6) DEFAULT 'es_CO'::character varying NOT NULL,
    id integer DEFAULT nextval('public.usuario_id_seq'::regclass) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    failed_attempts integer,
    unlock_token character varying(64),
    locked_at timestamp without time zone,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    oficina_id integer,
    tema_id integer,
    fincontrato date,
    observadorffechaini date,
    observadorffechafin date,
    territorial_id integer,
    CONSTRAINT usuario_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion))),
    CONSTRAINT usuario_rol_check CHECK ((rol >= 1))
);


--
-- Name: cor1440_gen_benefext2; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cor1440_gen_benefext2 AS
 SELECT a.fecha AS actividad_fecha,
    o.nombre AS actividad_oficina,
    us.nusuario AS actividad_responsable,
    t.sigla AS persona_tipodocumento,
    p.numerodocumento AS persona_numerodocumento,
    p.nombres AS persona_nombres,
    p.apellidos AS persona_apellidos,
    p.sexo AS persona_sexo,
    p.dianac AS persona_dianac,
    p.mesnac AS persona_mesnac,
    p.anionac AS persona_anionac,
    public.msip_edad_de_fechanac_fecharef(p.anionac, p.mesnac, p.dianac, (EXTRACT(year FROM a.fecha))::integer, (EXTRACT(month FROM a.fecha))::integer, (EXTRACT(day FROM a.fecha))::integer) AS persona_actividad_edad,
    b.persona_actividad_perfil,
    (((COALESCE(mun.nombre, ''::character varying))::text || ' / '::text) || (COALESCE(dep.nombre, ''::character varying))::text) AS actividad_municipio,
    a.id AS actividad_id,
    array_to_string(ARRAY( SELECT DISTINCT sivel2_gen_victima.caso_id
           FROM public.sivel2_gen_victima
          WHERE (sivel2_gen_victima.persona_id = p.id)), ','::text) AS persona_caso_ids,
    p.id AS persona_id
   FROM ((((((((public.cor1440_gen_benefext b
     JOIN public.cor1440_gen_actividad a ON ((a.id = b.actividad_id)))
     JOIN public.msip_oficina o ON ((o.id = a.oficina_id)))
     JOIN public.msip_persona p ON ((p.id = b.persona_id)))
     JOIN public.usuario us ON ((us.id = a.usuario_id)))
     LEFT JOIN public.msip_tdocumento t ON ((t.id = p.tdocumento_id)))
     LEFT JOIN public.msip_ubicacionpre u ON ((u.id = a.ubicacionpre_id)))
     LEFT JOIN public.msip_departamento dep ON ((dep.id = u.departamento_id)))
     LEFT JOIN public.msip_municipio mun ON ((mun.id = u.municipio_id)));


--
-- Name: cor1440_gen_benefactividadpf; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.cor1440_gen_benefactividadpf AS
 SELECT actividad_fecha,
    actividad_oficina,
    actividad_responsable,
    persona_tipodocumento,
    persona_numerodocumento,
    persona_nombres,
    persona_apellidos,
    persona_sexo,
    persona_dianac,
    persona_mesnac,
    persona_anionac,
    persona_actividad_edad,
    persona_actividad_perfil,
    actividad_municipio,
    actividad_id,
    persona_caso_ids,
    persona_id,
    array_to_string(ARRAY( SELECT sub.nombre
           FROM ( SELECT DISTINCT pf.id,
                    pf.nombre
                   FROM public.cor1440_gen_proyectofinanciero pf
                  WHERE (pf.id IN ( SELECT apf.proyectofinanciero_id
                           FROM public.cor1440_gen_actividad_proyectofinanciero apf
                          WHERE (apf.actividad_id = be.actividad_id)))
                  ORDER BY pf.id DESC) sub), '; '::text) AS actividad_proyectosfinancieros,
    array_to_string(ARRAY( SELECT sub.nom
           FROM ( SELECT DISTINCT apf.proyectofinanciero_id,
                    (((apf.nombrecorto)::text || ': '::text) || (apf.titulo)::text) AS nom
                   FROM public.cor1440_gen_actividadpf apf
                  WHERE (apf.id IN ( SELECT aapf.actividadpf_id
                           FROM public.cor1440_gen_actividad_actividadpf aapf
                          WHERE (aapf.actividad_id = be.actividad_id)))
                  ORDER BY apf.proyectofinanciero_id DESC) sub), '; '::text) AS actividad_actividadesml,
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1092))) AS "OE2R2.A1",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1093))) AS "OE2R2.A2",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1091))) AS "OE2R1.A1",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1085))) AS "OE1R1.A0",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1086))) AS "OE1R1.A0_5",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1094))) AS "OE2R3.A1",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1095))) AS "OE2R3.A2",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1108))) AS "OE3R2.A1",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1096))) AS "OE2R3.A3",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1107))) AS "OE3R1.A2",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1116))) AS "OE4R1.A3.",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1117))) AS "OE4R1.A4.",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1118))) AS "OE4R1.A5.",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1111))) AS "OE1R1.A4",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1119))) AS "OE4R2.A1.",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1120))) AS "OE4R2.A2.",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1121))) AS "OE4R2.A3.",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1122))) AS "OE4R3.A1.",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1123))) AS "OE4R3.A2.",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1087))) AS "OE1R1.A1",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1089))) AS "OE1R1.A2",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1090))) AS "OE1R1.A3",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1106))) AS "OE3R1.A1",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1109))) AS "OE3R2.A2",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1110))) AS "OE3R2.A3",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1113))) AS "OE1R2.A1",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1114))) AS "OE4R1.A1.",
    ( SELECT count(*) AS count
           FROM public.cor1440_gen_actividad_actividadpf aapf
          WHERE ((aapf.actividad_id = be.actividad_id) AND (aapf.actividadpf_id = 1115))) AS "OE4R1.A2."
   FROM public.cor1440_gen_benefext2 be
  WHERE (true AND (actividad_id IN ( SELECT cor1440_gen_actividad_proyectofinanciero.actividad_id
           FROM public.cor1440_gen_actividad_proyectofinanciero
          WHERE (cor1440_gen_actividad_proyectofinanciero.proyectofinanciero_id = 264))) AND (actividad_fecha >= '2023-07-01'::date) AND (actividad_fecha <= '2023-12-31'::date))
  WITH NO DATA;


--
-- Name: cor1440_gen_beneficiariopf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_beneficiariopf (
    persona_id integer,
    proyectofinanciero_id integer
);


--
-- Name: cor1440_gen_caracterizacionpersona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_caracterizacionpersona (
    id bigint NOT NULL,
    persona_id integer NOT NULL,
    respuestafor_id integer NOT NULL,
    ulteditor_id integer NOT NULL
);


--
-- Name: cor1440_gen_caracterizacionpersona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_caracterizacionpersona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_caracterizacionpersona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_caracterizacionpersona_id_seq OWNED BY public.cor1440_gen_caracterizacionpersona.id;


--
-- Name: cor1440_gen_caracterizacionpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_caracterizacionpf (
    formulario_id integer,
    proyectofinanciero_id integer
);


--
-- Name: cor1440_gen_datointermedioti; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_datointermedioti (
    id bigint NOT NULL,
    nombre character varying(1024) NOT NULL,
    tipoindicador_id integer,
    nombreinterno character varying(127),
    filtro character varying(5000),
    funcion character varying(5000),
    mindicadorpf_id integer
);


--
-- Name: cor1440_gen_datointermedioti_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_datointermedioti_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_datointermedioti_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_datointermedioti_id_seq OWNED BY public.cor1440_gen_datointermedioti.id;


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_datointermedioti_pmindicadorpf (
    id bigint NOT NULL,
    datointermedioti_id integer NOT NULL,
    pmindicadorpf_id integer NOT NULL,
    valor double precision,
    rutaevidencia character varying(5000)
);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_datointermedioti_pmindicadorpf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_datointermedioti_pmindicadorpf_id_seq OWNED BY public.cor1440_gen_datointermedioti_pmindicadorpf.id;


--
-- Name: cor1440_gen_desembolso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_desembolso (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    detalle character varying(5000),
    fecha date,
    valorpesos numeric(20,2),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_desembolso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_desembolso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_desembolso_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_desembolso_id_seq OWNED BY public.cor1440_gen_desembolso.id;


--
-- Name: cor1440_gen_efecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_efecto (
    id bigint NOT NULL,
    indicadorpf_id integer,
    fecha date,
    registradopor_id integer,
    nombre character varying(500),
    descripcion character varying(5000)
);


--
-- Name: cor1440_gen_efecto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_efecto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_efecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_efecto_id_seq OWNED BY public.cor1440_gen_efecto.id;


--
-- Name: cor1440_gen_efecto_orgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_efecto_orgsocial (
    efecto_id integer,
    orgsocial_id integer
);


--
-- Name: cor1440_gen_efecto_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_efecto_respuestafor (
    efecto_id integer,
    respuestafor_id integer
);


--
-- Name: cor1440_gen_financiador_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_financiador_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_financiador_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_financiador_id_seq OWNED BY public.cor1440_gen_financiador.id;


--
-- Name: cor1440_gen_formulario_mindicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_formulario_mindicadorpf (
    formulario_id bigint NOT NULL,
    mindicadorpf_id bigint NOT NULL
);


--
-- Name: cor1440_gen_formulario_tipoindicador; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_formulario_tipoindicador (
    tipoindicador_id integer NOT NULL,
    formulario_id integer NOT NULL
);


--
-- Name: cor1440_gen_indicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_indicadorpf (
    id bigint NOT NULL,
    proyectofinanciero_id integer,
    resultadopf_id integer,
    numero character varying(15) NOT NULL,
    indicador character varying(5000) NOT NULL,
    tipoindicador_id integer,
    objetivopf_id integer,
    CONSTRAINT objetivo_xor_resultado CHECK ((((objetivopf_id IS NOT NULL) OR (resultadopf_id IS NOT NULL)) AND ((objetivopf_id IS NULL) OR (resultadopf_id IS NULL))))
);


--
-- Name: cor1440_gen_indicadorpf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_indicadorpf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_indicadorpf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_indicadorpf_id_seq OWNED BY public.cor1440_gen_indicadorpf.id;


--
-- Name: cor1440_gen_informe; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_informe (
    id integer NOT NULL,
    titulo character varying(500) NOT NULL,
    filtrofechaini date NOT NULL,
    filtrofechafin date NOT NULL,
    filtroproyecto integer,
    filtroactividadarea integer,
    columnanombre boolean,
    columnatipo boolean,
    columnaobjetivo boolean,
    columnaproyecto boolean,
    columnapoblacion boolean,
    recomendaciones character varying(5000),
    avances character varying(5000),
    logros character varying(5000),
    dificultades character varying(5000),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    filtroproyectofinanciero integer,
    filtroresponsable integer,
    filtrooficina integer,
    columnafecha boolean,
    columnaresponsable boolean
);


--
-- Name: cor1440_gen_informe_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_informe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_informe_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_informe_id_seq OWNED BY public.cor1440_gen_informe.id;


--
-- Name: cor1440_gen_informeauditoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_informeauditoria (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    detalle character varying(5000),
    fecha date,
    devoluciones boolean,
    seguimiento character varying(5000),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_informeauditoria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_informeauditoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_informeauditoria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_informeauditoria_id_seq OWNED BY public.cor1440_gen_informeauditoria.id;


--
-- Name: cor1440_gen_informefinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_informefinanciero (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    detalle character varying(5000),
    fecha date,
    devoluciones boolean,
    seguimiento character varying(5000),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_informefinanciero_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_informefinanciero_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_informefinanciero_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_informefinanciero_id_seq OWNED BY public.cor1440_gen_informefinanciero.id;


--
-- Name: cor1440_gen_informenarrativo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_informenarrativo (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    detalle character varying(5000),
    fecha date,
    devoluciones boolean,
    seguimiento character varying(5000),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_informenarrativo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_informenarrativo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_informenarrativo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_informenarrativo_id_seq OWNED BY public.cor1440_gen_informenarrativo.id;


--
-- Name: cor1440_gen_mindicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_mindicadorpf (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    indicadorpf_id integer NOT NULL,
    formulacion character varying(512),
    frecuenciaanual character varying(128),
    descd1 character varying,
    descd2 character varying,
    descd3 character varying,
    meta double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    medircon integer,
    funcionresultado character varying(5000)
);


--
-- Name: cor1440_gen_mindicadorpf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_mindicadorpf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_mindicadorpf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_mindicadorpf_id_seq OWNED BY public.cor1440_gen_mindicadorpf.id;


--
-- Name: cor1440_gen_objetivopf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_objetivopf (
    id bigint NOT NULL,
    proyectofinanciero_id integer,
    numero character varying(15) NOT NULL,
    objetivo character varying(5000) NOT NULL
);


--
-- Name: cor1440_gen_objetivopf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_objetivopf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_objetivopf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_objetivopf_id_seq OWNED BY public.cor1440_gen_objetivopf.id;


--
-- Name: cor1440_gen_plantillahcm_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_plantillahcm_proyectofinanciero (
    plantillahcm_id integer,
    proyectofinanciero_id integer
);


--
-- Name: cor1440_gen_pmindicadorpf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_pmindicadorpf (
    id bigint NOT NULL,
    mindicadorpf_id integer NOT NULL,
    finicio date,
    ffin date,
    restiempo character varying(128),
    dmed1 double precision,
    dmed2 double precision,
    dmed3 double precision,
    datosmedicion json,
    resind double precision,
    meta double precision,
    resindicador json,
    porcump double precision,
    analisis character varying(4096),
    acciones character varying(4096),
    responsables character varying(4096),
    plazo character varying(4096),
    fecha date,
    urlev1 character varying(4096),
    urlev2 character varying(4096),
    urlev3 character varying(4096),
    rutaevidencia character varying(4096),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cor1440_gen_pmindicadorpf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_pmindicadorpf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_pmindicadorpf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_pmindicadorpf_id_seq OWNED BY public.cor1440_gen_pmindicadorpf.id;


--
-- Name: cor1440_gen_proyecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_proyecto (
    id integer NOT NULL,
    nombre character varying(1000),
    observaciones character varying(5000),
    fechainicio date,
    fechacierre date,
    resultados character varying(5000),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cor1440_gen_proyecto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_proyecto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_proyecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_proyecto_id_seq OWNED BY public.cor1440_gen_proyecto.id;


--
-- Name: cor1440_gen_proyecto_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_proyecto_proyectofinanciero (
    proyecto_id integer NOT NULL,
    proyectofinanciero_id integer NOT NULL
);


--
-- Name: cor1440_gen_proyectofinanciero_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_proyectofinanciero_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_proyectofinanciero_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_proyectofinanciero_id_seq OWNED BY public.cor1440_gen_proyectofinanciero.id;


--
-- Name: cor1440_gen_proyectofinanciero_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_proyectofinanciero_usuario (
    id bigint NOT NULL,
    proyectofinanciero_id integer NOT NULL,
    usuario_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_proyectofinanciero_usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_proyectofinanciero_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_proyectofinanciero_usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_proyectofinanciero_usuario_id_seq OWNED BY public.cor1440_gen_proyectofinanciero_usuario.id;


--
-- Name: cor1440_gen_rangoedadac; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_rangoedadac (
    id integer NOT NULL,
    nombre character varying,
    limiteinferior integer,
    limitesuperior integer,
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000)
);


--
-- Name: cor1440_gen_rangoedadac_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_rangoedadac_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_rangoedadac_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_rangoedadac_id_seq OWNED BY public.cor1440_gen_rangoedadac.id;


--
-- Name: cor1440_gen_resultadopf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_resultadopf (
    id bigint NOT NULL,
    proyectofinanciero_id integer,
    objetivopf_id integer,
    numero character varying(15) NOT NULL,
    resultado character varying(5000) NOT NULL
);


--
-- Name: cor1440_gen_resultadopf_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_resultadopf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_resultadopf_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_resultadopf_id_seq OWNED BY public.cor1440_gen_resultadopf.id;


--
-- Name: cor1440_gen_sectorapc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_sectorapc (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cor1440_gen_sectorapc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_sectorapc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_sectorapc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_sectorapc_id_seq OWNED BY public.cor1440_gen_sectorapc.id;


--
-- Name: cor1440_gen_tipoindicador; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_tipoindicador (
    id bigint NOT NULL,
    nombre character varying(32),
    medircon integer,
    espcampos character varying(1000),
    espvaloresomision character varying(1000),
    espvalidaciones character varying(1000),
    esptipometa character varying(32),
    espfuncionmedir character varying(1000),
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at date,
    updated_at date,
    descd1 character varying(32),
    descd2 character varying(32),
    descd3 character varying(32),
    descd4 character varying(32)
);


--
-- Name: cor1440_gen_tipoindicador_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_tipoindicador_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_tipoindicador_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_tipoindicador_id_seq OWNED BY public.cor1440_gen_tipoindicador.id;


--
-- Name: cor1440_gen_tipomoneda; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cor1440_gen_tipomoneda (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    codiso4217 character varying(3) NOT NULL,
    simbolo character varying(10),
    pais_id integer,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cor1440_gen_tipomoneda_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cor1440_gen_tipomoneda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cor1440_gen_tipomoneda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cor1440_gen_tipomoneda_id_seq OWNED BY public.cor1440_gen_tipomoneda.id;


--
-- Name: cor1440_gen_vista_asist_rangoe_sexo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cor1440_gen_vista_asist_rangoe_sexo AS
 SELECT actividad_id,
    rangoedadac_id,
    sexo,
    count(persona_id) AS cuenta
   FROM ( SELECT sub.actividad_id,
            sub.persona_id,
            sub.sexo,
            re.id AS rangoedadac_id
           FROM (( SELECT asi.actividad_id,
                    asi.persona_id,
                    p.sexo,
                    public.msip_edad_de_fechanac_fecharef(p.anionac, p.mesnac, p.dianac, (EXTRACT(year FROM a.fecha))::integer, (EXTRACT(month FROM a.fecha))::integer, (EXTRACT(day FROM a.fecha))::integer) AS edad
                   FROM ((public.cor1440_gen_asistencia asi
                     JOIN public.msip_persona p ON ((p.id = asi.persona_id)))
                     JOIN public.cor1440_gen_actividad a ON ((a.id = asi.actividad_id)))) sub
             JOIN public.cor1440_gen_rangoedadac re ON ((((re.id = 7) AND (sub.edad IS NULL)) OR ((re.id <> 7) AND (re.limiteinferior <= sub.edad) AND ((re.limitesuperior IS NULL) OR (sub.edad <= re.limitesuperior))))))) sub2
  GROUP BY actividad_id, rangoedadac_id, sexo
  ORDER BY actividad_id, rangoedadac_id, sexo;


--
-- Name: cor1440_gen_vista_resumentpob; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cor1440_gen_vista_resumentpob AS
 SELECT actividad_id,
    tpob
   FROM ( SELECT a.id AS actividad_id,
            array_to_string(ARRAY( SELECT (((((((((cor1440_gen_actividad_rangoedadac.rangoedadac_id)::text || ' '::text) || COALESCE((cor1440_gen_actividad_rangoedadac.fr)::text, '0'::text)) || ' '::text) || COALESCE((cor1440_gen_actividad_rangoedadac.mr)::text, '0'::text)) || ' '::text) || COALESCE((cor1440_gen_actividad_rangoedadac.s)::text, '0'::text)) || ' '::text) || COALESCE((cor1440_gen_actividad_rangoedadac.i)::text, '0'::text))
                   FROM public.cor1440_gen_actividad_rangoedadac
                  WHERE (cor1440_gen_actividad_rangoedadac.actividad_id = a.id)
                  ORDER BY cor1440_gen_actividad_rangoedadac.rangoedadac_id), ' | '::text) AS tpob
           FROM public.cor1440_gen_actividad a) sub
  WHERE (tpob <> ''::text)
  ORDER BY actividad_id;


--
-- Name: cor1440_gen_vista_tpoblacion_de_asist; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cor1440_gen_vista_tpoblacion_de_asist AS
 SELECT actividad_id,
    rangoedadac_id,
    COALESCE(fn, (0)::bigint) AS f,
    COALESCE(mn, (0)::bigint) AS m,
    COALESCE(sn, (0)::bigint) AS s,
    COALESCE(inum, (0)::bigint) AS i
   FROM ( SELECT DISTINCT v.actividad_id,
            v.rangoedadac_id,
            ( SELECT i.cuenta
                   FROM public.cor1440_gen_vista_asist_rangoe_sexo i
                  WHERE ((i.actividad_id = v.actividad_id) AND (i.rangoedadac_id = v.rangoedadac_id) AND (i.sexo = 'M'::bpchar))
                 LIMIT 1) AS fn,
            ( SELECT i.cuenta
                   FROM public.cor1440_gen_vista_asist_rangoe_sexo i
                  WHERE ((i.actividad_id = v.actividad_id) AND (i.rangoedadac_id = v.rangoedadac_id) AND (i.sexo = 'H'::bpchar))
                 LIMIT 1) AS mn,
            ( SELECT i.cuenta
                   FROM public.cor1440_gen_vista_asist_rangoe_sexo i
                  WHERE ((i.actividad_id = v.actividad_id) AND (i.rangoedadac_id = v.rangoedadac_id) AND (i.sexo = 'S'::bpchar))
                 LIMIT 1) AS sn,
            ( SELECT i.cuenta
                   FROM public.cor1440_gen_vista_asist_rangoe_sexo i
                  WHERE ((i.actividad_id = v.actividad_id) AND (i.rangoedadac_id = v.rangoedadac_id) AND (i.sexo = 'O'::bpchar))
                 LIMIT 1) AS inum
           FROM public.cor1440_gen_vista_asist_rangoe_sexo v) sub;


--
-- Name: cor1440_gen_vista_resumentpob2; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.cor1440_gen_vista_resumentpob2 AS
 SELECT actividad_id,
    tpob
   FROM ( SELECT a.id AS actividad_id,
            array_to_string(ARRAY( SELECT (((((((((cor1440_gen_vista_tpoblacion_de_asist.rangoedadac_id)::text || ' '::text) || COALESCE((cor1440_gen_vista_tpoblacion_de_asist.f)::text, '0'::text)) || ' '::text) || COALESCE((cor1440_gen_vista_tpoblacion_de_asist.m)::text, '0'::text)) || ' '::text) || COALESCE((cor1440_gen_vista_tpoblacion_de_asist.s)::text, '0'::text)) || ' '::text) || COALESCE((cor1440_gen_vista_tpoblacion_de_asist.i)::text, '0'::text))
                   FROM public.cor1440_gen_vista_tpoblacion_de_asist
                  WHERE (cor1440_gen_vista_tpoblacion_de_asist.actividad_id = a.id)
                  ORDER BY cor1440_gen_vista_tpoblacion_de_asist.rangoedadac_id), ' | '::text) AS tpob
           FROM public.cor1440_gen_actividad a) sub
  WHERE (tpob <> ''::text)
  ORDER BY actividad_id
  WITH NO DATA;


--
-- Name: mr519_gen_valorcampo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_valorcampo (
    id bigint NOT NULL,
    campo_id integer NOT NULL,
    valor character varying(5000),
    respuestafor_id integer NOT NULL,
    valorjson json
);


--
-- Name: cres1; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.cres1 AS
 SELECT actividad_id,
    fecha,
    oficina_id,
    ayudaestado_id
   FROM ( SELECT DISTINCT a.id AS actividad_id,
            a.fecha,
            a.oficina_id,
            json_array_elements_text(v.valorjson) AS ayudaestado_id
           FROM ((public.mr519_gen_valorcampo v
             JOIN public.cor1440_gen_actividad_respuestafor ar ON ((ar.respuestafor_id = v.respuestafor_id)))
             JOIN public.cor1440_gen_actividad a ON ((a.id = ar.actividad_id)))
          WHERE (v.campo_id = 103)) sub
  WHERE ((ayudaestado_id IS NOT NULL) AND (ayudaestado_id <> ''::text))
  WITH NO DATA;


--
-- Name: sivel2_sjr_derecho_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_derecho_respuesta (
    derecho_id integer DEFAULT 9 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    respuesta_id integer NOT NULL
);


--
-- Name: sivel2_sjr_respuesta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_respuesta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_respuesta (
    caso_id integer NOT NULL,
    fechaatencion date NOT NULL,
    prorrogas boolean,
    numprorrogas integer,
    montoprorrogas integer,
    fechaultima date,
    lugarultima character varying(500),
    entregada boolean,
    proxprorroga boolean,
    turno character varying(100),
    lugar character varying(500),
    descamp character varying(5000),
    compromisos character varying(5000),
    remision character varying(5000),
    orientaciones character varying(5000),
    gestionessjr character varying(5000),
    observaciones character varying(5000),
    personadesea_id integer DEFAULT 0,
    causaref_id integer DEFAULT 0,
    verifcsjr character varying(5000),
    verifcper character varying(5000),
    efectividad character varying(5000),
    detallear character varying(5000),
    cantidadayes character varying(50),
    institucionayes character varying(500),
    informacionder boolean,
    accionesder character varying(5000),
    detallemotivo character varying(5000),
    difobsprog character varying(5000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_sjr_respuesta_id_seq'::regclass) NOT NULL,
    montoar integer,
    montoal integer,
    detalleal character varying(5000),
    descatencion character varying(5000)
);


--
-- Name: cvp1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cvp1 AS
 SELECT respuesta.id AS respuesta_id,
    derecho_respuesta.derecho_id,
    casosjr.oficina_id
   FROM public.sivel2_sjr_casosjr casosjr,
    public.sivel2_sjr_respuesta respuesta,
    public.sivel2_sjr_derecho_respuesta derecho_respuesta
  WHERE ((respuesta.caso_id = casosjr.caso_id) AND (derecho_respuesta.respuesta_id = respuesta.id));


--
-- Name: sivel2_sjr_ayudaestado_derecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudaestado_derecho (
    ayudaestado_id integer,
    derecho_id integer
);


--
-- Name: sivel2_sjr_ayudaestado_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudaestado_respuesta (
    ayudaestado_id integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    respuesta_id integer NOT NULL
);


--
-- Name: cvp2; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cvp2 AS
 SELECT ar.respuesta_id,
    ad.derecho_id,
    ar.ayudaestado_id
   FROM public.sivel2_sjr_ayudaestado_respuesta ar,
    public.sivel2_sjr_ayudaestado_derecho ad
  WHERE (ar.ayudaestado_id = ad.ayudaestado_id);


--
-- Name: declaracionruv; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.declaracionruv (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: declaracionruv_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.declaracionruv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: declaracionruv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.declaracionruv_id_seq OWNED BY public.declaracionruv.id;


--
-- Name: depgifmm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.depgifmm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: depgifmm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.depgifmm_id_seq OWNED BY public.depgifmm.id;


--
-- Name: detallefinanciero_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.detallefinanciero_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: detallefinanciero_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.detallefinanciero_id_seq OWNED BY public.detallefinanciero.id;


--
-- Name: dificultadmigracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dificultadmigracion (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: dificultadmigracion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dificultadmigracion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dificultadmigracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dificultadmigracion_id_seq OWNED BY public.dificultadmigracion.id;


--
-- Name: discapacidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discapacidad (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: discapacidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.discapacidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discapacidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.discapacidad_id_seq OWNED BY public.discapacidad.id;


--
-- Name: docidsecundario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.docidsecundario (
    id bigint NOT NULL,
    persona_id integer NOT NULL,
    tdocumento_id integer NOT NULL,
    numero character varying(100) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: docidsecundario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.docidsecundario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: docidsecundario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.docidsecundario_id_seq OWNED BY public.docidsecundario.id;


--
-- Name: sivel2_sjr_migracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_migracion (
    id bigint NOT NULL,
    caso_id integer NOT NULL,
    fechasalida date NOT NULL,
    fechallegada date,
    se_establece_en_sitio_llegada boolean,
    migracontactopre_id integer,
    statusmigratorio_id integer,
    perfilmigracion_id integer,
    pep boolean,
    "fechaPep" date,
    "salvoNpi" character varying(127),
    "fechaNpi" date,
    "causaRefugio_id" integer,
    observacionesref character varying(5000),
    proteccion_id integer,
    viadeingreso_id integer,
    causamigracion_id integer,
    pagoingreso_id integer DEFAULT 1,
    valor_pago integer,
    concepto_pago character varying DEFAULT ''::character varying,
    actor_pago character varying DEFAULT ''::character varying,
    otracausa character varying,
    ubifamilia character varying,
    otraagresion character varying,
    otracausaagresion character varying,
    perpetradoresagresion character varying,
    fechaendestino date,
    perpeagresenpais character varying,
    otracausagrpais character varying,
    tipopep character varying,
    otronpi character varying,
    autoridadrefugio_id integer,
    otraautoridad character varying,
    tipoproteccion_id integer,
    miembrofamiliar_id integer,
    otromiembro character varying,
    tratoauto character varying(5000),
    tratoresi character varying(5000),
    salidaubicacionpre_id integer,
    llegadaubicacionpre_id integer,
    destinoubicacionpre_id integer,
    numppt character varying(32)
);


--
-- Name: emblematica1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.emblematica1 AS
 SELECT caso_id,
    fecha,
    despomigracion,
    despomigracion_id,
    expulsionubicacionpre_id,
    expulsionpais_id,
    expulsionpais,
    expulsiondepartamento_id,
    expulsiondepartamento,
    expulsionmunicipio_id,
    expulsionmunicipio,
    expulsionubicacionpre,
    llegadaubicacionpre_id,
    llegadapais_id,
    llegadapais,
    llegadadepartamento_id,
    llegadadepartamento,
    llegadamunicipio_id,
    llegadamunicipio,
    llegadaubicacionpre
   FROM (( SELECT caso.id AS caso_id,
            caso.fecha,
            'desplazamiento'::text AS despomigracion,
            desplazamiento.id AS despomigracion_id,
            ubicacionpreex.id AS expulsionubicacionpre_id,
            paisex.id AS expulsionpais_id,
            paisex.nombre AS expulsionpais,
            departamentoex.id AS expulsiondepartamento_id,
            departamentoex.nombre AS expulsiondepartamento,
            municipioex.id AS expulsionmunicipio_id,
            municipioex.nombre AS expulsionmunicipio,
            (((((COALESCE(municipioex.nombre, ''::character varying))::text || ' / '::text) || (COALESCE(departamentoex.nombre, ''::character varying))::text) || ' / '::text) || (COALESCE(paisex.nombre, ''::character varying))::text) AS expulsionubicacionpre,
            ubicacionprel.id AS llegadaubicacionpre_id,
            paisl.id AS llegadapais_id,
            paisl.nombre AS llegadapais,
            departamentol.id AS llegadadepartamento_id,
            departamentol.nombre AS llegadadepartamento,
            municipiol.id AS llegadamunicipio_id,
            municipiol.nombre AS llegadamunicipio,
            (((((COALESCE(municipiol.nombre, ''::character varying))::text || ' / '::text) || (COALESCE(departamentol.nombre, ''::character varying))::text) || ' / '::text) || (COALESCE(paisl.nombre, ''::character varying))::text) AS llegadaubicacionpre
           FROM (((((((((public.sivel2_sjr_desplazamiento desplazamiento
             JOIN public.sivel2_gen_caso caso ON (((desplazamiento.caso_id = caso.id) AND (desplazamiento.fechaexpulsion = caso.fecha))))
             LEFT JOIN public.msip_ubicacionpre ubicacionpreex ON ((ubicacionpreex.id = desplazamiento.expulsionubicacionpre_id)))
             LEFT JOIN public.msip_pais paisex ON ((ubicacionpreex.pais_id = paisex.id)))
             LEFT JOIN public.msip_departamento departamentoex ON ((ubicacionpreex.departamento_id = departamentoex.id)))
             LEFT JOIN public.msip_municipio municipioex ON ((ubicacionpreex.municipio_id = municipioex.id)))
             LEFT JOIN public.msip_ubicacionpre ubicacionprel ON ((ubicacionprel.id = desplazamiento.llegadaubicacionpre_id)))
             LEFT JOIN public.msip_pais paisl ON ((ubicacionprel.pais_id = paisl.id)))
             LEFT JOIN public.msip_departamento departamentol ON ((ubicacionprel.departamento_id = departamentol.id)))
             LEFT JOIN public.msip_municipio municipiol ON ((ubicacionprel.municipio_id = municipiol.id)))
          ORDER BY desplazamiento.id)
        UNION
        ( SELECT caso.id AS caso_id,
            caso.fecha,
            'migracion'::text AS despomigracion,
            migracion.id AS despomigracion_id,
            ubicacionpres.id AS expulsionubicacionpre_id,
            paiss.id AS expulsionpais_id,
            paiss.nombre AS expulsionpais,
            departamentos.id AS expulsiondepartamento_id,
            departamentos.nombre AS expulsiondepartamento,
            municipios.id AS expulsionmunicipio_id,
            municipios.nombre AS expulsionmunicipio,
            (((((COALESCE(municipios.nombre, ''::character varying))::text || ' / '::text) || (COALESCE(departamentos.nombre, ''::character varying))::text) || ' / '::text) || (COALESCE(paiss.nombre, ''::character varying))::text) AS expulsionubicacionpre,
            ubicacionprel.id AS llegadaubicacionpre_id,
            paisl.id AS llegadapais_id,
            paisl.nombre AS llegadapais,
            departamentol.id AS llegadadepartamento_id,
            departamentol.nombre AS llegadadepartamento,
            municipiol.id AS llegadamunicipio_id,
            municipiol.nombre AS llegadamunicipio,
            (((((COALESCE(municipiol.nombre, ''::character varying))::text || ' / '::text) || (COALESCE(departamentol.nombre, ''::character varying))::text) || ' / '::text) || (COALESCE(paisl.nombre, ''::character varying))::text) AS llegadaubicacionpre
           FROM (((((((((public.sivel2_sjr_migracion migracion
             JOIN public.sivel2_gen_caso caso ON (((migracion.caso_id = caso.id) AND (migracion.fechasalida = caso.fecha))))
             LEFT JOIN public.msip_ubicacionpre ubicacionpres ON ((ubicacionpres.id = migracion.salidaubicacionpre_id)))
             LEFT JOIN public.msip_pais paiss ON ((ubicacionpres.pais_id = paiss.id)))
             LEFT JOIN public.msip_departamento departamentos ON ((ubicacionpres.departamento_id = departamentos.id)))
             LEFT JOIN public.msip_municipio municipios ON ((ubicacionpres.municipio_id = municipios.id)))
             LEFT JOIN public.msip_ubicacionpre ubicacionprel ON ((ubicacionprel.id = migracion.llegadaubicacionpre_id)))
             LEFT JOIN public.msip_pais paisl ON ((ubicacionprel.pais_id = paisl.id)))
             LEFT JOIN public.msip_departamento departamentol ON ((ubicacionprel.departamento_id = departamentol.id)))
             LEFT JOIN public.msip_municipio municipiol ON ((ubicacionprel.municipio_id = municipiol.id)))
          ORDER BY migracion.id)) sub
  ORDER BY caso_id;


--
-- Name: emblematica; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.emblematica AS
 SELECT id AS caso_id,
    fecha,
    ( SELECT emblematica1.despomigracion
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS despomigracion,
    ( SELECT emblematica1.despomigracion_id
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS despomigracion_id,
    ( SELECT emblematica1.expulsionubicacionpre_id
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS expulsionubicacionpre_id,
    ( SELECT emblematica1.expulsionpais_id
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS expulsionpais_id,
    ( SELECT emblematica1.expulsionpais
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS expulsionpais,
    ( SELECT emblematica1.expulsiondepartamento_id
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS expulsiondepartamento_id,
    ( SELECT emblematica1.expulsiondepartamento
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS expulsiondepartamento,
    ( SELECT emblematica1.expulsionmunicipio_id
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS expulsionmunicipio_id,
    ( SELECT emblematica1.expulsionmunicipio
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS expulsionmunicipio,
    ( SELECT emblematica1.expulsionubicacionpre
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS expulsionubicacionpre,
    ( SELECT emblematica1.llegadaubicacionpre_id
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS llegadaubicacionpre_id,
    ( SELECT emblematica1.llegadapais_id
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS llegadapais_id,
    ( SELECT emblematica1.llegadapais
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS llegadapais,
    ( SELECT emblematica1.llegadadepartamento_id
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS llegadadepartamento_id,
    ( SELECT emblematica1.llegadadepartamento
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS llegadadepartamento,
    ( SELECT emblematica1.llegadamunicipio_id
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS llegadamunicipio_id,
    ( SELECT emblematica1.llegadamunicipio
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS llegadamunicipio,
    ( SELECT emblematica1.llegadaubicacionpre
           FROM public.emblematica1
          WHERE (emblematica1.caso_id = caso.id)
         LIMIT 1) AS llegadaubicacionpre
   FROM public.sivel2_gen_caso caso;


--
-- Name: espaciopart; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.espaciopart (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: espaciopart_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.espaciopart_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: espaciopart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.espaciopart_id_seq OWNED BY public.espaciopart.id;


--
-- Name: frecuenciaentrega; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.frecuenciaentrega (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: frecuenciaentrega_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.frecuenciaentrega_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: frecuenciaentrega_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.frecuenciaentrega_id_seq OWNED BY public.frecuenciaentrega.id;


--
-- Name: heb412_gen_campohc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_campohc (
    id integer NOT NULL,
    doc_id integer NOT NULL,
    nombrecampo character varying(127) NOT NULL,
    columna character varying(5) NOT NULL,
    fila integer
);


--
-- Name: heb412_gen_campohc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_campohc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campohc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_campohc_id_seq OWNED BY public.heb412_gen_campohc.id;


--
-- Name: heb412_gen_campoplantillahcm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_campoplantillahcm (
    id integer NOT NULL,
    plantillahcm_id integer,
    nombrecampo character varying(183) COLLATE public.es_co_utf_8,
    columna character varying(5)
);


--
-- Name: heb412_gen_campoplantillahcm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_campoplantillahcm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campoplantillahcm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_campoplantillahcm_id_seq OWNED BY public.heb412_gen_campoplantillahcm.id;


--
-- Name: heb412_gen_campoplantillahcr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_campoplantillahcr (
    id bigint NOT NULL,
    plantillahcr_id integer,
    nombrecampo character varying(127) COLLATE public.es_co_utf_8,
    columna character varying(5),
    fila integer
);


--
-- Name: heb412_gen_campoplantillahcr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_campoplantillahcr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_campoplantillahcr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_campoplantillahcr_id_seq OWNED BY public.heb412_gen_campoplantillahcr.id;


--
-- Name: heb412_gen_carpetaexclusiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_carpetaexclusiva (
    id bigint NOT NULL,
    carpeta character varying(2048),
    grupo_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: heb412_gen_carpetaexclusiva_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_carpetaexclusiva_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_carpetaexclusiva_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_carpetaexclusiva_id_seq OWNED BY public.heb412_gen_carpetaexclusiva.id;


--
-- Name: heb412_gen_doc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_doc (
    id integer NOT NULL,
    nombre character varying(512),
    tipodoc character varying(1),
    dirpapa integer,
    url character varying(1024),
    fuente character varying(1024),
    descripcion character varying(5000),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    adjunto_file_name character varying,
    adjunto_content_type character varying,
    adjunto_file_size integer,
    adjunto_updated_at timestamp without time zone,
    nombremenu character varying(127),
    vista character varying(255),
    filainicial integer,
    ruta character varying(2047),
    licencia character varying(255),
    tdoc_id integer,
    tdoc_type character varying
);


--
-- Name: heb412_gen_doc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_doc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_doc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_doc_id_seq OWNED BY public.heb412_gen_doc.id;


--
-- Name: heb412_gen_formulario_plantillahcm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_formulario_plantillahcm (
    formulario_id integer,
    plantillahcm_id integer
);


--
-- Name: heb412_gen_formulario_plantillahcr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_formulario_plantillahcr (
    id bigint NOT NULL,
    plantillahcr_id integer,
    formulario_id integer
);


--
-- Name: heb412_gen_formulario_plantillahcr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_formulario_plantillahcr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_formulario_plantillahcr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_formulario_plantillahcr_id_seq OWNED BY public.heb412_gen_formulario_plantillahcr.id;


--
-- Name: heb412_gen_plantilladoc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_plantilladoc (
    id bigint NOT NULL,
    ruta character varying(2047),
    fuente character varying(1023),
    licencia character varying(1023),
    vista character varying(127),
    nombremenu character varying(127)
);


--
-- Name: heb412_gen_plantilladoc_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_plantilladoc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_plantilladoc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_plantilladoc_id_seq OWNED BY public.heb412_gen_plantilladoc.id;


--
-- Name: heb412_gen_plantillahcm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_plantillahcm (
    id integer NOT NULL,
    ruta character varying(2047) NOT NULL,
    fuente character varying(1023),
    licencia character varying(1023),
    vista character varying(127) NOT NULL,
    nombremenu character varying(127) NOT NULL,
    filainicial integer NOT NULL
);


--
-- Name: heb412_gen_plantillahcm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_plantillahcm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_plantillahcm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_plantillahcm_id_seq OWNED BY public.heb412_gen_plantillahcm.id;


--
-- Name: heb412_gen_plantillahcr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.heb412_gen_plantillahcr (
    id bigint NOT NULL,
    ruta character varying(2047),
    fuente character varying(1023),
    licencia character varying(1023),
    vista character varying(127),
    nombremenu character varying(127)
);


--
-- Name: heb412_gen_plantillahcr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.heb412_gen_plantillahcr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: heb412_gen_plantillahcr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.heb412_gen_plantillahcr_id_seq OWNED BY public.heb412_gen_plantillahcr.id;


--
-- Name: indicadorgifmm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.indicadorgifmm (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    sectorgifmm_id integer NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: indicadorgifmm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.indicadorgifmm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: indicadorgifmm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.indicadorgifmm_id_seq OWNED BY public.indicadorgifmm.id;


--
-- Name: jos19_consactividadcaso; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.jos19_consactividadcaso AS
 SELECT row_number() OVER () AS id,
    caso.id AS caso_id,
    asi.actividad_id,
    victima.id AS victima_id,
        CASE
            WHEN (casosjr.contacto_id = persona.id) THEN 1
            ELSE 0
        END AS es_contacto,
    actividad.fecha AS actividad_fecha,
    ( SELECT msip_oficina.nombre
           FROM public.msip_oficina
          WHERE (msip_oficina.id = actividad.oficina_id)
         LIMIT 1) AS actividad_oficina,
    ( SELECT usuario.nusuario
           FROM public.usuario
          WHERE (usuario.id = actividad.usuario_id)
         LIMIT 1) AS actividad_responsable,
    array_to_string(ARRAY( SELECT cor1440_gen_proyectofinanciero.nombre
           FROM public.cor1440_gen_proyectofinanciero
          WHERE (cor1440_gen_proyectofinanciero.id IN ( SELECT apf.proyectofinanciero_id
                   FROM public.cor1440_gen_actividad_proyectofinanciero apf
                  WHERE (apf.actividad_id = actividad.id)))), ','::text) AS actividad_convenios,
    persona.id AS persona_id,
    persona.nombres AS persona_nombres,
    persona.apellidos AS persona_apellidos,
    persona.tdocumento_id AS persona_tipodocumento,
    caso.memo AS caso_memo,
    casosjr.fecharec AS caso_fecharec
   FROM ((((((public.cor1440_gen_asistencia asi
     JOIN public.msip_persona persona ON ((persona.id = asi.persona_id)))
     JOIN public.cor1440_gen_actividad actividad ON ((asi.actividad_id = actividad.id)))
     JOIN public.msip_oficina oficinaac ON ((oficinaac.id = actividad.oficina_id)))
     JOIN public.sivel2_gen_victima victima ON ((victima.persona_id = persona.id)))
     JOIN public.sivel2_gen_caso caso ON ((victima.caso_id = caso.id)))
     JOIN public.sivel2_sjr_casosjr casosjr ON ((caso.id = casosjr.caso_id)))
  WITH NO DATA;


--
-- Name: mcben1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.mcben1 AS
 SELECT caso.id AS caso_id,
    victima.persona_id,
        CASE
            WHEN (casosjr.contacto_id = victima.persona_id) THEN 1
            ELSE 0
        END AS contacto,
        CASE
            WHEN (casosjr.contacto_id <> victima.persona_id) THEN 1
            ELSE 0
        END AS beneficiario,
    1 AS npersona,
    victimasjr.actividadoficio_id
   FROM public.sivel2_gen_caso caso,
    public.sivel2_sjr_casosjr casosjr,
    public.sivel2_gen_victima victima,
    public.msip_persona persona,
    public.sivel2_sjr_victimasjr victimasjr
  WHERE ((caso.id = victima.caso_id) AND (caso.id = casosjr.caso_id) AND (caso.id = victima.caso_id) AND (persona.id = victima.persona_id) AND (victima.id = victimasjr.victima_id) AND (victimasjr.fechadesagregacion IS NULL) AND (victimasjr.actividadoficio_id = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 101, 102, 104, 105, 106, 107, 108, 109, 110, 111])) AND ((persona.anionac IS NULL) OR (persona.anionac = ANY (ARRAY[1900, 1901, 1903, 1910, 1911, 1913, 1914, 1915, 1916, 1917, 1918, 1919, 1920, 1921, 1922, 1923, 1924, 1925, 1926, 1927, 1928, 1929, 1930, 1931, 1932, 1933, 1934, 1935, 1936, 1937, 1938, 1939, 1940, 1941, 1942, 1943, 1944, 1945, 1946, 1947, 1948, 1949, 1950, 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959, 1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969, 1970, 1971, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979, 1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 20011]))) AND (victimasjr.cabezafamilia = ANY (ARRAY[false, true])) AND (victimasjr.estadocivil_id = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6])) AND (persona.etnia_id = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 2001, 2002, 2003])) AND ((((EXTRACT(year FROM casosjr.fecharec))::text || '-'::text) || lpad((EXTRACT(month FROM casosjr.fecharec))::text, 2, '0'::text)) = ANY (ARRAY['2003-10'::text, '2010-08'::text, '2011-02'::text, '2012-06'::text, '2012-07'::text, '2012-08'::text, '2012-09'::text, '2012-10'::text, '2012-11'::text, '2013-01'::text, '2013-02'::text, '2013-03'::text, '2013-04'::text, '2013-05'::text, '2013-06'::text, '2013-07'::text, '2013-08'::text, '2013-09'::text, '2013-10'::text, '2013-11'::text, '2013-12'::text, '2014-01'::text, '2014-02'::text, '2014-03'::text, '2014-04'::text, '2014-05'::text, '2014-06'::text, '2014-07'::text, '2014-08'::text, '2014-09'::text, '2014-10'::text, '2014-11'::text, '2015-01'::text, '2015-02'::text, '2015-03'::text, '2015-04'::text, '2015-05'::text, '2015-06'::text, '2015-07'::text, '2015-08'::text, '2015-09'::text, '2015-10'::text, '2015-11'::text, '2015-12'::text, '2016-01'::text, '2016-02'::text, '2016-03'::text, '2016-04'::text, '2016-05'::text, '2016-06'::text, '2016-07'::text, '2016-08'::text, '2016-09'::text, '2016-10'::text, '2016-11'::text, '2016-12'::text, '2017-01'::text, '2017-02'::text, '2017-03'::text, '2017-04'::text, '2017-05'::text, '2017-06'::text, '2017-07'::text, '2017-08'::text, '2017-09'::text, '2017-10'::text, '2017-11'::text, '2017-12'::text, '2018-01'::text, '2018-02'::text, '2018-03'::text, '2018-04'::text, '2018-05'::text, '2018-06'::text, '2018-07'::text, '2018-08'::text, '2018-09'::text, '2018-10'::text, '2018-11'::text, '2018-12'::text, '2019-01'::text, '2019-02'::text, '2019-03'::text, '2019-04'::text, '2019-05'::text, '2019-06'::text, '2019-07'::text, '2019-08'::text, '2019-09'::text, '2019-10'::text, '2019-11'::text, '2019-12'::text, '2020-01'::text, '2020-02'::text, '2020-03'::text, '2020-04'::text, '2020-05'::text, '2020-06'::text, '2020-07'::text, '2020-08'::text, '2020-09'::text, '2020-10'::text, '2020-11'::text, '2020-12'::text, '2021-01'::text, '2021-02'::text, '2021-03'::text, '2021-04'::text, '2021-05'::text, '2021-06'::text, '2021-07'::text, '2021-08'::text, '2021-09'::text, '2021-10'::text, '2021-11'::text, '2021-12'::text, '2022-01'::text, '2022-02'::text, '2022-03'::text, '2022-04'::text, '2022-05'::text, '2022-06'::text, '2022-07'::text, '2022-08'::text, '2022-09'::text, '2022-10'::text, '2022-11'::text, '2022-12'::text, '2023-01'::text, '2023-02'::text, '2023-03'::text, '2023-04'::text, '2023-05'::text, '2023-06'::text, '2023-07'::text, '2023-08'::text, '2023-09'::text, '2023-10'::text, '2023-11'::text, '2023-12'::text, '2024-05'::text, '2024-06'::text, '2024-07'::text, '25-08'::text, '26-08'::text, '26-12'::text, '32-08'::text, '33-07'::text])) AND (victimasjr.escolaridad_id = ANY (ARRAY[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])) AND (victima.rangoedad_id = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])) AND (victimasjr.regimensalud_id = ANY (ARRAY[0, 1, 2, 3])) AND (persona.sexo = ANY (ARRAY['H'::bpchar, 'M'::bpchar, 'O'::bpchar, 'S'::bpchar])));


--
-- Name: msip_centropoblado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_centropoblado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_centropoblado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_centropoblado (
    cplocal_cod integer,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    tcentropoblado_id character varying(10) DEFAULT 'CP'::character varying NOT NULL,
    latitud double precision,
    longitud double precision,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    municipio_id integer,
    id integer DEFAULT nextval('public.msip_centropoblado_id_seq'::regclass) NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    ultvigenciaini date,
    ultvigenciafin date,
    svgruta character varying,
    svgcdx integer,
    svgcdy integer,
    svgcdancho integer,
    svgcdalto integer,
    svgrotx double precision,
    svgroty double precision,
    CONSTRAINT msip_centropoblado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: ultimodesplazamiento; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.ultimodesplazamiento AS
 SELECT sivel2_sjr_desplazamiento.id,
    s.caso_id,
    s.fechaexpulsion,
    sivel2_sjr_desplazamiento.expulsionubicacionpre_id
   FROM public.sivel2_sjr_desplazamiento,
    ( SELECT sivel2_sjr_desplazamiento_1.caso_id,
            max(sivel2_sjr_desplazamiento_1.fechaexpulsion) AS fechaexpulsion
           FROM public.sivel2_sjr_desplazamiento sivel2_sjr_desplazamiento_1
          GROUP BY sivel2_sjr_desplazamiento_1.caso_id) s
  WHERE ((sivel2_sjr_desplazamiento.caso_id = s.caso_id) AND (sivel2_sjr_desplazamiento.fechaexpulsion = s.fechaexpulsion));


--
-- Name: mcben2; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.mcben2 AS
 SELECT mcben1.caso_id,
    mcben1.persona_id,
    mcben1.contacto,
    mcben1.beneficiario,
    mcben1.npersona,
    mcben1.actividadoficio_id,
    ubicacion.departamento_id,
    departamento.nombre AS departamento_nombre,
    ubicacion.municipio_id,
    municipio.nombre AS municipio_nombre,
    ubicacion.centropoblado_id,
    centropoblado.nombre AS centropoblado_nombre,
    ultimodesplazamiento.fechaexpulsion
   FROM (((((public.mcben1
     LEFT JOIN public.ultimodesplazamiento ON ((mcben1.caso_id = ultimodesplazamiento.caso_id)))
     LEFT JOIN public.msip_ubicacionpre ubicacion ON ((ultimodesplazamiento.expulsionubicacionpre_id = ubicacion.id)))
     LEFT JOIN public.msip_departamento departamento ON ((ubicacion.departamento_id = departamento.id)))
     LEFT JOIN public.msip_municipio municipio ON ((ubicacion.municipio_id = municipio.id)))
     LEFT JOIN public.msip_centropoblado centropoblado ON ((ubicacion.centropoblado_id = centropoblado.id)));


--
-- Name: mecanismodeentrega; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mecanismodeentrega (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mecanismodeentrega_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mecanismodeentrega_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mecanismodeentrega_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mecanismodeentrega_id_seq OWNED BY public.mecanismodeentrega.id;


--
-- Name: miembrofamiliar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.miembrofamiliar (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: miembrofamiliar_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.miembrofamiliar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: miembrofamiliar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.miembrofamiliar_id_seq OWNED BY public.miembrofamiliar.id;


--
-- Name: migracontactopre; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migracontactopre (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: migracontactopre_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migracontactopre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migracontactopre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migracontactopre_id_seq OWNED BY public.migracontactopre.id;


--
-- Name: modalidadentrega; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modalidadentrega (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: modalidadentrega_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modalidadentrega_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modalidadentrega_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modalidadentrega_id_seq OWNED BY public.modalidadentrega.id;


--
-- Name: mr519_gen_campo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_campo (
    id bigint NOT NULL,
    nombre character varying(512) NOT NULL,
    ayudauso character varying(1024),
    tipo integer DEFAULT 1 NOT NULL,
    obligatorio boolean,
    formulario_id integer NOT NULL,
    nombreinterno character varying(60),
    fila integer,
    columna integer,
    ancho integer,
    tablabasica character varying(32)
);


--
-- Name: mr519_gen_campo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_campo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_campo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_campo_id_seq OWNED BY public.mr519_gen_campo.id;


--
-- Name: mr519_gen_encuestapersona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_encuestapersona (
    id bigint NOT NULL,
    persona_id integer,
    fecha date,
    adurl character varying(32),
    respuestafor_id integer,
    planencuesta_id integer
);


--
-- Name: mr519_gen_encuestapersona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_encuestapersona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_encuestapersona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_encuestapersona_id_seq OWNED BY public.mr519_gen_encuestapersona.id;


--
-- Name: mr519_gen_encuestausuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_encuestausuario (
    id bigint NOT NULL,
    usuario_id integer NOT NULL,
    fecha date,
    fechainicio date NOT NULL,
    fechafin date,
    respuestafor_id integer
);


--
-- Name: mr519_gen_encuestausuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_encuestausuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_encuestausuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_encuestausuario_id_seq OWNED BY public.mr519_gen_encuestausuario.id;


--
-- Name: mr519_gen_formulario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_formulario (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    nombreinterno character varying(60)
);


--
-- Name: mr519_gen_formulario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_formulario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_formulario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_formulario_id_seq OWNED BY public.mr519_gen_formulario.id;


--
-- Name: mr519_gen_opcioncs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_opcioncs (
    id bigint NOT NULL,
    campo_id integer NOT NULL,
    nombre character varying(1024) NOT NULL,
    valor character varying(60) NOT NULL
);


--
-- Name: mr519_gen_opcioncs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_opcioncs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_opcioncs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_opcioncs_id_seq OWNED BY public.mr519_gen_opcioncs.id;


--
-- Name: mr519_gen_planencuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_planencuesta (
    id bigint NOT NULL,
    fechaini date,
    fechafin date,
    formulario_id integer,
    plantillacorreoinv_id integer,
    adurl character varying(32),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mr519_gen_planencuesta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_planencuesta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_planencuesta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_planencuesta_id_seq OWNED BY public.mr519_gen_planencuesta.id;


--
-- Name: mr519_gen_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mr519_gen_respuestafor (
    id bigint NOT NULL,
    formulario_id integer,
    fechaini date NOT NULL,
    fechacambio date NOT NULL
);


--
-- Name: mr519_gen_respuestafor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_respuestafor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_respuestafor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_respuestafor_id_seq OWNED BY public.mr519_gen_respuestafor.id;


--
-- Name: mr519_gen_valorcampo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mr519_gen_valorcampo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mr519_gen_valorcampo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mr519_gen_valorcampo_id_seq OWNED BY public.mr519_gen_valorcampo.id;


--
-- Name: msip_anexo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_anexo (
    id integer NOT NULL,
    descripcion character varying(1500) COLLATE public.es_co_utf_8,
    adjunto_file_name character varying(255) NOT NULL,
    adjunto_content_type character varying(255) NOT NULL,
    adjunto_file_size integer NOT NULL,
    adjunto_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: msip_anexo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_anexo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_anexo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_anexo_id_seq OWNED BY public.msip_anexo.id;


--
-- Name: msip_bitacora; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_bitacora (
    id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    ip character varying(100),
    usuario_id integer,
    url character varying(1023),
    params character varying(5000),
    modelo character varying(511),
    modelo_id integer,
    operacion character varying(63),
    detalle json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_bitacora_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_bitacora_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_bitacora_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_bitacora_id_seq OWNED BY public.msip_bitacora.id;


--
-- Name: msip_centropoblado_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_centropoblado_histvigencia (
    id bigint NOT NULL,
    centropoblado_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    nombre character varying(256),
    cplocal_cod integer,
    tcentropoblado_id character varying,
    observaciones character varying(5000)
);


--
-- Name: msip_centropoblado_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_centropoblado_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_centropoblado_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_centropoblado_histvigencia_id_seq OWNED BY public.msip_centropoblado_histvigencia.id;


--
-- Name: msip_claverespaldo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_claverespaldo (
    id bigint NOT NULL,
    clave character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: msip_claverespaldo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_claverespaldo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_claverespaldo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_claverespaldo_id_seq OWNED BY public.msip_claverespaldo.id;


--
-- Name: msip_departamento_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_departamento_histvigencia (
    id bigint NOT NULL,
    departamento_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    nombre character varying(256),
    deplocal_cod integer,
    codiso integer,
    catiso integer,
    codreg integer,
    observaciones character varying(5000)
);


--
-- Name: msip_departamento_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_departamento_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_departamento_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_departamento_histvigencia_id_seq OWNED BY public.msip_departamento_histvigencia.id;


--
-- Name: msip_estadosol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_estadosol (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_estadosol_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_estadosol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_estadosol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_estadosol_id_seq OWNED BY public.msip_estadosol.id;


--
-- Name: msip_etiqueta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_etiqueta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_etiqueta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_etiqueta (
    id integer DEFAULT nextval('public.msip_etiqueta_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT etiqueta_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_etiqueta_municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_etiqueta_municipio (
    etiqueta_id bigint NOT NULL,
    municipio_id bigint NOT NULL
);


--
-- Name: msip_etiqueta_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_etiqueta_persona (
    id bigint NOT NULL,
    etiqueta_id integer NOT NULL,
    persona_id integer NOT NULL,
    usuario_id integer NOT NULL,
    fecha date NOT NULL,
    observaciones character varying(5000),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: msip_etiqueta_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_etiqueta_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_etiqueta_persona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_etiqueta_persona_id_seq OWNED BY public.msip_etiqueta_persona.id;


--
-- Name: msip_etnia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_etnia (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    descripcion character varying(1000),
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT etnia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_etnia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_etnia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_etnia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_etnia_id_seq OWNED BY public.msip_etnia.id;


--
-- Name: msip_fuenteprensa_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_fuenteprensa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_fuenteprensa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_fuenteprensa (
    id integer DEFAULT nextval('public.msip_fuenteprensa_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    tfuente character varying(25),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT msip_fuenteprensa_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_grupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_grupo (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_grupo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_grupo_id_seq OWNED BY public.msip_grupo.id;


--
-- Name: msip_grupo_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_grupo_usuario (
    usuario_id bigint NOT NULL,
    grupo_id bigint NOT NULL
);


--
-- Name: msip_grupoper_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_grupoper_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_grupoper; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_grupoper (
    id integer DEFAULT nextval('public.msip_grupoper_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    anotaciones character varying(1000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: msip_lineaorgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_lineaorgsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_lineaorgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_lineaorgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_lineaorgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_lineaorgsocial_id_seq OWNED BY public.msip_lineaorgsocial.id;


--
-- Name: msip_mundep_sinorden; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.msip_mundep_sinorden AS
 SELECT ((msip_departamento.deplocal_cod * 1000) + msip_municipio.munlocal_cod) AS idlocal,
    (((msip_municipio.nombre)::text || ' / '::text) || (msip_departamento.nombre)::text) AS nombre
   FROM (public.msip_municipio
     JOIN public.msip_departamento ON ((msip_municipio.departamento_id = msip_departamento.id)))
  WHERE ((msip_departamento.pais_id = 170) AND (msip_municipio.fechadeshabilitacion IS NULL) AND (msip_departamento.fechadeshabilitacion IS NULL))
UNION
 SELECT msip_departamento.deplocal_cod AS idlocal,
    msip_departamento.nombre
   FROM public.msip_departamento
  WHERE ((msip_departamento.pais_id = 170) AND (msip_departamento.fechadeshabilitacion IS NULL));


--
-- Name: msip_mundep; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.msip_mundep AS
 SELECT idlocal,
    nombre,
    to_tsvector('spanish'::regconfig, public.unaccent(nombre)) AS mundep
   FROM public.msip_mundep_sinorden
  ORDER BY (nombre COLLATE public.es_co_utf_8)
  WITH NO DATA;


--
-- Name: msip_municipio_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_municipio_histvigencia (
    id bigint NOT NULL,
    municipio_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    nombre character varying(256),
    munlocal_cod integer,
    observaciones character varying(5000),
    codreg integer
);


--
-- Name: msip_municipio_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_municipio_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_municipio_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_municipio_histvigencia_id_seq OWNED BY public.msip_municipio_histvigencia.id;


--
-- Name: msip_orgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_orgsocial (
    id bigint NOT NULL,
    grupoper_id integer NOT NULL,
    telefono character varying(500),
    fax character varying(500),
    direccion character varying(500),
    pais_id integer,
    web character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tipoorgsocial_id integer,
    lineaorgsocial_id integer,
    departamento_id integer,
    municipio_id integer,
    email character varying(128),
    nit character varying(128),
    fechadeshabilitacion date,
    tipoorg_id integer DEFAULT 2 NOT NULL
);


--
-- Name: msip_orgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_orgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_orgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_orgsocial_id_seq OWNED BY public.msip_orgsocial.id;


--
-- Name: msip_orgsocial_persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_orgsocial_persona (
    id bigint NOT NULL,
    persona_id integer NOT NULL,
    orgsocial_id integer,
    perfilorgsocial_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    correo character varying(100),
    cargo character varying(254)
);


--
-- Name: msip_orgsocial_persona_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_orgsocial_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_orgsocial_persona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_orgsocial_persona_id_seq OWNED BY public.msip_orgsocial_persona.id;


--
-- Name: msip_orgsocial_sectororgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_orgsocial_sectororgsocial (
    orgsocial_id integer,
    sectororgsocial_id integer
);


--
-- Name: msip_pais_histvigencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_pais_histvigencia (
    id bigint NOT NULL,
    pais_id integer,
    vigenciaini date,
    vigenciafin date NOT NULL,
    codiso integer,
    alfa2 character varying(2),
    alfa3 character varying(3),
    codcambio character varying(4)
);


--
-- Name: msip_pais_histvigencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_pais_histvigencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_pais_histvigencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_pais_histvigencia_id_seq OWNED BY public.msip_pais_histvigencia.id;


--
-- Name: msip_pais_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_pais_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_pais_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_pais_id_seq OWNED BY public.msip_pais.id;


--
-- Name: msip_params_vistam; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_params_vistam (
    id bigint NOT NULL,
    vistam character varying(128),
    usuario_id integer,
    params json,
    marcadetiempo timestamp without time zone
);


--
-- Name: msip_params_vistam_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_params_vistam_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_params_vistam_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_params_vistam_id_seq OWNED BY public.msip_params_vistam.id;


--
-- Name: msip_perfilorgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_perfilorgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_perfilorgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_perfilorgsocial_id_seq OWNED BY public.msip_perfilorgsocial.id;


--
-- Name: msip_persona_trelacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_persona_trelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_persona_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_persona_trelacion (
    persona1 integer NOT NULL,
    persona2 integer NOT NULL,
    trelacion_id character(2) DEFAULT 'SI'::bpchar NOT NULL,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.msip_persona_trelacion_id_seq'::regclass) NOT NULL
);


--
-- Name: msip_sectororgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_sectororgsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_sectororgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_sectororgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_sectororgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_sectororgsocial_id_seq OWNED BY public.msip_sectororgsocial.id;


--
-- Name: msip_solicitud; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_solicitud (
    id bigint NOT NULL,
    usuario_id integer NOT NULL,
    fecha date NOT NULL,
    solicitud character varying(5000),
    estadosol_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_solicitud_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_solicitud_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_solicitud_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_solicitud_id_seq OWNED BY public.msip_solicitud.id;


--
-- Name: msip_solicitud_usuarionotificar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_solicitud_usuarionotificar (
    usuarionotificar_id integer,
    solicitud_id integer
);


--
-- Name: msip_tcentropoblado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tcentropoblado (
    id character varying(10) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT msip_tcentropoblado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_tdocumento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tdocumento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tdocumento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tdocumento_id_seq OWNED BY public.msip_tdocumento.id;


--
-- Name: msip_tema; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tema (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    nav_ini character varying(8),
    nav_fin character varying(8),
    nav_fuente character varying(8),
    fondo_lista character varying(8),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    btn_primario_fondo_ini character varying(127),
    btn_primario_fondo_fin character varying(127),
    btn_primario_fuente character varying(127),
    btn_peligro_fondo_ini character varying(127),
    btn_peligro_fondo_fin character varying(127),
    btn_peligro_fuente character varying(127),
    btn_accion_fondo_ini character varying(127),
    btn_accion_fondo_fin character varying(127),
    btn_accion_fuente character varying(127),
    alerta_exito_fondo character varying(127),
    alerta_exito_fuente character varying(127),
    alerta_problema_fondo character varying(127),
    alerta_problema_fuente character varying(127),
    fondo character varying(127),
    color_fuente character varying(127),
    color_flota_subitem_fuente character varying,
    color_flota_subitem_fondo character varying
);


--
-- Name: msip_tema_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tema_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tema_id_seq OWNED BY public.msip_tema.id;


--
-- Name: msip_tipoanexo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tipoanexo (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: msip_tipoanexo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tipoanexo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tipoanexo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tipoanexo_id_seq OWNED BY public.msip_tipoanexo.id;


--
-- Name: msip_tipoorg; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tipoorg (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: msip_tipoorg_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tipoorg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tipoorg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tipoorg_id_seq OWNED BY public.msip_tipoorg.id;


--
-- Name: msip_tipoorgsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tipoorgsocial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_tipoorgsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tipoorgsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tipoorgsocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_tipoorgsocial_id_seq OWNED BY public.msip_tipoorgsocial.id;


--
-- Name: msip_trelacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_trelacion (
    id character(2) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    inverso character varying(2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT trelacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_trivalente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_trivalente (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: msip_trivalente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_trivalente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_trivalente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_trivalente_id_seq OWNED BY public.msip_trivalente.id;


--
-- Name: msip_tsitio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_tsitio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_tsitio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_tsitio (
    id integer DEFAULT nextval('public.msip_tsitio_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000) COLLATE public.es_co_utf_8,
    CONSTRAINT tsitio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: msip_ubicacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_ubicacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_ubicacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_ubicacion (
    id integer DEFAULT nextval('public.msip_ubicacion_id_seq'::regclass) NOT NULL,
    lugar character varying(500) COLLATE public.es_co_utf_8,
    sitio character varying(500) COLLATE public.es_co_utf_8,
    tsitio_id integer DEFAULT 1 NOT NULL,
    caso_id integer NOT NULL,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pais_id integer,
    departamento_id integer,
    municipio_id integer,
    centropoblado_id integer
);


--
-- Name: msip_ubicacionpre_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_ubicacionpre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_ubicacionpre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_ubicacionpre_id_seq OWNED BY public.msip_ubicacionpre.id;


--
-- Name: msip_vereda; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.msip_vereda (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    municipio_id integer,
    verlocal_cod integer,
    observaciones character varying(5000),
    latitud double precision,
    longitud double precision,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: msip_vereda_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.msip_vereda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msip_vereda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.msip_vereda_id_seq OWNED BY public.msip_vereda.id;


--
-- Name: mungifmm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mungifmm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mungifmm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mungifmm_id_seq OWNED BY public.mungifmm.id;


--
-- Name: napellidos; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.napellidos AS
 SELECT (p).nombre AS apellido,
    count((p).caso) AS frec
   FROM ( SELECT public.divarr_concod(string_to_array(btrim((msip_persona.apellidos)::text), ' '::text), sivel2_gen_victima.caso_id) AS p
           FROM public.msip_persona,
            public.sivel2_gen_victima
          WHERE (sivel2_gen_victima.persona_id = msip_persona.id)
          ORDER BY (public.divarr_concod(string_to_array(btrim((msip_persona.apellidos)::text), ' '::text), sivel2_gen_victima.caso_id))) r
  GROUP BY (p).nombre
  ORDER BY (count((p).caso))
  WITH NO DATA;


--
-- Name: nhombres; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.nhombres AS
 SELECT (p).nombre AS nombre,
    count((p).caso) AS frec
   FROM ( SELECT public.divarr_concod(string_to_array((msip_persona.nombres)::text, ' '::text), sivel2_gen_victima.caso_id) AS p
           FROM public.msip_persona,
            public.sivel2_gen_victima
          WHERE ((sivel2_gen_victima.persona_id = msip_persona.id) AND (msip_persona.sexo = 'M'::bpchar))
          ORDER BY (public.divarr_concod(string_to_array((msip_persona.nombres)::text, ' '::text), sivel2_gen_victima.caso_id))) r
  GROUP BY (p).nombre
  ORDER BY (count((p).caso))
  WITH NO DATA;


--
-- Name: nmujeres; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.nmujeres AS
 SELECT (p).nombre AS nombre,
    count((p).caso) AS frec
   FROM ( SELECT public.divarr_concod(string_to_array(btrim((msip_persona.nombres)::text), ' '::text), sivel2_gen_victima.caso_id) AS p
           FROM public.msip_persona,
            public.sivel2_gen_victima
          WHERE ((sivel2_gen_victima.persona_id = msip_persona.id) AND (msip_persona.sexo = 'F'::bpchar))
          ORDER BY (public.divarr_concod(string_to_array(btrim((msip_persona.nombres)::text), ' '::text), sivel2_gen_victima.caso_id))) r
  GROUP BY (p).nombre
  ORDER BY (count((p).caso))
  WITH NO DATA;


--
-- Name: perfilmigracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.perfilmigracion (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: perfilmigracion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.perfilmigracion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: perfilmigracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.perfilmigracion_id_seq OWNED BY public.perfilmigracion.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sectorgifmm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sectorgifmm (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sectorgifmm_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sectorgifmm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sectorgifmm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sectorgifmm_id_seq OWNED BY public.sectorgifmm.id;


--
-- Name: sivel2_gen_actividadoficio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_actividadoficio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actividadoficio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_actividadoficio (
    id integer DEFAULT nextval('public.sivel2_gen_actividadoficio_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT actividadoficio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_acto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_acto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_acto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_acto (
    presponsable_id integer NOT NULL,
    categoria_id integer NOT NULL,
    persona_id integer NOT NULL,
    caso_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_acto_id_seq'::regclass) NOT NULL,
    categoriaant_id integer
);


--
-- Name: sivel2_gen_actocolectivo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_actocolectivo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actocolectivo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_actocolectivo (
    presponsable_id integer NOT NULL,
    categoria_id integer NOT NULL,
    grupoper_id integer NOT NULL,
    caso_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_actocolectivo_id_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_anexo_caso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_anexo_caso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_anexo_caso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_anexo_caso (
    id integer DEFAULT nextval('public.sivel2_gen_anexo_caso_id_seq'::regclass) NOT NULL,
    caso_id integer NOT NULL,
    fecha date NOT NULL,
    fuenteprensa_id integer,
    fechaffrecuente date,
    fotra_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    anexo_id integer NOT NULL
);


--
-- Name: sivel2_gen_anexo_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_anexo_victima (
    id bigint NOT NULL,
    anexo_id integer,
    victima_id integer,
    fecha date,
    tipoanexo_id integer
);


--
-- Name: sivel2_gen_anexo_victima_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_anexo_victima_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_anexo_victima_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_anexo_victima_id_seq OWNED BY public.sivel2_gen_anexo_victima.id;


--
-- Name: sivel2_gen_antecedente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_antecedente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_antecedente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente (
    id integer DEFAULT nextval('public.sivel2_gen_antecedente_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT antecedente_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_antecedente_caso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_caso (
    antecedente_id integer NOT NULL,
    caso_id integer NOT NULL
);


--
-- Name: sivel2_gen_antecedente_combatiente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_combatiente (
    antecedente_id integer NOT NULL,
    combatiente_id integer NOT NULL
);


--
-- Name: sivel2_gen_antecedente_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_victima (
    antecedente_id integer NOT NULL,
    victima_id integer NOT NULL
);


--
-- Name: sivel2_gen_antecedente_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_antecedente_victimacolectiva (
    antecedente_id integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_caso_categoria_presponsable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_categoria_presponsable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_categoria_presponsable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_categoria_presponsable (
    categoria_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    caso_presponsable_id integer,
    id integer DEFAULT nextval('public.sivel2_gen_caso_categoria_presponsable_id_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_caso_contexto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_contexto (
    caso_id integer NOT NULL,
    contexto_id integer NOT NULL
);


--
-- Name: sivel2_gen_caso_etiqueta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_etiqueta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_etiqueta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_etiqueta (
    caso_id integer NOT NULL,
    etiqueta_id integer NOT NULL,
    usuario_id integer NOT NULL,
    fecha date NOT NULL,
    observaciones character varying(10000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_caso_etiqueta_id_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_caso_fotra_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_fotra_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_fotra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_fotra (
    caso_id integer NOT NULL,
    fotra_id integer,
    anotacion character varying(1024),
    fecha date NOT NULL,
    ubicacionfisica character varying(1024),
    tfuente character varying(25),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    id integer DEFAULT nextval('public.sivel2_gen_caso_fotra_id_seq'::regclass) NOT NULL,
    anexo_caso_id integer
);


--
-- Name: sivel2_gen_caso_frontera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_frontera (
    frontera_id integer NOT NULL,
    caso_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_fuenteprensa_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_fuenteprensa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_fuenteprensa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_fuenteprensa (
    fecha date NOT NULL,
    ubicacion character varying(1024),
    clasificacion character varying(100),
    ubicacionfisica character varying(1024),
    fuenteprensa_id integer NOT NULL,
    caso_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_caso_fuenteprensa_id_seq'::regclass) NOT NULL,
    anexo_caso_id integer
);


--
-- Name: sivel2_gen_caso_presponsable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_presponsable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_presponsable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_presponsable (
    caso_id integer NOT NULL,
    presponsable_id integer NOT NULL,
    tipo integer DEFAULT 0 NOT NULL,
    bloque character varying(50),
    frente character varying(50),
    otro character varying(500),
    id integer DEFAULT nextval('public.sivel2_gen_caso_presponsable_id_seq'::regclass) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    subdivision character varying
);


--
-- Name: sivel2_gen_caso_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_region (
    caso_id integer NOT NULL,
    region_id integer NOT NULL
);


--
-- Name: sivel2_gen_caso_respuestafor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_respuestafor (
    caso_id integer NOT NULL,
    respuestafor_id integer NOT NULL
);


--
-- Name: sivel2_gen_caso_solicitud; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_solicitud (
    id bigint NOT NULL,
    caso_id integer NOT NULL,
    solicitud_id integer NOT NULL
);


--
-- Name: sivel2_gen_caso_solicitud_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_caso_solicitud_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_caso_solicitud_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_caso_solicitud_id_seq OWNED BY public.sivel2_gen_caso_solicitud.id;


--
-- Name: sivel2_gen_caso_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_caso_usuario (
    usuario_id integer NOT NULL,
    caso_id integer NOT NULL,
    fechainicio date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_combatiente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_combatiente (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    alias character varying(500),
    edad integer,
    sexo character varying(1) DEFAULT 'S'::character varying NOT NULL,
    resagresion_id integer DEFAULT 1 NOT NULL,
    profesion_id integer DEFAULT 22,
    rangoedad_id integer DEFAULT 6,
    filiacion_id integer DEFAULT 10,
    sectorsocial_id integer DEFAULT 15,
    organizacion_id integer DEFAULT 16,
    vinculoestado_id integer DEFAULT 38,
    caso_id integer,
    organizacionarmada integer DEFAULT 35,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_combatiente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_combatiente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_combatiente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_combatiente_id_seq OWNED BY public.sivel2_gen_combatiente.id;


--
-- Name: sivel2_sjr_ultimaatencion_aux; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sivel2_sjr_ultimaatencion_aux AS
 SELECT DISTINCT v1.caso_id,
    a1.fecha,
    a1.id AS actividad_id
   FROM (((public.cor1440_gen_asistencia asi1
     JOIN public.cor1440_gen_actividad a1 ON ((asi1.actividad_id = a1.id)))
     JOIN public.msip_persona p1 ON ((p1.id = asi1.persona_id)))
     JOIN public.sivel2_gen_victima v1 ON ((v1.persona_id = p1.id)))
  WHERE ((v1.caso_id, a1.fecha, a1.id) IN ( SELECT v2.caso_id,
            a2.fecha,
            a2.id AS actividad_id
           FROM (((public.cor1440_gen_asistencia asi2
             JOIN public.cor1440_gen_actividad a2 ON ((asi2.actividad_id = a2.id)))
             JOIN public.msip_persona p2 ON ((p2.id = asi2.persona_id)))
             JOIN public.sivel2_gen_victima v2 ON ((v2.persona_id = p2.id)))
          WHERE (v2.caso_id = v1.caso_id)
          ORDER BY a2.fecha DESC, a2.id DESC
         LIMIT 1));


--
-- Name: sivel2_sjr_ultimaatencion; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sivel2_sjr_ultimaatencion AS
 SELECT casosjr.caso_id,
    a.id AS actividad_id,
    a.fecha,
    a.objetivo,
    a.resultado,
    public.msip_edad_de_fechanac_fecharef(contacto.anionac, contacto.mesnac, contacto.dianac, (EXTRACT(year FROM a.fecha))::integer, (EXTRACT(month FROM a.fecha))::integer, (EXTRACT(day FROM a.fecha))::integer) AS contacto_edad
   FROM (((public.sivel2_sjr_ultimaatencion_aux uaux
     JOIN public.cor1440_gen_actividad a ON ((uaux.actividad_id = a.id)))
     JOIN public.sivel2_sjr_casosjr casosjr ON ((uaux.caso_id = casosjr.caso_id)))
     JOIN public.msip_persona contacto ON ((contacto.id = casosjr.contacto_id)));


--
-- Name: sivel2_gen_conscaso1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.sivel2_gen_conscaso1 AS
 SELECT casosjr.caso_id,
    (((contacto.nombres)::text || ' '::text) || (contacto.apellidos)::text) AS contacto,
    ultimaatencion.fecha AS ultimaatencion_fecha,
    casosjr.fecharec,
    oficina.nombre AS oficina,
    usuario.nusuario,
    caso.fecha,
    ( SELECT emblematica.expulsionubicacionpre
           FROM public.emblematica
          WHERE (emblematica.caso_id = caso.id)
         LIMIT 1) AS expulsion,
    ( SELECT emblematica.llegadaubicacionpre
           FROM public.emblematica
          WHERE (emblematica.caso_id = caso.id)
         LIMIT 1) AS llegada,
    caso.memo
   FROM ((((((public.sivel2_sjr_casosjr casosjr
     JOIN public.sivel2_gen_caso caso ON ((casosjr.caso_id = caso.id)))
     JOIN public.msip_oficina oficina ON ((oficina.id = casosjr.oficina_id)))
     JOIN public.usuario ON ((usuario.id = casosjr.asesor)))
     JOIN public.msip_persona contacto ON ((contacto.id = casosjr.contacto_id)))
     JOIN public.sivel2_gen_victima vcontacto ON (((vcontacto.persona_id = contacto.id) AND (vcontacto.caso_id = caso.id))))
     LEFT JOIN public.sivel2_sjr_ultimaatencion ultimaatencion ON ((ultimaatencion.caso_id = caso.id)));


--
-- Name: sivel2_gen_conscaso; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.sivel2_gen_conscaso AS
 SELECT caso_id,
    contacto,
    fecharec,
    oficina,
    nusuario,
    fecha,
    expulsion,
    llegada,
    ultimaatencion_fecha,
    memo,
    to_tsvector('spanish'::regconfig, public.unaccent(((((((((((((((((((caso_id || ' '::text) || contacto) || ' '::text) || replace((fecharec)::text, '-'::text, ' '::text)) || ' '::text) || (oficina)::text) || ' '::text) || (nusuario)::text) || ' '::text) || replace((fecha)::text, '-'::text, ' '::text)) || ' '::text) || COALESCE(expulsion, ''::text)) || ' '::text) || COALESCE(llegada, ''::text)) || ' '::text) || replace(COALESCE((ultimaatencion_fecha)::text, ''::text), '-'::text, ' '::text)) || ' '::text) || memo))) AS q
   FROM public.sivel2_gen_conscaso1
  WITH NO DATA;


--
-- Name: sivel2_gen_rangoedad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_rangoedad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_rangoedad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_rangoedad (
    id integer DEFAULT nextval('public.sivel2_gen_rangoedad_id_seq'::regclass) NOT NULL,
    nombre character varying(20) NOT NULL COLLATE public.es_co_utf_8,
    limiteinferior integer DEFAULT 0 NOT NULL,
    limitesuperior integer DEFAULT 0 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT rangoedad_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_supracategoria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_supracategoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_supracategoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_supracategoria (
    codigo integer,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    tviolencia_id character varying(1) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    id integer DEFAULT nextval('public.sivel2_gen_supracategoria_id_seq'::regclass) NOT NULL,
    CONSTRAINT supracategoria_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_consexpcaso; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.sivel2_gen_consexpcaso AS
 SELECT conscaso.caso_id,
    conscaso.fecharec AS fecharecepcion,
    conscaso.nusuario AS asesor,
    conscaso.oficina,
    conscaso.fecha AS fechadespemb,
    conscaso.expulsion,
    conscaso.llegada,
    conscaso.memo AS descripcion,
    (EXTRACT(month FROM ultimaatencion.fecha))::integer AS ultimaatencion_mes,
    conscaso.ultimaatencion_fecha,
    conscaso.contacto,
    contacto.nombres AS contacto_nombres,
    contacto.apellidos AS contacto_apellidos,
    (((COALESCE(tdocumento.sigla, ''::character varying))::text || ' '::text) || (contacto.numerodocumento)::text) AS contacto_identificacion,
    contacto.sexo AS contacto_sexo,
    public.msip_edad_de_fechanac_fecharef(contacto.anionac, contacto.mesnac, contacto.dianac, (EXTRACT(year FROM conscaso.fecharec))::integer, (EXTRACT(month FROM conscaso.fecharec))::integer, (EXTRACT(day FROM conscaso.fecharec))::integer) AS contacto_edad_fecha_recepcion,
    public.msip_edad_de_fechanac_fecharef(( SELECT persona.anionac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 1
         LIMIT 1), ( SELECT persona.mesnac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 1
         LIMIT 1), ( SELECT persona.dianac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 1
         LIMIT 1), (EXTRACT(year FROM conscaso.fecharec))::integer, (EXTRACT(month FROM conscaso.fecharec))::integer, (EXTRACT(day FROM conscaso.fecharec))::integer) AS familiar1_edad_fecha_recepcion,
    public.msip_edad_de_fechanac_fecharef(( SELECT persona.anionac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 1
         LIMIT 1), ( SELECT persona.mesnac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 1
         LIMIT 1), ( SELECT persona.dianac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 1
         LIMIT 1), (EXTRACT(year FROM conscaso.ultimaatencion_fecha))::integer, (EXTRACT(month FROM conscaso.ultimaatencion_fecha))::integer, (EXTRACT(day FROM conscaso.ultimaatencion_fecha))::integer) AS familiar1_edad_ultimaatencion,
    public.msip_edad_de_fechanac_fecharef(( SELECT persona.anionac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 2
         LIMIT 1), ( SELECT persona.mesnac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 2
         LIMIT 1), ( SELECT persona.dianac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 2
         LIMIT 1), (EXTRACT(year FROM conscaso.fecharec))::integer, (EXTRACT(month FROM conscaso.fecharec))::integer, (EXTRACT(day FROM conscaso.fecharec))::integer) AS familiar2_edad_fecha_recepcion,
    public.msip_edad_de_fechanac_fecharef(( SELECT persona.anionac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 2
         LIMIT 1), ( SELECT persona.mesnac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 2
         LIMIT 1), ( SELECT persona.dianac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 2
         LIMIT 1), (EXTRACT(year FROM conscaso.ultimaatencion_fecha))::integer, (EXTRACT(month FROM conscaso.ultimaatencion_fecha))::integer, (EXTRACT(day FROM conscaso.ultimaatencion_fecha))::integer) AS familiar2_edad_ultimaatencion,
    public.msip_edad_de_fechanac_fecharef(( SELECT persona.anionac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 3
         LIMIT 1), ( SELECT persona.mesnac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 3
         LIMIT 1), ( SELECT persona.dianac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 3
         LIMIT 1), (EXTRACT(year FROM conscaso.fecharec))::integer, (EXTRACT(month FROM conscaso.fecharec))::integer, (EXTRACT(day FROM conscaso.fecharec))::integer) AS familiar3_edad_fecha_recepcion,
    public.msip_edad_de_fechanac_fecharef(( SELECT persona.anionac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 3
         LIMIT 1), ( SELECT persona.mesnac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 3
         LIMIT 1), ( SELECT persona.dianac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 3
         LIMIT 1), (EXTRACT(year FROM conscaso.ultimaatencion_fecha))::integer, (EXTRACT(month FROM conscaso.ultimaatencion_fecha))::integer, (EXTRACT(day FROM conscaso.ultimaatencion_fecha))::integer) AS familiar3_edad_ultimaatencion,
    public.msip_edad_de_fechanac_fecharef(( SELECT persona.anionac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 4
         LIMIT 1), ( SELECT persona.mesnac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 4
         LIMIT 1), ( SELECT persona.dianac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 4
         LIMIT 1), (EXTRACT(year FROM conscaso.fecharec))::integer, (EXTRACT(month FROM conscaso.fecharec))::integer, (EXTRACT(day FROM conscaso.fecharec))::integer) AS familiar4_edad_fecha_recepcion,
    public.msip_edad_de_fechanac_fecharef(( SELECT persona.anionac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 4
         LIMIT 1), ( SELECT persona.mesnac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 4
         LIMIT 1), ( SELECT persona.dianac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 4
         LIMIT 1), (EXTRACT(year FROM conscaso.ultimaatencion_fecha))::integer, (EXTRACT(month FROM conscaso.ultimaatencion_fecha))::integer, (EXTRACT(day FROM conscaso.ultimaatencion_fecha))::integer) AS familiar4_edad_ultimaatencion,
    public.msip_edad_de_fechanac_fecharef(( SELECT persona.anionac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 5
         LIMIT 1), ( SELECT persona.mesnac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 5
         LIMIT 1), ( SELECT persona.dianac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 5
         LIMIT 1), (EXTRACT(year FROM conscaso.fecharec))::integer, (EXTRACT(month FROM conscaso.fecharec))::integer, (EXTRACT(day FROM conscaso.fecharec))::integer) AS familiar5_edad_fecha_recepcion,
    public.msip_edad_de_fechanac_fecharef(( SELECT persona.anionac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 5
         LIMIT 1), ( SELECT persona.mesnac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 5
         LIMIT 1), ( SELECT persona.dianac
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))
         OFFSET 5
         LIMIT 1), (EXTRACT(year FROM conscaso.ultimaatencion_fecha))::integer, (EXTRACT(month FROM conscaso.ultimaatencion_fecha))::integer, (EXTRACT(day FROM conscaso.ultimaatencion_fecha))::integer) AS familiar5_edad_ultimaatencion,
    ( SELECT sivel2_gen_rangoedad.nombre
           FROM public.sivel2_gen_rangoedad
          WHERE ((sivel2_gen_rangoedad.fechadeshabilitacion IS NULL) AND (sivel2_gen_rangoedad.limiteinferior <= public.msip_edad_de_fechanac_fecharef(contacto.anionac, contacto.mesnac, contacto.dianac, (EXTRACT(year FROM conscaso.fecharec))::integer, (EXTRACT(month FROM conscaso.fecharec))::integer, (EXTRACT(day FROM conscaso.fecharec))::integer)) AND (sivel2_gen_rangoedad.limitesuperior >= public.msip_edad_de_fechanac_fecharef(contacto.anionac, contacto.mesnac, contacto.dianac, (EXTRACT(year FROM conscaso.fecharec))::integer, (EXTRACT(month FROM conscaso.fecharec))::integer, (EXTRACT(day FROM conscaso.fecharec))::integer)))
         LIMIT 1) AS contacto_rangoedad_fecha_recepcion,
    public.msip_edad_de_fechanac_fecharef(contacto.anionac, contacto.mesnac, contacto.dianac, (EXTRACT(year FROM conscaso.fecha))::integer, (EXTRACT(month FROM conscaso.fecha))::integer, (EXTRACT(day FROM conscaso.fecha))::integer) AS contacto_edad_fecha_salida,
    ( SELECT sivel2_gen_rangoedad.nombre
           FROM public.sivel2_gen_rangoedad
          WHERE ((sivel2_gen_rangoedad.fechadeshabilitacion IS NULL) AND (sivel2_gen_rangoedad.limiteinferior <= public.msip_edad_de_fechanac_fecharef(contacto.anionac, contacto.mesnac, contacto.dianac, (EXTRACT(year FROM conscaso.fecha))::integer, (EXTRACT(month FROM conscaso.fecha))::integer, (EXTRACT(day FROM conscaso.fecha))::integer)) AND (sivel2_gen_rangoedad.limitesuperior >= public.msip_edad_de_fechanac_fecharef(contacto.anionac, contacto.mesnac, contacto.dianac, (EXTRACT(year FROM conscaso.fecha))::integer, (EXTRACT(month FROM conscaso.fecha))::integer, (EXTRACT(day FROM conscaso.fecha))::integer)))
         LIMIT 1) AS contacto_rangoedad_fecha_salida,
    COALESCE(etnia.nombre, ''::character varying) AS contacto_etnia,
    ultimaatencion.contacto_edad AS contacto_edad_ultimaatencion,
    ( SELECT sivel2_gen_rangoedad.nombre
           FROM public.sivel2_gen_rangoedad
          WHERE ((sivel2_gen_rangoedad.fechadeshabilitacion IS NULL) AND (sivel2_gen_rangoedad.limiteinferior <= ultimaatencion.contacto_edad) AND (ultimaatencion.contacto_edad <= sivel2_gen_rangoedad.limitesuperior))
         LIMIT 1) AS contacto_rangoedad_ultimaatencion,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'H'::bpchar) AND (victima.rangoedad_id = 7))) AS beneficiarios_0_5_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'H'::bpchar) AND (victima.rangoedad_id = 8))) AS beneficiarios_6_12_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'H'::bpchar) AND (victima.rangoedad_id = 9))) AS beneficiarios_13_17_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'H'::bpchar) AND (victima.rangoedad_id = 10))) AS beneficiarios_18_26_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'H'::bpchar) AND (victima.rangoedad_id = 11))) AS beneficiarios_27_59_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'H'::bpchar) AND (victima.rangoedad_id = 12))) AS beneficiarios_60m_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'H'::bpchar) AND (victima.rangoedad_id = 6))) AS beneficiarios_se_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'M'::bpchar) AND (victima.rangoedad_id = 7))) AS beneficiarias_0_5_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'M'::bpchar) AND (victima.rangoedad_id = 8))) AS beneficiarias_6_12_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'M'::bpchar) AND (victima.rangoedad_id = 9))) AS beneficiarias_13_17_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'M'::bpchar) AND (victima.rangoedad_id = 10))) AS beneficiarias_18_26_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'M'::bpchar) AND (victima.rangoedad_id = 11))) AS beneficiarias_27_59_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'M'::bpchar) AND (victima.rangoedad_id = 12))) AS beneficiarias_60m_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'M'::bpchar) AND (victima.rangoedad_id = 6))) AS beneficiarias_se_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'S'::bpchar) AND (victima.rangoedad_id = 7))) AS beneficiarios_ss_0_5_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'S'::bpchar) AND (victima.rangoedad_id = 8))) AS beneficiarios_ss_6_12_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'S'::bpchar) AND (victima.rangoedad_id = 9))) AS beneficiarios_ss_13_17_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'S'::bpchar) AND (victima.rangoedad_id = 10))) AS beneficiarios_ss_18_26_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'S'::bpchar) AND (victima.rangoedad_id = 11))) AS beneficiarios_ss_27_59_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'S'::bpchar) AND (victima.rangoedad_id = 12))) AS beneficiarios_ss_60m_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'S'::bpchar) AND (victima.rangoedad_id = 6))) AS beneficiarios_ss_se_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'O'::bpchar) AND (victima.rangoedad_id = 7))) AS beneficiarios_os_0_5_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'O'::bpchar) AND (victima.rangoedad_id = 8))) AS beneficiarios_os_6_12_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'O'::bpchar) AND (victima.rangoedad_id = 9))) AS beneficiarios_os_13_17_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'O'::bpchar) AND (victima.rangoedad_id = 10))) AS beneficiarios_os_18_26_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'O'::bpchar) AND (victima.rangoedad_id = 11))) AS beneficiarios_os_27_59_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'O'::bpchar) AND (victima.rangoedad_id = 12))) AS beneficiarios_os_60m_fecha_salida,
    ( SELECT count(*) AS count
           FROM (public.sivel2_gen_victima victima
             JOIN public.msip_persona ON ((msip_persona.id = victima.persona_id)))
          WHERE ((victima.caso_id = caso.id) AND (msip_persona.sexo = 'O'::bpchar) AND (victima.rangoedad_id = 6))) AS beneficiarios_os_se_fecha_salida,
    array_to_string(ARRAY( SELECT (((((((supracategoria.tviolencia_id)::text || ':'::text) || categoria.supracategoria_id) || ':'::text) || categoria.id) || ' '::text) || (categoria.nombre)::text)
           FROM public.sivel2_gen_categoria categoria,
            public.sivel2_gen_supracategoria supracategoria,
            public.sivel2_gen_acto acto
          WHERE ((categoria.id = acto.categoria_id) AND (supracategoria.id = categoria.supracategoria_id) AND (acto.caso_id = caso.id))), ', '::text) AS tipificacion,
    array_to_string(ARRAY( SELECT (((persona.nombres)::text || ' '::text) || (persona.apellidos)::text)
           FROM public.msip_persona persona,
            public.sivel2_gen_victima victima
          WHERE ((persona.id = victima.persona_id) AND (victima.caso_id = caso.id))), ', '::text) AS victimas,
    array_to_string(ARRAY( SELECT (((departamento.nombre)::text || ' / '::text) || (municipio.nombre)::text)
           FROM ((public.msip_ubicacion ubicacion
             LEFT JOIN public.msip_departamento departamento ON ((ubicacion.departamento_id = departamento.id)))
             LEFT JOIN public.msip_municipio municipio ON ((ubicacion.municipio_id = municipio.id)))
          WHERE (ubicacion.caso_id = caso.id)), ', '::text) AS ubicaciones,
    array_to_string(ARRAY( SELECT presponsable.nombre
           FROM public.sivel2_gen_presponsable presponsable,
            public.sivel2_gen_caso_presponsable caso_presponsable
          WHERE ((presponsable.id = caso_presponsable.presponsable_id) AND (caso_presponsable.caso_id = caso.id))), ', '::text) AS presponsables,
    casosjr.memo1612,
    ultimaatencion.actividad_id AS ultimaatencion_actividad_id
   FROM (((((((((public.sivel2_gen_conscaso conscaso
     JOIN public.sivel2_sjr_casosjr casosjr ON ((casosjr.caso_id = conscaso.caso_id)))
     JOIN public.sivel2_gen_caso caso ON ((casosjr.caso_id = caso.id)))
     JOIN public.msip_oficina oficina ON ((oficina.id = casosjr.oficina_id)))
     JOIN public.usuario ON ((usuario.id = casosjr.asesor)))
     JOIN public.msip_persona contacto ON ((contacto.id = casosjr.contacto_id)))
     LEFT JOIN public.msip_tdocumento tdocumento ON ((tdocumento.id = contacto.tdocumento_id)))
     JOIN public.sivel2_gen_victima vcontacto ON (((vcontacto.persona_id = contacto.id) AND (vcontacto.caso_id = caso.id))))
     LEFT JOIN public.msip_etnia etnia ON ((contacto.etnia_id = etnia.id)))
     LEFT JOIN public.sivel2_sjr_ultimaatencion ultimaatencion ON ((ultimaatencion.caso_id = caso.id)))
  WHERE (conscaso.caso_id IN ( SELECT sivel2_gen_conscaso.caso_id
           FROM public.sivel2_gen_conscaso
          WHERE (sivel2_gen_conscaso.caso_id = 33649)
          ORDER BY sivel2_gen_conscaso.fecharec DESC, sivel2_gen_conscaso.caso_id))
  ORDER BY conscaso.fecha, conscaso.caso_id
  WITH NO DATA;


--
-- Name: sivel2_gen_contexto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_contexto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_contexto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_contexto (
    id integer DEFAULT nextval('public.sivel2_gen_contexto_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT contexto_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_contextovictima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_contextovictima (
    id bigint NOT NULL,
    nombre character varying(100) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_contextovictima_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_contextovictima_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_contextovictima_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_contextovictima_id_seq OWNED BY public.sivel2_gen_contextovictima.id;


--
-- Name: sivel2_gen_contextovictima_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_contextovictima_victima (
    contextovictima_id integer NOT NULL,
    victima_id integer NOT NULL
);


--
-- Name: sivel2_gen_departamento_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_departamento_region (
    departamento_id integer,
    region_id integer
);


--
-- Name: sivel2_gen_escolaridad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_escolaridad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_escolaridad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_escolaridad (
    id integer DEFAULT nextval('public.sivel2_gen_escolaridad_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT escolaridad_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_estadocivil_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_estadocivil_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_estadocivil; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_estadocivil (
    id integer DEFAULT nextval('public.sivel2_gen_estadocivil_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT estadocivil_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_etnia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_etnia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_etnia_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_etnia_victimacolectiva (
    victimacolectiva_id integer NOT NULL,
    etnia_id integer DEFAULT 1 NOT NULL
);


--
-- Name: sivel2_gen_filiacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_filiacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_filiacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_filiacion (
    id integer DEFAULT nextval('public.sivel2_gen_filiacion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT filiacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_filiacion_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_filiacion_victimacolectiva (
    filiacion_id integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_fotra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_fotra (
    id integer DEFAULT nextval(('sivel2_gen_fotra_id_seq'::text)::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_fotra_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_fotra_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_frontera_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_frontera_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_frontera; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_frontera (
    id integer DEFAULT nextval('public.sivel2_gen_frontera_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT frontera_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_iglesia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_iglesia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_iglesia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_iglesia (
    id integer DEFAULT nextval('public.sivel2_gen_iglesia_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    descripcion character varying(1000),
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT iglesia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_intervalo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_intervalo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_intervalo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_intervalo (
    id integer DEFAULT nextval('public.sivel2_gen_intervalo_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    rango character varying(25) NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT intervalo_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_maternidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_maternidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_maternidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_maternidad (
    id integer DEFAULT nextval('public.sivel2_gen_maternidad_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT maternidad_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_municipio_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_municipio_region (
    municipio_id integer,
    region_id integer
);


--
-- Name: sivel2_gen_observador_filtrodepartamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_observador_filtrodepartamento (
    usuario_id integer,
    departamento_id integer
);


--
-- Name: sivel2_gen_organizacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_organizacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_organizacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_organizacion (
    id integer DEFAULT nextval('public.sivel2_gen_organizacion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT organizacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_organizacion_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_organizacion_victimacolectiva (
    organizacion_id integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_otraorga_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_otraorga_victima (
    organizacion_id integer,
    victima_id integer
);


--
-- Name: sivel2_gen_pconsolidado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_pconsolidado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_pconsolidado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_pconsolidado (
    id integer DEFAULT nextval('public.sivel2_gen_pconsolidado_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    tipoviolencia character varying(25) NOT NULL,
    clasificacion character varying(25) NOT NULL,
    peso integer DEFAULT 0,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(500),
    CONSTRAINT pconsolidado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_profesion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_profesion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_profesion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_profesion (
    id integer DEFAULT nextval('public.sivel2_gen_profesion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT profesion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_profesion_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_profesion_victima (
    id bigint NOT NULL,
    victima_id bigint NOT NULL,
    profesion_id bigint NOT NULL
);


--
-- Name: sivel2_gen_profesion_victima_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_profesion_victima_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_profesion_victima_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_profesion_victima_id_seq OWNED BY public.sivel2_gen_profesion_victima.id;


--
-- Name: sivel2_gen_profesion_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_profesion_victimacolectiva (
    profesion_id integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_rangoedad_victimacolectiva (
    rangoedad_id integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_region_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_region (
    id integer DEFAULT nextval('public.sivel2_gen_region_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT region_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_resagresion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_resagresion (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_gen_resagresion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_resagresion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_resagresion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_gen_resagresion_id_seq OWNED BY public.sivel2_gen_resagresion.id;


--
-- Name: sivel2_gen_sectorsocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_sectorsocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_sectorsocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_sectorsocial (
    id integer DEFAULT nextval('public.sivel2_gen_sectorsocial_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT sectorsocial_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_sectorsocial_victimacolectiva (
    sectorsocial_id integer NOT NULL,
    victimacolectiva_id integer NOT NULL
);


--
-- Name: sivel2_gen_sectorsocialsec_victima; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_sectorsocialsec_victima (
    sectorsocial_id integer,
    victima_id integer
);


--
-- Name: sivel2_gen_tviolencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_tviolencia (
    id character(1) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    nomcorto character varying(10) NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT tviolencia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_victimacolectiva_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_victimacolectiva_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_victimacolectiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_victimacolectiva (
    grupoper_id integer NOT NULL,
    caso_id integer NOT NULL,
    personasaprox integer,
    organizacionarmada integer DEFAULT 35,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('public.sivel2_gen_victimacolectiva_id_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_victimacolectiva_vinculoestado (
    victimacolectiva_id integer NOT NULL,
    vinculoestado_id integer NOT NULL
);


--
-- Name: sivel2_gen_vinculoestado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_gen_vinculoestado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_vinculoestado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_gen_vinculoestado (
    id integer DEFAULT nextval('public.sivel2_gen_vinculoestado_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT vinculoestado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_accionjuridica; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_accionjuridica (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_sjr_accionjuridica_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_accionjuridica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_accionjuridica_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_accionjuridica_id_seq OWNED BY public.sivel2_sjr_accionjuridica.id;


--
-- Name: sivel2_sjr_accionjuridica_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_accionjuridica_respuesta (
    id bigint NOT NULL,
    accionjuridica_id integer NOT NULL,
    respuesta_id integer NOT NULL,
    favorable boolean
);


--
-- Name: sivel2_sjr_accionjuridica_respuesta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_accionjuridica_respuesta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_accionjuridica_respuesta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_accionjuridica_respuesta_id_seq OWNED BY public.sivel2_sjr_accionjuridica_respuesta.id;


--
-- Name: sivel2_sjr_acreditacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_acreditacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_acreditacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_acreditacion (
    id integer DEFAULT nextval('public.sivel2_sjr_acreditacion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT acreditacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_actividad_casosjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_actividad_casosjr (
    id bigint NOT NULL,
    actividad_id integer,
    casosjr_id integer
);


--
-- Name: sivel2_sjr_actividad_casosjr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_actividad_casosjr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_actividad_casosjr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_actividad_casosjr_id_seq OWNED BY public.sivel2_sjr_actividad_casosjr.id;


--
-- Name: sivel2_sjr_actosjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_actosjr (
    fecha date NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    acto_id integer NOT NULL,
    desplazamiento_id integer
);


--
-- Name: sivel2_sjr_agreenpais_migracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_agreenpais_migracion (
    agreenpais_id integer,
    migracion_id integer
);


--
-- Name: sivel2_sjr_agremigracion_migracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_agremigracion_migracion (
    agremigracion_id integer,
    migracion_id integer
);


--
-- Name: sivel2_sjr_aslegal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_aslegal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_aslegal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_aslegal (
    id integer DEFAULT nextval('public.sivel2_sjr_aslegal_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT aslegal_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_aslegal_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_aslegal_respuesta (
    respuesta_id integer NOT NULL,
    aslegal_id integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_aspsicosocial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_aspsicosocial (
    id bigint NOT NULL,
    nombre character varying(100) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sivel2_sjr_aspsicosocial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_aspsicosocial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_aspsicosocial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_aspsicosocial_id_seq OWNED BY public.sivel2_sjr_aspsicosocial.id;


--
-- Name: sivel2_sjr_aspsicosocial_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_aspsicosocial_respuesta (
    aspsicosocial_id bigint NOT NULL,
    respuesta_id bigint NOT NULL
);


--
-- Name: sivel2_sjr_ayudaestado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_ayudaestado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_ayudaestado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudaestado (
    id integer DEFAULT nextval('public.sivel2_sjr_ayudaestado_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT ayudaestado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_ayudasjr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_ayudasjr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_ayudasjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudasjr (
    id integer DEFAULT nextval('public.sivel2_sjr_ayudasjr_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT ayudasjr_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_ayudasjr_derecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudasjr_derecho (
    ayudasjr_id integer,
    derecho_id integer
);


--
-- Name: sivel2_sjr_ayudasjr_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_ayudasjr_respuesta (
    ayudasjr_id integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    respuesta_id integer NOT NULL
);


--
-- Name: sivel2_sjr_categoria_desplazamiento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_categoria_desplazamiento (
    categoria_id integer NOT NULL,
    desplazamiento_id integer NOT NULL
);


--
-- Name: sivel2_sjr_causaagresion_migracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_causaagresion_migracion (
    causaagresion_id integer,
    migracion_id integer
);


--
-- Name: sivel2_sjr_causaagrpais_migracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_causaagrpais_migracion (
    causaagrpais_id integer,
    migracion_id integer
);


--
-- Name: sivel2_sjr_clasifdesp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_clasifdesp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_clasifdesp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_clasifdesp (
    id integer DEFAULT nextval('public.sivel2_sjr_clasifdesp_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT clasifdesp_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_comosupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_comosupo (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_comosupo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_comosupo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_comosupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_comosupo_id_seq OWNED BY public.sivel2_sjr_comosupo.id;


--
-- Name: sivel2_sjr_declaroante_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_declaroante_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_declaroante; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_declaroante (
    id integer DEFAULT nextval('public.sivel2_sjr_declaroante_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT declaroante_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_derecho_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_derecho_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_derecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_derecho (
    id integer DEFAULT nextval('public.sivel2_sjr_derecho_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT '2013-06-12'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT derecho_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_difmigracion_migracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_difmigracion_migracion (
    difmigracion_id integer,
    migracion_id integer
);


--
-- Name: sivel2_sjr_etiqueta_usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_etiqueta_usuario (
    id integer NOT NULL,
    etiqueta_id integer,
    usuario_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_sjr_etiqueta_usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_etiqueta_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_etiqueta_usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_etiqueta_usuario_id_seq OWNED BY public.sivel2_sjr_etiqueta_usuario.id;


--
-- Name: sivel2_sjr_idioma; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_idioma (
    id integer NOT NULL,
    nombre character varying(100),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000)
);


--
-- Name: sivel2_sjr_idioma_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_idioma_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_idioma_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_idioma_id_seq OWNED BY public.sivel2_sjr_idioma.id;


--
-- Name: sivel2_sjr_inclusion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_inclusion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_inclusion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_inclusion (
    id integer DEFAULT nextval('public.sivel2_sjr_inclusion_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    pospres integer,
    CONSTRAINT inclusion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_instanciader_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_instanciader_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_mecanismoder_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_mecanismoder_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_migracion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_migracion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_migracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_migracion_id_seq OWNED BY public.sivel2_sjr_migracion.id;


--
-- Name: sivel2_sjr_modalidadtierra_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_modalidadtierra_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_modalidadtierra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_modalidadtierra (
    id integer DEFAULT nextval('public.sivel2_sjr_modalidadtierra_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT modalidadtierra_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_motivoconsulta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_motivoconsulta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_motivosjr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_motivosjr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_motivosjr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_motivosjr (
    id integer DEFAULT nextval('public.sivel2_sjr_motivosjr_id_seq'::regclass) NOT NULL,
    nombre character varying(100) NOT NULL,
    fechacreacion date DEFAULT '2013-06-16'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT motivosjr_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_motivosjr_derecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_motivosjr_derecho (
    motivosjr_id integer,
    derecho_id integer
);


--
-- Name: sivel2_sjr_motivosjr_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_motivosjr_respuesta (
    motivosjr_id integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    respuesta_id integer NOT NULL
);


--
-- Name: sivel2_sjr_oficina_proyectofinanciero; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_oficina_proyectofinanciero (
    oficina_id bigint NOT NULL,
    proyectofinanciero_id bigint NOT NULL
);


--
-- Name: sivel2_sjr_personadesea_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_personadesea_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_personadesea; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_personadesea (
    id integer DEFAULT nextval('public.sivel2_sjr_personadesea_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT '2013-06-17'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT personadesea_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_progestado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_progestado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_progestado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_progestado (
    id integer DEFAULT nextval('public.sivel2_sjr_progestado_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT '2013-06-17'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT progestado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_progestado_derecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_progestado_derecho (
    progestado_id integer,
    derecho_id integer
);


--
-- Name: sivel2_sjr_progestado_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_progestado_respuesta (
    progestado_id integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    respuesta_id integer NOT NULL
);


--
-- Name: sivel2_sjr_proteccion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_proteccion (
    id integer NOT NULL,
    nombre character varying(100),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000)
);


--
-- Name: sivel2_sjr_proteccion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_proteccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_proteccion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_proteccion_id_seq OWNED BY public.sivel2_sjr_proteccion.id;


--
-- Name: sivel2_sjr_regimensalud_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_regimensalud_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_regimensalud; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_regimensalud (
    id integer DEFAULT nextval('public.sivel2_sjr_regimensalud_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT '2013-05-13'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT regimensalud_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_resagresion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_resagresion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_rolfamilia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_rolfamilia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_rolfamilia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_rolfamilia (
    id integer DEFAULT nextval('public.sivel2_sjr_rolfamilia_id_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT rolfamilia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_sjr_statusmigratorio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_statusmigratorio (
    id integer NOT NULL,
    nombre character varying(100),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    formupersona boolean
);


--
-- Name: sivel2_sjr_statusmigratorio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_statusmigratorio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_statusmigratorio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sivel2_sjr_statusmigratorio_id_seq OWNED BY public.sivel2_sjr_statusmigratorio.id;


--
-- Name: sivel2_sjr_tipodesp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sivel2_sjr_tipodesp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_sjr_tipodesp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sivel2_sjr_tipodesp (
    id integer DEFAULT nextval('public.sivel2_sjr_tipodesp_id_seq'::regclass) NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    fechacreacion date DEFAULT '2013-05-24'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    observaciones character varying(5000),
    CONSTRAINT tipodesp_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: territorial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.territorial (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    pais_id integer,
    departamento_id integer,
    municipio_id integer,
    centropoblado_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: territorial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.territorial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: territorial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.territorial_id_seq OWNED BY public.territorial.id;


--
-- Name: tipoproteccion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tipoproteccion (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tipoproteccion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tipoproteccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tipoproteccion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tipoproteccion_id_seq OWNED BY public.tipoproteccion.id;


--
-- Name: tipotransferencia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tipotransferencia (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tipotransferencia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tipotransferencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tipotransferencia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tipotransferencia_id_seq OWNED BY public.tipotransferencia.id;


--
-- Name: trivalentepositiva; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trivalentepositiva (
    id bigint NOT NULL,
    nombre character varying(100),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    observaciones character varying(5000)
);


--
-- Name: trivalentepositiva_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trivalentepositiva_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trivalentepositiva_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trivalentepositiva_id_seq OWNED BY public.trivalentepositiva.id;


--
-- Name: unidadayuda; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unidadayuda (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL COLLATE public.es_co_utf_8,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    orden integer
);


--
-- Name: unidadayuda_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.unidadayuda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unidadayuda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.unidadayuda_id_seq OWNED BY public.unidadayuda.id;


--
-- Name: viadeingreso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.viadeingreso (
    id bigint NOT NULL,
    nombre character varying(500) NOT NULL,
    observaciones character varying(5000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: viadeingreso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.viadeingreso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: viadeingreso_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.viadeingreso_id_seq OWNED BY public.viadeingreso.id;


--
-- Name: actonino id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actonino ALTER COLUMN id SET DEFAULT nextval('public.actonino_id_seq'::regclass);


--
-- Name: agresionmigracion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agresionmigracion ALTER COLUMN id SET DEFAULT nextval('public.agresionmigracion_id_seq'::regclass);


--
-- Name: asesorhistorico id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asesorhistorico ALTER COLUMN id SET DEFAULT nextval('public.asesorhistorico_id_seq'::regclass);


--
-- Name: autoridadrefugio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autoridadrefugio ALTER COLUMN id SET DEFAULT nextval('public.autoridadrefugio_id_seq'::regclass);


--
-- Name: causaagresion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.causaagresion ALTER COLUMN id SET DEFAULT nextval('public.causaagresion_id_seq'::regclass);


--
-- Name: causamigracion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.causamigracion ALTER COLUMN id SET DEFAULT nextval('public.causamigracion_id_seq'::regclass);


--
-- Name: cor1440_gen_actividad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividad_id_seq'::regclass);


--
-- Name: cor1440_gen_actividad_proyecto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyecto ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividad_proyecto_id_seq'::regclass);


--
-- Name: cor1440_gen_actividad_rangoedadac id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_rangoedadac ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividad_rangoedadac_id_seq'::regclass);


--
-- Name: cor1440_gen_actividadarea id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadarea ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividadarea_id_seq'::regclass);


--
-- Name: cor1440_gen_actividadareas_actividad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadareas_actividad ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividadareas_actividad_id_seq'::regclass);


--
-- Name: cor1440_gen_actividadpf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividadpf_id_seq'::regclass);


--
-- Name: cor1440_gen_actividadtipo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadtipo ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_actividadtipo_id_seq'::regclass);


--
-- Name: cor1440_gen_anexo_efecto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_efecto ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_anexo_efecto_id_seq'::regclass);


--
-- Name: cor1440_gen_anexo_proyectofinanciero id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_proyectofinanciero ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_anexo_proyectofinanciero_id_seq'::regclass);


--
-- Name: cor1440_gen_asistencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_asistencia ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_asistencia_id_seq'::regclass);


--
-- Name: cor1440_gen_caracterizacionpersona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpersona ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_caracterizacionpersona_id_seq'::regclass);


--
-- Name: cor1440_gen_datointermedioti id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_datointermedioti_id_seq'::regclass);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti_pmindicadorpf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_datointermedioti_pmindicadorpf_id_seq'::regclass);


--
-- Name: cor1440_gen_desembolso id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_desembolso ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_desembolso_id_seq'::regclass);


--
-- Name: cor1440_gen_efecto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_efecto_id_seq'::regclass);


--
-- Name: cor1440_gen_financiador id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_financiador ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_financiador_id_seq'::regclass);


--
-- Name: cor1440_gen_indicadorpf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_indicadorpf_id_seq'::regclass);


--
-- Name: cor1440_gen_informe id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_informe_id_seq'::regclass);


--
-- Name: cor1440_gen_informeauditoria id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informeauditoria ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_informeauditoria_id_seq'::regclass);


--
-- Name: cor1440_gen_informefinanciero id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informefinanciero ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_informefinanciero_id_seq'::regclass);


--
-- Name: cor1440_gen_informenarrativo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informenarrativo ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_informenarrativo_id_seq'::regclass);


--
-- Name: cor1440_gen_mindicadorpf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_mindicadorpf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_mindicadorpf_id_seq'::regclass);


--
-- Name: cor1440_gen_objetivopf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_objetivopf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_objetivopf_id_seq'::regclass);


--
-- Name: cor1440_gen_pmindicadorpf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_pmindicadorpf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_pmindicadorpf_id_seq'::regclass);


--
-- Name: cor1440_gen_proyecto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyecto ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_proyecto_id_seq'::regclass);


--
-- Name: cor1440_gen_proyectofinanciero id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_proyectofinanciero_id_seq'::regclass);


--
-- Name: cor1440_gen_proyectofinanciero_usuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero_usuario ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_proyectofinanciero_usuario_id_seq'::regclass);


--
-- Name: cor1440_gen_rangoedadac id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_rangoedadac ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_rangoedadac_id_seq'::regclass);


--
-- Name: cor1440_gen_resultadopf id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_resultadopf ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_resultadopf_id_seq'::regclass);


--
-- Name: cor1440_gen_sectorapc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_sectorapc ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_sectorapc_id_seq'::regclass);


--
-- Name: cor1440_gen_tipoindicador id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_tipoindicador ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_tipoindicador_id_seq'::regclass);


--
-- Name: cor1440_gen_tipomoneda id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_tipomoneda ALTER COLUMN id SET DEFAULT nextval('public.cor1440_gen_tipomoneda_id_seq'::regclass);


--
-- Name: declaracionruv id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.declaracionruv ALTER COLUMN id SET DEFAULT nextval('public.declaracionruv_id_seq'::regclass);


--
-- Name: depgifmm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.depgifmm ALTER COLUMN id SET DEFAULT nextval('public.depgifmm_id_seq'::regclass);


--
-- Name: detallefinanciero id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero ALTER COLUMN id SET DEFAULT nextval('public.detallefinanciero_id_seq'::regclass);


--
-- Name: dificultadmigracion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dificultadmigracion ALTER COLUMN id SET DEFAULT nextval('public.dificultadmigracion_id_seq'::regclass);


--
-- Name: discapacidad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discapacidad ALTER COLUMN id SET DEFAULT nextval('public.discapacidad_id_seq'::regclass);


--
-- Name: docidsecundario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.docidsecundario ALTER COLUMN id SET DEFAULT nextval('public.docidsecundario_id_seq'::regclass);


--
-- Name: espaciopart id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.espaciopart ALTER COLUMN id SET DEFAULT nextval('public.espaciopart_id_seq'::regclass);


--
-- Name: frecuenciaentrega id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frecuenciaentrega ALTER COLUMN id SET DEFAULT nextval('public.frecuenciaentrega_id_seq'::regclass);


--
-- Name: heb412_gen_campohc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campohc ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_campohc_id_seq'::regclass);


--
-- Name: heb412_gen_campoplantillahcm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcm ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_campoplantillahcm_id_seq'::regclass);


--
-- Name: heb412_gen_campoplantillahcr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcr ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_campoplantillahcr_id_seq'::regclass);


--
-- Name: heb412_gen_carpetaexclusiva id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_carpetaexclusiva ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_carpetaexclusiva_id_seq'::regclass);


--
-- Name: heb412_gen_doc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_doc ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_doc_id_seq'::regclass);


--
-- Name: heb412_gen_formulario_plantillahcr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_formulario_plantillahcr_id_seq'::regclass);


--
-- Name: heb412_gen_plantilladoc id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantilladoc ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_plantilladoc_id_seq'::regclass);


--
-- Name: heb412_gen_plantillahcm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcm ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_plantillahcm_id_seq'::regclass);


--
-- Name: heb412_gen_plantillahcr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcr ALTER COLUMN id SET DEFAULT nextval('public.heb412_gen_plantillahcr_id_seq'::regclass);


--
-- Name: indicadorgifmm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indicadorgifmm ALTER COLUMN id SET DEFAULT nextval('public.indicadorgifmm_id_seq'::regclass);


--
-- Name: mecanismodeentrega id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mecanismodeentrega ALTER COLUMN id SET DEFAULT nextval('public.mecanismodeentrega_id_seq'::regclass);


--
-- Name: miembrofamiliar id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.miembrofamiliar ALTER COLUMN id SET DEFAULT nextval('public.miembrofamiliar_id_seq'::regclass);


--
-- Name: migracontactopre id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migracontactopre ALTER COLUMN id SET DEFAULT nextval('public.migracontactopre_id_seq'::regclass);


--
-- Name: modalidadentrega id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modalidadentrega ALTER COLUMN id SET DEFAULT nextval('public.modalidadentrega_id_seq'::regclass);


--
-- Name: mr519_gen_campo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_campo_id_seq'::regclass);


--
-- Name: mr519_gen_encuestapersona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_encuestapersona_id_seq'::regclass);


--
-- Name: mr519_gen_encuestausuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_encuestausuario_id_seq'::regclass);


--
-- Name: mr519_gen_formulario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_formulario ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_formulario_id_seq'::regclass);


--
-- Name: mr519_gen_opcioncs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_opcioncs_id_seq'::regclass);


--
-- Name: mr519_gen_planencuesta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_planencuesta ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_planencuesta_id_seq'::regclass);


--
-- Name: mr519_gen_respuestafor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_respuestafor_id_seq'::regclass);


--
-- Name: mr519_gen_valorcampo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo ALTER COLUMN id SET DEFAULT nextval('public.mr519_gen_valorcampo_id_seq'::regclass);


--
-- Name: msip_anexo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_anexo ALTER COLUMN id SET DEFAULT nextval('public.msip_anexo_id_seq'::regclass);


--
-- Name: msip_bitacora id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_bitacora ALTER COLUMN id SET DEFAULT nextval('public.msip_bitacora_id_seq'::regclass);


--
-- Name: msip_centropoblado_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_centropoblado_histvigencia_id_seq'::regclass);


--
-- Name: msip_claverespaldo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_claverespaldo ALTER COLUMN id SET DEFAULT nextval('public.msip_claverespaldo_id_seq'::regclass);


--
-- Name: msip_departamento_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_departamento_histvigencia_id_seq'::regclass);


--
-- Name: msip_estadosol id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_estadosol ALTER COLUMN id SET DEFAULT nextval('public.msip_estadosol_id_seq'::regclass);


--
-- Name: msip_etiqueta_persona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_persona ALTER COLUMN id SET DEFAULT nextval('public.msip_etiqueta_persona_id_seq'::regclass);


--
-- Name: msip_etnia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etnia ALTER COLUMN id SET DEFAULT nextval('public.msip_etnia_id_seq'::regclass);


--
-- Name: msip_grupo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo ALTER COLUMN id SET DEFAULT nextval('public.msip_grupo_id_seq'::regclass);


--
-- Name: msip_lineaorgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_lineaorgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_lineaorgsocial_id_seq'::regclass);


--
-- Name: msip_municipio_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_municipio_histvigencia_id_seq'::regclass);


--
-- Name: msip_orgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_orgsocial_id_seq'::regclass);


--
-- Name: msip_orgsocial_persona id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona ALTER COLUMN id SET DEFAULT nextval('public.msip_orgsocial_persona_id_seq'::regclass);


--
-- Name: msip_pais id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais ALTER COLUMN id SET DEFAULT nextval('public.msip_pais_id_seq'::regclass);


--
-- Name: msip_pais_histvigencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais_histvigencia ALTER COLUMN id SET DEFAULT nextval('public.msip_pais_histvigencia_id_seq'::regclass);


--
-- Name: msip_params_vistam id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_params_vistam ALTER COLUMN id SET DEFAULT nextval('public.msip_params_vistam_id_seq'::regclass);


--
-- Name: msip_perfilorgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_perfilorgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_perfilorgsocial_id_seq'::regclass);


--
-- Name: msip_sectororgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_sectororgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_sectororgsocial_id_seq'::regclass);


--
-- Name: msip_solicitud id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud ALTER COLUMN id SET DEFAULT nextval('public.msip_solicitud_id_seq'::regclass);


--
-- Name: msip_tdocumento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tdocumento ALTER COLUMN id SET DEFAULT nextval('public.msip_tdocumento_id_seq'::regclass);


--
-- Name: msip_tema id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tema ALTER COLUMN id SET DEFAULT nextval('public.msip_tema_id_seq'::regclass);


--
-- Name: msip_tipoanexo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tipoanexo ALTER COLUMN id SET DEFAULT nextval('public.msip_tipoanexo_id_seq'::regclass);


--
-- Name: msip_tipoorg id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tipoorg ALTER COLUMN id SET DEFAULT nextval('public.msip_tipoorg_id_seq'::regclass);


--
-- Name: msip_tipoorgsocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tipoorgsocial ALTER COLUMN id SET DEFAULT nextval('public.msip_tipoorgsocial_id_seq'::regclass);


--
-- Name: msip_trivalente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_trivalente ALTER COLUMN id SET DEFAULT nextval('public.msip_trivalente_id_seq'::regclass);


--
-- Name: msip_ubicacionpre id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre ALTER COLUMN id SET DEFAULT nextval('public.msip_ubicacionpre_id_seq'::regclass);


--
-- Name: msip_vereda id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_vereda ALTER COLUMN id SET DEFAULT nextval('public.msip_vereda_id_seq'::regclass);


--
-- Name: mungifmm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mungifmm ALTER COLUMN id SET DEFAULT nextval('public.mungifmm_id_seq'::regclass);


--
-- Name: perfilmigracion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.perfilmigracion ALTER COLUMN id SET DEFAULT nextval('public.perfilmigracion_id_seq'::regclass);


--
-- Name: sectorgifmm id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sectorgifmm ALTER COLUMN id SET DEFAULT nextval('public.sectorgifmm_id_seq'::regclass);


--
-- Name: sivel2_gen_anexo_victima id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_victima ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_anexo_victima_id_seq'::regclass);


--
-- Name: sivel2_gen_caso_solicitud id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_solicitud ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_caso_solicitud_id_seq'::regclass);


--
-- Name: sivel2_gen_combatiente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_combatiente_id_seq'::regclass);


--
-- Name: sivel2_gen_contextovictima id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_contextovictima_id_seq'::regclass);


--
-- Name: sivel2_gen_profesion_victima id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victima ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_profesion_victima_id_seq'::regclass);


--
-- Name: sivel2_gen_resagresion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_resagresion ALTER COLUMN id SET DEFAULT nextval('public.sivel2_gen_resagresion_id_seq'::regclass);


--
-- Name: sivel2_sjr_accionjuridica id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_accionjuridica ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_accionjuridica_id_seq'::regclass);


--
-- Name: sivel2_sjr_accionjuridica_respuesta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_accionjuridica_respuesta ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_accionjuridica_respuesta_id_seq'::regclass);


--
-- Name: sivel2_sjr_actividad_casosjr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actividad_casosjr ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_actividad_casosjr_id_seq'::regclass);


--
-- Name: sivel2_sjr_aspsicosocial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aspsicosocial ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_aspsicosocial_id_seq'::regclass);


--
-- Name: sivel2_sjr_comosupo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_comosupo ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_comosupo_id_seq'::regclass);


--
-- Name: sivel2_sjr_etiqueta_usuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_etiqueta_usuario ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_etiqueta_usuario_id_seq'::regclass);


--
-- Name: sivel2_sjr_idioma id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_idioma ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_idioma_id_seq'::regclass);


--
-- Name: sivel2_sjr_migracion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_migracion_id_seq'::regclass);


--
-- Name: sivel2_sjr_proteccion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_proteccion ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_proteccion_id_seq'::regclass);


--
-- Name: sivel2_sjr_statusmigratorio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_statusmigratorio ALTER COLUMN id SET DEFAULT nextval('public.sivel2_sjr_statusmigratorio_id_seq'::regclass);


--
-- Name: territorial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.territorial ALTER COLUMN id SET DEFAULT nextval('public.territorial_id_seq'::regclass);


--
-- Name: tipoproteccion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipoproteccion ALTER COLUMN id SET DEFAULT nextval('public.tipoproteccion_id_seq'::regclass);


--
-- Name: tipotransferencia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipotransferencia ALTER COLUMN id SET DEFAULT nextval('public.tipotransferencia_id_seq'::regclass);


--
-- Name: trivalentepositiva id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trivalentepositiva ALTER COLUMN id SET DEFAULT nextval('public.trivalentepositiva_id_seq'::regclass);


--
-- Name: unidadayuda id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidadayuda ALTER COLUMN id SET DEFAULT nextval('public.unidadayuda_id_seq'::regclass);


--
-- Name: viadeingreso id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viadeingreso ALTER COLUMN id SET DEFAULT nextval('public.viadeingreso_id_seq'::regclass);


--
-- Name: sivel2_sjr_acreditacion acreditacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_acreditacion
    ADD CONSTRAINT acreditacion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_actividadoficio actividadoficio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actividadoficio
    ADD CONSTRAINT actividadoficio_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_acto acto_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_key UNIQUE (id);


--
-- Name: sivel2_gen_acto acto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_pkey PRIMARY KEY (id);


--
-- Name: actonino actonino_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actonino
    ADD CONSTRAINT actonino_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_actosjr actosjr_id_acto_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actosjr
    ADD CONSTRAINT actosjr_id_acto_key UNIQUE (acto_id);


--
-- Name: sivel2_sjr_actosjr actosjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actosjr
    ADD CONSTRAINT actosjr_pkey PRIMARY KEY (acto_id);


--
-- Name: agresionmigracion agresionmigracion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agresionmigracion
    ADD CONSTRAINT agresionmigracion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_antecedente antecedente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente
    ADD CONSTRAINT antecedente_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: asesorhistorico asesorhistorico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asesorhistorico
    ADD CONSTRAINT asesorhistorico_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_aslegal aslegal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aslegal
    ADD CONSTRAINT aslegal_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_aslegal_respuesta aslegal_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aslegal_respuesta
    ADD CONSTRAINT aslegal_respuesta_pkey PRIMARY KEY (respuesta_id, aslegal_id);


--
-- Name: autoridadrefugio autoridadrefugio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autoridadrefugio
    ADD CONSTRAINT autoridadrefugio_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_ayudaestado ayudaestado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudaestado
    ADD CONSTRAINT ayudaestado_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_ayudaestado_respuesta ayudaestado_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudaestado_respuesta
    ADD CONSTRAINT ayudaestado_respuesta_pkey PRIMARY KEY (respuesta_id, ayudaestado_id);


--
-- Name: sivel2_sjr_ayudasjr ayudasjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr
    ADD CONSTRAINT ayudasjr_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_ayudasjr_respuesta ayudasjr_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr_respuesta
    ADD CONSTRAINT ayudasjr_respuesta_pkey PRIMARY KEY (respuesta_id, ayudasjr_id);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_key UNIQUE (id);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso caso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso
    ADD CONSTRAINT caso_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_presponsable caso_presponsable_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_id_key UNIQUE (id);


--
-- Name: sivel2_gen_caso_presponsable caso_presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_casosjr casosjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_pkey PRIMARY KEY (caso_id);


--
-- Name: sivel2_gen_categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- Name: causaagresion causaagresion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.causaagresion
    ADD CONSTRAINT causaagresion_pkey PRIMARY KEY (id);


--
-- Name: causamigracion causamigracion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.causamigracion
    ADD CONSTRAINT causamigracion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_clasifdesp clasifdesp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_clasifdesp
    ADD CONSTRAINT clasifdesp_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_contexto contexto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contexto
    ADD CONSTRAINT contexto_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad_anexo cor1440_gen_actividad_anexo_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_anexo
    ADD CONSTRAINT cor1440_gen_actividad_anexo_id_key UNIQUE (id);


--
-- Name: cor1440_gen_actividad_anexo cor1440_gen_actividad_anexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_anexo
    ADD CONSTRAINT cor1440_gen_actividad_anexo_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad cor1440_gen_actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad
    ADD CONSTRAINT cor1440_gen_actividad_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad_proyecto cor1440_gen_actividad_proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyecto
    ADD CONSTRAINT cor1440_gen_actividad_proyecto_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero cor1440_gen_actividad_proyectofinanciero_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyectofinanciero
    ADD CONSTRAINT cor1440_gen_actividad_proyectofinanciero_id_key UNIQUE (id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero cor1440_gen_actividad_proyectofinanciero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyectofinanciero
    ADD CONSTRAINT cor1440_gen_actividad_proyectofinanciero_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad_rangoedadac cor1440_gen_actividad_rangoedadac_unicos; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_rangoedadac
    ADD CONSTRAINT cor1440_gen_actividad_rangoedadac_unicos UNIQUE (actividad_id, rangoedadac_id);


--
-- Name: cor1440_gen_actividadpf cor1440_gen_actividadpf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT cor1440_gen_actividadpf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividadtipo cor1440_gen_actividadtipo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadtipo
    ADD CONSTRAINT cor1440_gen_actividadtipo_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_anexo_efecto cor1440_gen_anexo_efecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_efecto
    ADD CONSTRAINT cor1440_gen_anexo_efecto_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_anexo_proyectofinanciero cor1440_gen_anexo_proyectofinanciero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_proyectofinanciero
    ADD CONSTRAINT cor1440_gen_anexo_proyectofinanciero_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_asistencia cor1440_gen_asistencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_asistencia
    ADD CONSTRAINT cor1440_gen_asistencia_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_caracterizacionpersona cor1440_gen_caracterizacionpersona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpersona
    ADD CONSTRAINT cor1440_gen_caracterizacionpersona_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_datointermedioti cor1440_gen_datointermedioti_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti
    ADD CONSTRAINT cor1440_gen_datointermedioti_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf cor1440_gen_datointermedioti_pmindicadorpf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti_pmindicadorpf
    ADD CONSTRAINT cor1440_gen_datointermedioti_pmindicadorpf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_desembolso cor1440_gen_desembolso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_desembolso
    ADD CONSTRAINT cor1440_gen_desembolso_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_efecto cor1440_gen_efecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto
    ADD CONSTRAINT cor1440_gen_efecto_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_financiador cor1440_gen_financiador_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_financiador
    ADD CONSTRAINT cor1440_gen_financiador_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_indicadorpf cor1440_gen_indicadorpf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf
    ADD CONSTRAINT cor1440_gen_indicadorpf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_informe cor1440_gen_informe_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT cor1440_gen_informe_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_informeauditoria cor1440_gen_informeauditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informeauditoria
    ADD CONSTRAINT cor1440_gen_informeauditoria_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_informefinanciero cor1440_gen_informefinanciero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informefinanciero
    ADD CONSTRAINT cor1440_gen_informefinanciero_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_informenarrativo cor1440_gen_informenarrativo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informenarrativo
    ADD CONSTRAINT cor1440_gen_informenarrativo_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_mindicadorpf cor1440_gen_mindicadorpf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_mindicadorpf
    ADD CONSTRAINT cor1440_gen_mindicadorpf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_objetivopf cor1440_gen_objetivopf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_objetivopf
    ADD CONSTRAINT cor1440_gen_objetivopf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_pmindicadorpf cor1440_gen_pmindicadorpf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_pmindicadorpf
    ADD CONSTRAINT cor1440_gen_pmindicadorpf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_proyecto cor1440_gen_proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyecto
    ADD CONSTRAINT cor1440_gen_proyecto_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_proyectofinanciero cor1440_gen_proyectofinanciero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero
    ADD CONSTRAINT cor1440_gen_proyectofinanciero_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_proyectofinanciero_usuario cor1440_gen_proyectofinanciero_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero_usuario
    ADD CONSTRAINT cor1440_gen_proyectofinanciero_usuario_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_resultadopf cor1440_gen_resultadopf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_resultadopf
    ADD CONSTRAINT cor1440_gen_resultadopf_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_sectorapc cor1440_gen_sectorapc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_sectorapc
    ADD CONSTRAINT cor1440_gen_sectorapc_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_tipoindicador cor1440_gen_tipoindicador_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_tipoindicador
    ADD CONSTRAINT cor1440_gen_tipoindicador_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_tipomoneda cor1440_gen_tipomoneda_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_tipomoneda
    ADD CONSTRAINT cor1440_gen_tipomoneda_pkey PRIMARY KEY (id);


--
-- Name: declaracionruv declaracionruv_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.declaracionruv
    ADD CONSTRAINT declaracionruv_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_declaroante declaroante_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_declaroante
    ADD CONSTRAINT declaroante_pkey PRIMARY KEY (id);


--
-- Name: depgifmm depgifmm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.depgifmm
    ADD CONSTRAINT depgifmm_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_derecho derecho_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_derecho
    ADD CONSTRAINT derecho_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_derecho_respuesta derecho_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_derecho_respuesta
    ADD CONSTRAINT derecho_respuesta_pkey PRIMARY KEY (respuesta_id, derecho_id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_caso_fechaexpulsion_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_caso_fechaexpulsion_key UNIQUE (caso_id, fechaexpulsion);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_key UNIQUE (id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_pkey PRIMARY KEY (id);


--
-- Name: detallefinanciero detallefinanciero_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero
    ADD CONSTRAINT detallefinanciero_pkey PRIMARY KEY (id);


--
-- Name: dificultadmigracion dificultadmigracion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dificultadmigracion
    ADD CONSTRAINT dificultadmigracion_pkey PRIMARY KEY (id);


--
-- Name: discapacidad discapacidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discapacidad
    ADD CONSTRAINT discapacidad_pkey PRIMARY KEY (id);


--
-- Name: docidsecundario docidsecundario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.docidsecundario
    ADD CONSTRAINT docidsecundario_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_escolaridad escolaridad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_escolaridad
    ADD CONSTRAINT escolaridad_pkey PRIMARY KEY (id);


--
-- Name: espaciopart espaciopart_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.espaciopart
    ADD CONSTRAINT espaciopart_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_estadocivil estadocivil_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_estadocivil
    ADD CONSTRAINT estadocivil_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_filiacion filiacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion
    ADD CONSTRAINT filiacion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_fotra fotra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_fotra
    ADD CONSTRAINT fotra_pkey PRIMARY KEY (id);


--
-- Name: frecuenciaentrega frecuenciaentrega_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frecuenciaentrega
    ADD CONSTRAINT frecuenciaentrega_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_frontera frontera_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_frontera
    ADD CONSTRAINT frontera_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_campohc heb412_gen_campohc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campohc
    ADD CONSTRAINT heb412_gen_campohc_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_campoplantillahcm heb412_gen_campoplantillahcm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcm
    ADD CONSTRAINT heb412_gen_campoplantillahcm_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_campoplantillahcr heb412_gen_campoplantillahcr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcr
    ADD CONSTRAINT heb412_gen_campoplantillahcr_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_carpetaexclusiva heb412_gen_carpetaexclusiva_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_carpetaexclusiva
    ADD CONSTRAINT heb412_gen_carpetaexclusiva_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_doc heb412_gen_doc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_doc
    ADD CONSTRAINT heb412_gen_doc_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_formulario_plantillahcr heb412_gen_formulario_plantillahcr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr
    ADD CONSTRAINT heb412_gen_formulario_plantillahcr_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_plantilladoc heb412_gen_plantilladoc_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantilladoc
    ADD CONSTRAINT heb412_gen_plantilladoc_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_plantillahcm heb412_gen_plantillahcm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcm
    ADD CONSTRAINT heb412_gen_plantillahcm_pkey PRIMARY KEY (id);


--
-- Name: heb412_gen_plantillahcr heb412_gen_plantillahcr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_plantillahcr
    ADD CONSTRAINT heb412_gen_plantillahcr_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_idioma idioma_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_idioma
    ADD CONSTRAINT idioma_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_iglesia iglesia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_iglesia
    ADD CONSTRAINT iglesia_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_inclusion inclusion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_inclusion
    ADD CONSTRAINT inclusion_pkey PRIMARY KEY (id);


--
-- Name: indicadorgifmm indicadorgifmm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indicadorgifmm
    ADD CONSTRAINT indicadorgifmm_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_intervalo intervalo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_intervalo
    ADD CONSTRAINT intervalo_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_maternidad maternidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_maternidad
    ADD CONSTRAINT maternidad_pkey PRIMARY KEY (id);


--
-- Name: mecanismodeentrega mecanismodeentrega_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mecanismodeentrega
    ADD CONSTRAINT mecanismodeentrega_pkey PRIMARY KEY (id);


--
-- Name: miembrofamiliar miembrofamiliar_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.miembrofamiliar
    ADD CONSTRAINT miembrofamiliar_pkey PRIMARY KEY (id);


--
-- Name: migracontactopre migracontactopre_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migracontactopre
    ADD CONSTRAINT migracontactopre_pkey PRIMARY KEY (id);


--
-- Name: modalidadentrega modalidadentrega_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modalidadentrega
    ADD CONSTRAINT modalidadentrega_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_modalidadtierra modalidadtierra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_modalidadtierra
    ADD CONSTRAINT modalidadtierra_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_motivosjr motivosjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr
    ADD CONSTRAINT motivosjr_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_motivosjr_respuesta motivosjr_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr_respuesta
    ADD CONSTRAINT motivosjr_respuesta_pkey PRIMARY KEY (respuesta_id, motivosjr_id);


--
-- Name: mr519_gen_campo mr519_gen_campo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo
    ADD CONSTRAINT mr519_gen_campo_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_encuestapersona mr519_gen_encuestapersona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT mr519_gen_encuestapersona_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_encuestausuario mr519_gen_encuestausuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT mr519_gen_encuestausuario_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_formulario mr519_gen_formulario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_formulario
    ADD CONSTRAINT mr519_gen_formulario_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_opcioncs mr519_gen_opcioncs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs
    ADD CONSTRAINT mr519_gen_opcioncs_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_planencuesta mr519_gen_planencuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_planencuesta
    ADD CONSTRAINT mr519_gen_planencuesta_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_respuestafor mr519_gen_respuestafor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor
    ADD CONSTRAINT mr519_gen_respuestafor_pkey PRIMARY KEY (id);


--
-- Name: mr519_gen_valorcampo mr519_gen_valorcampo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT mr519_gen_valorcampo_pkey PRIMARY KEY (id);


--
-- Name: msip_anexo msip_anexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_anexo
    ADD CONSTRAINT msip_anexo_pkey PRIMARY KEY (id);


--
-- Name: msip_bitacora msip_bitacora_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_bitacora
    ADD CONSTRAINT msip_bitacora_pkey PRIMARY KEY (id);


--
-- Name: msip_centropoblado_histvigencia msip_centropoblado_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado_histvigencia
    ADD CONSTRAINT msip_centropoblado_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_centropoblado msip_centropoblado_id_municipio_id_cplocal_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_id_municipio_id_cplocal_key UNIQUE (municipio_id, cplocal_cod);


--
-- Name: msip_centropoblado msip_centropoblado_id_uniqe; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_id_uniqe UNIQUE (id);


--
-- Name: msip_centropoblado msip_centropoblado_municipio_id_id_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_municipio_id_id_unico UNIQUE (municipio_id, id);


--
-- Name: msip_centropoblado msip_centropoblado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_pkey PRIMARY KEY (id);


--
-- Name: msip_claverespaldo msip_claverespaldo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_claverespaldo
    ADD CONSTRAINT msip_claverespaldo_pkey PRIMARY KEY (id);


--
-- Name: msip_departamento_histvigencia msip_departamento_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento_histvigencia
    ADD CONSTRAINT msip_departamento_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_departamento msip_departamento_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT msip_departamento_id_key UNIQUE (id);


--
-- Name: msip_departamento msip_departamento_id_pais_id_deplocal_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT msip_departamento_id_pais_id_deplocal_unico UNIQUE (pais_id, deplocal_cod);


--
-- Name: msip_departamento msip_departamento_pais_id_id_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT msip_departamento_pais_id_id_unico UNIQUE (pais_id, id);


--
-- Name: msip_departamento msip_departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT msip_departamento_pkey PRIMARY KEY (id);


--
-- Name: msip_estadosol msip_estadosol_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_estadosol
    ADD CONSTRAINT msip_estadosol_pkey PRIMARY KEY (id);


--
-- Name: msip_etiqueta_persona msip_etiqueta_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_persona
    ADD CONSTRAINT msip_etiqueta_persona_pkey PRIMARY KEY (id);


--
-- Name: msip_etiqueta msip_etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta
    ADD CONSTRAINT msip_etiqueta_pkey PRIMARY KEY (id);


--
-- Name: msip_etnia msip_etnia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etnia
    ADD CONSTRAINT msip_etnia_pkey PRIMARY KEY (id);


--
-- Name: msip_fuenteprensa msip_fuenteprensa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_fuenteprensa
    ADD CONSTRAINT msip_fuenteprensa_pkey PRIMARY KEY (id);


--
-- Name: msip_grupo msip_grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo
    ADD CONSTRAINT msip_grupo_pkey PRIMARY KEY (id);


--
-- Name: msip_grupoper msip_grupoper_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupoper
    ADD CONSTRAINT msip_grupoper_pkey PRIMARY KEY (id);


--
-- Name: msip_lineaorgsocial msip_lineaorgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_lineaorgsocial
    ADD CONSTRAINT msip_lineaorgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_municipio msip_municipio_departamento_id_id_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_departamento_id_id_unico UNIQUE (departamento_id, id);


--
-- Name: msip_municipio_histvigencia msip_municipio_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio_histvigencia
    ADD CONSTRAINT msip_municipio_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_municipio msip_municipio_id_departamento_id_munlocal_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_id_departamento_id_munlocal_unico UNIQUE (departamento_id, munlocal_cod);


--
-- Name: msip_municipio msip_municipio_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_id_key UNIQUE (id);


--
-- Name: msip_municipio msip_municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_pkey PRIMARY KEY (id);


--
-- Name: msip_oficina msip_oficina_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_oficina
    ADD CONSTRAINT msip_oficina_pkey PRIMARY KEY (id);


--
-- Name: msip_orgsocial_persona msip_orgsocial_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona
    ADD CONSTRAINT msip_orgsocial_persona_pkey PRIMARY KEY (id);


--
-- Name: msip_orgsocial msip_orgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT msip_orgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_pais msip_pais_codiso_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais
    ADD CONSTRAINT msip_pais_codiso_unico UNIQUE (codiso);


--
-- Name: msip_pais_histvigencia msip_pais_histvigencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais_histvigencia
    ADD CONSTRAINT msip_pais_histvigencia_pkey PRIMARY KEY (id);


--
-- Name: msip_pais msip_pais_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_pais
    ADD CONSTRAINT msip_pais_pkey PRIMARY KEY (id);


--
-- Name: msip_params_vistam msip_params_vistam_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_params_vistam
    ADD CONSTRAINT msip_params_vistam_pkey PRIMARY KEY (id);


--
-- Name: msip_perfilorgsocial msip_perfilorgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_perfilorgsocial
    ADD CONSTRAINT msip_perfilorgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_persona msip_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT msip_persona_pkey PRIMARY KEY (id);


--
-- Name: msip_persona_trelacion msip_persona_trelacion_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT msip_persona_trelacion_id_key UNIQUE (id);


--
-- Name: msip_persona_trelacion msip_persona_trelacion_persona1_persona2_id_trelacion_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT msip_persona_trelacion_persona1_persona2_id_trelacion_key UNIQUE (persona1, persona2, trelacion_id);


--
-- Name: msip_persona_trelacion msip_persona_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT msip_persona_trelacion_pkey PRIMARY KEY (id);


--
-- Name: msip_sectororgsocial msip_sectororgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_sectororgsocial
    ADD CONSTRAINT msip_sectororgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_solicitud msip_solicitud_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud
    ADD CONSTRAINT msip_solicitud_pkey PRIMARY KEY (id);


--
-- Name: msip_tcentropoblado msip_tcentropoblado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tcentropoblado
    ADD CONSTRAINT msip_tcentropoblado_pkey PRIMARY KEY (id);


--
-- Name: msip_tdocumento msip_tdocumento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tdocumento
    ADD CONSTRAINT msip_tdocumento_pkey PRIMARY KEY (id);


--
-- Name: msip_tema msip_tema_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tema
    ADD CONSTRAINT msip_tema_pkey PRIMARY KEY (id);


--
-- Name: msip_tipoanexo msip_tipoanexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tipoanexo
    ADD CONSTRAINT msip_tipoanexo_pkey PRIMARY KEY (id);


--
-- Name: msip_tipoorg msip_tipoorg_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tipoorg
    ADD CONSTRAINT msip_tipoorg_pkey PRIMARY KEY (id);


--
-- Name: msip_tipoorgsocial msip_tipoorgsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tipoorgsocial
    ADD CONSTRAINT msip_tipoorgsocial_pkey PRIMARY KEY (id);


--
-- Name: msip_trelacion msip_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_trelacion
    ADD CONSTRAINT msip_trelacion_pkey PRIMARY KEY (id);


--
-- Name: msip_trivalente msip_trivalente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_trivalente
    ADD CONSTRAINT msip_trivalente_pkey PRIMARY KEY (id);


--
-- Name: msip_tsitio msip_tsitio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_tsitio
    ADD CONSTRAINT msip_tsitio_pkey PRIMARY KEY (id);


--
-- Name: msip_ubicacion msip_ubicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT msip_ubicacion_pkey PRIMARY KEY (id);


--
-- Name: msip_ubicacionpre msip_ubicacionpre_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT msip_ubicacionpre_pkey PRIMARY KEY (id);


--
-- Name: msip_vereda msip_vereda_municipio_id_id_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_vereda
    ADD CONSTRAINT msip_vereda_municipio_id_id_unico UNIQUE (municipio_id, id);


--
-- Name: msip_vereda msip_vereda_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_vereda
    ADD CONSTRAINT msip_vereda_pkey PRIMARY KEY (id);


--
-- Name: mungifmm mungifmm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mungifmm
    ADD CONSTRAINT mungifmm_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_organizacion organizacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion
    ADD CONSTRAINT organizacion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_pconsolidado pconsolidado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_pconsolidado
    ADD CONSTRAINT pconsolidado_pkey PRIMARY KEY (id);


--
-- Name: perfilmigracion perfilmigracion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.perfilmigracion
    ADD CONSTRAINT perfilmigracion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_personadesea personadesea_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_personadesea
    ADD CONSTRAINT personadesea_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_presponsable presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_presponsable
    ADD CONSTRAINT presponsable_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_profesion profesion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion
    ADD CONSTRAINT profesion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_progestado progestado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado
    ADD CONSTRAINT progestado_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_progestado_respuesta progestado_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado_respuesta
    ADD CONSTRAINT progestado_respuesta_pkey PRIMARY KEY (respuesta_id, progestado_id);


--
-- Name: sivel2_sjr_proteccion proteccion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_proteccion
    ADD CONSTRAINT proteccion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_rangoedad rangoedad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad
    ADD CONSTRAINT rangoedad_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_regimensalud regimensalud_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_regimensalud
    ADD CONSTRAINT regimensalud_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_region region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_respuesta respuesta_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_respuesta
    ADD CONSTRAINT respuesta_id_key UNIQUE (id);


--
-- Name: sivel2_sjr_respuesta respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_respuesta
    ADD CONSTRAINT respuesta_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_rolfamilia rolfamilia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_rolfamilia
    ADD CONSTRAINT rolfamilia_pkey PRIMARY KEY (id);


--
-- Name: sectorgifmm sectorgifmm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sectorgifmm
    ADD CONSTRAINT sectorgifmm_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_sectorsocial sectorsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial
    ADD CONSTRAINT sectorsocial_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividad_rangoedadac sivel2_gen_actividad_rangoedadac_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_rangoedadac
    ADD CONSTRAINT sivel2_gen_actividad_rangoedadac_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividadarea sivel2_gen_actividadarea_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadarea
    ADD CONSTRAINT sivel2_gen_actividadarea_pkey PRIMARY KEY (id);


--
-- Name: cor1440_gen_actividadareas_actividad sivel2_gen_actividadareas_actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadareas_actividad
    ADD CONSTRAINT sivel2_gen_actividadareas_actividad_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_actocolectivo sivel2_gen_actocolectivo_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT sivel2_gen_actocolectivo_id_key UNIQUE (id);


--
-- Name: sivel2_gen_actocolectivo sivel2_gen_actocolectivo_id_presponsable_id_categoria_id_gr_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT sivel2_gen_actocolectivo_id_presponsable_id_categoria_id_gr_key UNIQUE (presponsable_id, categoria_id, grupoper_id, caso_id);


--
-- Name: sivel2_gen_actocolectivo sivel2_gen_actocolectivo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT sivel2_gen_actocolectivo_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_anexo_caso sivel2_gen_anexo_caso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT sivel2_gen_anexo_caso_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_anexo_victima sivel2_gen_anexo_victima_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_victima
    ADD CONSTRAINT sivel2_gen_anexo_victima_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_antecedente_caso sivel2_gen_antecedente_caso_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT sivel2_gen_antecedente_caso_pkey1 PRIMARY KEY (antecedente_id, caso_id);


--
-- Name: sivel2_gen_antecedente_combatiente sivel2_gen_antecedente_combatiente_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_combatiente
    ADD CONSTRAINT sivel2_gen_antecedente_combatiente_pkey1 PRIMARY KEY (antecedente_id, combatiente_id);


--
-- Name: sivel2_gen_antecedente_victima sivel2_gen_antecedente_victima_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victima
    ADD CONSTRAINT sivel2_gen_antecedente_victima_pkey1 PRIMARY KEY (antecedente_id, victima_id);


--
-- Name: sivel2_gen_antecedente_victimacolectiva sivel2_gen_antecedente_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victimacolectiva
    ADD CONSTRAINT sivel2_gen_antecedente_victimacolectiva_pkey1 PRIMARY KEY (antecedente_id, victimacolectiva_id);


--
-- Name: sivel2_gen_caso_categoria_presponsable sivel2_gen_caso_categoria_pre_id_caso_presponsable_id_categ_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT sivel2_gen_caso_categoria_pre_id_caso_presponsable_id_categ_key UNIQUE (caso_presponsable_id, categoria_id);


--
-- Name: sivel2_gen_caso_categoria_presponsable sivel2_gen_caso_categoria_presponsable_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT sivel2_gen_caso_categoria_presponsable_id_key UNIQUE (id);


--
-- Name: sivel2_gen_caso_categoria_presponsable sivel2_gen_caso_categoria_presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT sivel2_gen_caso_categoria_presponsable_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_contexto sivel2_gen_caso_contexto_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_contexto
    ADD CONSTRAINT sivel2_gen_caso_contexto_pkey1 PRIMARY KEY (caso_id, contexto_id);


--
-- Name: sivel2_gen_caso_fotra sivel2_gen_caso_fotra_id_caso_nombre_fecha_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT sivel2_gen_caso_fotra_id_caso_nombre_fecha_key UNIQUE (caso_id, nombre, fecha);


--
-- Name: sivel2_gen_caso_fotra sivel2_gen_caso_fotra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT sivel2_gen_caso_fotra_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_id_caso_fecha_fuenteprensa_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_id_caso_fecha_fuenteprensa_id_key UNIQUE (caso_id, fecha, fuenteprensa_id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_caso_region sivel2_gen_caso_region_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_region
    ADD CONSTRAINT sivel2_gen_caso_region_pkey1 PRIMARY KEY (caso_id, region_id);


--
-- Name: sivel2_gen_caso_respuestafor sivel2_gen_caso_respuestafor_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_respuestafor
    ADD CONSTRAINT sivel2_gen_caso_respuestafor_pkey1 PRIMARY KEY (caso_id, respuestafor_id);


--
-- Name: sivel2_gen_caso_solicitud sivel2_gen_caso_solicitud_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_solicitud
    ADD CONSTRAINT sivel2_gen_caso_solicitud_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_combatiente sivel2_gen_combatiente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT sivel2_gen_combatiente_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_contextovictima sivel2_gen_contextovictima_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima
    ADD CONSTRAINT sivel2_gen_contextovictima_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_contextovictima_victima sivel2_gen_contextovictima_victima_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima_victima
    ADD CONSTRAINT sivel2_gen_contextovictima_victima_pkey1 PRIMARY KEY (contextovictima_id, victima_id);


--
-- Name: sivel2_gen_etnia_victimacolectiva sivel2_gen_etnia_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia_victimacolectiva
    ADD CONSTRAINT sivel2_gen_etnia_victimacolectiva_pkey1 PRIMARY KEY (etnia_id, victimacolectiva_id);


--
-- Name: sivel2_gen_filiacion_victimacolectiva sivel2_gen_filiacion_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion_victimacolectiva
    ADD CONSTRAINT sivel2_gen_filiacion_victimacolectiva_pkey1 PRIMARY KEY (filiacion_id, victimacolectiva_id);


--
-- Name: sivel2_gen_organizacion_victimacolectiva sivel2_gen_organizacion_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion_victimacolectiva
    ADD CONSTRAINT sivel2_gen_organizacion_victimacolectiva_pkey1 PRIMARY KEY (organizacion_id, victimacolectiva_id);


--
-- Name: sivel2_gen_profesion_victima sivel2_gen_profesion_victima_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victima
    ADD CONSTRAINT sivel2_gen_profesion_victima_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_profesion_victimacolectiva sivel2_gen_profesion_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victimacolectiva
    ADD CONSTRAINT sivel2_gen_profesion_victimacolectiva_pkey1 PRIMARY KEY (profesion_id, victimacolectiva_id);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva sivel2_gen_rangoedad_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad_victimacolectiva
    ADD CONSTRAINT sivel2_gen_rangoedad_victimacolectiva_pkey1 PRIMARY KEY (rangoedad_id, victimacolectiva_id);


--
-- Name: cor1440_gen_rangoedadac sivel2_gen_rangoedadac_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_rangoedadac
    ADD CONSTRAINT sivel2_gen_rangoedadac_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_resagresion sivel2_gen_resagresion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_resagresion
    ADD CONSTRAINT sivel2_gen_resagresion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva sivel2_gen_sectorsocial_victimacolectiva_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial_victimacolectiva
    ADD CONSTRAINT sivel2_gen_sectorsocial_victimacolectiva_pkey1 PRIMARY KEY (sectorsocial_id, victimacolectiva_id);


--
-- Name: sivel2_gen_supracategoria sivel2_gen_supracategoria_id_tviolencia_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_supracategoria
    ADD CONSTRAINT sivel2_gen_supracategoria_id_tviolencia_codigo_key UNIQUE (tviolencia_id, codigo);


--
-- Name: sivel2_gen_supracategoria sivel2_gen_supracategoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_supracategoria
    ADD CONSTRAINT sivel2_gen_supracategoria_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_victimacolectiva sivel2_gen_victimacolectiva_id_caso_id_grupoper_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT sivel2_gen_victimacolectiva_id_caso_id_grupoper_key UNIQUE (caso_id, grupoper_id);


--
-- Name: sivel2_gen_victimacolectiva sivel2_gen_victimacolectiva_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT sivel2_gen_victimacolectiva_id_key UNIQUE (id);


--
-- Name: sivel2_gen_victimacolectiva sivel2_gen_victimacolectiva_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT sivel2_gen_victimacolectiva_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado sivel2_gen_victimacolectiva_vinculoestado_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva_vinculoestado
    ADD CONSTRAINT sivel2_gen_victimacolectiva_vinculoestado_pkey1 PRIMARY KEY (victimacolectiva_id, vinculoestado_id);


--
-- Name: sivel2_sjr_accionjuridica sivel2_sjr_accionjuridica_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_accionjuridica
    ADD CONSTRAINT sivel2_sjr_accionjuridica_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_accionjuridica_respuesta sivel2_sjr_accionjuridica_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_accionjuridica_respuesta
    ADD CONSTRAINT sivel2_sjr_accionjuridica_respuesta_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_actividad_casosjr sivel2_sjr_actividad_casosjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actividad_casosjr
    ADD CONSTRAINT sivel2_sjr_actividad_casosjr_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_aspsicosocial sivel2_sjr_aspsicosocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aspsicosocial
    ADD CONSTRAINT sivel2_sjr_aspsicosocial_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_comosupo sivel2_sjr_comosupo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_comosupo
    ADD CONSTRAINT sivel2_sjr_comosupo_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_etiqueta_usuario sivel2_sjr_etiqueta_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_etiqueta_usuario
    ADD CONSTRAINT sivel2_sjr_etiqueta_usuario_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_migracion sivel2_sjr_migracion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT sivel2_sjr_migracion_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_statusmigratorio statusmigratorio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_statusmigratorio
    ADD CONSTRAINT statusmigratorio_pkey PRIMARY KEY (id);


--
-- Name: territorial territorial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.territorial
    ADD CONSTRAINT territorial_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_tipodesp tipodesp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_tipodesp
    ADD CONSTRAINT tipodesp_pkey PRIMARY KEY (id);


--
-- Name: tipoproteccion tipoproteccion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipoproteccion
    ADD CONSTRAINT tipoproteccion_pkey PRIMARY KEY (id);


--
-- Name: tipotransferencia tipotransferencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipotransferencia
    ADD CONSTRAINT tipotransferencia_pkey PRIMARY KEY (id);


--
-- Name: msip_persona tipoynumdoc_unicos; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT tipoynumdoc_unicos UNIQUE (tdocumento_id, numerodocumento);


--
-- Name: trivalentepositiva trivalentepositiva_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trivalentepositiva
    ADD CONSTRAINT trivalentepositiva_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_tviolencia tviolencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_tviolencia
    ADD CONSTRAINT tviolencia_pkey PRIMARY KEY (id);


--
-- Name: unidadayuda unidadayuda_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidadayuda
    ADD CONSTRAINT unidadayuda_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: viadeingreso viadeingreso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.viadeingreso
    ADD CONSTRAINT viadeingreso_pkey PRIMARY KEY (id);


--
-- Name: sivel2_gen_victima victima_id_caso_id_persona_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_id_persona_key UNIQUE (caso_id, persona_id);


--
-- Name: sivel2_gen_victima victima_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_key UNIQUE (id);


--
-- Name: sivel2_gen_victima victima_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_pkey PRIMARY KEY (id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_pkey PRIMARY KEY (victima_id);


--
-- Name: sivel2_gen_vinculoestado vinculoestado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_vinculoestado
    ADD CONSTRAINT vinculoestado_pkey PRIMARY KEY (id);


--
-- Name: busca_conscaso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX busca_conscaso ON public.sivel2_gen_conscaso USING gin (q);


--
-- Name: consgifmm_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX consgifmm_id_idx ON public.consgifmm USING btree (id);


--
-- Name: cor1440_gen_actividad_actividadpf_actividad_id_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_actividad_actividadpf_actividad_id_ind ON public.cor1440_gen_actividad_actividadpf USING btree (actividad_id);


--
-- Name: cor1440_gen_actividad_actividadpf_actividadpf_id_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_actividad_actividadpf_actividadpf_id_ind ON public.cor1440_gen_actividad_actividadpf USING btree (actividadpf_id);


--
-- Name: cor1440_gen_actividad_fecha_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_actividad_fecha_ind ON public.cor1440_gen_actividad USING btree (fecha);


--
-- Name: cor1440_gen_actividad_id_actividadpf_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cor1440_gen_actividad_id_actividadpf_id_idx ON public.cor1440_gen_actividad_actividadpf USING btree (actividad_id, actividadpf_id);


--
-- Name: cor1440_gen_actividad_id_persona_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cor1440_gen_actividad_id_persona_id_idx ON public.cor1440_gen_asistencia USING btree (actividad_id, persona_id);


--
-- Name: cor1440_gen_actividad_oficina_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_actividad_oficina_id_idx ON public.cor1440_gen_actividad USING btree (oficina_id);


--
-- Name: cor1440_gen_actividad_proyectofinanci_proyectofinanciero_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_actividad_proyectofinanci_proyectofinanciero_id_idx ON public.cor1440_gen_actividad_proyectofinanciero USING btree (proyectofinanciero_id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero_actividad_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_actividad_proyectofinanciero_actividad_id_idx ON public.cor1440_gen_actividad_proyectofinanciero USING btree (actividad_id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero_unico; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cor1440_gen_actividad_proyectofinanciero_unico ON public.cor1440_gen_actividad_proyectofinanciero USING btree (actividad_id, proyectofinanciero_id);


--
-- Name: cor1440_gen_asistencia_actividad_id_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_asistencia_actividad_id_ind ON public.cor1440_gen_asistencia USING btree (actividad_id);


--
-- Name: cor1440_gen_asistencia_persona_id_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cor1440_gen_asistencia_persona_id_ind ON public.cor1440_gen_asistencia USING btree (persona_id);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf_llaves_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cor1440_gen_datointermedioti_pmindicadorpf_llaves_idx ON public.cor1440_gen_datointermedioti_pmindicadorpf USING btree (datointermedioti_id, pmindicadorpf_id);


--
-- Name: i_cor1440_gen_actividadpf_proyectofinanciero_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX i_cor1440_gen_actividadpf_proyectofinanciero_id ON public.cor1440_gen_actividadpf USING btree (proyectofinanciero_id);


--
-- Name: index_asesorhistorico_on_usuario_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_asesorhistorico_on_usuario_id ON public.asesorhistorico USING btree (usuario_id);


--
-- Name: index_cor1440_gen_actividad_anexo_on_anexo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cor1440_gen_actividad_anexo_on_anexo_id ON public.cor1440_gen_actividad_anexo USING btree (anexo_id);


--
-- Name: index_cor1440_gen_actividad_on_usuario_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cor1440_gen_actividad_on_usuario_id ON public.cor1440_gen_actividad USING btree (usuario_id);


--
-- Name: index_cor1440_gen_actividadpf_mindicadorpf_on_actividadpf_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cor1440_gen_actividadpf_mindicadorpf_on_actividadpf_id ON public.cor1440_gen_actividadpf_mindicadorpf USING btree (actividadpf_id);


--
-- Name: index_cor1440_gen_actividadpf_mindicadorpf_on_mindicadorpf_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cor1440_gen_actividadpf_mindicadorpf_on_mindicadorpf_id ON public.cor1440_gen_actividadpf_mindicadorpf USING btree (mindicadorpf_id);


--
-- Name: index_cor1440_gen_datointermedioti_on_mindicadorpf_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cor1440_gen_datointermedioti_on_mindicadorpf_id ON public.cor1440_gen_datointermedioti USING btree (mindicadorpf_id);


--
-- Name: index_docidsecundario_on_persona_id_and_tdocumento_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_docidsecundario_on_persona_id_and_tdocumento_id ON public.docidsecundario USING btree (persona_id, tdocumento_id);


--
-- Name: index_docidsecundario_on_tdocumento_id_and_numero; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_docidsecundario_on_tdocumento_id_and_numero ON public.docidsecundario USING btree (tdocumento_id, numero);


--
-- Name: index_heb412_gen_doc_on_tdoc_type_and_tdoc_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_heb412_gen_doc_on_tdoc_type_and_tdoc_id ON public.heb412_gen_doc USING btree (tdoc_type, tdoc_id);


--
-- Name: index_mr519_gen_encuestapersona_on_adurl; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mr519_gen_encuestapersona_on_adurl ON public.mr519_gen_encuestapersona USING btree (adurl);


--
-- Name: index_msip_orgsocial_on_grupoper_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_orgsocial_on_grupoper_id ON public.msip_orgsocial USING btree (grupoper_id);


--
-- Name: index_msip_orgsocial_on_pais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_orgsocial_on_pais_id ON public.msip_orgsocial USING btree (pais_id);


--
-- Name: index_msip_persona_on_etnia_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_persona_on_etnia_id ON public.msip_persona USING btree (etnia_id);


--
-- Name: index_msip_solicitud_usuarionotificar_on_solicitud_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_solicitud_usuarionotificar_on_solicitud_id ON public.msip_solicitud_usuarionotificar USING btree (solicitud_id);


--
-- Name: index_msip_solicitud_usuarionotificar_on_usuarionotificar_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_solicitud_usuarionotificar_on_usuarionotificar_id ON public.msip_solicitud_usuarionotificar USING btree (usuarionotificar_id);


--
-- Name: index_msip_ubicacion_on_caso_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_caso_id ON public.msip_ubicacion USING btree (caso_id);


--
-- Name: index_msip_ubicacion_on_centropoblado_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_centropoblado_id ON public.msip_ubicacion USING btree (centropoblado_id);


--
-- Name: index_msip_ubicacion_on_departamento_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_departamento_id ON public.msip_ubicacion USING btree (departamento_id);


--
-- Name: index_msip_ubicacion_on_municipio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_municipio_id ON public.msip_ubicacion USING btree (municipio_id);


--
-- Name: index_msip_ubicacion_on_pais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_msip_ubicacion_on_pais_id ON public.msip_ubicacion USING btree (pais_id);


--
-- Name: index_sivel2_gen_actividad_rangoedadac_on_actividad_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_actividad_rangoedadac_on_actividad_id ON public.cor1440_gen_actividad_rangoedadac USING btree (actividad_id);


--
-- Name: index_sivel2_gen_actividad_rangoedadac_on_rangoedadac_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_actividad_rangoedadac_on_rangoedadac_id ON public.cor1440_gen_actividad_rangoedadac USING btree (rangoedadac_id);


--
-- Name: index_sivel2_gen_caso_on_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_caso_on_fecha ON public.sivel2_gen_caso USING btree (fecha);


--
-- Name: index_sivel2_gen_caso_on_ubicacion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_caso_on_ubicacion_id ON public.sivel2_gen_caso USING btree (ubicacion_id);


--
-- Name: index_sivel2_gen_caso_solicitud_on_caso_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_caso_solicitud_on_caso_id ON public.sivel2_gen_caso_solicitud USING btree (caso_id);


--
-- Name: index_sivel2_gen_caso_solicitud_on_solicitud_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_caso_solicitud_on_solicitud_id ON public.sivel2_gen_caso_solicitud USING btree (solicitud_id);


--
-- Name: index_sivel2_gen_otraorga_victima_on_organizacion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_otraorga_victima_on_organizacion_id ON public.sivel2_gen_otraorga_victima USING btree (organizacion_id);


--
-- Name: index_sivel2_gen_otraorga_victima_on_victima_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_otraorga_victima_on_victima_id ON public.sivel2_gen_otraorga_victima USING btree (victima_id);


--
-- Name: index_sivel2_gen_profesion_victima_on_profesion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_profesion_victima_on_profesion_id ON public.sivel2_gen_profesion_victima USING btree (profesion_id);


--
-- Name: index_sivel2_gen_profesion_victima_on_victima_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_profesion_victima_on_victima_id ON public.sivel2_gen_profesion_victima USING btree (victima_id);


--
-- Name: index_sivel2_gen_sectorsocialsec_victima_on_sectorsocial_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_sectorsocialsec_victima_on_sectorsocial_id ON public.sivel2_gen_sectorsocialsec_victima USING btree (sectorsocial_id);


--
-- Name: index_sivel2_gen_sectorsocialsec_victima_on_victima_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_gen_sectorsocialsec_victima_on_victima_id ON public.sivel2_gen_sectorsocialsec_victima USING btree (victima_id);


--
-- Name: index_sivel2_sjr_agreenpais_migracion_on_agreenpais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_agreenpais_migracion_on_agreenpais_id ON public.sivel2_sjr_agreenpais_migracion USING btree (agreenpais_id);


--
-- Name: index_sivel2_sjr_agreenpais_migracion_on_migracion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_agreenpais_migracion_on_migracion_id ON public.sivel2_sjr_agreenpais_migracion USING btree (migracion_id);


--
-- Name: index_sivel2_sjr_agremigracion_migracion_on_agremigracion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_agremigracion_migracion_on_agremigracion_id ON public.sivel2_sjr_agremigracion_migracion USING btree (agremigracion_id);


--
-- Name: index_sivel2_sjr_agremigracion_migracion_on_migracion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_agremigracion_migracion_on_migracion_id ON public.sivel2_sjr_agremigracion_migracion USING btree (migracion_id);


--
-- Name: index_sivel2_sjr_caso_on_asesor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_caso_on_asesor ON public.sivel2_sjr_casosjr USING btree (asesor);


--
-- Name: index_sivel2_sjr_caso_on_caso_contacto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_caso_on_caso_contacto ON public.sivel2_sjr_casosjr USING btree (caso_id, contacto_id);


--
-- Name: index_sivel2_sjr_caso_on_oficina_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_caso_on_oficina_id ON public.sivel2_sjr_casosjr USING btree (oficina_id);


--
-- Name: index_sivel2_sjr_casosjr_on_comosupo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_casosjr_on_comosupo_id ON public.sivel2_sjr_casosjr USING btree (comosupo_id);


--
-- Name: index_sivel2_sjr_causaagresion_migracion_on_causaagresion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_causaagresion_migracion_on_causaagresion_id ON public.sivel2_sjr_causaagresion_migracion USING btree (causaagresion_id);


--
-- Name: index_sivel2_sjr_causaagresion_migracion_on_migracion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_causaagresion_migracion_on_migracion_id ON public.sivel2_sjr_causaagresion_migracion USING btree (migracion_id);


--
-- Name: index_sivel2_sjr_causaagrpais_migracion_on_causaagrpais_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_causaagrpais_migracion_on_causaagrpais_id ON public.sivel2_sjr_causaagrpais_migracion USING btree (causaagrpais_id);


--
-- Name: index_sivel2_sjr_causaagrpais_migracion_on_migracion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_causaagrpais_migracion_on_migracion_id ON public.sivel2_sjr_causaagrpais_migracion USING btree (migracion_id);


--
-- Name: index_sivel2_sjr_desplazamiento_on_caso_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_desplazamiento_on_caso_id ON public.sivel2_sjr_desplazamiento USING btree (caso_id);


--
-- Name: index_sivel2_sjr_desplazamiento_on_fechaexpulsion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_desplazamiento_on_fechaexpulsion ON public.sivel2_sjr_desplazamiento USING btree (fechaexpulsion);


--
-- Name: index_sivel2_sjr_difmigracion_migracion_on_difmigracion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_difmigracion_migracion_on_difmigracion_id ON public.sivel2_sjr_difmigracion_migracion USING btree (difmigracion_id);


--
-- Name: index_sivel2_sjr_difmigracion_migracion_on_migracion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_difmigracion_migracion_on_migracion_id ON public.sivel2_sjr_difmigracion_migracion USING btree (migracion_id);


--
-- Name: index_sivel2_sjr_respuesta_on_fechaatencion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sivel2_sjr_respuesta_on_fechaatencion ON public.sivel2_sjr_respuesta USING btree (fechaatencion);


--
-- Name: index_usuario_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_usuario_on_email ON public.usuario USING btree (email);


--
-- Name: index_usuario_on_regionsjr_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_usuario_on_regionsjr_id ON public.usuario USING btree (oficina_id);


--
-- Name: index_usuario_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_usuario_on_reset_password_token ON public.usuario USING btree (reset_password_token);


--
-- Name: indice_msip_ubicacion_sobre_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_msip_ubicacion_sobre_id_caso ON public.msip_ubicacion USING btree (caso_id);


--
-- Name: indice_sivel2_gen_acto_sobre_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_caso ON public.sivel2_gen_acto USING btree (caso_id);


--
-- Name: indice_sivel2_gen_acto_sobre_id_categoria; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_categoria ON public.sivel2_gen_acto USING btree (categoria_id);


--
-- Name: indice_sivel2_gen_acto_sobre_id_persona; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_persona ON public.sivel2_gen_acto USING btree (persona_id);


--
-- Name: indice_sivel2_gen_acto_sobre_id_presponsable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_acto_sobre_id_presponsable ON public.sivel2_gen_acto USING btree (presponsable_id);


--
-- Name: indice_sivel2_gen_caso_presponsable_sobre_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_presponsable_sobre_id_caso ON public.sivel2_gen_caso_presponsable USING btree (caso_id);


--
-- Name: indice_sivel2_gen_caso_presponsable_sobre_id_presponsable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_presponsable_sobre_id_presponsable ON public.sivel2_gen_caso_presponsable USING btree (presponsable_id);


--
-- Name: indice_sivel2_gen_caso_presponsable_sobre_ids_caso_presp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_presponsable_sobre_ids_caso_presp ON public.sivel2_gen_caso_presponsable USING btree (caso_id, presponsable_id);


--
-- Name: indice_sivel2_gen_caso_sobre_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_sobre_fecha ON public.sivel2_gen_caso USING btree (fecha);


--
-- Name: indice_sivel2_gen_caso_sobre_ubicacion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_caso_sobre_ubicacion_id ON public.sivel2_gen_caso USING btree (ubicacion_id);


--
-- Name: indice_sivel2_gen_categoria_sobre_supracategoria_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_gen_categoria_sobre_supracategoria_id ON public.sivel2_gen_categoria USING btree (supracategoria_id);


--
-- Name: indice_sivel2_sjr_casosjr_on_asesor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_casosjr_on_asesor ON public.sivel2_sjr_casosjr USING btree (asesor);


--
-- Name: indice_sivel2_sjr_casosjr_on_caso_contacto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_casosjr_on_caso_contacto ON public.sivel2_sjr_casosjr USING btree (caso_id, contacto_id);


--
-- Name: indice_sivel2_sjr_casosjr_on_oficina_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_casosjr_on_oficina_id ON public.sivel2_sjr_casosjr USING btree (oficina_id);


--
-- Name: indice_sivel2_sjr_desplazamiento_on_fechaexpulsion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_desplazamiento_on_fechaexpulsion ON public.sivel2_sjr_desplazamiento USING btree (fechaexpulsion);


--
-- Name: indice_sivel2_sjr_desplazamiento_on_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_desplazamiento_on_id_caso ON public.sivel2_sjr_desplazamiento USING btree (caso_id);


--
-- Name: indice_sivel2_sjr_respuesta_on_fechaatencion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX indice_sivel2_sjr_respuesta_on_fechaatencion ON public.sivel2_sjr_respuesta USING btree (fechaatencion);


--
-- Name: msip_busca_mundep; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_busca_mundep ON public.msip_mundep USING gin (mundep);


--
-- Name: msip_centropobaldo_id_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_centropobaldo_id_municipio ON public.msip_centropoblado USING btree (municipio_id);


--
-- Name: msip_departamento_id_pais; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_departamento_id_pais ON public.msip_departamento USING btree (pais_id);


--
-- Name: msip_municipio_id_departamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_municipio_id_departamento ON public.msip_municipio USING btree (departamento_id);


--
-- Name: msip_nombre_ubicacionpre_b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_nombre_ubicacionpre_b ON public.msip_ubicacionpre USING gin (to_tsvector('spanish'::regconfig, public.f_unaccent((nombre)::text)));


--
-- Name: msip_persona_anionac; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_anionac ON public.msip_persona USING btree (anionac);


--
-- Name: msip_persona_anionac_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_anionac_ind ON public.msip_persona USING btree (anionac);


--
-- Name: msip_persona_buscable_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_buscable_ind ON public.msip_persona USING gin (buscable);


--
-- Name: msip_persona_numerodocumento_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_numerodocumento_idx ON public.msip_persona USING btree (numerodocumento);


--
-- Name: msip_persona_sexo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_sexo ON public.msip_persona USING btree (sexo);


--
-- Name: msip_persona_sexo_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_sexo_ind ON public.msip_persona USING btree (sexo);


--
-- Name: msip_persona_tdocumento_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_persona_tdocumento_id_idx ON public.msip_persona USING btree (tdocumento_id);


--
-- Name: msip_ubicacionpre_centropoblado_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_centropoblado_id_idx ON public.msip_ubicacionpre USING btree (centropoblado_id);


--
-- Name: msip_ubicacionpre_departamento_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_departamento_id_idx ON public.msip_ubicacionpre USING btree (departamento_id);


--
-- Name: msip_ubicacionpre_departamento_id_municipio_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_departamento_id_municipio_id_idx ON public.msip_ubicacionpre USING btree (departamento_id, municipio_id);


--
-- Name: msip_ubicacionpre_municipio_id_centropoblado_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_municipio_id_centropoblado_id_idx ON public.msip_ubicacionpre USING btree (municipio_id, centropoblado_id);


--
-- Name: msip_ubicacionpre_municipio_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_municipio_id_idx ON public.msip_ubicacionpre USING btree (municipio_id);


--
-- Name: msip_ubicacionpre_municipio_id_vereda_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_municipio_id_vereda_id_idx ON public.msip_ubicacionpre USING btree (municipio_id, vereda_id);


--
-- Name: msip_ubicacionpre_pais_id_departamento_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_pais_id_departamento_id_idx ON public.msip_ubicacionpre USING btree (pais_id, departamento_id);


--
-- Name: msip_ubicacionpre_pais_id_departamento_id_municipio_id_centropo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_pais_id_departamento_id_municipio_id_centropo ON public.msip_ubicacionpre USING btree (pais_id, departamento_id, municipio_id, centropoblado_id);


--
-- Name: msip_ubicacionpre_pais_id_departamento_id_municipio_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_pais_id_departamento_id_municipio_id_idx ON public.msip_ubicacionpre USING btree (pais_id, departamento_id, municipio_id);


--
-- Name: msip_ubicacionpre_pais_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_pais_id_idx ON public.msip_ubicacionpre USING btree (pais_id);


--
-- Name: msip_ubicacionpre_tsitio_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_tsitio_id_idx ON public.msip_ubicacionpre USING btree (tsitio_id);


--
-- Name: msip_ubicacionpre_vereda_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX msip_ubicacionpre_vereda_id_idx ON public.msip_ubicacionpre USING btree (vereda_id);


--
-- Name: sivel2_gen_actividadoficio_nombre_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_actividadoficio_nombre_ind ON public.sivel2_gen_actividadoficio USING btree (nombre);


--
-- Name: sivel2_gen_caso_anio_mes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_caso_anio_mes ON public.sivel2_gen_caso USING btree (((((date_part('year'::text, (fecha)::timestamp without time zone))::text || '-'::text) || lpad((date_part('month'::text, (fecha)::timestamp without time zone))::text, 2, '0'::text))));


--
-- Name: sivel2_gen_obs_fildep_d_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_obs_fildep_d_idx ON public.sivel2_gen_observador_filtrodepartamento USING btree (departamento_id);


--
-- Name: sivel2_gen_obs_fildep_u_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_obs_fildep_u_idx ON public.sivel2_gen_observador_filtrodepartamento USING btree (usuario_id);


--
-- Name: sivel2_gen_victima_id_caso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_caso ON public.sivel2_gen_victima USING btree (caso_id);


--
-- Name: sivel2_gen_victima_id_caso_id_persona_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sivel2_gen_victima_id_caso_id_persona_idx ON public.sivel2_gen_victima USING btree (caso_id, persona_id);


--
-- Name: sivel2_gen_victima_id_caso_id_persona_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sivel2_gen_victima_id_caso_id_persona_idx1 ON public.sivel2_gen_victima USING btree (caso_id, persona_id);


--
-- Name: sivel2_gen_victima_id_caso_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_caso_idx ON public.sivel2_gen_victima USING btree (caso_id);


--
-- Name: sivel2_gen_victima_id_filiacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_filiacion ON public.sivel2_gen_victima USING btree (filiacion_id);


--
-- Name: sivel2_gen_victima_id_iglesia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_iglesia ON public.sivel2_gen_victima USING btree (iglesia_id);


--
-- Name: sivel2_gen_victima_id_organizacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_organizacion ON public.sivel2_gen_victima USING btree (organizacion_id);


--
-- Name: sivel2_gen_victima_id_persona; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_persona ON public.sivel2_gen_victima USING btree (persona_id);


--
-- Name: sivel2_gen_victima_id_persona_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_persona_idx ON public.sivel2_gen_victima USING btree (persona_id);


--
-- Name: sivel2_gen_victima_id_profesion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_profesion ON public.sivel2_gen_victima USING btree (profesion_id);


--
-- Name: sivel2_gen_victima_id_rangoedad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_rangoedad ON public.sivel2_gen_victima USING btree (rangoedad_id);


--
-- Name: sivel2_gen_victima_id_rangoedad_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_rangoedad_ind ON public.sivel2_gen_victima USING btree (rangoedad_id);


--
-- Name: sivel2_gen_victima_id_sectorsocial; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_sectorsocial ON public.sivel2_gen_victima USING btree (sectorsocial_id);


--
-- Name: sivel2_gen_victima_id_vinculoestado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_id_vinculoestado ON public.sivel2_gen_victima USING btree (vinculoestado_id);


--
-- Name: sivel2_gen_victima_orientacionsexual; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_gen_victima_orientacionsexual ON public.sivel2_gen_victima USING btree (orientacionsexual);


--
-- Name: sivel2_sjr_actividad_casosjr_actividad_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_actividad_casosjr_actividad_id_idx ON public.sivel2_sjr_actividad_casosjr USING btree (actividad_id);


--
-- Name: sivel2_sjr_actividad_casosjr_casosjr_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_actividad_casosjr_casosjr_id_idx ON public.sivel2_sjr_actividad_casosjr USING btree (casosjr_id);


--
-- Name: sivel2_sjr_casosjr_contacto_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sivel2_sjr_casosjr_contacto_idx ON public.sivel2_sjr_casosjr USING btree (contacto_id);


--
-- Name: sivel2_sjr_casosjr_fecharec_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_casosjr_fecharec_ind ON public.sivel2_sjr_casosjr USING btree (fecharec);


--
-- Name: sivel2_sjr_casosjr_id_caso_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sivel2_sjr_casosjr_id_caso_idx ON public.sivel2_sjr_casosjr USING btree (caso_id);


--
-- Name: sivel2_sjr_casosjr_mes_fecharec_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_casosjr_mes_fecharec_ind ON public.sivel2_sjr_casosjr USING btree (((((date_part('year'::text, (fecharec)::timestamp without time zone))::text || '-'::text) || lpad((date_part('month'::text, (fecharec)::timestamp without time zone))::text, 2, '0'::text))));


--
-- Name: sivel2_sjr_desplazamiento_expulsionubicacionpre_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_desplazamiento_expulsionubicacionpre_id_idx ON public.sivel2_sjr_desplazamiento USING btree (expulsionubicacionpre_id);


--
-- Name: sivel2_sjr_desplazamiento_fechaexpulsion_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_desplazamiento_fechaexpulsion_idx ON public.sivel2_sjr_desplazamiento USING btree (fechaexpulsion);


--
-- Name: sivel2_sjr_desplazamiento_fechallegada_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_desplazamiento_fechallegada_idx ON public.sivel2_sjr_desplazamiento USING btree (fechallegada);


--
-- Name: sivel2_sjr_desplazamiento_id_caso_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_desplazamiento_id_caso_idx ON public.sivel2_sjr_desplazamiento USING btree (caso_id);


--
-- Name: sivel2_sjr_desplazamiento_llegadaubicacionpre_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_desplazamiento_llegadaubicacionpre_id_idx ON public.sivel2_sjr_desplazamiento USING btree (llegadaubicacionpre_id);


--
-- Name: sivel2_sjr_migracion_caso_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_migracion_caso_id_idx ON public.sivel2_sjr_migracion USING btree (caso_id);


--
-- Name: sivel2_sjr_migracion_fechallegada_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_migracion_fechallegada_idx ON public.sivel2_sjr_migracion USING btree (fechallegada);


--
-- Name: sivel2_sjr_migracion_fechasalida_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_migracion_fechasalida_idx ON public.sivel2_sjr_migracion USING btree (fechasalida);


--
-- Name: sivel2_sjr_migracion_llegadaubicacionpre_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_migracion_llegadaubicacionpre_id_idx ON public.sivel2_sjr_migracion USING btree (llegadaubicacionpre_id);


--
-- Name: sivel2_sjr_migracion_salidaubicacionpre_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_migracion_salidaubicacionpre_id_idx ON public.sivel2_sjr_migracion USING btree (salidaubicacionpre_id);


--
-- Name: sivel2_sjr_respuesta_fechaatencion_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_respuesta_fechaatencion_idx ON public.sivel2_sjr_respuesta USING btree (fechaatencion);


--
-- Name: sivel2_sjr_respuesta_id_caso_fechaatencion_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sivel2_sjr_respuesta_id_caso_fechaatencion_idx ON public.sivel2_sjr_respuesta USING btree (caso_id, fechaatencion);


--
-- Name: sivel2_sjr_respuesta_id_caso_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_respuesta_id_caso_idx ON public.sivel2_sjr_respuesta USING btree (caso_id);


--
-- Name: sivel2_sjr_victimasjr_cabezafamilia_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_victimasjr_cabezafamilia_ind ON public.sivel2_sjr_victimasjr USING btree (cabezafamilia);


--
-- Name: sivel2_sjr_victimasjr_fechadesagregacion_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_victimasjr_fechadesagregacion_ind ON public.sivel2_sjr_victimasjr USING btree (fechadesagregacion);


--
-- Name: sivel2_sjr_victimasjr_id_actividadoficio_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_victimasjr_id_actividadoficio_ind ON public.sivel2_sjr_victimasjr USING btree (actividadoficio_id);


--
-- Name: sivel2_sjr_victimasjr_id_escolaridad_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_victimasjr_id_escolaridad_ind ON public.sivel2_sjr_victimasjr USING btree (escolaridad_id);


--
-- Name: sivel2_sjr_victimasjr_id_estadocivil_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_victimasjr_id_estadocivil_ind ON public.sivel2_sjr_victimasjr USING btree (estadocivil_id);


--
-- Name: sivel2_sjr_victimasjr_id_regimensalud_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sivel2_sjr_victimasjr_id_regimensalud_ind ON public.sivel2_sjr_victimasjr USING btree (regimensalud_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: usuario_nusuario; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX usuario_nusuario ON public.usuario USING btree (nusuario);


--
-- Name: cor1440_gen_actividad cor1440_gen_recalcular_tras_cambiar_actividad; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cor1440_gen_recalcular_tras_cambiar_actividad AFTER UPDATE ON public.cor1440_gen_actividad FOR EACH ROW EXECUTE FUNCTION public.cor1440_gen_actividad_cambiada();


--
-- Name: cor1440_gen_asistencia cor1440_gen_recalcular_tras_cambiar_asistencia; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cor1440_gen_recalcular_tras_cambiar_asistencia AFTER INSERT OR DELETE OR UPDATE ON public.cor1440_gen_asistencia FOR EACH ROW EXECUTE FUNCTION public.cor1440_gen_asistencia_cambiada_creada_eliminada();


--
-- Name: msip_persona cor1440_gen_recalcular_tras_cambiar_persona; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cor1440_gen_recalcular_tras_cambiar_persona AFTER UPDATE ON public.msip_persona FOR EACH ROW EXECUTE FUNCTION public.cor1440_gen_persona_cambiada();


--
-- Name: docidsecundario docidsecundario_actualiza_buscable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER docidsecundario_actualiza_buscable AFTER INSERT OR UPDATE ON public.docidsecundario FOR EACH ROW EXECUTE FUNCTION public.docidsecundario_actualiza_buscable_trigger();


--
-- Name: docidsecundario docidsecundario_elimina_buscable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER docidsecundario_elimina_buscable AFTER DELETE ON public.docidsecundario FOR EACH ROW EXECUTE FUNCTION public.docidsecundario_elimina_buscable_trigger();


--
-- Name: msip_persona_trelacion msip_eliminar_familiar; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_eliminar_familiar AFTER DELETE ON public.msip_persona_trelacion FOR EACH ROW EXECUTE FUNCTION public.msip_eliminar_familiar_inverso();


--
-- Name: msip_persona_trelacion msip_insertar_familiar; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_insertar_familiar AFTER INSERT OR UPDATE ON public.msip_persona_trelacion FOR EACH ROW EXECUTE FUNCTION public.msip_agregar_o_remplazar_familiar_inverso();


--
-- Name: msip_persona msip_persona_actualiza_buscable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER msip_persona_actualiza_buscable BEFORE INSERT OR UPDATE ON public.msip_persona FOR EACH ROW EXECUTE FUNCTION public.msip_persona_buscable_trigger();


--
-- Name: cor1440_gen_actividad actividad_regionsjr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad
    ADD CONSTRAINT actividad_regionsjr_id_fkey FOREIGN KEY (oficina_id) REFERENCES public.msip_oficina(id);


--
-- Name: sivel2_gen_acto acto_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_acto acto_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_categoria_fkey FOREIGN KEY (categoria_id) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_acto acto_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_persona_fkey FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: sivel2_gen_acto acto_id_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_id_presponsable_fkey FOREIGN KEY (presponsable_id) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_acto acto_victima_lf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_acto
    ADD CONSTRAINT acto_victima_lf FOREIGN KEY (caso_id, persona_id) REFERENCES public.sivel2_gen_victima(caso_id, persona_id);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_categoria_fkey FOREIGN KEY (categoria_id) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_grupoper_fkey FOREIGN KEY (grupoper_id) REFERENCES public.msip_grupoper(id);


--
-- Name: sivel2_gen_actocolectivo actocolectivo_id_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_presponsable_fkey FOREIGN KEY (presponsable_id) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_sjr_actosjr actosjr_desplazamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actosjr
    ADD CONSTRAINT actosjr_desplazamiento_id_fkey FOREIGN KEY (desplazamiento_id) REFERENCES public.sivel2_sjr_desplazamiento(id);


--
-- Name: sivel2_sjr_actosjr actosjr_id_acto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actosjr
    ADD CONSTRAINT actosjr_id_acto_fkey FOREIGN KEY (acto_id) REFERENCES public.sivel2_gen_acto(id);


--
-- Name: sivel2_gen_anexo_caso anexo_fuenteprensa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT anexo_fuenteprensa_id_fkey FOREIGN KEY (fuenteprensa_id) REFERENCES public.msip_fuenteprensa(id);


--
-- Name: sivel2_gen_anexo_caso anexo_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT anexo_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_anexo_caso anexo_id_fotra_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT anexo_id_fotra_fkey FOREIGN KEY (fotra_id) REFERENCES public.sivel2_gen_fotra(id);


--
-- Name: sivel2_gen_antecedente_caso antecedente_caso_id_antecedente_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_id_antecedente_fkey1 FOREIGN KEY (antecedente_id) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_caso antecedente_caso_id_caso_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_id_caso_fkey1 FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_antecedente_combatiente antecedente_combatiente_id_antecedente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_combatiente
    ADD CONSTRAINT antecedente_combatiente_id_antecedente_fkey FOREIGN KEY (antecedente_id) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_combatiente antecedente_combatiente_id_combatiente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_combatiente
    ADD CONSTRAINT antecedente_combatiente_id_combatiente_fkey FOREIGN KEY (combatiente_id) REFERENCES public.sivel2_gen_combatiente(id);


--
-- Name: sivel2_gen_antecedente_victima antecedente_victima_id_antecedente_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_id_antecedente_fkey1 FOREIGN KEY (antecedente_id) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_victima antecedente_victima_id_victima_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_id_victima_fkey1 FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: sivel2_gen_antecedente_victimacolectiva antecedente_victimacolectiva_id_antecedente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victimacolectiva
    ADD CONSTRAINT antecedente_victimacolectiva_id_antecedente_fkey FOREIGN KEY (antecedente_id) REFERENCES public.sivel2_gen_antecedente(id);


--
-- Name: sivel2_gen_antecedente_victimacolectiva antecedente_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_antecedente_victimacolectiva
    ADD CONSTRAINT antecedente_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_sjr_ayudaestado_respuesta ayudaestado_respuesta_id_ayudaestado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudaestado_respuesta
    ADD CONSTRAINT ayudaestado_respuesta_id_ayudaestado_fkey FOREIGN KEY (ayudaestado_id) REFERENCES public.sivel2_sjr_ayudaestado(id);


--
-- Name: sivel2_sjr_ayudaestado_respuesta ayudaestado_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudaestado_respuesta
    ADD CONSTRAINT ayudaestado_respuesta_id_respuesta_fkey FOREIGN KEY (respuesta_id) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_sjr_ayudasjr_respuesta ayudasjr_respuesta_id_ayudasjr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr_respuesta
    ADD CONSTRAINT ayudasjr_respuesta_id_ayudasjr_fkey FOREIGN KEY (ayudasjr_id) REFERENCES public.sivel2_sjr_ayudasjr(id);


--
-- Name: sivel2_sjr_ayudasjr_respuesta ayudasjr_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr_respuesta
    ADD CONSTRAINT ayudasjr_respuesta_id_respuesta_fkey FOREIGN KEY (respuesta_id) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_gen_caso_categoria_presponsable caso_categoria_presponsable_id_caso_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_caso_presponsable_fkey FOREIGN KEY (caso_presponsable_id) REFERENCES public.sivel2_gen_caso_presponsable(id);


--
-- Name: sivel2_gen_caso_categoria_presponsable caso_categoria_presponsable_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_categoria_fkey FOREIGN KEY (categoria_id) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_caso_contexto caso_contexto_id_caso_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_contexto
    ADD CONSTRAINT caso_contexto_id_caso_fkey1 FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_contexto caso_contexto_id_contexto_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_contexto
    ADD CONSTRAINT caso_contexto_id_contexto_fkey1 FOREIGN KEY (contexto_id) REFERENCES public.sivel2_gen_contexto(id);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_id_etiqueta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_etiqueta_fkey FOREIGN KEY (etiqueta_id) REFERENCES public.msip_etiqueta(id);


--
-- Name: sivel2_gen_caso_etiqueta caso_etiqueta_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_usuario_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_gen_caso_fotra caso_fotra_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT caso_fotra_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_fotra caso_fotra_id_fotra_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT caso_fotra_id_fotra_fkey FOREIGN KEY (fotra_id) REFERENCES public.sivel2_gen_fotra(id);


--
-- Name: sivel2_gen_caso_frontera caso_frontera_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_frontera
    ADD CONSTRAINT caso_frontera_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_frontera caso_frontera_id_frontera_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_frontera
    ADD CONSTRAINT caso_frontera_id_frontera_fkey FOREIGN KEY (frontera_id) REFERENCES public.sivel2_gen_frontera(id);


--
-- Name: sivel2_gen_caso_usuario caso_funcionario_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_usuario
    ADD CONSTRAINT caso_funcionario_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso caso_id_intervalo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso
    ADD CONSTRAINT caso_id_intervalo_fkey FOREIGN KEY (intervalo_id) REFERENCES public.sivel2_gen_intervalo(id);


--
-- Name: sivel2_gen_caso_presponsable caso_presponsable_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_presponsable caso_presponsable_id_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_id_presponsable_fkey FOREIGN KEY (presponsable_id) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_caso_region caso_region_id_caso_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_region
    ADD CONSTRAINT caso_region_id_caso_fkey1 FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_region caso_region_id_region_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_region
    ADD CONSTRAINT caso_region_id_region_fkey1 FOREIGN KEY (region_id) REFERENCES public.sivel2_gen_region(id);


--
-- Name: sivel2_gen_caso_respuestafor caso_respuestafor_caso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_respuestafor
    ADD CONSTRAINT caso_respuestafor_caso_id_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_caso_respuestafor caso_respuestafor_respuestafor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_respuestafor
    ADD CONSTRAINT caso_respuestafor_respuestafor_id_fkey FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sivel2_gen_caso_usuario caso_usuario_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_usuario
    ADD CONSTRAINT caso_usuario_id_usuario_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_casosjr casosjr_asesor_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_asesor_id_usuario_fkey FOREIGN KEY (asesor) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_casosjr casosjr_categoriaref_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_categoriaref_fkey FOREIGN KEY (categoriaref) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_sjr_casosjr casosjr_comosupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_comosupo_id_fkey FOREIGN KEY (comosupo_id) REFERENCES public.sivel2_sjr_comosupo(id);


--
-- Name: sivel2_sjr_casosjr casosjr_contacto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_contacto_fkey FOREIGN KEY (contacto_id) REFERENCES public.msip_persona(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_llegada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_llegada_fkey FOREIGN KEY (llegada_id) REFERENCES public.msip_ubicacion(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_regionsjr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_regionsjr_fkey FOREIGN KEY (oficina_id) REFERENCES public.msip_oficina(id);


--
-- Name: sivel2_sjr_casosjr casosjr_id_salida_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT casosjr_id_salida_fkey FOREIGN KEY (salida_id) REFERENCES public.msip_ubicacion(id);


--
-- Name: sivel2_gen_categoria categoria_contadaen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT categoria_contadaen_fkey FOREIGN KEY (contadaen) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_categoria categoria_id_pconsolidado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT categoria_id_pconsolidado_fkey FOREIGN KEY (pconsolidado_id) REFERENCES public.sivel2_gen_pconsolidado(id);


--
-- Name: sivel2_gen_contextovictima_victima contextovictima_victima_contextovictima_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima_victima
    ADD CONSTRAINT contextovictima_victima_contextovictima_id_fkey FOREIGN KEY (contextovictima_id) REFERENCES public.sivel2_gen_contextovictima(id);


--
-- Name: sivel2_gen_contextovictima_victima contextovictima_victima_victima_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_contextovictima_victima
    ADD CONSTRAINT contextovictima_victima_victima_id_fkey FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: cor1440_gen_actividad_actividadtipo cor1440_gen_actividad_actividadtipo_actividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_actividadtipo
    ADD CONSTRAINT cor1440_gen_actividad_actividadtipo_actividad_id_fkey FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_actividad_actividadtipo cor1440_gen_actividad_actividadtipo_actividadtipo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_actividadtipo
    ADD CONSTRAINT cor1440_gen_actividad_actividadtipo_actividadtipo_id_fkey FOREIGN KEY (actividadtipo_id) REFERENCES public.cor1440_gen_actividadtipo(id);


--
-- Name: msip_departamento departamento_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT departamento_id_pais_fkey FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: sivel2_sjr_derecho_respuesta derecho_respuesta_id_derecho_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_derecho_respuesta
    ADD CONSTRAINT derecho_respuesta_id_derecho_fkey FOREIGN KEY (derecho_id) REFERENCES public.sivel2_sjr_derecho(id);


--
-- Name: sivel2_sjr_derecho_respuesta derecho_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_derecho_respuesta
    ADD CONSTRAINT derecho_respuesta_id_respuesta_fkey FOREIGN KEY (respuesta_id) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_acreditacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_acreditacion_fkey FOREIGN KEY (acreditacion_id) REFERENCES public.sivel2_sjr_acreditacion(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_clasifdesp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_clasifdesp_fkey FOREIGN KEY (clasifdesp_id) REFERENCES public.sivel2_sjr_clasifdesp(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_declaroante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_declaroante_fkey FOREIGN KEY (declaroante_id) REFERENCES public.sivel2_sjr_declaroante(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_inclusion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_inclusion_fkey FOREIGN KEY (inclusion_id) REFERENCES public.sivel2_sjr_inclusion(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_modalidadtierra_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_modalidadtierra_fkey FOREIGN KEY (modalidadtierra_id) REFERENCES public.sivel2_sjr_modalidadtierra(id);


--
-- Name: sivel2_sjr_desplazamiento desplazamiento_id_tipodesp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT desplazamiento_id_tipodesp_fkey FOREIGN KEY (tipodesp_id) REFERENCES public.sivel2_sjr_tipodesp(id);


--
-- Name: sivel2_gen_etnia_victimacolectiva etnia_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia_victimacolectiva
    ADD CONSTRAINT etnia_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_gen_filiacion_victimacolectiva filiacion_victimacolectiva_id_filiacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion_victimacolectiva
    ADD CONSTRAINT filiacion_victimacolectiva_id_filiacion_fkey FOREIGN KEY (filiacion_id) REFERENCES public.sivel2_gen_filiacion(id);


--
-- Name: sivel2_gen_filiacion_victimacolectiva filiacion_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_filiacion_victimacolectiva
    ADD CONSTRAINT filiacion_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_sjr_desplazamiento fk_rails_015db0d437; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT fk_rails_015db0d437 FOREIGN KEY (declaracionruv_id) REFERENCES public.declaracionruv(id);


--
-- Name: docidsecundario fk_rails_017bea13f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.docidsecundario
    ADD CONSTRAINT fk_rails_017bea13f4 FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: territorial fk_rails_02965341df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.territorial
    ADD CONSTRAINT fk_rails_02965341df FOREIGN KEY (centropoblado_id) REFERENCES public.msip_centropoblado(id);


--
-- Name: cor1440_gen_anexo_efecto fk_rails_037289a77c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_efecto
    ADD CONSTRAINT fk_rails_037289a77c FOREIGN KEY (efecto_id) REFERENCES public.cor1440_gen_efecto(id);


--
-- Name: sivel2_sjr_causaagresion_migracion fk_rails_061c047c82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_causaagresion_migracion
    ADD CONSTRAINT fk_rails_061c047c82 FOREIGN KEY (migracion_id) REFERENCES public.sivel2_sjr_migracion(id);


--
-- Name: cor1440_gen_mindicadorpf fk_rails_06564b910d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_mindicadorpf
    ADD CONSTRAINT fk_rails_06564b910d FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_resultadopf fk_rails_06ba24bd54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_resultadopf
    ADD CONSTRAINT fk_rails_06ba24bd54 FOREIGN KEY (objetivopf_id) REFERENCES public.cor1440_gen_objetivopf(id);


--
-- Name: sivel2_gen_caso_solicitud fk_rails_06deb84185; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_solicitud
    ADD CONSTRAINT fk_rails_06deb84185 FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: msip_municipio fk_rails_089870a38d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT fk_rails_089870a38d FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: cor1440_gen_actividad_actividadpf fk_rails_08b9aa072b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_actividadpf
    ADD CONSTRAINT fk_rails_08b9aa072b FOREIGN KEY (actividadpf_id) REFERENCES public.cor1440_gen_actividadpf(id);


--
-- Name: cor1440_gen_actividad fk_rails_0a032e5445; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad
    ADD CONSTRAINT fk_rails_0a032e5445 FOREIGN KEY (ubicacionpre_id) REFERENCES public.msip_ubicacionpre(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_0b10834ba7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_0b10834ba7 FOREIGN KEY (resultadopf_id) REFERENCES public.cor1440_gen_resultadopf(id);


--
-- Name: msip_etiqueta_persona fk_rails_0b3fc3ed9d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_persona
    ADD CONSTRAINT fk_rails_0b3fc3ed9d FOREIGN KEY (etiqueta_id) REFERENCES public.msip_etiqueta(id);


--
-- Name: cor1440_gen_actividad_respuestafor fk_rails_0b4fb6fceb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_respuestafor
    ADD CONSTRAINT fk_rails_0b4fb6fceb FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_efecto_respuestafor fk_rails_0ba7ab4660; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto_respuestafor
    ADD CONSTRAINT fk_rails_0ba7ab4660 FOREIGN KEY (efecto_id) REFERENCES public.cor1440_gen_efecto(id);


--
-- Name: cor1440_gen_financiador_proyectofinanciero fk_rails_0cd09d688c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_financiador_proyectofinanciero
    ADD CONSTRAINT fk_rails_0cd09d688c FOREIGN KEY (financiador_id) REFERENCES public.cor1440_gen_financiador(id);


--
-- Name: detallefinanciero fk_rails_0d386dedcf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero
    ADD CONSTRAINT fk_rails_0d386dedcf FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_mindicadorpf fk_rails_0fbac6136b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_mindicadorpf
    ADD CONSTRAINT fk_rails_0fbac6136b FOREIGN KEY (indicadorpf_id) REFERENCES public.cor1440_gen_indicadorpf(id);


--
-- Name: sivel2_gen_sectorsocialsec_victima fk_rails_0feb0e70eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocialsec_victima
    ADD CONSTRAINT fk_rails_0feb0e70eb FOREIGN KEY (sectorsocial_id) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: sivel2_sjr_progestado_derecho fk_rails_1066716dca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado_derecho
    ADD CONSTRAINT fk_rails_1066716dca FOREIGN KEY (progestado_id) REFERENCES public.sivel2_sjr_progestado(id);


--
-- Name: msip_etiqueta_municipio fk_rails_10d88626c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_municipio
    ADD CONSTRAINT fk_rails_10d88626c3 FOREIGN KEY (etiqueta_id) REFERENCES public.msip_etiqueta(id);


--
-- Name: msip_etiqueta_persona fk_rails_117b029532; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_persona
    ADD CONSTRAINT fk_rails_117b029532 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_gen_caso_presponsable fk_rails_118837ae4c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT fk_rails_118837ae4c FOREIGN KEY (presponsable_id) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: cor1440_gen_caracterizacionpersona fk_rails_119f5dffb4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpersona
    ADD CONSTRAINT fk_rails_119f5dffb4 FOREIGN KEY (ulteditor_id) REFERENCES public.usuario(id);


--
-- Name: cor1440_gen_efecto_orgsocial fk_rails_12f7139ec8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto_orgsocial
    ADD CONSTRAINT fk_rails_12f7139ec8 FOREIGN KEY (orgsocial_id) REFERENCES public.msip_orgsocial(id);


--
-- Name: cor1440_gen_actividad_rangoedadac fk_rails_1366d14fb8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_rangoedadac
    ADD CONSTRAINT fk_rails_1366d14fb8 FOREIGN KEY (rangoedadac_id) REFERENCES public.cor1440_gen_rangoedadac(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_13f8d66312; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_13f8d66312 FOREIGN KEY (planencuesta_id) REFERENCES public.mr519_gen_planencuesta(id);


--
-- Name: sivel2_sjr_difmigracion_migracion fk_rails_1554d38441; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_difmigracion_migracion
    ADD CONSTRAINT fk_rails_1554d38441 FOREIGN KEY (difmigracion_id) REFERENCES public.dificultadmigracion(id);


--
-- Name: sivel2_gen_profesion_victima fk_rails_16a578e865; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victima
    ADD CONSTRAINT fk_rails_16a578e865 FOREIGN KEY (profesion_id) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: msip_orgsocial fk_rails_16d31c62f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT fk_rails_16d31c62f4 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_16d8cc3b46; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_16d8cc3b46 FOREIGN KEY (heredade_id) REFERENCES public.cor1440_gen_actividadpf(id);


--
-- Name: mr519_gen_encuestausuario fk_rails_1b24d10e82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT fk_rails_1b24d10e82 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_gen_profesion_victima fk_rails_1b333ee743; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victima
    ADD CONSTRAINT fk_rails_1b333ee743 FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: heb412_gen_formulario_plantillahcr fk_rails_1bdf79898c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr
    ADD CONSTRAINT fk_rails_1bdf79898c FOREIGN KEY (plantillahcr_id) REFERENCES public.heb412_gen_plantillahcr(id);


--
-- Name: cor1440_gen_efecto fk_rails_1d0050a070; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto
    ADD CONSTRAINT fk_rails_1d0050a070 FOREIGN KEY (registradopor_id) REFERENCES public.usuario(id);


--
-- Name: cor1440_gen_caracterizacionpf fk_rails_1d1caee38f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpf
    ADD CONSTRAINT fk_rails_1d1caee38f FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: msip_oficina fk_rails_1e27fc6829; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_oficina
    ADD CONSTRAINT fk_rails_1e27fc6829 FOREIGN KEY (centropoblado_id) REFERENCES public.msip_centropoblado(id);


--
-- Name: heb412_gen_campohc fk_rails_1e5f26c999; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campohc
    ADD CONSTRAINT fk_rails_1e5f26c999 FOREIGN KEY (doc_id) REFERENCES public.heb412_gen_doc(id);


--
-- Name: sivel2_gen_anexo_victima fk_rails_1ee17419cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_victima
    ADD CONSTRAINT fk_rails_1ee17419cc FOREIGN KEY (anexo_id) REFERENCES public.msip_anexo(id);


--
-- Name: cor1440_gen_caracterizacionpersona fk_rails_240640f30e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpersona
    ADD CONSTRAINT fk_rails_240640f30e FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: indicadorgifmm fk_rails_25ad72ab6f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.indicadorgifmm
    ADD CONSTRAINT fk_rails_25ad72ab6f FOREIGN KEY (sectorgifmm_id) REFERENCES public.sectorgifmm(id);


--
-- Name: cor1440_gen_anexo_proyectofinanciero fk_rails_26e56f96f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_proyectofinanciero
    ADD CONSTRAINT fk_rails_26e56f96f9 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sivel2_sjr_causaagrpais_migracion fk_rails_29273b3f7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_causaagrpais_migracion
    ADD CONSTRAINT fk_rails_29273b3f7a FOREIGN KEY (migracion_id) REFERENCES public.sivel2_sjr_migracion(id);


--
-- Name: cor1440_gen_informe fk_rails_294895347e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT fk_rails_294895347e FOREIGN KEY (filtroproyecto) REFERENCES public.cor1440_gen_proyecto(id);


--
-- Name: sivel2_sjr_casosjr fk_rails_2a8ac48225; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT fk_rails_2a8ac48225 FOREIGN KEY (llegadam_id) REFERENCES public.msip_ubicacion(id);


--
-- Name: cor1440_gen_informe fk_rails_2bd685d2b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT fk_rails_2bd685d2b3 FOREIGN KEY (filtroresponsable) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_casosjr fk_rails_2be82bc047; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT fk_rails_2be82bc047 FOREIGN KEY (proteccion_id) REFERENCES public.sivel2_sjr_proteccion(id);


--
-- Name: mr519_gen_encuestausuario fk_rails_2cb09d778a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestausuario
    ADD CONSTRAINT fk_rails_2cb09d778a FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: msip_bitacora fk_rails_2db961766c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_bitacora
    ADD CONSTRAINT fk_rails_2db961766c FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: heb412_gen_doc fk_rails_2dd6d3dac3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_doc
    ADD CONSTRAINT fk_rails_2dd6d3dac3 FOREIGN KEY (dirpapa) REFERENCES public.heb412_gen_doc(id);


--
-- Name: msip_ubicacionpre fk_rails_2e86701dfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_2e86701dfb FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: cor1440_gen_actividad_rangoedadac fk_rails_2f8fe7fdca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_rangoedadac
    ADD CONSTRAINT fk_rails_2f8fe7fdca FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: sivel2_gen_otraorga_victima fk_rails_3029d2736a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_otraorga_victima
    ADD CONSTRAINT fk_rails_3029d2736a FOREIGN KEY (organizacion_id) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: actonino fk_rails_338c234631; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actonino
    ADD CONSTRAINT fk_rails_338c234631 FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_anexo_victima fk_rails_33ed22a32a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_victima
    ADD CONSTRAINT fk_rails_33ed22a32a FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: sivel2_sjr_oficina_proyectofinanciero fk_rails_3479b42b5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_oficina_proyectofinanciero
    ADD CONSTRAINT fk_rails_3479b42b5c FOREIGN KEY (oficina_id) REFERENCES public.msip_oficina(id);


--
-- Name: sivel2_gen_anexo_victima fk_rails_34cb4b0e2b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_victima
    ADD CONSTRAINT fk_rails_34cb4b0e2b FOREIGN KEY (tipoanexo_id) REFERENCES public.msip_tipoanexo(id);


--
-- Name: sivel2_sjr_categoria_desplazamiento fk_rails_357e09aa50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_categoria_desplazamiento
    ADD CONSTRAINT fk_rails_357e09aa50 FOREIGN KEY (desplazamiento_id) REFERENCES public.sivel2_sjr_desplazamiento(id);


--
-- Name: sivel2_sjr_accionjuridica_respuesta fk_rails_362600bcf3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_accionjuridica_respuesta
    ADD CONSTRAINT fk_rails_362600bcf3 FOREIGN KEY (accionjuridica_id) REFERENCES public.sivel2_sjr_accionjuridica(id);


--
-- Name: cor1440_gen_proyectofinanciero fk_rails_3792591d9e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero
    ADD CONSTRAINT fk_rails_3792591d9e FOREIGN KEY (sectorapc_id) REFERENCES public.cor1440_gen_sectorapc(id);


--
-- Name: sivel2_sjr_aspsicosocial_respuesta fk_rails_389ca79c21; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aspsicosocial_respuesta
    ADD CONSTRAINT fk_rails_389ca79c21 FOREIGN KEY (respuesta_id) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf fk_rails_390cd96f7c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti_pmindicadorpf
    ADD CONSTRAINT fk_rails_390cd96f7c FOREIGN KEY (pmindicadorpf_id) REFERENCES public.cor1440_gen_pmindicadorpf(id);


--
-- Name: sivel2_sjr_migracion fk_rails_393930af08; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_393930af08 FOREIGN KEY (statusmigratorio_id) REFERENCES public.sivel2_sjr_statusmigratorio(id);


--
-- Name: cor1440_gen_actividad_proyecto fk_rails_395faa0882; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyecto
    ADD CONSTRAINT fk_rails_395faa0882 FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: msip_ubicacionpre fk_rails_3b59c12090; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_3b59c12090 FOREIGN KEY (centropoblado_id) REFERENCES public.msip_centropoblado(id);


--
-- Name: sivel2_sjr_victimasjr fk_rails_4005fe5a7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT fk_rails_4005fe5a7e FOREIGN KEY (discapacidad_id) REFERENCES public.discapacidad(id);


--
-- Name: sivel2_sjr_migracion fk_rails_40371f9525; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_40371f9525 FOREIGN KEY (proteccion_id) REFERENCES public.sivel2_sjr_proteccion(id);


--
-- Name: cor1440_gen_informe fk_rails_40cb623d50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT fk_rails_40cb623d50 FOREIGN KEY (filtroproyectofinanciero) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sivel2_gen_caso_solicitud fk_rails_435e539f61; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_solicitud
    ADD CONSTRAINT fk_rails_435e539f61 FOREIGN KEY (solicitud_id) REFERENCES public.msip_solicitud(id);


--
-- Name: cor1440_gen_actividad fk_rails_4426fc905e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad
    ADD CONSTRAINT fk_rails_4426fc905e FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_actividad_casosjr fk_rails_4499c9b012; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actividad_casosjr
    ADD CONSTRAINT fk_rails_4499c9b012 FOREIGN KEY (casosjr_id) REFERENCES public.sivel2_sjr_casosjr(caso_id);


--
-- Name: cor1440_gen_informeauditoria fk_rails_44cf03d3e2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informeauditoria
    ADD CONSTRAINT fk_rails_44cf03d3e2 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: msip_orgsocial_persona fk_rails_4672f6cbcd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona
    ADD CONSTRAINT fk_rails_4672f6cbcd FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: cor1440_gen_actividad_anexo fk_rails_49ec1ae361; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_anexo
    ADD CONSTRAINT fk_rails_49ec1ae361 FOREIGN KEY (anexo_id) REFERENCES public.msip_anexo(id);


--
-- Name: cor1440_gen_indicadorpf fk_rails_4a0bd96143; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf
    ADD CONSTRAINT fk_rails_4a0bd96143 FOREIGN KEY (objetivopf_id) REFERENCES public.cor1440_gen_objetivopf(id);


--
-- Name: msip_oficina fk_rails_4ddab7b9ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_oficina
    ADD CONSTRAINT fk_rails_4ddab7b9ca FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: cor1440_gen_efecto fk_rails_4ebe8f74fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto
    ADD CONSTRAINT fk_rails_4ebe8f74fc FOREIGN KEY (indicadorpf_id) REFERENCES public.cor1440_gen_indicadorpf(id);


--
-- Name: sivel2_gen_etnia_victimacolectiva fk_rails_4fafec807e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_etnia_victimacolectiva
    ADD CONSTRAINT fk_rails_4fafec807e FOREIGN KEY (etnia_id) REFERENCES public.msip_etnia(id);


--
-- Name: cor1440_gen_caracterizacionpf fk_rails_4fcf0ffb4f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpf
    ADD CONSTRAINT fk_rails_4fcf0ffb4f FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sivel2_sjr_progestado_derecho fk_rails_5167158166; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado_derecho
    ADD CONSTRAINT fk_rails_5167158166 FOREIGN KEY (derecho_id) REFERENCES public.sivel2_sjr_derecho(id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero fk_rails_524486e06b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyectofinanciero
    ADD CONSTRAINT fk_rails_524486e06b FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: docidsecundario fk_rails_53955c3cba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.docidsecundario
    ADD CONSTRAINT fk_rails_53955c3cba FOREIGN KEY (tdocumento_id) REFERENCES public.msip_tdocumento(id);


--
-- Name: msip_orgsocial fk_rails_548bef9dcf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT fk_rails_548bef9dcf FOREIGN KEY (lineaorgsocial_id) REFERENCES public.msip_lineaorgsocial(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_54b3e0ed5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_54b3e0ed5c FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: msip_ubicacionpre fk_rails_558c98f353; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_558c98f353 FOREIGN KEY (vereda_id) REFERENCES public.msip_vereda(id);


--
-- Name: msip_etiqueta_municipio fk_rails_5672729520; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_municipio
    ADD CONSTRAINT fk_rails_5672729520 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: cor1440_gen_objetivopf fk_rails_57b4fd8780; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_objetivopf
    ADD CONSTRAINT fk_rails_57b4fd8780 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_formulario_mindicadorpf fk_rails_590a6d182f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_formulario_mindicadorpf
    ADD CONSTRAINT fk_rails_590a6d182f FOREIGN KEY (mindicadorpf_id) REFERENCES public.cor1440_gen_mindicadorpf(id);


--
-- Name: sivel2_sjr_migracion fk_rails_5a00c018f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_5a00c018f2 FOREIGN KEY (migracontactopre_id) REFERENCES public.migracontactopre(id);


--
-- Name: sivel2_gen_caso_presponsable fk_rails_5a8abbdd31; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_presponsable
    ADD CONSTRAINT fk_rails_5a8abbdd31 FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: msip_orgsocial fk_rails_5b21e3a2af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT fk_rails_5b21e3a2af FOREIGN KEY (grupoper_id) REFERENCES public.msip_grupoper(id);


--
-- Name: sivel2_sjr_agreenpais_migracion fk_rails_5ca3db2b82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_agreenpais_migracion
    ADD CONSTRAINT fk_rails_5ca3db2b82 FOREIGN KEY (migracion_id) REFERENCES public.sivel2_sjr_migracion(id);


--
-- Name: msip_etiqueta_persona fk_rails_5e6e6f10da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_etiqueta_persona
    ADD CONSTRAINT fk_rails_5e6e6f10da FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: sivel2_sjr_migracion fk_rails_5eaabddcc1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_5eaabddcc1 FOREIGN KEY (destinoubicacionpre_id) REFERENCES public.msip_ubicacionpre(id);


--
-- Name: detallefinanciero fk_rails_61118f6437; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero
    ADD CONSTRAINT fk_rails_61118f6437 FOREIGN KEY (mecanismodeentrega_id) REFERENCES public.mecanismodeentrega(id);


--
-- Name: sivel2_sjr_agreenpais_migracion fk_rails_6218990f83; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_agreenpais_migracion
    ADD CONSTRAINT fk_rails_6218990f83 FOREIGN KEY (agreenpais_id) REFERENCES public.agresionmigracion(id);


--
-- Name: msip_solicitud_usuarionotificar fk_rails_6296c40917; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud_usuarionotificar
    ADD CONSTRAINT fk_rails_6296c40917 FOREIGN KEY (solicitud_id) REFERENCES public.msip_solicitud(id);


--
-- Name: cor1440_gen_informenarrativo fk_rails_629d2a2cb8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informenarrativo
    ADD CONSTRAINT fk_rails_629d2a2cb8 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_plantillahcm_proyectofinanciero fk_rails_62c9243a43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_plantillahcm_proyectofinanciero
    ADD CONSTRAINT fk_rails_62c9243a43 FOREIGN KEY (plantillahcm_id) REFERENCES public.heb412_gen_plantillahcm(id);


--
-- Name: sivel2_sjr_migracion fk_rails_634c5f2020; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_634c5f2020 FOREIGN KEY (llegadaubicacionpre_id) REFERENCES public.msip_ubicacionpre(id);


--
-- Name: sivel2_gen_combatiente fk_rails_6485d06d37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_6485d06d37 FOREIGN KEY (vinculoestado_id) REFERENCES public.sivel2_gen_vinculoestado(id);


--
-- Name: mr519_gen_opcioncs fk_rails_656b4a3ca7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_opcioncs
    ADD CONSTRAINT fk_rails_656b4a3ca7 FOREIGN KEY (campo_id) REFERENCES public.mr519_gen_campo(id);


--
-- Name: sivel2_sjr_oficina_proyectofinanciero fk_rails_669494cbb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_oficina_proyectofinanciero
    ADD CONSTRAINT fk_rails_669494cbb1 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_datointermedioti fk_rails_669ada0c54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti
    ADD CONSTRAINT fk_rails_669ada0c54 FOREIGN KEY (mindicadorpf_id) REFERENCES public.cor1440_gen_mindicadorpf(id);


--
-- Name: heb412_gen_formulario_plantillahcr fk_rails_696d27d6f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcr
    ADD CONSTRAINT fk_rails_696d27d6f5 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: cor1440_gen_caracterizacionpersona fk_rails_6a82dffb63; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_caracterizacionpersona
    ADD CONSTRAINT fk_rails_6a82dffb63 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: heb412_gen_formulario_plantillahcm fk_rails_6e214a7168; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcm
    ADD CONSTRAINT fk_rails_6e214a7168 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: cor1440_gen_actividadpf_mindicadorpf fk_rails_6e9cbecf02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf_mindicadorpf
    ADD CONSTRAINT fk_rails_6e9cbecf02 FOREIGN KEY (mindicadorpf_id) REFERENCES public.cor1440_gen_mindicadorpf(id);


--
-- Name: msip_oficina fk_rails_6f52b85db3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_oficina
    ADD CONSTRAINT fk_rails_6f52b85db3 FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: cor1440_gen_pmindicadorpf fk_rails_701d924c54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_pmindicadorpf
    ADD CONSTRAINT fk_rails_701d924c54 FOREIGN KEY (mindicadorpf_id) REFERENCES public.cor1440_gen_mindicadorpf(id);


--
-- Name: sivel2_sjr_migracion fk_rails_70b4c24bbe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_70b4c24bbe FOREIGN KEY ("causaRefugio_id") REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: detallefinanciero_persona fk_rails_7240771312; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero_persona
    ADD CONSTRAINT fk_rails_7240771312 FOREIGN KEY (detallefinanciero_id) REFERENCES public.detallefinanciero(id);


--
-- Name: msip_oficina fk_rails_729931f131; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_oficina
    ADD CONSTRAINT fk_rails_729931f131 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: cor1440_gen_efecto_orgsocial fk_rails_72ba94182e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto_orgsocial
    ADD CONSTRAINT fk_rails_72ba94182e FOREIGN KEY (efecto_id) REFERENCES public.cor1440_gen_efecto(id);


--
-- Name: msip_grupo_usuario fk_rails_734ee21e62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo_usuario
    ADD CONSTRAINT fk_rails_734ee21e62 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_migracion fk_rails_757246b473; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_757246b473 FOREIGN KEY (pagoingreso_id) REFERENCES public.msip_trivalente(id);


--
-- Name: msip_persona fk_rails_75a6c8eb10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT fk_rails_75a6c8eb10 FOREIGN KEY (ultimoestatusmigratorio_id) REFERENCES public.sivel2_sjr_statusmigratorio(id);


--
-- Name: sivel2_sjr_casosjr fk_rails_77cbc429a5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT fk_rails_77cbc429a5 FOREIGN KEY (salidam_id) REFERENCES public.msip_ubicacion(id);


--
-- Name: msip_orgsocial fk_rails_7bc2a60574; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT fk_rails_7bc2a60574 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_orgsocial_persona fk_rails_7c335482f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_persona
    ADD CONSTRAINT fk_rails_7c335482f6 FOREIGN KEY (orgsocial_id) REFERENCES public.msip_orgsocial(id);


--
-- Name: territorial fk_rails_7ce44ab810; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.territorial
    ADD CONSTRAINT fk_rails_7ce44ab810 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: sivel2_sjr_ayudasjr_derecho fk_rails_7d05004a64; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr_derecho
    ADD CONSTRAINT fk_rails_7d05004a64 FOREIGN KEY (derecho_id) REFERENCES public.sivel2_sjr_derecho(id);


--
-- Name: mr519_gen_respuestafor fk_rails_805efe6935; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_respuestafor
    ADD CONSTRAINT fk_rails_805efe6935 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: mr519_gen_valorcampo fk_rails_819cf17399; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT fk_rails_819cf17399 FOREIGN KEY (campo_id) REFERENCES public.mr519_gen_campo(id);


--
-- Name: sivel2_gen_anexo_caso fk_rails_825547f886; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_anexo_caso
    ADD CONSTRAINT fk_rails_825547f886 FOREIGN KEY (anexo_id) REFERENCES public.msip_anexo(id);


--
-- Name: cor1440_gen_tipomoneda fk_rails_82fd06de79; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_tipomoneda
    ADD CONSTRAINT fk_rails_82fd06de79 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: mr519_gen_encuestapersona fk_rails_83755e20b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_encuestapersona
    ADD CONSTRAINT fk_rails_83755e20b9 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sivel2_gen_caso fk_rails_850036942a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso
    ADD CONSTRAINT fk_rails_850036942a FOREIGN KEY (ubicacion_id) REFERENCES public.msip_ubicacion(id);


--
-- Name: usuario fk_rails_88f7b7a50d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_rails_88f7b7a50d FOREIGN KEY (territorial_id) REFERENCES public.territorial(id);


--
-- Name: cor1440_gen_formulario_tipoindicador fk_rails_8978582d8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_formulario_tipoindicador
    ADD CONSTRAINT fk_rails_8978582d8a FOREIGN KEY (tipoindicador_id) REFERENCES public.cor1440_gen_tipoindicador(id);


--
-- Name: msip_orgsocial fk_rails_898ac05185; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT fk_rails_898ac05185 FOREIGN KEY (tipoorgsocial_id) REFERENCES public.msip_tipoorgsocial(id);


--
-- Name: sivel2_sjr_migracion fk_rails_8a94bf787d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_8a94bf787d FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: cor1440_gen_actividad_orgsocial fk_rails_8ba599a224; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_orgsocial
    ADD CONSTRAINT fk_rails_8ba599a224 FOREIGN KEY (orgsocial_id) REFERENCES public.msip_orgsocial(id);


--
-- Name: mr519_gen_valorcampo fk_rails_8bb7650018; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_valorcampo
    ADD CONSTRAINT fk_rails_8bb7650018 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: cor1440_gen_informefinanciero fk_rails_8bd007af77; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informefinanciero
    ADD CONSTRAINT fk_rails_8bd007af77 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sivel2_sjr_desplazamiento fk_rails_8c6497f428; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT fk_rails_8c6497f428 FOREIGN KEY (llegadaubicacionpre_id) REFERENCES public.msip_ubicacionpre(id);


--
-- Name: msip_grupo_usuario fk_rails_8d24f7c1c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_grupo_usuario
    ADD CONSTRAINT fk_rails_8d24f7c1c0 FOREIGN KEY (grupo_id) REFERENCES public.msip_grupo(id);


--
-- Name: sivel2_sjr_ayudaestado_derecho fk_rails_8e883e437d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudaestado_derecho
    ADD CONSTRAINT fk_rails_8e883e437d FOREIGN KEY (derecho_id) REFERENCES public.sivel2_sjr_derecho(id);


--
-- Name: detallefinanciero fk_rails_90682521dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero
    ADD CONSTRAINT fk_rails_90682521dc FOREIGN KEY (actividadpf_id) REFERENCES public.cor1440_gen_actividadpf(id);


--
-- Name: msip_departamento fk_rails_92093de1a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_departamento
    ADD CONSTRAINT fk_rails_92093de1a1 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: detallefinanciero fk_rails_9482642f4e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero
    ADD CONSTRAINT fk_rails_9482642f4e FOREIGN KEY (tipotransferencia_id) REFERENCES public.tipotransferencia(id);


--
-- Name: actonino fk_rails_94e63d76eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actonino
    ADD CONSTRAINT fk_rails_94e63d76eb FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: cor1440_gen_resultadopf fk_rails_95485cfc7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_resultadopf
    ADD CONSTRAINT fk_rails_95485cfc7a FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_efecto_respuestafor fk_rails_95a3aff09f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_efecto_respuestafor
    ADD CONSTRAINT fk_rails_95a3aff09f FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: sivel2_gen_combatiente fk_rails_95f4a0b8f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_95f4a0b8f6 FOREIGN KEY (profesion_id) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: sivel2_sjr_desplazamiento fk_rails_9b35090c48; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT fk_rails_9b35090c48 FOREIGN KEY (destinoubicacionpre_id) REFERENCES public.msip_ubicacionpre(id);


--
-- Name: sivel2_sjr_ayudaestado_derecho fk_rails_9b831754a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudaestado_derecho
    ADD CONSTRAINT fk_rails_9b831754a4 FOREIGN KEY (ayudaestado_id) REFERENCES public.sivel2_sjr_ayudaestado(id);


--
-- Name: sivel2_sjr_migracion fk_rails_9d5a5e57b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_9d5a5e57b1 FOREIGN KEY (miembrofamiliar_id) REFERENCES public.miembrofamiliar(id);


--
-- Name: msip_orgsocial_sectororgsocial fk_rails_9f61a364e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_sectororgsocial
    ADD CONSTRAINT fk_rails_9f61a364e0 FOREIGN KEY (sectororgsocial_id) REFERENCES public.msip_sectororgsocial(id);


--
-- Name: detallefinanciero fk_rails_9fb84e623b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero
    ADD CONSTRAINT fk_rails_9fb84e623b FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: asesorhistorico fk_rails_a020144a5c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asesorhistorico
    ADD CONSTRAINT fk_rails_a020144a5c FOREIGN KEY (oficina_id) REFERENCES public.msip_oficina(id);


--
-- Name: asesorhistorico fk_rails_a0ce6f0b19; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asesorhistorico
    ADD CONSTRAINT fk_rails_a0ce6f0b19 FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: mr519_gen_campo fk_rails_a186e1a8a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mr519_gen_campo
    ADD CONSTRAINT fk_rails_a186e1a8a0 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: msip_solicitud fk_rails_a670d661ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud
    ADD CONSTRAINT fk_rails_a670d661ef FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: cor1440_gen_actividad_proyectofinanciero fk_rails_a8489e0d62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyectofinanciero
    ADD CONSTRAINT fk_rails_a8489e0d62 FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_actividad_respuestafor fk_rails_abc0cafc05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_respuestafor
    ADD CONSTRAINT fk_rails_abc0cafc05 FOREIGN KEY (respuestafor_id) REFERENCES public.mr519_gen_respuestafor(id);


--
-- Name: cor1440_gen_beneficiariopf fk_rails_ac70e973ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_beneficiariopf
    ADD CONSTRAINT fk_rails_ac70e973ee FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sivel2_sjr_causaagrpais_migracion fk_rails_acb340fd32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_causaagrpais_migracion
    ADD CONSTRAINT fk_rails_acb340fd32 FOREIGN KEY (causaagrpais_id) REFERENCES public.causaagresion(id);


--
-- Name: sivel2_sjr_migracion fk_rails_af31a06cec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_af31a06cec FOREIGN KEY (tipoproteccion_id) REFERENCES public.tipoproteccion(id);


--
-- Name: sivel2_gen_combatiente fk_rails_af43e915a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_af43e915a6 FOREIGN KEY (filiacion_id) REFERENCES public.sivel2_gen_filiacion(id);


--
-- Name: detallefinanciero fk_rails_b092affa22; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero
    ADD CONSTRAINT fk_rails_b092affa22 FOREIGN KEY (modalidadentrega_id) REFERENCES public.modalidadentrega(id);


--
-- Name: sivel2_sjr_actividad_casosjr fk_rails_b2461f538f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_actividad_casosjr
    ADD CONSTRAINT fk_rails_b2461f538f FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: sivel2_sjr_casosjr fk_rails_b324d125c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT fk_rails_b324d125c0 FOREIGN KEY (estatusmigratorio_id) REFERENCES public.sivel2_sjr_statusmigratorio(id);


--
-- Name: detallefinanciero fk_rails_b4cc8107b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero
    ADD CONSTRAINT fk_rails_b4cc8107b9 FOREIGN KEY (frecuenciaentrega_id) REFERENCES public.frecuenciaentrega(id);


--
-- Name: sivel2_sjr_migracion fk_rails_b52dcfd040; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_b52dcfd040 FOREIGN KEY (viadeingreso_id) REFERENCES public.viadeingreso(id);


--
-- Name: cor1440_gen_indicadorpf fk_rails_b5b70fb7f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf
    ADD CONSTRAINT fk_rails_b5b70fb7f7 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_actividad_actividadpf fk_rails_baad271930; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_actividadpf
    ADD CONSTRAINT fk_rails_baad271930 FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: cor1440_gen_anexo_efecto fk_rails_bcd8d7b7ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_efecto
    ADD CONSTRAINT fk_rails_bcd8d7b7ad FOREIGN KEY (anexo_id) REFERENCES public.msip_anexo(id);


--
-- Name: sivel2_gen_combatiente fk_rails_bfb49597e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_bfb49597e1 FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: cor1440_gen_informe fk_rails_c02831dd89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT fk_rails_c02831dd89 FOREIGN KEY (filtroactividadarea) REFERENCES public.cor1440_gen_actividadarea(id);


--
-- Name: msip_ubicacionpre fk_rails_c08a606417; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_c08a606417 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_persona fk_rails_c11683a4fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT fk_rails_c11683a4fd FOREIGN KEY (ultimadiscapacidad_id) REFERENCES public.discapacidad(id);


--
-- Name: sivel2_sjr_motivosjr_derecho fk_rails_c31c559a22; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr_derecho
    ADD CONSTRAINT fk_rails_c31c559a22 FOREIGN KEY (motivosjr_id) REFERENCES public.sivel2_sjr_motivosjr(id);


--
-- Name: sivel2_sjr_motivosjr_derecho fk_rails_c3337af2ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr_derecho
    ADD CONSTRAINT fk_rails_c3337af2ab FOREIGN KEY (derecho_id) REFERENCES public.sivel2_sjr_derecho(id);


--
-- Name: territorial fk_rails_c3df8352e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.territorial
    ADD CONSTRAINT fk_rails_c3df8352e6 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: cor1440_gen_datointermedioti_pmindicadorpf fk_rails_c5ec912cc3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti_pmindicadorpf
    ADD CONSTRAINT fk_rails_c5ec912cc3 FOREIGN KEY (datointermedioti_id) REFERENCES public.cor1440_gen_datointermedioti(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_c68e2278b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_c68e2278b2 FOREIGN KEY (actividadtipo_id) REFERENCES public.cor1440_gen_actividadtipo(id);


--
-- Name: cor1440_gen_proyectofinanciero_usuario fk_rails_c6f8d7af05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero_usuario
    ADD CONSTRAINT fk_rails_c6f8d7af05 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: msip_ubicacionpre fk_rails_c8024a90df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_c8024a90df FOREIGN KEY (tsitio_id) REFERENCES public.msip_tsitio(id);


--
-- Name: cor1440_gen_desembolso fk_rails_c858edd00a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_desembolso
    ADD CONSTRAINT fk_rails_c858edd00a FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: cor1440_gen_financiador_proyectofinanciero fk_rails_ca93eb04dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_financiador_proyectofinanciero
    ADD CONSTRAINT fk_rails_ca93eb04dc FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: actonino fk_rails_cb9d0fd150; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actonino
    ADD CONSTRAINT fk_rails_cb9d0fd150 FOREIGN KEY (presponsable_id) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: usuario fk_rails_cc636858ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_rails_cc636858ad FOREIGN KEY (tema_id) REFERENCES public.msip_tema(id);


--
-- Name: cor1440_gen_actividad_anexo fk_rails_cc9d44f9de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_anexo
    ADD CONSTRAINT fk_rails_cc9d44f9de FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: sivel2_sjr_migracion fk_rails_cd52a78f0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_cd52a78f0b FOREIGN KEY (autoridadrefugio_id) REFERENCES public.autoridadrefugio(id);


--
-- Name: cor1440_gen_actividad_proyecto fk_rails_cf5d592625; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_proyecto
    ADD CONSTRAINT fk_rails_cf5d592625 FOREIGN KEY (proyecto_id) REFERENCES public.cor1440_gen_proyecto(id);


--
-- Name: cor1440_gen_indicadorpf fk_rails_cf888d1b56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf
    ADD CONSTRAINT fk_rails_cf888d1b56 FOREIGN KEY (tipoindicador_id) REFERENCES public.cor1440_gen_tipoindicador(id);


--
-- Name: cor1440_gen_actividadpf_mindicadorpf fk_rails_cfff77ad98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf_mindicadorpf
    ADD CONSTRAINT fk_rails_cfff77ad98 FOREIGN KEY (actividadpf_id) REFERENCES public.cor1440_gen_actividadpf(id);


--
-- Name: cor1440_gen_proyectofinanciero fk_rails_d0ff83bfc6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero
    ADD CONSTRAINT fk_rails_d0ff83bfc6 FOREIGN KEY (tipomoneda_id) REFERENCES public.cor1440_gen_tipomoneda(id);


--
-- Name: actonino fk_rails_d18b7bd1f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actonino
    ADD CONSTRAINT fk_rails_d18b7bd1f1 FOREIGN KEY (ubicacionpre_id) REFERENCES public.msip_ubicacionpre(id);


--
-- Name: cor1440_gen_indicadorpf fk_rails_d264d408b0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_indicadorpf
    ADD CONSTRAINT fk_rails_d264d408b0 FOREIGN KEY (resultadopf_id) REFERENCES public.cor1440_gen_resultadopf(id);


--
-- Name: sivel2_sjr_ayudasjr_derecho fk_rails_d4e8fe33bc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_ayudasjr_derecho
    ADD CONSTRAINT fk_rails_d4e8fe33bc FOREIGN KEY (ayudasjr_id) REFERENCES public.sivel2_sjr_ayudasjr(id);


--
-- Name: sivel2_sjr_migracion fk_rails_d5449c6d83; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_d5449c6d83 FOREIGN KEY (salidaubicacionpre_id) REFERENCES public.msip_ubicacionpre(id);


--
-- Name: cor1440_gen_plantillahcm_proyectofinanciero fk_rails_d56d245f70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_plantillahcm_proyectofinanciero
    ADD CONSTRAINT fk_rails_d56d245f70 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: msip_persona fk_rails_d5b92f1c45; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT fk_rails_d5b92f1c45 FOREIGN KEY (etnia_id) REFERENCES public.msip_etnia(id);


--
-- Name: sivel2_sjr_categoria_desplazamiento fk_rails_d6d414f139; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_categoria_desplazamiento
    ADD CONSTRAINT fk_rails_d6d414f139 FOREIGN KEY (categoria_id) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: cor1440_gen_informe fk_rails_daf0af8605; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_informe
    ADD CONSTRAINT fk_rails_daf0af8605 FOREIGN KEY (filtrooficina) REFERENCES public.msip_oficina(id);


--
-- Name: msip_solicitud_usuarionotificar fk_rails_db0f7c1dd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud_usuarionotificar
    ADD CONSTRAINT fk_rails_db0f7c1dd6 FOREIGN KEY (usuarionotificar_id) REFERENCES public.usuario(id);


--
-- Name: cor1440_gen_proyectofinanciero_usuario fk_rails_dc664c3eaf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero_usuario
    ADD CONSTRAINT fk_rails_dc664c3eaf FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_migracion fk_rails_dcf3147f89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_dcf3147f89 FOREIGN KEY (perfilmigracion_id) REFERENCES public.perfilmigracion(id);


--
-- Name: sivel2_gen_otraorga_victima fk_rails_e023799a03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_otraorga_victima
    ADD CONSTRAINT fk_rails_e023799a03 FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: sivel2_gen_sectorsocialsec_victima fk_rails_e04ef7c3e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocialsec_victima
    ADD CONSTRAINT fk_rails_e04ef7c3e5 FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id);


--
-- Name: cor1440_gen_formulario_mindicadorpf fk_rails_e07a0a8650; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_formulario_mindicadorpf
    ADD CONSTRAINT fk_rails_e07a0a8650 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: heb412_gen_campoplantillahcm fk_rails_e0e38e0782; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_campoplantillahcm
    ADD CONSTRAINT fk_rails_e0e38e0782 FOREIGN KEY (plantillahcm_id) REFERENCES public.heb412_gen_plantillahcm(id);


--
-- Name: actonino fk_rails_e196eba044; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actonino
    ADD CONSTRAINT fk_rails_e196eba044 FOREIGN KEY (categoria_id) REFERENCES public.sivel2_gen_categoria(id);


--
-- Name: sivel2_gen_combatiente fk_rails_e2d01a5a99; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_e2d01a5a99 FOREIGN KEY (sectorsocial_id) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: territorial fk_rails_e3b2049e4c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.territorial
    ADD CONSTRAINT fk_rails_e3b2049e4c FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: sivel2_sjr_causaagresion_migracion fk_rails_e5161bdd4e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_causaagresion_migracion
    ADD CONSTRAINT fk_rails_e5161bdd4e FOREIGN KEY (causaagresion_id) REFERENCES public.causaagresion(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_e69a8b5822; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_e69a8b5822 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: cor1440_gen_beneficiariopf fk_rails_e6ba73556e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_beneficiariopf
    ADD CONSTRAINT fk_rails_e6ba73556e FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: sivel2_sjr_aspsicosocial_respuesta fk_rails_e8410c8faa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_aspsicosocial_respuesta
    ADD CONSTRAINT fk_rails_e8410c8faa FOREIGN KEY (aspsicosocial_id) REFERENCES public.sivel2_sjr_aspsicosocial(id);


--
-- Name: msip_orgsocial fk_rails_e860f377d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial
    ADD CONSTRAINT fk_rails_e860f377d7 FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: sivel2_sjr_agremigracion_migracion fk_rails_e86a1e3ca3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_agremigracion_migracion
    ADD CONSTRAINT fk_rails_e86a1e3ca3 FOREIGN KEY (migracion_id) REFERENCES public.sivel2_sjr_migracion(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_e876f1b705; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_e876f1b705 FOREIGN KEY (indicadorgifmm_id) REFERENCES public.indicadorgifmm(id);


--
-- Name: asesorhistorico fk_rails_e9632297a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asesorhistorico
    ADD CONSTRAINT fk_rails_e9632297a2 FOREIGN KEY (casosjr_id) REFERENCES public.sivel2_sjr_casosjr(caso_id);


--
-- Name: heb412_gen_carpetaexclusiva fk_rails_ea1add81e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_carpetaexclusiva
    ADD CONSTRAINT fk_rails_ea1add81e6 FOREIGN KEY (grupo_id) REFERENCES public.msip_grupo(id);


--
-- Name: msip_ubicacionpre fk_rails_eba8cc9124; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_rails_eba8cc9124 FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_persona fk_rails_ebe5d3759e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT fk_rails_ebe5d3759e FOREIGN KEY (ultimoperfilorgsocial_id) REFERENCES public.msip_perfilorgsocial(id);


--
-- Name: cor1440_gen_actividad_orgsocial fk_rails_ecdad5c731; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividad_orgsocial
    ADD CONSTRAINT fk_rails_ecdad5c731 FOREIGN KEY (actividad_id) REFERENCES public.cor1440_gen_actividad(id);


--
-- Name: sivel2_sjr_difmigracion_migracion fk_rails_ef83297098; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_difmigracion_migracion
    ADD CONSTRAINT fk_rails_ef83297098 FOREIGN KEY (migracion_id) REFERENCES public.sivel2_sjr_migracion(id);


--
-- Name: msip_orgsocial_sectororgsocial fk_rails_f032bb21a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_orgsocial_sectororgsocial
    ADD CONSTRAINT fk_rails_f032bb21a6 FOREIGN KEY (orgsocial_id) REFERENCES public.msip_orgsocial(id);


--
-- Name: detallefinanciero_persona fk_rails_f0b14a6b6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero_persona
    ADD CONSTRAINT fk_rails_f0b14a6b6b FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: sivel2_gen_combatiente fk_rails_f0cf2a7bec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_f0cf2a7bec FOREIGN KEY (resagresion_id) REFERENCES public.sivel2_gen_resagresion(id);


--
-- Name: cor1440_gen_actividadtipo_formulario fk_rails_f17af6bf9c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadtipo_formulario
    ADD CONSTRAINT fk_rails_f17af6bf9c FOREIGN KEY (actividadtipo_id) REFERENCES public.cor1440_gen_actividadtipo(id);


--
-- Name: cor1440_gen_datointermedioti fk_rails_f2e0ba2f26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_datointermedioti
    ADD CONSTRAINT fk_rails_f2e0ba2f26 FOREIGN KEY (tipoindicador_id) REFERENCES public.cor1440_gen_tipoindicador(id);


--
-- Name: detallefinanciero fk_rails_f41da17421; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detallefinanciero
    ADD CONSTRAINT fk_rails_f41da17421 FOREIGN KEY (unidadayuda_id) REFERENCES public.unidadayuda(id);


--
-- Name: sivel2_sjr_accionjuridica_respuesta fk_rails_f583703acd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_accionjuridica_respuesta
    ADD CONSTRAINT fk_rails_f583703acd FOREIGN KEY (respuesta_id) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_gen_combatiente fk_rails_f77dda7a40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_f77dda7a40 FOREIGN KEY (organizacion_id) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: cor1440_gen_actividadpf fk_rails_f941b0c512; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadpf
    ADD CONSTRAINT fk_rails_f941b0c512 FOREIGN KEY (proyectofinanciero_id) REFERENCES public.cor1440_gen_proyectofinanciero(id);


--
-- Name: sivel2_sjr_migracion fk_rails_fa38ef778b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_migracion
    ADD CONSTRAINT fk_rails_fa38ef778b FOREIGN KEY (causamigracion_id) REFERENCES public.causamigracion(id);


--
-- Name: sivel2_sjr_agremigracion_migracion fk_rails_faf51c7755; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_agremigracion_migracion
    ADD CONSTRAINT fk_rails_faf51c7755 FOREIGN KEY (agremigracion_id) REFERENCES public.agresionmigracion(id);


--
-- Name: cor1440_gen_actividadtipo_formulario fk_rails_faf663ab7f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_actividadtipo_formulario
    ADD CONSTRAINT fk_rails_faf663ab7f FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: sivel2_gen_combatiente fk_rails_fb02819ec4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_combatiente
    ADD CONSTRAINT fk_rails_fb02819ec4 FOREIGN KEY (rangoedad_id) REFERENCES public.sivel2_gen_rangoedad(id);


--
-- Name: msip_centropoblado fk_rails_fb09f016e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT fk_rails_fb09f016e4 FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: heb412_gen_formulario_plantillahcm fk_rails_fc3149fc44; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.heb412_gen_formulario_plantillahcm
    ADD CONSTRAINT fk_rails_fc3149fc44 FOREIGN KEY (plantillahcm_id) REFERENCES public.heb412_gen_plantillahcm(id);


--
-- Name: cor1440_gen_formulario_tipoindicador fk_rails_fd2fbcd1b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_formulario_tipoindicador
    ADD CONSTRAINT fk_rails_fd2fbcd1b8 FOREIGN KEY (formulario_id) REFERENCES public.mr519_gen_formulario(id);


--
-- Name: cor1440_gen_anexo_proyectofinanciero fk_rails_fd94296801; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_anexo_proyectofinanciero
    ADD CONSTRAINT fk_rails_fd94296801 FOREIGN KEY (anexo_id) REFERENCES public.msip_anexo(id);


--
-- Name: sivel2_sjr_desplazamiento fk_rails_fe4eac003a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_desplazamiento
    ADD CONSTRAINT fk_rails_fe4eac003a FOREIGN KEY (expulsionubicacionpre_id) REFERENCES public.msip_ubicacionpre(id);


--
-- Name: msip_solicitud fk_rails_ffa31a0de6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_solicitud
    ADD CONSTRAINT fk_rails_ffa31a0de6 FOREIGN KEY (estadosol_id) REFERENCES public.msip_estadosol(id);


--
-- Name: msip_ubicacionpre fk_ubicacionpre_departamento_municipio; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_ubicacionpre_departamento_municipio FOREIGN KEY (departamento_id, municipio_id) REFERENCES public.msip_municipio(departamento_id, id);


--
-- Name: msip_ubicacionpre fk_ubicacionpre_municipio_centropoblado; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_ubicacionpre_municipio_centropoblado FOREIGN KEY (municipio_id, centropoblado_id) REFERENCES public.msip_centropoblado(municipio_id, id);


--
-- Name: msip_ubicacionpre fk_ubicacionpre_municipio_vereda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_ubicacionpre_municipio_vereda FOREIGN KEY (municipio_id, vereda_id) REFERENCES public.msip_vereda(municipio_id, id);


--
-- Name: msip_ubicacionpre fk_ubicacionpre_pais_departamento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacionpre
    ADD CONSTRAINT fk_ubicacionpre_pais_departamento FOREIGN KEY (pais_id, departamento_id) REFERENCES public.msip_departamento(pais_id, id);


--
-- Name: sivel2_sjr_casosjr fk_vcontacto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT fk_vcontacto FOREIGN KEY (caso_id, contacto_id) REFERENCES public.sivel2_gen_victima(caso_id, persona_id);


--
-- Name: cor1440_gen_proyectofinanciero lf_proyectofinanciero_responsable; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cor1440_gen_proyectofinanciero
    ADD CONSTRAINT lf_proyectofinanciero_responsable FOREIGN KEY (responsable_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_sjr_motivosjr_respuesta motivosjr_respuesta_id_motivosjr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr_respuesta
    ADD CONSTRAINT motivosjr_respuesta_id_motivosjr_fkey FOREIGN KEY (motivosjr_id) REFERENCES public.sivel2_sjr_motivosjr(id);


--
-- Name: sivel2_sjr_motivosjr_respuesta motivosjr_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_motivosjr_respuesta
    ADD CONSTRAINT motivosjr_respuesta_id_respuesta_fkey FOREIGN KEY (respuesta_id) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: msip_centropoblado msip_centropoblado_id_tcentropoblado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_id_tcentropoblado_fkey FOREIGN KEY (tcentropoblado_id) REFERENCES public.msip_tcentropoblado(id);


--
-- Name: msip_centropoblado msip_centropoblado_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_centropoblado
    ADD CONSTRAINT msip_centropoblado_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_municipio msip_municipio_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_municipio
    ADD CONSTRAINT msip_municipio_id_departamento_fkey FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_persona msip_persona_centropoblado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT msip_persona_centropoblado_id_fkey FOREIGN KEY (centropoblado_id) REFERENCES public.msip_centropoblado(id);


--
-- Name: msip_persona msip_persona_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT msip_persona_id_departamento_fkey FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_persona msip_persona_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT msip_persona_id_municipio_fkey FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: msip_ubicacion msip_ubicacion_centropoblado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT msip_ubicacion_centropoblado_id_fkey FOREIGN KEY (centropoblado_id) REFERENCES public.msip_centropoblado(id);


--
-- Name: msip_ubicacion msip_ubicacion_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT msip_ubicacion_id_departamento_fkey FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: msip_ubicacion msip_ubicacion_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT msip_ubicacion_id_municipio_fkey FOREIGN KEY (municipio_id) REFERENCES public.msip_municipio(id);


--
-- Name: sivel2_gen_organizacion_victimacolectiva organizacion_victimacolectiva_id_organizacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion_victimacolectiva
    ADD CONSTRAINT organizacion_victimacolectiva_id_organizacion_fkey FOREIGN KEY (organizacion_id) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: sivel2_gen_organizacion_victimacolectiva organizacion_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_organizacion_victimacolectiva
    ADD CONSTRAINT organizacion_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: msip_persona persona_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_id_pais_fkey FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_persona persona_nacionalde_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_nacionalde_fkey FOREIGN KEY (nacionalde) REFERENCES public.msip_pais(id);


--
-- Name: msip_persona persona_tdocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona
    ADD CONSTRAINT persona_tdocumento_id_fkey FOREIGN KEY (tdocumento_id) REFERENCES public.msip_tdocumento(id);


--
-- Name: msip_persona_trelacion persona_trelacion_id_trelacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_id_trelacion_fkey FOREIGN KEY (trelacion_id) REFERENCES public.msip_trelacion(id);


--
-- Name: msip_persona_trelacion persona_trelacion_persona1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona1_fkey FOREIGN KEY (persona1) REFERENCES public.msip_persona(id);


--
-- Name: msip_persona_trelacion persona_trelacion_persona2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona2_fkey FOREIGN KEY (persona2) REFERENCES public.msip_persona(id);


--
-- Name: sivel2_gen_presponsable presponsable_papa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_presponsable
    ADD CONSTRAINT presponsable_papa_fkey FOREIGN KEY (papa_id) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_profesion_victimacolectiva profesion_victimacolectiva_id_profesion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victimacolectiva
    ADD CONSTRAINT profesion_victimacolectiva_id_profesion_fkey FOREIGN KEY (profesion_id) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: sivel2_gen_profesion_victimacolectiva profesion_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_profesion_victimacolectiva
    ADD CONSTRAINT profesion_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_sjr_progestado_respuesta progestado_respuesta_id_progestado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado_respuesta
    ADD CONSTRAINT progestado_respuesta_id_progestado_fkey FOREIGN KEY (progestado_id) REFERENCES public.sivel2_sjr_progestado(id);


--
-- Name: sivel2_sjr_progestado_respuesta progestado_respuesta_id_respuesta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_progestado_respuesta
    ADD CONSTRAINT progestado_respuesta_id_respuesta_fkey FOREIGN KEY (respuesta_id) REFERENCES public.sivel2_sjr_respuesta(id);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva rangoedad_victimacolectiva_id_rangoedad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad_victimacolectiva
    ADD CONSTRAINT rangoedad_victimacolectiva_id_rangoedad_fkey FOREIGN KEY (rangoedad_id) REFERENCES public.sivel2_gen_rangoedad(id);


--
-- Name: sivel2_gen_rangoedad_victimacolectiva rangoedad_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_rangoedad_victimacolectiva
    ADD CONSTRAINT rangoedad_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_sjr_respuesta respuesta_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_respuesta
    ADD CONSTRAINT respuesta_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_sjr_casosjr(caso_id);


--
-- Name: sivel2_sjr_respuesta respuesta_id_personadesea_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_respuesta
    ADD CONSTRAINT respuesta_id_personadesea_fkey FOREIGN KEY (personadesea_id) REFERENCES public.sivel2_sjr_personadesea(id);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva sectorsocial_victimacolectiva_id_sectorsocial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial_victimacolectiva
    ADD CONSTRAINT sectorsocial_victimacolectiva_id_sectorsocial_fkey FOREIGN KEY (sectorsocial_id) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: sivel2_gen_sectorsocial_victimacolectiva sectorsocial_victimacolectiva_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_sectorsocial_victimacolectiva
    ADD CONSTRAINT sectorsocial_victimacolectiva_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_gen_caso_fotra sivel2_gen_caso_fotra_anexo_caso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fotra
    ADD CONSTRAINT sivel2_gen_caso_fotra_anexo_caso_id_fkey FOREIGN KEY (anexo_caso_id) REFERENCES public.sivel2_gen_anexo_caso(id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_anexo_caso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_anexo_caso_id_fkey FOREIGN KEY (anexo_caso_id) REFERENCES public.sivel2_gen_anexo_caso(id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_fuenteprensa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_fuenteprensa_id_fkey FOREIGN KEY (fuenteprensa_id) REFERENCES public.msip_fuenteprensa(id);


--
-- Name: sivel2_gen_caso_fuenteprensa sivel2_gen_caso_fuenteprensa_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_caso_fuenteprensa
    ADD CONSTRAINT sivel2_gen_caso_fuenteprensa_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_categoria sivel2_gen_categoria_supracategoria_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_categoria
    ADD CONSTRAINT sivel2_gen_categoria_supracategoria_id_fkey FOREIGN KEY (supracategoria_id) REFERENCES public.sivel2_gen_supracategoria(id);


--
-- Name: sivel2_gen_observador_filtrodepartamento sivel2_gen_observador_filtrodepartamento_d_idx; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_observador_filtrodepartamento
    ADD CONSTRAINT sivel2_gen_observador_filtrodepartamento_d_idx FOREIGN KEY (departamento_id) REFERENCES public.msip_departamento(id);


--
-- Name: sivel2_gen_observador_filtrodepartamento sivel2_gen_observador_filtrodepartamento_u_idx; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_observador_filtrodepartamento
    ADD CONSTRAINT sivel2_gen_observador_filtrodepartamento_u_idx FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: sivel2_gen_supracategoria supracategoria_id_tviolencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_supracategoria
    ADD CONSTRAINT supracategoria_id_tviolencia_fkey FOREIGN KEY (tviolencia_id) REFERENCES public.sivel2_gen_tviolencia(id);


--
-- Name: msip_ubicacion ubicacion_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: msip_ubicacion ubicacion_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_pais_fkey FOREIGN KEY (pais_id) REFERENCES public.msip_pais(id);


--
-- Name: msip_ubicacion ubicacion_id_tsitio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.msip_ubicacion
    ADD CONSTRAINT ubicacion_id_tsitio_fkey FOREIGN KEY (tsitio_id) REFERENCES public.msip_tsitio(id);


--
-- Name: sivel2_sjr_casosjr vcontacto_lfor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_casosjr
    ADD CONSTRAINT vcontacto_lfor FOREIGN KEY (caso_id, contacto_id) REFERENCES public.sivel2_gen_victima(caso_id, persona_id);


--
-- Name: sivel2_gen_victima victima_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_victima victima_id_filiacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_filiacion_fkey FOREIGN KEY (filiacion_id) REFERENCES public.sivel2_gen_filiacion(id);


--
-- Name: sivel2_gen_victima victima_id_iglesia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_iglesia_fkey FOREIGN KEY (iglesia_id) REFERENCES public.sivel2_gen_iglesia(id);


--
-- Name: sivel2_gen_victima victima_id_organizacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_organizacion_fkey FOREIGN KEY (organizacion_id) REFERENCES public.sivel2_gen_organizacion(id);


--
-- Name: sivel2_gen_victima victima_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_persona_fkey FOREIGN KEY (persona_id) REFERENCES public.msip_persona(id);


--
-- Name: sivel2_gen_victima victima_id_profesion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_profesion_fkey FOREIGN KEY (profesion_id) REFERENCES public.sivel2_gen_profesion(id);


--
-- Name: sivel2_gen_victima victima_id_rangoedad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_rangoedad_fkey FOREIGN KEY (rangoedad_id) REFERENCES public.sivel2_gen_rangoedad(id);


--
-- Name: sivel2_gen_victima victima_id_sectorsocial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_sectorsocial_fkey FOREIGN KEY (sectorsocial_id) REFERENCES public.sivel2_gen_sectorsocial(id);


--
-- Name: sivel2_gen_victima victima_id_vinculoestado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_id_vinculoestado_fkey FOREIGN KEY (vinculoestado_id) REFERENCES public.sivel2_gen_vinculoestado(id);


--
-- Name: sivel2_gen_victima victima_organizacionarmada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victima
    ADD CONSTRAINT victima_organizacionarmada_fkey FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_victimacolectiva victimacolectiva_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT victimacolectiva_id_caso_fkey FOREIGN KEY (caso_id) REFERENCES public.sivel2_gen_caso(id);


--
-- Name: sivel2_gen_victimacolectiva victimacolectiva_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT victimacolectiva_id_grupoper_fkey FOREIGN KEY (grupoper_id) REFERENCES public.msip_grupoper(id);


--
-- Name: sivel2_gen_victimacolectiva victimacolectiva_organizacionarmada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva
    ADD CONSTRAINT victimacolectiva_organizacionarmada_fkey FOREIGN KEY (organizacionarmada) REFERENCES public.sivel2_gen_presponsable(id);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado victimacolectiva_vinculoestado_id_vinculoestado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva_vinculoestado
    ADD CONSTRAINT victimacolectiva_vinculoestado_id_vinculoestado_fkey FOREIGN KEY (vinculoestado_id) REFERENCES public.sivel2_gen_vinculoestado(id);


--
-- Name: sivel2_gen_victimacolectiva_vinculoestado victimacolectiva_vinculoestado_victimacolectiva_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_gen_victimacolectiva_vinculoestado
    ADD CONSTRAINT victimacolectiva_vinculoestado_victimacolectiva_id_fkey FOREIGN KEY (victimacolectiva_id) REFERENCES public.sivel2_gen_victimacolectiva(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_actividadoficio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_actividadoficio_fkey FOREIGN KEY (actividadoficio_id) REFERENCES public.sivel2_gen_actividadoficio(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_escolaridad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_escolaridad_fkey FOREIGN KEY (escolaridad_id) REFERENCES public.sivel2_gen_escolaridad(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_estadocivil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_estadocivil_fkey FOREIGN KEY (estadocivil_id) REFERENCES public.sivel2_gen_estadocivil(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_maternidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_maternidad_fkey FOREIGN KEY (maternidad_id) REFERENCES public.sivel2_gen_maternidad(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_regimensalud_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_regimensalud_fkey FOREIGN KEY (regimensalud_id) REFERENCES public.sivel2_sjr_regimensalud(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_rolfamilia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_rolfamilia_fkey FOREIGN KEY (rolfamilia_id) REFERENCES public.sivel2_sjr_rolfamilia(id);


--
-- Name: sivel2_sjr_victimasjr victimasjr_id_victima_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sivel2_sjr_victimasjr
    ADD CONSTRAINT victimasjr_id_victima_fkey FOREIGN KEY (victima_id) REFERENCES public.sivel2_gen_victima(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20241125115043'),
('20241119195733'),
('20241119180614'),
('20241113150932'),
('20241113141404'),
('20241113102219'),
('20241113090822'),
('20241112200428'),
('20241112195544'),
('20241106114858'),
('20241104072046'),
('20241010132247'),
('20241010110744'),
('20241006115708'),
('20241005013833'),
('20241005013800'),
('20240910202302'),
('20240826125819'),
('20240813151536'),
('20240806082036'),
('20240715230510'),
('20240619170550'),
('20240611120310'),
('20240509173622'),
('20240423143517'),
('20240418231104'),
('20240418222925'),
('20240418222423'),
('20240417143616'),
('20240416151439'),
('20240319141612'),
('20240312182320'),
('20240307123248'),
('20240305165644'),
('20240221015729'),
('20240221002426'),
('20240220233356'),
('20240220230008'),
('20240220164637'),
('20240220111410'),
('20240219221519'),
('20240219220944'),
('20231211155412'),
('20231211082951'),
('20231210224436'),
('20231210213752'),
('20231210020428'),
('20231208162022'),
('20231208160043'),
('20231205205600'),
('20231205205549'),
('20231205205500'),
('20231205202418'),
('20231126132857'),
('20231125230000'),
('20231125221159'),
('20231125152810'),
('20231125152802'),
('20231124204935'),
('20231124204000'),
('20231124200056'),
('20231121203443'),
('20231121154749'),
('20231121135551'),
('20231120175125'),
('20231120094041'),
('20231109184942'),
('20231108094709'),
('20231009171450'),
('20231009090632'),
('20231009090231'),
('20231009085621'),
('20231007095930'),
('20231006084042'),
('20231005122005'),
('20230927001422'),
('20230921195408'),
('20230921184659'),
('20230914145448'),
('20230914145138'),
('20230911165625'),
('20230911155127'),
('20230906154935'),
('20230904144334'),
('20230811101631'),
('20230723011110'),
('20230722180204'),
('20230712163859'),
('20230712004821'),
('20230707125612'),
('20230706090216'),
('20230706085249'),
('20230622205530'),
('20230622205529'),
('20230622205528'),
('20230616203948'),
('20230614220241'),
('20230614170400'),
('20230613111532'),
('20230508193508'),
('20230506192413'),
('20230506183428'),
('20230505194356'),
('20230505183021'),
('20230504084246'),
('20230427195057'),
('20230424182752'),
('20230424175427'),
('20230424110835'),
('20230419174417'),
('20230418194845'),
('20230418155831'),
('20230407011451'),
('20230407010923'),
('20230406092509'),
('20230406023817'),
('20230406021624'),
('20230405141724'),
('20230405032350'),
('20230405012229'),
('20230404025025'),
('20230327161238'),
('20230301212546'),
('20230301145222'),
('20230225022307'),
('20230213001339'),
('20230207195955'),
('20230131094311'),
('20230129103236'),
('20230127123623'),
('20230127041839'),
('20230113133200'),
('20221215102923'),
('20221215012346'),
('20221212021533'),
('20221211141209'),
('20221211141208'),
('20221211141207'),
('20221211032103'),
('20221211012152'),
('20221211005549'),
('20221210233055'),
('20221210232108'),
('20221210230905'),
('20221210155527'),
('20221210145029'),
('20221209165024'),
('20221209142327'),
('20221208173349'),
('20221201154025'),
('20221201143440'),
('20221122124751'),
('20221121131424'),
('20221121010448'),
('20221118051631'),
('20221118032223'),
('20221118023539'),
('20221118010717'),
('20221117050734'),
('20221115102504'),
('20221115023319'),
('20221114034442'),
('20221114032511'),
('20221113120724'),
('20221113023328'),
('20221112113323'),
('20221102145906'),
('20221102144613'),
('20221025025402'),
('20221024222000'),
('20221024221557'),
('20221024000400'),
('20221024000200'),
('20221024000100'),
('20221024000000'),
('20221020172553'),
('20221019102006'),
('20221005165307'),
('20221001042722'),
('20220925223144'),
('20220925220223'),
('20220925214711'),
('20220902015635'),
('20220822132754'),
('20220822132710'),
('20220822132000'),
('20220819022548'),
('20220818145228'),
('20220818133338'),
('20220816203504'),
('20220816155229'),
('20220815125353'),
('20220811222831'),
('20220808142135'),
('20220808141102'),
('20220805181901'),
('20220803163303'),
('20220722192214'),
('20220722000850'),
('20220721200858'),
('20220721170452'),
('20220719111148'),
('20220714191555'),
('20220714191510'),
('20220714191505'),
('20220714191500'),
('20220713200444'),
('20220713200101'),
('20220630162659'),
('20220630145649'),
('20220625105636'),
('20220613224844'),
('20220601111520'),
('20220527221026'),
('20220525122150'),
('20220509122054'),
('20220428145059'),
('20220422190546'),
('20220420154535'),
('20220420143020'),
('20220417221010'),
('20220417220914'),
('20220417203841'),
('20220414122419'),
('20220414114233'),
('20220414095321'),
('20220413174607'),
('20220413123127'),
('20220323201321'),
('20220323004929'),
('20220323001645'),
('20220323001338'),
('20220316025851'),
('20220215095957'),
('20220214232150'),
('20220214121713'),
('20220213031520'),
('20220122105047'),
('20211216125250'),
('20211214130956'),
('20211121095245'),
('20211119110211'),
('20211119085218'),
('20211117200456'),
('20211024174829'),
('20211024105507'),
('20211024105450'),
('20211024092307'),
('20211020221141'),
('20211019121200'),
('20211011233005'),
('20211011214752'),
('20211010164634'),
('20211008022130'),
('20210924022913'),
('20210921194018'),
('20210921111350'),
('20210825202135'),
('20210823162357'),
('20210823162356'),
('20210730120340'),
('20210728214424'),
('20210728173950'),
('20210727111355'),
('20210716015756'),
('20210709222044'),
('20210709221643'),
('20210619191706'),
('20210617105509'),
('20210616003251'),
('20210614212220'),
('20210614120835'),
('20210609024118'),
('20210608180736'),
('20210604225609'),
('20210601023557'),
('20210601023450'),
('20210531223906'),
('20210524121112'),
('20210514201449'),
('20210509193202'),
('20210505135714'),
('20210501112541'),
('20210501002133'),
('20210430160739'),
('20210428143811'),
('20210419161145'),
('20210417152053'),
('20210416134930'),
('20210414201956'),
('20210406090148'),
('20210406072455'),
('20210405045324'),
('20210403225927'),
('20210403175939'),
('20210403174614'),
('20210401305106'),
('20210401210102'),
('20210401194637'),
('20210329151057'),
('20210328012658'),
('20210318040227'),
('20210318024306'),
('20210312050413'),
('20210312045631'),
('20210311041939'),
('20210311041611'),
('20210308214507'),
('20210308211112'),
('20210308183041'),
('20210305153936'),
('20210305153701'),
('20210305051726'),
('20210226155035'),
('20210226100107'),
('20210225154422'),
('20210206191033'),
('20210202201530'),
('20210202201520'),
('20210202144410'),
('20210201112227'),
('20210201101144'),
('20210121224746'),
('20210121103247'),
('20210121000001'),
('20210120195043'),
('20210120173726'),
('20210120154705'),
('20210120032234'),
('20210119193900'),
('20210119191828'),
('20210118202020'),
('20210118125338'),
('20210118120920'),
('20210117234541'),
('20210117115915'),
('20210116131831'),
('20210116124051'),
('20210116104426'),
('20210116090353'),
('20210115235118'),
('20210115211600'),
('20210115202314'),
('20210114033856'),
('20210114003743'),
('20210113205441'),
('20210113024104'),
('20210112021105'),
('20210111235535'),
('20210109125429'),
('20210108202122'),
('20201231194433'),
('20201230210601'),
('20201214215209'),
('20201205213317'),
('20201205041350'),
('20201201015501'),
('20201130020715'),
('20201124145625'),
('20201124142002'),
('20201124050637'),
('20201124035715'),
('20201121162913'),
('20201119125643'),
('20201031182132'),
('20201030102713'),
('20201021104257'),
('20201020125750'),
('20201016122053'),
('20201013114341'),
('20201009004421'),
('20201008201100'),
('20200930091134'),
('20200930034317'),
('20200929021041'),
('20200923120201'),
('20200922083809'),
('20200921210411'),
('20200921174602'),
('20200921170159'),
('20200921123831'),
('20200920180233'),
('20200920160846'),
('20200919003430'),
('20200916181414'),
('20200916022934'),
('20200915215739'),
('20200912201532'),
('20200912192204'),
('20200912174723'),
('20200912171009'),
('20200912170233'),
('20200912161253'),
('20200912160618'),
('20200912143241'),
('20200912142918'),
('20200911215955'),
('20200911213718'),
('20200910134003'),
('20200909232515'),
('20200909174002'),
('20200909045238'),
('20200909025016'),
('20200909015730'),
('20200907215858'),
('20200907174303'),
('20200907165157'),
('20200810164753'),
('20200807174136'),
('20200807170745'),
('20200807165932'),
('20200807165756'),
('20200807163808'),
('20200807163322'),
('20200807161748'),
('20200807150834'),
('20200807143159'),
('20200807135014'),
('20200807044641'),
('20200806202150'),
('20200805220557'),
('20200805212533'),
('20200805201200'),
('20200805195426'),
('20200805193758'),
('20200804205521'),
('20200804154120'),
('20200803213643'),
('20200803210025'),
('20200803202253'),
('20200802121601'),
('20200802112451'),
('20200727021707'),
('20200723133542'),
('20200722210144'),
('20200722052937'),
('20200722051939'),
('20200722051806'),
('20200722032255'),
('20200722024432'),
('20200722023954'),
('20200721233547'),
('20200721231722'),
('20200721231340'),
('20200721223028'),
('20200721221535'),
('20200720013144'),
('20200720005020'),
('20200713194611'),
('20200713161527'),
('20200713034223'),
('20200713032557'),
('20200712215715'),
('20200711195547'),
('20200711182402'),
('20200711174138'),
('20200710103327'),
('20200706113547'),
('20200622193241'),
('20200601232156'),
('20200601224756'),
('20200527235952'),
('20200527234835'),
('20200527234620'),
('20200522142932'),
('20200519022054'),
('20200430101709'),
('20200427091939'),
('20200423100344'),
('20200422103916'),
('20200415102103'),
('20200415021859'),
('20200411100013'),
('20200411095105'),
('20200411094012'),
('20200410201058'),
('20200409213831'),
('20200409203129'),
('20200331212346'),
('20200331210411'),
('20200331203401'),
('20200330180854'),
('20200330174434'),
('20200327004702'),
('20200326212919'),
('20200324164130'),
('20200320152017'),
('20200319183515'),
('20200314033958'),
('20200302194744'),
('20200229005951'),
('20200228235200'),
('20200227231621'),
('20200224134339'),
('20200221181049'),
('20200212103617'),
('20200211112230'),
('20200211105331'),
('20200116003807'),
('20200115121715'),
('20200115120347'),
('20200113091017'),
('20200109003105'),
('20200108153919'),
('20200106144215'),
('20200106141436'),
('20200105154040'),
('20200104144303'),
('20200104131841'),
('20191231102721'),
('20191219143243'),
('20191219011910'),
('20191209005851'),
('20191208235017'),
('20191208234911'),
('20191208234821'),
('20191208225448'),
('20191208225358'),
('20191208225311'),
('20191208225117'),
('20191206154511'),
('20191205204511'),
('20191205202150'),
('20191205200007'),
('20191127230143'),
('20191127182834'),
('20191127181739'),
('20191127173053'),
('20191116165332'),
('20191116160553'),
('20191116151549'),
('20191105185049'),
('20191016100031'),
('20191012042159'),
('20191012042150'),
('20191012014823'),
('20191012014000'),
('20190926170423'),
('20190926165901'),
('20190926143845'),
('20190926133640'),
('20190926104551'),
('20190926104116'),
('20190924112646'),
('20190924013712'),
('20190830172824'),
('20190818014000'),
('20190818013900'),
('20190818013251'),
('20190805162246'),
('20190804223012'),
('20190726203302'),
('20190718032712'),
('20190715182611'),
('20190715083916'),
('20190703044126'),
('20190625140232'),
('20190625112649'),
('20190618135559'),
('20190613155843'),
('20190613155738'),
('20190612200000'),
('20190612198000'),
('20190612113734'),
('20190612111043'),
('20190612101211'),
('20190605143420'),
('20190603234145'),
('20190603213842'),
('20190430112229'),
('20190426131119'),
('20190426125052'),
('20190418142712'),
('20190418123920'),
('20190418014012'),
('20190418011743'),
('20190406164301'),
('20190406141156'),
('20190403202049'),
('20190401175521'),
('20190331111015'),
('20190326150948'),
('20190322102311'),
('20190308195346'),
('20190225143501'),
('20190208103518'),
('20190206005635'),
('20190205203619'),
('20190128032125'),
('20190116133230'),
('20190111102201'),
('20190111092816'),
('20190110191802'),
('20190109125417'),
('20181228014507'),
('20181227210510'),
('20181227114431'),
('20181227100523'),
('20181227095037'),
('20181227094559'),
('20181227093834'),
('20181224112813'),
('20181219085236'),
('20181218215222'),
('20181218165559'),
('20181218165548'),
('20181213103204'),
('20181206143039'),
('20181130112320'),
('20181126222648'),
('20181126221928'),
('20181126220625'),
('20181126203615'),
('20181126200244'),
('20181119172200'),
('20181113025055'),
('20181111181411'),
('20181030135202'),
('20181030130433'),
('20181030103838'),
('20181029100626'),
('20181029095750'),
('20181029094903'),
('20181029094031'),
('20181029084908'),
('20181026113302'),
('20181026105324'),
('20181018003945'),
('20181017094456'),
('20181012110629'),
('20181011104537'),
('20181008100023'),
('20180921120954'),
('20180920031351'),
('20180918195821'),
('20180918195008'),
('20180917072914'),
('20180914170936'),
('20180914153010'),
('20180912114413'),
('20180910132139'),
('20180905031617'),
('20180905031342'),
('20180813110808'),
('20180812220011'),
('20180810221619'),
('20180810220807'),
('20180801105304'),
('20180726234755'),
('20180726213123'),
('20180724202353'),
('20180724135332'),
('20180720171842'),
('20180720140443'),
('20180719015902'),
('20180718094829'),
('20180717135811'),
('20180717134314'),
('20180627031905'),
('20180626123640'),
('20180612030340'),
('20180612024009'),
('20180611222635'),
('20180601104012'),
('20180601093421'),
('20180519102415'),
('20180509111948'),
('20180427194732'),
('20180418094727'),
('20180320230847'),
('20180319015743'),
('20180312183214'),
('20180307125759'),
('20180225152848'),
('20180223091622'),
('20180220104234'),
('20180220103644'),
('20180219032546'),
('20180212223621'),
('20180126055129'),
('20180126035129'),
('20171217135318'),
('20171212001011'),
('20171130133741'),
('20171130125044'),
('20171128234148'),
('20171019133203'),
('20171011213548'),
('20171011213405'),
('20171011213037'),
('20171011212156'),
('20171010104604'),
('20171003110007'),
('20170925113912'),
('20170829135450'),
('20170829132710'),
('20170814110031'),
('20170725042806'),
('20170718011726'),
('20170712205819'),
('20170609131212'),
('20170607125033'),
('20170529154413'),
('20170529020218'),
('20170526131129'),
('20170526124219'),
('20170526100040'),
('20170503145808'),
('20170414035328'),
('20170413185012'),
('20170406213334'),
('20170405104322'),
('20161212175928'),
('20161130233916'),
('20161130230358'),
('20161129142319'),
('20161117134414'),
('20161108102349'),
('20161103083352'),
('20161103081041'),
('20161103080156'),
('20161028214858'),
('20161027233011'),
('20161027101509'),
('20161026110802'),
('20161010152631'),
('20161009111443'),
('20160921112808'),
('20160805103310'),
('20160802134021'),
('20160725131347'),
('20160725125929'),
('20160725123242'),
('20160724164110'),
('20160724160049'),
('20160719214520'),
('20160719195853'),
('20160628110301'),
('20160627130141'),
('20160627113500'),
('20160519195544'),
('20160518025044'),
('20160316100626'),
('20160316100625'),
('20160316100624'),
('20160316100623'),
('20160316100622'),
('20160316100621'),
('20160316100620'),
('20160316094627'),
('20160316093659'),
('20160308213334'),
('20151130101417'),
('20151127102425'),
('20151124110943'),
('20151030181131'),
('20151030154458'),
('20151030154449'),
('20151030094611'),
('20151022103115'),
('20151020203421'),
('20151020203420'),
('20151006105402'),
('20150929112313'),
('20150826000000'),
('20150819122835'),
('20150809032138'),
('20150803082520'),
('20150724024110'),
('20150724003736'),
('20150723110322'),
('20150722233211'),
('20150722231825'),
('20150722113654'),
('20150720120236'),
('20150720115701'),
('20150718213611'),
('20150717161539'),
('20150717101243'),
('20150716192356'),
('20150716171420'),
('20150716085420'),
('20150710114451'),
('20150710012947'),
('20150709203137'),
('20150707164448'),
('20150702224217'),
('20150628104015'),
('20150626211501'),
('20150624200701'),
('20150616100551'),
('20150616100351'),
('20150616095023'),
('20150615030659'),
('20150615024318'),
('20150612203808'),
('20150609094820'),
('20150609094809'),
('20150604155923'),
('20150604102321'),
('20150604101858'),
('20150603181900'),
('20150602104342'),
('20150602095241'),
('20150602094513'),
('20150528100944'),
('20150521191227'),
('20150521181918'),
('20150521092657'),
('20150520115257'),
('20150513160835'),
('20150513130510'),
('20150513130058'),
('20150513112126'),
('20150510130031'),
('20150510125926'),
('20150503120915'),
('20150420200255'),
('20150420153835'),
('20150420125522'),
('20150420110000'),
('20150420104520'),
('20150419000000'),
('20150417180314'),
('20150417180000'),
('20150417071153'),
('20150416101228'),
('20150416095646'),
('20150416090140'),
('20150416074423'),
('20150413160159'),
('20150413160158'),
('20150413160157'),
('20150413160156'),
('20150413000000'),
('20150317090631'),
('20150317084737'),
('20150317084149'),
('20150314122808'),
('20150313153722'),
('20150225141729'),
('20150225140336'),
('20150224085334'),
('20150224083945'),
('20150217185859'),
('20150213114933'),
('20141225174739'),
('20141222174267'),
('20141222174257'),
('20141222174247'),
('20141222174237'),
('20141126085907'),
('20141112111129'),
('20141111203313'),
('20141111120432'),
('20141111120431'),
('20141111120430'),
('20141111102451'),
('20141009131427'),
('20141009002211'),
('20141008112530'),
('20141008105803'),
('20141002140242'),
('20140923143242'),
('20140922110956'),
('20140922102737'),
('20140918115412'),
('20140912141913'),
('20140909165233'),
('20140909141336'),
('20140904213327'),
('20140904211823'),
('20140904033941'),
('20140902101425'),
('20140901106000'),
('20140901105741'),
('20140827142659'),
('20140815124606'),
('20140815124157'),
('20140815123542'),
('20140815121224'),
('20140815111352'),
('20140815111351'),
('20140804210000'),
('20140804202958'),
('20140804202101'),
('20140804202100'),
('20140804200235'),
('20140804194616'),
('20140704035033'),
('20140613044320'),
('20140528043115'),
('20140527110223'),
('20140518120059'),
('20140514142421'),
('20140313012209'),
('20140211172443'),
('20140211164659'),
('20140211162355'),
('20140207102739'),
('20140207102709'),
('20140129151136'),
('20140117212555'),
('20131223175141'),
('20131220103409'),
('20131210221541'),
('20131206081531'),
('20131204183530'),
('20131204143718'),
('20131204140000'),
('20131204135932'),
('20131128151014');

