class AgregaPlantillaConsultabd < ActiveRecord::Migration[7.1]
  def up
    Heb412Gen::Plantillahcm.create(
      id: 57,
      ruta: 'Plantillas/consultabd.ods',
      fuente: 'pdJ',
      licencia: 'Dominio Público de acuerdo a legislación colombiana',
      vista: 'Consultabd',
      nombremenu: 'Excel rápido',
      filainicial: 1
    )
  end
  def down
    Heb412Gen::Plantillahcm.where(id: 57).delete_all
  end
end
