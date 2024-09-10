# frozen_string_literal: true

require "msip/concerns/models/sectororgsocial"

module Msip
  # Población relacionada con una organización social.
  class Sectororgsocial < ActiveRecord::Base
    include Msip::Concerns::Models::Sectororgsocial
  end
end
