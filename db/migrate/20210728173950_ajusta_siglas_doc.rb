class AjustaSiglasDoc < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      UPDATE sip_tdocumento SET sigla='CON' WHERE id=5;
      UPDATE sip_tdocumento SET sigla='CE' WHERE id=13;
      UPDATE sip_tdocumento SET sigla='ANV' WHERE id=15;
    SQL
  end
  def down
    execute <<-SQL
      UPDATE sip_tdocumento SET sigla='CT' WHERE id=5;
      UPDATE sip_tdocumento SET sigla='' WHERE id=13;
      UPDATE sip_tdocumento SET sigla='AN' WHERE id=15;
    SQL
  end
end
