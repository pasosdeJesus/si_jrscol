module Sivel2Sjr
  # Obsoleto
  class ActividadCasosjr < ActiveRecord::Base

    include Msip::Modelo

    self.table_name = "sivel2_sjr_actividad_casosjr"

    belongs_to :actividad, class_name: 'Cor1440Gen::Actividad',
      foreign_key: 'actividad_id', validate: true, optional: false
    belongs_to :casosjr, class_name: 'Sivel2Sjr::Casosjr',
      foreign_key: 'casosjr_id', validate: true, optional: false
    accepts_nested_attributes_for :casosjr, reject_if: :all_blank 


    validates :actividad, presence: true
    validates :casosjr, presence: true


  end
end
