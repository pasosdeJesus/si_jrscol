# frozen_string_literal: true

class PoblacionSexoO < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      CREATE OR REPLACE PROCEDURE public.cor1440_gen_recalcular_poblacion_actividad(IN par_actividad_id bigint)
      LANGUAGE plpgsql AS $$
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
    SQL
  end

  def down
    remove_column(:cor1440_gen_actividad_rangoedadac, :i)
    execute(<<-SQL)
      CREATE OR REPLACE PROCEDURE public.cor1440_gen_recalcular_poblacion_actividad(IN par_actividad_id bigint)
      LANGUAGE plpgsql AS $$
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
            WHEN 'I' THEN
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
    SQL
  end
end
