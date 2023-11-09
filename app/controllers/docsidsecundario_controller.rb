class DocsidsecundarioController < ApplicationController
  load_and_authorize_resource class: ::Docidsecundario
  before_action :preparar_persona

  def destroy
  end

  def create
    respond_to do |formato| 
      formato.turbo_stream {
        render :create
      }
    end
  end

  def preparar_persona
    @registro = @persona = 
      Msip::Persona.new(docidsecundario: [Docidsecundario.new])
  end

end 
