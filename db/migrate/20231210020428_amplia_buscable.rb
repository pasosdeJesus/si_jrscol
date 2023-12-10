class AmpliaBuscable < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP TRIGGER IF EXISTS msip_persona_actualiza_buscable ON msip_persona;
      CREATE OR REPLACE FUNCTION public.msip_persona_buscable_trigger() RETURNS trigger
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
      CREATE TRIGGER msip_persona_actualiza_buscable 
        BEFORE INSERT OR UPDATE 
        ON public.msip_persona 
        FOR EACH ROW 
        EXECUTE FUNCTION public.msip_persona_buscable_trigger();

      DROP TRIGGER IF EXISTS docidsecundario_actualiza_buscable ON docidsecundario;
      CREATE OR REPLACE FUNCTION public.docidsecundario_actualiza_buscable_trigger() RETURNS trigger
      LANGUAGE plpgsql
      AS $$
        begin
          UPDATE msip_persona SET
            numerodocumento = numerodocumento 
            WHERE id = new.persona_id; -- Lanza otro trigger
          RETURN new;
        end
        $$;
      CREATE TRIGGER docidsecundario_actualiza_buscable 
        AFTER INSERT OR UPDATE
        ON public.docidsecundario
        FOR EACH ROW 
        EXECUTE FUNCTION public.docidsecundario_actualiza_buscable_trigger();

      DROP TRIGGER IF EXISTS docidsecundario_elimina_buscable ON docidsecundario;
      CREATE OR REPLACE FUNCTION public.docidsecundario_elimina_buscable_trigger() RETURNS trigger
      LANGUAGE plpgsql
      AS $$
        begin
          UPDATE msip_persona SET
            numerodocumento = numerodocumento 
            WHERE id = old.persona_id; -- Lanza otro trigger
          RETURN old;
        end
        $$;
      CREATE TRIGGER docidsecundario_elimina_buscable 
        AFTER DELETE
        ON public.docidsecundario
        FOR EACH ROW 
        EXECUTE FUNCTION public.docidsecundario_elimina_buscable_trigger();


      UPDATE msip_persona SET
        numerodocumento = numerodocumento || ''
        WHERE id IN (SELECT persona_id FROM docidsecundario);
    SQL
  end
  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS msip_persona_actualiza_buscable ON msip_persona;
      CREATE OR REPLACE FUNCTION public.msip_persona_buscable_trigger() RETURNS trigger
      LANGUAGE plpgsql
      AS $$
        begin
          new.buscable := to_tsvector('spanish', 
            es_unaccent(new.nombres) ||
            ' ' || es_unaccent(new.apellidos) || 
            ' ' || COALESCE(new.numerodocumento::TEXT, ''));
          return new;
        end
        $$;
      CREATE TRIGGER msip_persona_actualiza_buscable 
        BEFORE INSERT OR UPDATE 
        ON public.msip_persona 
        FOR EACH ROW 
        EXECUTE FUNCTION public.msip_persona_buscable_trigger();

      DROP TRIGGER IF EXISTS docidsecundario_elimina_buscable ON docidsecundario;
      DROP TRIGGER IF EXISTS docidsecundario_actualiza_buscable ON docidsecundario;
      UPDATE msip_persona SET
        numerodocumento = numerodocumento || ''
        WHERE id IN (SELECT persona_id FROM docidsecundario);
    SQL
  end
end
