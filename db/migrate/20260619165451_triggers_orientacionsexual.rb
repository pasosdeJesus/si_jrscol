class TriggersOrientacionsexual < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      -- Trigger para cor1440_gen_asistencia
      CREATE OR REPLACE FUNCTION sincronizar_orientacionsexual_asistencia()
      RETURNS TRIGGER AS $$
      DECLARE
          persona_ultima CHAR(1);
      BEGIN
          SELECT ultimaorientacionsexual INTO persona_ultima
          FROM msip_persona
          WHERE id = NEW.persona_id;

          IF TG_OP = 'INSERT' THEN
              IF NEW.orientacionsexual = 'S' AND persona_ultima != 'S' THEN
                  NEW.orientacionsexual := persona_ultima;
              END IF;
              RETURN NEW;
          ELSIF TG_OP = 'UPDATE' THEN
              IF OLD.orientacionsexual IS DISTINCT FROM NEW.orientacionsexual THEN
                  IF persona_ultima = 'S' THEN
                      UPDATE msip_persona 
                      SET ultimaorientacionsexual = NEW.orientacionsexual,
                          updated_at = NOW()
                      WHERE id = NEW.persona_id;
                  END IF;
              END IF;
              RETURN NEW;
          END IF;
          RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      DROP TRIGGER IF EXISTS sincronizar_orientacionsexual_asistencia_trigger ON cor1440_gen_asistencia;
      CREATE TRIGGER sincronizar_orientacionsexual_asistencia_trigger
      BEFORE INSERT OR UPDATE OF orientacionsexual ON cor1440_gen_asistencia
      FOR EACH ROW
      EXECUTE FUNCTION sincronizar_orientacionsexual_asistencia();

      -- Trigger para sivel2_gen_victima
      CREATE OR REPLACE FUNCTION sincronizar_orientacionsexual_victima()
      RETURNS TRIGGER AS $$
      DECLARE
          persona_ultima CHAR(1);
      BEGIN
          SELECT ultimaorientacionsexual INTO persona_ultima
          FROM msip_persona
          WHERE id = NEW.persona_id;

          IF TG_OP = 'INSERT' THEN
              IF NEW.orientacionsexual = 'S' AND persona_ultima != 'S' THEN
                  NEW.orientacionsexual := persona_ultima;
              END IF;
              RETURN NEW;
          ELSIF TG_OP = 'UPDATE' THEN
              IF OLD.orientacionsexual IS DISTINCT FROM NEW.orientacionsexual THEN
                  IF persona_ultima = 'S' THEN
                      UPDATE msip_persona 
                      SET ultimaorientacionsexual = NEW.orientacionsexual,
                          updated_at = NOW()
                      WHERE id = NEW.persona_id;
                  END IF;
              END IF;
              RETURN NEW;
          END IF;
          RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      DROP TRIGGER IF EXISTS sincronizar_orientacionsexual_victima_trigger ON sivel2_gen_victima;
      CREATE TRIGGER sincronizar_orientacionsexual_victima_trigger
      BEFORE INSERT OR UPDATE OF orientacionsexual ON sivel2_gen_victima
      FOR EACH ROW
      EXECUTE FUNCTION sincronizar_orientacionsexual_victima();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS sincronizar_orientacionsexual_asistencia_trigger ON cor1440_gen_asistencia;
      DROP FUNCTION IF EXISTS sincronizar_orientacionsexual_asistencia();

      DROP TRIGGER IF EXISTS sincronizar_orientacionsexual_victima_trigger ON sivel2_gen_victima;
      DROP FUNCTION IF EXISTS sincronizar_orientacionsexual_victima();
    SQL
  end
end
