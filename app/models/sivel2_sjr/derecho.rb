
class Sivel2Sjr::Derecho < ActiveRecord::Base

  include Msip::Basica

  self.table_name = "sivel2_sjr_derecho"

  has_and_belongs_to_many :respuesta, 
    class_name: "Sivel2Sjr::Respuesta", 
    foreign_key: "derecho_id", 
    validate: true,
    association_foreign_key: "respuesta_id",
    join_table: 'sivel2_sjr_derecho_respuesta' 

  has_and_belongs_to_many :ayudaestado, 
    class_name: "Sivel2Sjr::Ayudaestado", 
    foreign_key: "derecho_id",
    association_foreign_key: "ayudaestado_id",
    join_table: 'sivel2_sjr_ayudaestado_derecho' 

  has_and_belongs_to_many :ayudasjr, 
    class_name: "Sivel2Sjr::Ayudasjr", 
    foreign_key: "derecho_id",
    association_foreign_key: "ayudasjr_id",
    join_table: 'sivel2_sjr_ayudasjr_derecho' 

  has_and_belongs_to_many :motivosjr, 
    class_name: "Sivel2Sjr::Motivosjr", 
    foreign_key: "derecho_id",
    association_foreign_key: "motivosjr_id",
    join_table: 'sivel2_sjr_motivosjr_derecho' 

  has_and_belongs_to_many :progestado, 
    class_name: "Sivel2Sjr::Progestado", 
    foreign_key: "derecho_id",
    association_foreign_key: "progestado_id",
    join_table: 'sivel2_sjr_progestado_derecho' 


  has_many :ayudaestado_derecho, 
    class_name: 'Sivel2Sjr::AyudaestadoDerecho', foreign_key: "derecho_id"
  has_many :ayudasjr_derecho, 
    class_name: 'Sivel2Sjr::AyudasjrDerecho', foreign_key: "derecho_id"
  has_many :motivosjr_derecho, 
    class_name: 'Sivel2Sjr::MotivosjrDerecho', foreign_key: "derecho_id"
  has_many :progestado_derecho, 
    class_name: 'Sivel2Sjr::ProgestadoDerecho', foreign_key: "derecho_id"
  #has_many :respuesta, :through => :derecho_respuesta

end
