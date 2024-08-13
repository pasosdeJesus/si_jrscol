
class Diccionariodatos
  include ActiveModel::Model
  attr_accessor :motor

  class ColMod
    def count
      3
    end
    def reorder(col)
      return self
    end
    def all
      return self
    end
    def paginate(p)
    end
    def total_pages
      0
    end
  end

  def self.accessible_by(x, y=nil)
    ColMod.new
  end
end
