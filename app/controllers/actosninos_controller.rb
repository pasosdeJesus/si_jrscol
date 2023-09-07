class ActosninosController < ApplicationController
  load_and_authorize_resource class: ::Actonino

  include ActionView::Helpers::AssetUrlHelper

  def destroy
  end

  def create
    prepara_nuevo
    if !params["caso_id"] || 
        Sivel2Gen::Caso.where(id: params["caso_id"]).count == 0
      return
    end
    @caso = Sivel2Gen::Caso.find(params["caso_id"])
  end

  private

  def prepara_nuevo
    @registro = @acto = ::Actonino.new
    @caso = Sivel2Gen::Caso.new(
      actonino: [@acto]
    )
  end

end 
