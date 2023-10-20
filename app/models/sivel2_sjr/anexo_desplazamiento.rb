module Sivel2Sjr
  class AnexoDesplazamiento < ActiveRecord::Base

    include Msip::Localizacion
    include Msip::FormatoFechaHelper

    self.table_name = "sivel2_sjr_anexo_desplazamiento"

    belongs_to :desplazamiento, foreign_key: "desplazamiento_id", validate: true, 
      class_name: "Sivel2Sjr::Desplazamiento", 
      inverse_of: :anexo_desplazamiento, optional: false
    belongs_to :msip_anexo, foreign_key: "anexo_id", validate: true, 
      class_name: "Msip::Anexo", optional: false
    accepts_nested_attributes_for :msip_anexo, reject_if: :all_blank


    campofecha_localizado :fecha

    validates :desplazamiento, presence: true
    validates :msip_anexo, presence: true
    validates :fecha, presence: true
  end
end
