module Sivel2Sjr
  class CategoriaDesplazamiento < ActiveRecord::Base
    belongs_to :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "desplazamiento_id", optional: false
    belongs_to :categoria, class_name: "Sivel2Gen::Categoria", 
      foreign_key: "categoria_id", optional: false
  end
end
