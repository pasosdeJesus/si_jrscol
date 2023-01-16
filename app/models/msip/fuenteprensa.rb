require 'sal7711_gen/concerns/models/fuenteprensa'
require 'sivel2_gen/concerns/models/fuenteprensa'

module Msip
  class Fuenteprensa < ActiveRecord::Base
    include Sivel2Gen::Concerns::Models::Fuenteprensa
    include Sal7711Gen::Concerns::Models::Fuenteprensa
  end
end
