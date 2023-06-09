Rails.application.routes.draw do

  rutarel = ENV.fetch('RUTA_RELATIVA', '/')
  scope rutarel do 
    devise_scope :usuario do
      get 'sign_out' => 'devise/sessions#destroy'
      get 'salir' => 'devise/sessions#destroy',
        as: :terminar_sesion
      post 'usuarios/iniciar_sesion', to: 'devise/sessions#create'
      get 'usuarios/iniciar_sesion', to: 'devise/sessions#new',
        as: :iniciar_sesion

      # El siguiente para superar mala generación del action en el formulario
      # cuando se autentica mal y esta montado no en / (genera 
      # /puntomontaje/puntomontaje/usuarios/sign_in )
      if (Rails.configuration.relative_url_root != '/') 
        ruta = File.join(Rails.configuration.relative_url_root, 
                         'usuarios/sign_in')
        post ruta, to: 'devise/sessions#create'
        get  ruta, to: 'devise/sessions#new'
      end
    end
    devise_for :usuarios, :skip => [:registrations], module: :devise
    as :usuario do
      get 'usuarios/edit' => 'devise/registrations#edit', 
        :as => 'editar_registro_usuario'    
      put 'usuarios/:id' => 'devise/registrations#update', 
        :as => 'registro_usuario'            
    end
    resources :usuarios, path_names: { new: 'nuevo', edit: 'edita' } 

    post '/beneficiarios/unificar' => 'msip/personas#unificar',
      as: :beneficiarios_unificar
    get '/beneficiarios/unificar' => 'msip/personas#unificar',
      as: :beneficiarios_unificar_get
    get '/beneficiarios/deduplicar' => 'msip/personas#deduplicar',
      as: :beneficiarios_deduplicar
    get '/beneficiarios/repetidos' => 'msip/personas#reporterepetidos',
      as: :beneficiarios_repetidos
    post '/beneficiarios/repetidos' => 'msip/personas#reporterepetidos',
      as: :envia_beneficiarios_repetidas

    get 'beneficiarios/identificacionsd' => 'msip/personas#identificacionsd',
      as: :beneficiarios_identificacionsd

    post "/actos/agregar" => 'sivel2_sjr/actos#agregar',
      as: :actos_agregar
    get "/actos/eliminar" => 'sivel2_sjr/actos#eliminar',
      as: :actos_eliminar
    patch "/actos/agregarpr" => 'sivel2_sjr/actos#nuevopr',
      as: :actos_nuevopr

    # No se requiere edición
    resources :clavesrespaldos, path_names: { new: 'nueva' },
      controller: 'msip/clavesrespaldos'

    get "/conteos/accionesjuridicas" => 'sivel2_sjr/conteos#accionesjuridicas', 
      as: :conteos_accionesjuridicas
    get "/conteos/desplazamientos" => 'sivel2_sjr/conteos#desplazamientos', 
      as: :conteos_desplazamientos
    get "/conteos/municipios" => 'sivel2_sjr/conteos#municipios', 
      as: :conteos_municipios
    get "/conteos/rutas" => 'sivel2_sjr/conteos#rutas', 
      as: :contes_rutas
    get "/conteos/vacios" => 'sivel2_sjr/conteos#vacios',
      as: :conteos_vacios

    get '/migraciones/nuevo' => 'sivel2_sjr/migraciones#nuevo'  

    #get "/personas" => 'msip/personas#index'
    #get "/personas/remplazar" => 'msip/personas#remplazar'

    get "/casos/:id/fichaimp" => "sivel2_sjr/casos#fichaimp",
      as: :caso_fichaimp

    get "/casos/:id/fichapdf" => "sivel2_sjr/casos#fichapdf",
      as: :caso_fichapdf

    get "/casos/:id/solicitar" => "sivel2_sjr/casos#solicitar",
      as: :caso_solicitar

    get '/personas_casos' => 'sivel2_sjr/casos#personas_casos',
      as: :personas_casos

    get '/ubicacionespre' => 'msip/ubicacionespre#index',
      as: :ubicacionespre
    get '/ubicacionespre_mundep' => 'msip/ubicacionespre#mundep',
      as: :ubicacionespre_mundep
    get '/ubicacionespre_lugar' => 'msip/ubicacionespre#lugar',
      as: :ubicacionespre_lugar

    get '/actividadespf/nueva' => 'cor1440_gen/actividadespf#new',
      as: :nueva_actividadespf

    get '/actividadespf/:id' => 'cor1440_gen/actividadespf#show',
      as: :show_actividadespf

    get '/actividadespflistado' => 'cor1440_gen/actividadespf#index',
      as: :index_actividadespf

    get '/asistencia/rapidobenefcaso' => 'cor1440_gen/actividades#rapido_benef_caso', 
      as: :rapido_benef_caso

    get '/consgifmm' => 'consgifmm#index',
      as: :consgifmm

    get '/detallesfinancieros/nuevo' => 'detallesfinancieros#nuevo'

    get '/revisaben_detalle' => 'cor1440_gen/actividades#revisaben_detalle'

    root "msip/hogar#index"

    namespace :admin do
      ab = ::Ability.new
      ab.tablasbasicas.each do |t|
        if (t[0] == "") 
          c = t[1].pluralize
          resources c.to_sym, 
            path_names: { new: 'nueva', edit: 'edita' }
        end
      end
    end
  end

  mount Sivel2Sjr::Engine, at: rutarel, as: 'sivel2_sjr'
  mount Jos19::Engine, at: rutarel, as: 'jos19'
  mount Sivel2Gen::Engine, at: rutarel, as: 'sivel2_gen'
  mount Cor1440Gen::Engine, at: rutarel, as: 'cor1440_gen'
  mount Sal7711Gen::Engine, at: rutarel, as: 'sal7711_gen'
  mount Mr519Gen::Engine, at: rutarel, as: 'mr519_gen'
  mount Heb412Gen::Engine, at: rutarel, as: 'heb412_gen'
  mount Msip::Engine, at: rutarel, as: 'msip'

end
