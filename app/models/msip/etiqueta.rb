
require 'msip/concerns/models/etiqueta'

module Msip
  class Etiqueta < ActiveRecord::Base
    include Msip::Concerns::Models::Etiqueta

  end
end
