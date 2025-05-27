# frozen_string_literal: true

module Sivel2Sjr
  # Obsoleto
  class Idioma < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_idioma"
  end
end
