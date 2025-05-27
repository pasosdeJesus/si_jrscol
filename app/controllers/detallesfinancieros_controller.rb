# frozen_string_literal: true

class DetallesfinancierosController < ApplicationController
  include ActionView::Helpers::AssetUrlHelper

  # Authorize en cada función

  # Responde a requerimiento AJAX generado por cocoon creando una
  # nueva fuente de prensa para el caso que recibe por parametro
  # params[:caso_id].  Pone valores simples en los campos requeridos
  def nuevo
    authorize!(:new, Cor1440Gen::Actividad)
    if !params[:actividad_id].nil?
      @detfinanciero = Detallefinanciero.new
      @detfinanciero.actividad_id = params[:actividad_id]
      if @detfinanciero.save(validate: false)
        respond_to do |format|
          format.js { render(text: @detfinanciero.id.to_s) }
          format.json do
            render(
              json: @detfinanciero.id.to_s,
              status: :created,
            )
          end
          format.html { render(inline: @detfinanciero.id.to_s) }
        end
      else
        respond_to do |format|
          format.html do
            render(inline: "No pudo crear fuente frecuente: " +
              "'#{@detfinanciero.errors.message}'")
          end
          format.json do
            render(
              json: @detfinanciero.errors,
              status: :unprocessable_entity,
            )
          end
        end
      end
    else
      respond_to do |format|
        format.html { render(inline: "Falta identificacion de la actividad") }
      end
    end
  end # def nuevo
end
