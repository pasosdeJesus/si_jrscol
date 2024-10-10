module Sivel2Gen
  # Relación n:n entre Anexo y Víctima
  class AnexoVictima < ActiveRecord::Base

    include Msip::Modelo
    include Msip::Localizacion
    include Msip::FormatoFechaHelper

    belongs_to :victima, foreign_key: "victima_id", validate: true, 
      class_name: "Sivel2Gen::Victima", inverse_of: :anexo_victima, 
      optional: false
    belongs_to :msip_anexo, foreign_key: "anexo_id", validate: true, 
      class_name: "Msip::Anexo", optional: false
    accepts_nested_attributes_for :msip_anexo, reject_if: :all_blank


    campofecha_localizado :fecha

    validates :victima, presence: true
    validates :msip_anexo, presence: true
    validates :fecha, presence: true
  end
end
