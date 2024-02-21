class ElimConsexpcasoFeb24 < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      DROP MATERIALIZED VIEW sivel2_gen_consexpcaso CASCADE;
    SQL
  end
  def down
    execute <<-SQL
      DROP MATERIALIZED VIEW sivel2_gen_consexpcaso CASCADE;
    SQL
  end
end
