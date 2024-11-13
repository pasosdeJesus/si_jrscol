module Sivel2Gen
  # Relación n:n entre Anexo y Víctima
  class AnexoVictima < ActiveRecord::Base

    include Msip::Modelo
    include Msip::Localizacion
    include Msip::FormatoFechaHelper

    belongs_to :victima, 
      class_name: "Sivel2Gen::Victima", 
      foreign_key: "victima_id", 
      inverse_of: :anexo_victima, 
      optional: false,
      validate: true
    belongs_to :msip_anexo,
      class_name: "Msip::Anexo", 
      foreign_key: "anexo_id", 
      optional: false,
      validate: true
    belongs_to :tipoanexo,
      class_name: "Msip::Tipoanexo", 
      foreign_key: "tipoanexo_id", 
      optional: true

    accepts_nested_attributes_for :msip_anexo, reject_if: :all_blank


    campofecha_localizado :fecha

    validates :victima, presence: true
    validates :msip_anexo, presence: true
    validates :fecha, presence: true
  end
end
