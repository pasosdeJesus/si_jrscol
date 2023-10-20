class Sivel2Sjr::ActividadCasosjr < ActiveRecord::Base

  include Msip::Modelo

  belongs_to :actividad, class_name: 'Cor1440Gen::Actividad',
    foreign_key: 'actividad_id', validate: true, optional: false
  belongs_to :casosjr, class_name: 'Sivel2Sjr::Casosjr',
    foreign_key: 'casosjr_id', validate: true, optional: false
  accepts_nested_attributes_for :casosjr, reject_if: :all_blank 


  validates :actividad, presence: true
  validates :casosjr, presence: true


end
