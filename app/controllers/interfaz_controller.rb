# frozen_string_literal: true

# require 'sivel2_gen/application_controller'
class InterfazController < ApplicationController
  # No requiere autorización
  #
  def fichacasovertical
    session[:capturacaso_acordeon] = if session[:capturacaso_acordeon]
      false
    else
      true
    end
    redirect_to(root_path)
  end
end
