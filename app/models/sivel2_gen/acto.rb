require 'sivel2_gen/concerns/models/acto'

class Sivel2Gen::Acto < ActiveRecord::Base
  include Sivel2Gen::Concerns::Models::Acto

  has_one :actosjr, class_name: 'Sivel2Sjr::Actosjr',
    foreign_key: "acto_id", dependent: :delete, inverse_of: :acto
  accepts_nested_attributes_for :actosjr

end

