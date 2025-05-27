# frozen_string_literal: true

class DocsidsecundarioController < ApplicationController
  load_and_authorize_resource class: ::Docidsecundario
  before_action :preparar_persona

  def create
    respond_to do |formato|
      formato.turbo_stream do
        render(:create)
      end
    end
  end

  def destroy
  end

  def preparar_persona
    @registro = @persona =
      Msip::Persona.new(docidsecundario: [Docidsecundario.new])
  end
end
