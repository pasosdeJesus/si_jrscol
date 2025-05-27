# frozen_string_literal: true

module Msip
  class Reporterepetido
    include ActiveModel::Model
    attr_accessor :fechaini
    attr_accessor :fechafin
    attr_accessor :deduplicables_autom
  end
end
