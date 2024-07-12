require 'bcrypt'

require 'msip/concerns/controllers/usuarios_controller'

class UsuariosController < Msip::ModelosController
  include Msip::Concerns::Controllers::UsuariosController


  def registrar_en_bitacora
    true
  end

  def atributos_index
    [ :id,
      :nusuario,
      :nombre,
      :rol,
      :territorial_id,
      :fincontrato,
      :email,
      :tema,
      :habilitado,
      :created_at_localizada ]
  end

  def atributos_show
    ad = []
    if current_usuario.rol == Ability::ROLADMIN
      ad = [ :bitacora_ingresos_salidas ]
    end
    atributos_index + ad
  end
  
  def atributos_form
    r = [ :nusuario,
          :nombre,
          :descripcion,
          :rol,
          :territorial_id] +
          [ :etiqueta_ids =>  [] ] +
          [ :email,
            :tema,
            :idioma,
            :encrypted_password,
            :fechacreacion,
            :fechadeshabilitacion,
            :failed_attempts,
            :unlock_token,
            :locked_at,
            :fincontrato
          ]
    r
  end

  # Autoriza en cada función 
  def index
    authorize! :read, ::Usuario
    @registros= @usuarios = Usuario.order(
      'LOWER(nusuario)').paginate(:page => params[:pagina], per_page: 20)
    super(@usuarios)
    #render layout: '/application'
  end

  def lista_params
    [
      :current_sign_in_at, 
      :current_sign_in_ip, 
      :descripcion, 
      :email, 
      :encrypted_password, 
      :failed_attempts, 
      :fechacreacion, 
      :fechadeshabilitacion,
      :fincontrato,
      :id, 
      :idioma, 
      :last_sign_in_at, 
      :last_sign_in_ip, 
      :locked_at,
      :nombre, 
      :nusuario, 
      :password, 
      :territorial_id,
      :remember_created_at, 
      :reset_password_sent_at, 
      :reset_password_token, 
      :rol, 
      :sign_in_count, 
      :tema_id,
      :unlock_token, 
      :etiqueta_ids => []
    ]
  end

  def usuario_params
    p = params.require(:usuario).permit(lista_params)
    return p
  end

end
