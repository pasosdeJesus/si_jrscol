require 'sivel2_gen/concerns/controllers/victimas_controller'

module Sivel2Gen
  class VictimasController < ApplicationController
    include Sivel2Gen::Concerns::Controllers::VictimasController

    load_and_authorize_resource class: Sivel2Gen::Victima

    # Crea un nuevo registro para el caso que recibe por parametro 
    # params[:caso_id].  Pone valores simples en los campos requeridos
    def nuevo
      if !params[:caso_id].nil?
        @persona = Msip::Persona.new
        @victima = Sivel2Gen::Victima.new
        @victimasjr = Sivel2Sjr::Victimasjr.new
        @persona.nombres = 'N'
        @persona.apellidos = 'N'
        @persona.sexo = Msip::Persona::convencion_sexo[:sexo_sininformacion]
        @persona.tdocumento_id = 11
        if !@persona.save(validate: false)
          respond_to do |format|
            format.html { render inline: 'No pudo crear persona' }
          end
          return
        end
        @victima.caso_id = params[:caso_id]
        @victima.persona_id = @persona.id
        @victima.victimasjr = @victimasjr
        if @victima.save(validate: false)
          respond_to do |format|
            format.js { render json: {'victima' => @victima.id.to_s,
              'persona' => @persona.id.to_s} }
            format.json { render json: {'victima' => @victima.id.to_s,
              'persona' => @persona.id.to_s}, status: :created }
            format.html { render json: {'victima' => @victima.id.to_s,
              'persona' => @persona.id.to_s} }
          end
        else
          respond_to do |format|
            format.html { render action: "error" }
            format.json { render json: @victima.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html { render inline: 'Falta identificacion del caso' }
        end
      end
    end
  end
end
