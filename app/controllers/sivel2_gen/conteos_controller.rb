require 'sivel2_gen/concerns/controllers/conteos_controller'

module Sivel2Gen
  class ConteosController < ApplicationController

    # Autorización en cada función 
    include Sivel2Gen::Concerns::Controllers::ConteosController

  end
end
