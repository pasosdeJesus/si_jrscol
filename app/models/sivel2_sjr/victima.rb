require 'sivel2_gen/concerns/models/victima'

class Sivel2Sjr::Victima < ActiveRecord::Base
  include Sivel2Gen::Concerns::Models::Victima

  has_many :anexo_victima, foreign_key: 'victima_id', validate: true, dependent: :destroy, class_name: 'Sivel2Gen::AnexoVictima',
    inverse_of: :victima
  has_many :msip_anexo, :through => :anexo_victima, 
    class_name: 'Msip::Anexo'

  accepts_nested_attributes_for :anexo_victima, reject_if: :all_blank,
    update_only: true

end
