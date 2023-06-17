module ApplicationHelper
  TIPOAFILIACION = [
    ['BENEFICIARIO', :B],
    ['COTIZANTE', :C]
  ]

  def self.included klass
    klass.class_eval do
      include Sivel2Gen::ApplicationHelper
      include Heb412Gen::ApplicationHelper
    end
  end
end
