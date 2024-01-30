#require 'sivel2_gen/application_controller'
class InterfazController < ApplicationController

  # No requiere autorización 
  #
  def fichacasovertical
    if session[:capturacaso_acordeon]
        session[:capturacaso_acordeon] = false
    else
        session[:capturacaso_acordeon] = true
    end
    redirect_to root_path
  end
end

