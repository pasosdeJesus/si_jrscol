module Sivel2Sjr
  # Ayudas del JRS
  class Ayudasjr < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_ayudasjr"

    has_many :ayudasjr_respuesta, class_name: "Sivel2Sjr::AyudasjrRespuesta", 
      foreign_key: "ayudasjr_id", validate: true, dependent: :destroy
    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      :through => :ayudasjr_respuesta

    has_and_belongs_to_many :derecho,
      class_name: 'Sivel2Sjr::Derecho',
      foreign_key: 'ayudasjr_id',
      association_foreign_key: 'derecho_id',
      join_table: 'sivel2_sjr_ayudasjr_derecho'

    before_destroy :confirmar_ayudasjr_derecho

    private

    # No ha operado
    def confirmar_ayudasjr_derecho
      if Sivel2Sjr::AyudasjrRespuesta.where(ayudasjr_id: id).take 
        errors.add(:base, "hay respuestas con esta ayuda humanitaria")
        return false
      end
      return true
    end

  end
end
