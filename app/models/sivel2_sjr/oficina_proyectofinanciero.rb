module Sivel2Sjr
  # Obsoleto
  class OficinaProyectofinanciero < ActiveRecord::Base

    self.table_name = "sivel2_sjr_oficina_proyectofinanciero"

    belongs_to :oficina, class_name: 'Msip::Oficina',
      foreign_key: 'oficina_id', optional: false
    belongs_to :proyectofinanciero, 
      class_name: 'Cor1440Gen::Proyectofinanciero', 
      foreign_key: 'proyectofinanciero_id', optional: false
  end
end
