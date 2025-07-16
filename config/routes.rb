# frozen_string_literal: true

Rails.application.routes.draw do
  devise_scope :usuario do
    get "sign_out" => "sessions#destroy"
    get "salir" => "sessions#destroy", as: :terminar_sesion

    get "usuarios/iniciar_sesion",
      to: "sessions#new",
      as: :iniciar_sesion

    post "usuarios/iniciar_sesion", to: "sessions#create"
    # La anterior por si acaso porque en rails 7.1 y devise 4.9.3
    #   internamente se llama la siguiente
    post "usuarios/sign_in", to: "sessions#create"
  end

  # Permite a un usuario gestionar sus datos
  devise_for :usuarios, skip: [:registrations], module: :devise
  as :usuario do
    get "usuarios/edit" => "devise/registrations#edit",
      :as => "editar_registro_usuario"
    put "usuarios/:id" => "devise/registrations#update",
      :as => "registro_usuario"
  end

  resources :usuarios, path_names: { new: "nuevo", edit: "edita" }

  # De sivel2_sjr

  # patch '/actos/agregar' => 'sivel2_sjr/actos#agregar'
  # get '/actos/eliminar' => 'sivel2_sjr/actos#eliminar'

  get "/casos/lista" => "sivel2_sjr/casos#lista"
  get "/casos/mapaosm" => "sivel2_sjr/casos#mapaosm"
  get "/casos/nuevaubicacion" => "sivel2_sjr/casos#nueva_ubicacion"
  get "/casos/nuevavictima" => "sivel2_sjr/casos#nueva_victima"
  get "/casos/nuevopresponsable" => "sivel2_sjr/casos#nuevo_presponsable"
  get "/casos/busca" => "sivel2_sjr/casos#busca"
  get "/casos/filtro" => "sivel2_sjr/casos#index", as: :casos_filtro
  post "/casos/filtro" => "sivel2_sjr/casos#index", as: :envia_casos_filtro

  get "/conteos/personas" => "sivel2_sjr/conteos#personas", as: :conteos_personas
  post "/conteos/personas" => "sivel2_sjr/conteos#personas", as: :post_conteos_personas
  get "/conteos/respuestas" => "sivel2_sjr/conteos#respuestas", as: :conteos_respuestas

  get "/desplazamientos/nuevo" => "sivel2_sjr/desplazamientos#nuevo"

  get "/respuestas/nuevo" => "sivel2_sjr/respuestas#nuevo"

  #  get '/victimas' => 'victimas#index', as: :victimas
  #  get '/victimas/nuevo' => 'victimas#nuevo'
  get "/victimascolectivas/nuevo" => "sivel2_sjr/victimascolectivas#nuevo"

  get "/api/sivel2sjr/poblacion_sexo_rangoedadac" => "sivel2_sjr/casos#poblacion_sexo_rangoedadac",
    as: :sivel2sjr_poblacion_sexo_rangoedadac

  resources :casos,
    path_names: { new: "nuevo", edit: "edita" },
    controller: "sivel2_sjr/casos"

  # Fin de sivel2_sjr

  post "/beneficiarios/unificar" => "msip/personas#unificar",
    as: :beneficiarios_unificar
  get "/beneficiarios/unificar" => "msip/personas#unificar",
    as: :beneficiarios_unificar_get
  get "/beneficiarios/deduplicar" => "msip/personas#deduplicar",
    as: :beneficiarios_deduplicar
  get "/beneficiarios/repetidos" => "msip/personas#reporterepetidos",
    as: :beneficiarios_repetidos
  post "/beneficiarios/repetidos" => "msip/personas#reporterepetidos",
    as: :envia_beneficiarios_repetidas

  get "beneficiarios/identificacionsd" => "msip/personas#identificacionsd",
    as: :beneficiarios_identificacionsd

  post "/actos/agregar" => "sivel2_sjr/actos#agregar",
    as: :actos_agregar
  # get "/actos/eliminar" => 'sivel2_sjr/actos#eliminar',
  #  as: :actos_eliminar
  patch "/actos/agregarpr" => "sivel2_sjr/actos#nuevopr",
    as: :actos_nuevopr

  # No se requiere edición
  resources :clavesrespaldos,
    path_names: { new: "nueva" },
    controller: "msip/clavesrespaldos"

  get "/beneficiarios/caso_y_actividades" => "consbenefactcaso#index",
    as: :consbenefactcaso

  get "/ninosvictimas/" => "consninovictima#index",
    as: :consninovictima

  get "/conteos/accionesjuridicas" => "sivel2_sjr/conteos#accionesjuridicas",
    as: :conteos_accionesjuridicas
  get "/conteos/desplazamientos" => "sivel2_sjr/conteos#desplazamientos",
    as: :conteos_desplazamientos
  get "/conteos/municipios" => "sivel2_sjr/conteos#municipios",
    as: :conteos_municipios
  get "/conteos/rutas" => "sivel2_sjr/conteos#rutas",
    as: :contes_rutas
  get "/conteos/vacios" => "sivel2_sjr/conteos#vacios",
    as: :conteos_vacios

  get "/migraciones/nuevo" => "sivel2_sjr/migraciones#nuevo"

  # get "/personas" => 'msip/personas#index'
  # get "/personas/remplazar" => 'msip/personas#remplazar'

  get "/casos/:id/fichaimp" => "sivel2_sjr/casos#fichaimp",
    as: :caso_fichaimp

  get "/casos/:id/fichapdf" => "sivel2_sjr/casos#fichapdf",
    as: :caso_fichapdf

  get "/casos/:id/solicitar" => "sivel2_sjr/casos#solicitar",
    as: :caso_solicitar

  get "/casos/mapaosm" => "sivel2_sjr/casos#mapaosm"

  get "/consultabd" => "consultabd#index",
    as: :consultabd

  post "/consultabd" => "consultabd#index",
    as: :consultabd_post

  get "/diccionariodatos" => "diccionariodatos#presentar",
    as: :diccionariodatos
  post "/diccionariodatos" => "diccionariodatos#presentar",
    as: :diccionariodatos_enviar

  get "/personas_casos" => "sivel2_sjr/casos#personas_casos",
    as: :personas_casos

  get "/actividadespf/nueva" => "cor1440_gen/actividadespf#new",
    as: :nueva_actividadespf

  get "/actividadespf/:id" => "cor1440_gen/actividadespf#show",
    as: :show_actividadespf

  get "/actividadespflistado" => "cor1440_gen/actividadespf#index",
    as: :index_actividadespf

  get "/asistencia/rapidobenefcaso" => "cor1440_gen/actividades#rapido_benef_caso",
    as: :rapido_benef_caso

  get "/consgifmm" => "consgifmm#index",
    as: :consgifmm

  get "/detallesfinancieros/nuevo" => "detallesfinancieros#nuevo"

  get "/revisaben_detalle" => "cor1440_gen/actividades#revisaben_detalle"

  # Evita error en prueba dificil
  get "/admin/oficinas" => "msip/admin/oficinas#index", as: :oficinas_path

  # get '/ubicacionespre_mundep' => 'msip/admin/ubicacionespre#mundep',
  #  as: :ubicacionespre_mundep

  get "/ubicacionespre_lugar" => "msip/admin/ubicacionespre#lugar",
    as: :ubicacionespre_lugar

  resources :actonino, only: [] do
    member do
      delete "(:id)", to: "actosninos#destroy", as: "eliminar"
      post "/" => "actosninos#create", as: "crear"
    end
  end

  resources :docidsecundario, only: [] do
    member do
      delete "(:id)", to: "docsidsecundario#destroy", as: "eliminar"
      post "/" => "docsidsecundario#create", as: "crear"
    end
  end

  root "msip/hogar#index"

  namespace :admin do
    ab = Ability.new
    ab.tablasbasicas.each do |t|
      if t[0] == ""
        c = t[1].pluralize
        resources c.to_sym,
          path_names: { new: "nueva", edit: "edita" }
      elsif t[0] == "Sivel2Sjr"
        c = t[1].pluralize
        resources c.to_sym,
          path_names: { new: "nueva", edit: "edita" },
          controller: "/sivel2_sjr/admin/#{c}",
          path: "#{c}"
        #          resources c.to_sym,
        #            path_names: { new: "nueva", edit: "edita" },
        #            controller: "sivel2_sjr/#{c}"
      end
    end
  end

  mount Jos19::Engine, at: "/", as: "jos19"
  mount Sivel2Gen::Engine, at: "/", as: "sivel2_gen"
  mount Cor1440Gen::Engine, at: "/", as: "cor1440_gen"
  mount Mr519Gen::Engine, at: "/", as: "mr519_gen"
  mount Heb412Gen::Engine, at: "/", as: "heb412_gen"
  mount Msip::Engine, at: "/", as: "msip"
end
