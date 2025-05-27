# frozen_string_literal: true

# Una fila de la tabla detalle financiero en una actividad
class Detallefinanciero < ActiveRecord::Base
  belongs_to :actividad,
    validate: true,
    class_name: "Cor1440Gen::Actividad",
    optional: false

  belongs_to :proyectofinanciero,
    validate: true,
    class_name: "Cor1440Gen::Proyectofinanciero",
    optional: false

  belongs_to :actividadpf,
    class_name: "Cor1440Gen::Actividadpf",
    optional: false

  belongs_to :unidadayuda,
    optional: true,
    class_name: "Unidadayuda"

  belongs_to :mecanismodeentrega,
    optional: true,
    class_name: "Mecanismodeentrega"

  belongs_to :modalidadentrega,
    optional: true,
    class_name: "Modalidadentrega"

  belongs_to :tipotransferencia,
    optional: true,
    class_name: "Tipotransferencia"

  belongs_to :frecuenciaentrega,
    optional: true,
    class_name: "Frecuenciaentrega"

  has_and_belongs_to_many :persona,
    class_name: "Msip::Persona",
    association_foreign_key: "persona_id",
    join_table: "detallefinanciero_persona"

  validates :cantidad,
    numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true
  validates :valorunitario,
    numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true
  validates :valortotal,
    numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true
  validates :numeromeses,
    numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true
  validates :numeroasistencia,
    numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true

  attr_accessor :convenioactividad

  def convenioactividad=(valor)
    if valor.nil? || valor.split(" - ").count < 2
      self.proyectofinanciero_id = nil
      self.actividadpf_id = nil
      return
    end
    convenio = Cor1440Gen::Proyectofinanciero.where(
      nombre: valor.split(" - ")[0],
    )
    actividadpf = Cor1440Gen::Actividadpf.where(
      proyectofinanciero_id: convenio[0].id,
    )
      .where(
        "titulo LIKE '%' || ? || '%'", valor.split(" - ")[1].strip
      )
    if convenio.count == 1 && actividadpf.count == 1
      self.proyectofinanciero_id = convenio[0].id
      self.actividadpf_id = actividadpf[0].id
    else
      puts "** No se identificó convenio '#{convenio[0].id}' con " +
        "actividadpf '#{actividadpf[0].id}'"
    end
  end

  def convenioactividad
    if proyectofinanciero_id and actividadpf_id
      convenio = Cor1440Gen::Proyectofinanciero.find(proyectofinanciero_id).nombre
      actividadpf = Cor1440Gen::Actividadpf.find(actividadpf_id).titulo
      convenio + " - " + actividadpf
    else
      ""
    end
  end

  def presenta_nombre
    id
  end
end
