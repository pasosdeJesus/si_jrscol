class RepBeneficiariosCaosAct < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      INSERT INTO heb412_gen_plantillahcm 
      (id, ruta, fuente, licencia, vista, nombremenu, filainicial)
      VALUES (55, 'Plantillas/BeneficiariosConCasosYActividades.xlsx', '',
      '', 'Consbenefactcaso', 
      'Beneficiarios con Casos y Actividades -- solo en XLSX', 7);
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM heb412_gen_plantillahcm WHERE id=55;
    SQL
  end

end
