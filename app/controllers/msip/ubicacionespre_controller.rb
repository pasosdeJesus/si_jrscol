require 'msip/concerns/controllers/ubicacionespre_controller'

module Msip
  class UbicacionespreController < Msip::ModelosController

    before_action :set_ubicacionpre, only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: Msip::Ubicacionpre

    include Msip::Concerns::Controllers::UbicacionespreController

    def index
      @ubicacionespre = Msip::Ubicacionpre.all
      respond_to do |format|
        format.json { render :json, inline: @ubicacionespre.to_json }
      end
    end

    def lugar
      if params[:term]
        term = Msip::Ubicacion.connection.quote_string(params[:term])
        consNomubi = term.downcase.strip #sin_tildes
        consNomubi.gsub!(/ +/, ":* & ")
        if consNomubi.length > 0
          consNomubi+= ":*"
        end
        pais = "AND pais_id=#{params[:pais].to_i}"
        dep = "AND departamento_id=#{params[:dep].to_i}"
        mun = "AND municipio_id=#{params[:mun].to_i}"
        clas = params[:clas] && params[:clas] != '' && params[:clas] != '0' ? 
          "AND centropoblado_id=#{params[:clas].to_i}" : ""
        # Usamos la funcion f_unaccent definida con el indice
        # en db/migrate/20200916022934_indice_ubicacionpre.rb
        where = " to_tsvector('spanish', " +
          "f_unaccent(ubicacionpre.nombre)) " +
          "@@ to_tsquery('spanish', '#{consNomubi}')";

        cons = "SELECT TRIM(nombre) AS value, pais_id, departamento_id, "\
          "municipio_id, centropoblado_id, tsitio_id, lugar, sitio, "\
          "latitud, longitud "\
          "FROM public.msip_ubicacionpre AS ubicacionpre "\
          "WHERE #{where} #{pais} #{dep} #{mun} #{clas} " \
          "ORDER BY 1 LIMIT 10"
        puts "OJO cons=\n#{cons}"
        #debugger
        r = ActiveRecord::Base.connection.select_all cons
        respond_to do |format|
          format.json { render :json, inline: r.to_json }
          format.html { render inline: 'No responde con parametro term' }
        end
      end
    end
  end
end

