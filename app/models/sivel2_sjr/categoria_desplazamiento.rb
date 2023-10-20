module Sivel2Sjr
  class CategoriaDesplazamiento < ActiveRecord::Base

    self.table_name = "sivel2_sjr_categoria_desplazamiento"

    belongs_to :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "desplazamiento_id", optional: false
    belongs_to :categoria, class_name: "Sivel2Gen::Categoria", 
      foreign_key: "categoria_id", optional: false
  end
end
