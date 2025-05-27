# frozen_string_literal: true

class EliminaMotivoconsulta < ActiveRecord::Migration[7.2]
  def up
    drop_table(:sivel2_sjr_motivoconsulta)
  end
end
