class ActosninosController < ApplicationController
  load_and_authorize_resource class: ::Actonino

  include ActionView::Helpers::AssetUrlHelper

  def destroy
    @problema = ""
    if !params[:id]
      return
    end
    @actonino = ::Actonino.find(params[:id])
    @caso = @actonino.caso
    @actonino.destroy
  end

  def create
    prepara_nuevo
    @problema = "".dup
    if !params["caso_id"] || 
        Sivel2Gen::Caso.where(id: params["caso_id"]).count == 0
      @problema << "Falta caso_id"
    else
      @caso = Sivel2Gen::Caso.find(params["caso_id"])
    end
    if !params || !params[:caso] || !params[:caso][:actonino] ||
        !params[:caso][:actonino][:fecha]
      @problema << "Falta Fecha.\n "
    end
    if !params || !params[:caso] || !params[:caso][:actonino] ||
        !params[:caso][:actonino][:ubicacionpre_id]
      @problema << "Falta Municipio.\n "
    end
    if !params || !params[:caso] || !params[:caso][:actonino] ||
        !params[:caso][:actonino][:presponsable_id]
      @problema << "Falta P. Responsable.\n "
    end
    if !params || !params[:caso] || !params[:caso][:actonino] ||
        !params[:caso][:actonino][:categoria_id]
      @problema << "Falta Categoría.\n "
    end
    if !params || !params[:caso] || !params[:caso][:actonino] ||
        !params[:caso][:actonino][:persona_id]
      @problema << "Falta Víctima.\n "
    end

    if @problema == ''
      acto = ::Actonino.new(
        fecha: params[:caso][:actonino][:fecha],
        ubicacionpre_id: params[:caso][:actonino][:ubicacionpre_id],
        presponsable_id: params[:caso][:actonino][:presponsable_id],
        categoria_id: params[:caso][:actonino][:categoria_id],
        persona_id: params[:caso][:actonino][:persona_id],
        caso_id: params["caso_id"]
      )
      if acto.valid?
        acto.save
        params[:caso].delete(:actonino)
      else
        acto.errors.messages.each do |l,v|
          @problema << "#{l.to_s}: #{v.join('. ')}.\n"
        end
      end
    end

  end

  private

  def prepara_nuevo
    @registro = @acto = ::Actonino.new
    @caso = Sivel2Gen::Caso.new(
      actonino: [@acto]
    )
  end

end 
