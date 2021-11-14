class ApplicationController < Sip::ApplicationController
  protect_from_forgery with: :exception

  # No requiere autoerización
end

