class ReporteNinosconflicto < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      INSERT INTO public.heb412_gen_plantillahcm (id, ruta, fuente, 
        licencia, vista, nombremenu, filainicial) VALUES 
        (56, 'Plantillas/violencias_contra_nna.ods', 'PdJ', 
          'Dominio Publico', 'Consninovictima', 
          'Reporte de violencias contra NNA (Excel)', 5);
      DROP MATERIALIZED VIEW IF EXISTS consninovictima;
    SQL
  end
  def down
    execute <<-SQL
      DELETE FROM public.heb412_gen_plantillahcm WHERE id=56;
    SQL
  end
end
