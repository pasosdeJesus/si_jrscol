class ApplicationController < Msip::ApplicationController
  protect_from_forgery with: :exception

  # No requiere autorización
  if defined?(WEBrick)
    WEBrick::HTTPRequest.const_set("MAX_URI_LENGTH", 124000)
  end
end

