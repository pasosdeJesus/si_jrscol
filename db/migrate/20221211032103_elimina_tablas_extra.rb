# frozen_string_literal: true

class EliminaTablasExtra < ActiveRecord::Migration[7.0]
  def up
    execute(<<~SQL)
      DROP TABLE IF EXISTS taccion;
      DROP SEQUENCE IF EXISTS taccion_seq;
      DROP TABLE IF EXISTS tproceso;
      DROP SEQUENCE IF EXISTS tproceso_seq;
      DROP TABLE IF EXISTS tmpactvl;
    SQL
  end

  def down
  end
end
