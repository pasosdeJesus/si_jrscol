
require 'sivel2_gen/concerns/models/presponsable'

module Sivel2Gen
  class Presponsable < ActiveRecord::Base
    include Sivel2Gen::Concerns::Models::Presponsable

    scope :filtro_nombre_res1612, lambda {|n|
      where("unaccent(sivel2_gen_presponsable.nombre_res1612) "\
            "ILIKE '%' || unaccent(?) || '%'", n)
    }

  end
end
