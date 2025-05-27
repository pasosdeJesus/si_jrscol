# frozen_string_literal: true

class ::SessionsController < Devise::SessionsController
  # http://stackoverflow.com/questions/8570077/about-overriding-devise-or-clearance-controllers
  skip_before_action :require_no_authentication

  def new
    super
    #  puts "OJO en controlador, resource=", resource
    #  puts "OJO en controlador, self.resource=", self.resource
    #  respond_to do |format|
    #    format.html { render }
    #  end
  end

  def create
    super
    if current_usuario
      Msip::Bitacora.a(
        request.remote_ip,
        current_usuario.id,
        request.url,
        params,
        "",
        0,
        "ingreso",
        "",
      )
    end
  end

  def destroy
    if current_usuario
      Msip::Bitacora.a(
        request.remote_ip,
        current_usuario.id,
        request.url,
        params,
        "",
        0,
        "salida",
        "",
      )
    end
    # signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    # set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
    # flash[:error] = Ability::ultimo_error_aut if Ability::ultimo_error_aut
    # yield if block_given?
    # respond_to_on_destroy
    super
  end
end
