# frozen_string_literal: true

require 'cor1440_gen/concerns/models/actividad'

module Cor1440Gen
  class Actividad < ActiveRecord::Base
    include Cor1440Gen::Concerns::Models::Actividad

    belongs_to :ubicacionpre, class_name: '::Msip::Ubicacionpre',
      foreign_key: 'ubicacionpre_id', optional: true
    has_many :detallefinanciero, dependent: :delete_all,
      class_name: 'Detallefinanciero',
      foreign_key: 'actividad_id'
    accepts_nested_attributes_for :detallefinanciero,
      allow_destroy: true, reject_if: :all_blank

    attr_accessor :rapidobenefcaso_id

    attr_reader :territorial_id
    def territorial_id
      self.oficina.territorial_id
    end

    attr_reader :territorial
    def territorial
      self.oficina.territorial
    end

    attr_accessor :controlador

    attr_accessor :ubicacionpre_texto
    def ubicacionpre_texto
      if self.ubicacionpre
        self.ubicacionpre.nombre
      else
        ''
      end
    end

    attr_accessor :ubicacionpre_mundep_texto
    def ubicacionpre_mundep_texto
      if self.ubicacionpre
        self.ubicacionpre.nombre_sin_pais
      else
        ''
      end
    end

    validates :ubicacionpre_mundep_texto, presence: true
    validates :proyecto, presence: true
    validates :resultado, presence: true

    validate :territorial_responsable_current_usuario
    def territorial_responsable_current_usuario
      if (current_usuario && current_usuario.territorial_id && 
          current_usuario.rol != Ability::ROLADMIN &&
          current_usuario.rol != Ability::ROLDIR &&
          responsable && responsable.territorial_id &&
          responsable.territorial_id != current_usuario.territorial_id)
        errors.add(:responsable, "Para editar responsable el " +
                   "usuario actual debe estar en la misma territorial")
      end
      if (current_usuario && current_usuario.territorial_id && 
          current_usuario.rol != Ability::ROLADMIN &&
          current_usuario.rol != Ability::ROLDIR &&
          oficina && oficina.territorial_id &&
          current_usuario.territorial_id != oficina.territorial_id)
        errors.add(:oficina, "La oficina de la actividad debe ser " +
                   "de la misma territorial del usuario")
      end
    end

    validate :valida_detallefinanciero_sin_repetidos
    def valida_detallefinanciero_sin_repetidos
      pact = []
      self.detallefinanciero.map{
        |t| t.persona_ids.map{ |per| 
          if t.actividadpf_id
            pact.push([per, t.actividadpf_id])
          end
        }
      }
      if pact.length != pact.uniq.length
        errors.add(:persona, "En Detalle Financiero no se puden repetir " +
                   "beneficiarios si la actividad del marco lógico es la misma") 
      end 
    end 

    validate :valida_actividad_marco_logico
    def valida_actividad_marco_logico
      amlmin = Cor1440Gen::Actividadpf.where(proyectofinanciero: 10).pluck(:id)
      if (amlmin & self.actividadpf_ids) == []
        errors.add(:proyectofinanciero, "Falta alguna actividad de marco lógico del convenio 'PLAN ESTRATEGICO 1'")
      end
      if controlador && controlador.params && controlador.params[:actividad] &&
          controlador.params[:actividad][:actividad_proyectofinanciero_attributes]
        controlador.params[:actividad][:actividad_proyectofinanciero_attributes].each do |l, v|
          if v[:proyectofinanciero_id].to_i != 10 &&
              v['_destroy'] == 'false' && (v['actividadpf_ids'] == [] || 
              v['actividadpf_ids'] == [''])
            cf = v[:proyectofinanciero_id].to_i > 0 ?
            Cor1440Gen::Proyectofinanciero.find(
              v[:proyectofinanciero_id]).nombre : ''
            errors.add(
              :proyectofinanciero, 
              "Falta agregar actividad de marco lógico en "\
              "convenio financiador #{cf}"
            )
          end
        end
      end 
    end

    # Validación de perfil poblacional en asistente
    # no siempre detecta problema
    validate :valida_asistentes_con_perfil
    def valida_asistentes_con_perfil
      docerr = []
      if controlador && controlador.params && controlador.params[:actividad] &&
          controlador.params[:actividad][:asistencia_attributes]
        controlador.params[:actividad][:asistencia_attributes].each do |l, v|
          if v[:perfilorgsocial_id].to_i == 0 && v['_destroy'] == 'false'
            docerr <<  v[:persona_attributes][:numerodocumento]
          end
        end
      end
      if docerr.count > 0
        Rails.logger.info "*OJO* Falta perfil poblacional en asistente(s) con identificacion(es) " + docerr.join(", ") + "."
        errors.add(
          :actividad_asistencia_attributes, 
          "Falta perfil poblacional en asistente(s) con identificacion(es) " +
          docerr.join(", ") + "."
        )
      end
    end

    # Validación de sexo en asistente
    validate :valida_sexo_asistentes
    def valida_sexo_asistentes
      docerr = []
      if controlador && controlador.params && controlador.params[:actividad] &&
          controlador.params[:actividad][:asistencia_attributes]
        controlador.params[:actividad][:asistencia_attributes].each do |l, v|
          if v[:persona_attributes] && v[:persona_attributes][:sexo] &&
            v[:persona_attributes][:sexo] == 'S' && v['_destroy'] == 'false'
            docerr <<  v[:persona_attributes][:numerodocumento]
          end
        end
      end
      if docerr.count > 0
        errors.add(
          :actividad_asistencia_attributes, 
          "Falta sexo en asistente(s) con identificacion(es) " +
          docerr.join(", ") + "."
        )
      end
    end



    # FILTROS
   
    scope :filtro_oficina, lambda { |ids|
      where(oficina_id: ids.map(&:to_i))
    }

    scope :filtro_proyectofinanciero, lambda { |ids|
      where('cor1440_gen_actividad.id IN '\
            '(SELECT actividad_id '\
            ' FROM cor1440_gen_actividad_proyectofinanciero '\
            ' WHERE proyectofinanciero_id IN (?))', ids.map(&:to_i))
    }

    scope :filtro_territorial, lambda { |tid|
      where(tid.count == 0 ? "TRUE" :
            "oficina_id IN (SELECT id FROM msip_oficina "\
            "WHERE msip_oficina.territorial_id IN (?))", tid)
    }


    # PRESENTACIÓN DE INFORMACIÓN

    def casos_asociados
      lp = self.asistencia.pluck(:persona_id) 
      if lp.count == 0
        lc = []
      else
        lv = Sivel2Gen::Victima.where(persona_id: lp).joins(:victimasjr).
          where('fechadesagregacion IS NULL OR fechadesagregacion >= ?',
                self.fecha)
        lc = lv.pluck(:caso_id)
      end
      if lc.empty?
        return ""
      else
        return lc.sort.uniq.join(", ")
      end
    end

    def cuenta_victimas_condicion
      cuenta = 0
      lp = self.asistencia.pluck(:persona_id) 
      victimas = Sivel2Gen::Victima.where(persona_id: lp).joins(:victimasjr).
        where('fechadesagregacion IS NULL OR fechadesagregacion >= ?',
              self.fecha)
      victimas.each do |v|
        if (yield(v))
          cuenta += 1
        end
      end
      cuenta
    end

    # Auxiliar que retorna listado de identificaciones de asistentes
    # que cumplan una condición
    def personas_victimas_condicion
      ids = []
      lp = self.asistencia.pluck(:persona_id) 
      victimas = Sivel2Gen::Victima.where(persona_id: lp).joins(:victimasjr).
        where('fechadesagregacion IS NULL OR fechadesagregacion >= ?',
              self.fecha)
      victimas.each do |v|
        if (yield(v))
          ids << v.persona_id
        end
      end
      ids
    end

    # Auxiliar que retorna listado de identificaciones de personas del
    # listado de asistentes que cumplan una condición
    def personas_asistentes_condicion
      ids = []
      self.asistencia.each do |a| 
        if (yield(a))
          ids << a.persona_id
        end
      end
      ids
    end

    def poblacion_ids
      idp = personas_asistentes_condicion {|a| true}
      idp.uniq!
      idp.join(",")
    end

    def poblacion
      p1 = actividad_rangoedadac.inject(0) do |memo, r|
        memo + (r.mr ? r.mr : 0) +
          (r.fr ? r.fr : 0) +
          (r.s ? r.s : 0) +
          (r.i ? r.i : 0)
      end
      p2 = poblacion_ids.split(",").count
      if p1 >= p2
        p1.to_i
      else
        "#{p1} pero se esperaban al menos #{p2}"
      end
    end

    def poblacion_nuevos_ids
      idp += personas_asistentes_condicion {|a| 
        Sivel2Gen::Victima.where(persona_id: a.persona_id).joins(:victimasjr).
          where('fechadesagregacion IS NULL OR fechadesagregacion >= ?',
                self.fecha).count > 0 &&
          Sivel2Gen::Victima.where(persona_id: a.persona_id).take.caso.fecha.
            at_beginning_of_month >= self.fecha.at_beginning_of_month
      }
      idp.uniq!
      idp.join(",")
    end


    def poblacion_nuevos
      poblacion_nuevos_ids.split(",").count
    end

    def poblacion_colombianos_retornados_ids
      idcol = 170 # Colombia

      idp += personas_asistentes_condicion {|a| 
        Sivel2Gen::Victima.where(persona_id: a.persona_id).joins(:victimasjr).
          where('fechadesagregacion IS NULL OR fechadesagregacion >= ?',
                self.fecha).count > 0 &&
               Sivel2Gen::Victima.where(persona_id: a.persona_id).
               joins(:victimasjr).
               where('fechadesagregacion IS NULL OR fechadesagregacion >= ?',
                     self.fecha).take.caso.migracion.count > 0 &&
                    (a.persona.nacionalde == idcol || a.persona.pais_id == idcol)
      }
      idp.uniq!
      idp.join(",")
    end

    def poblacion_colombianos_retornados
      poblacion_colombianos_retornados_ids.split(",").count
    end


    # Retorna listado de ids de personas de casos y asistencia
    # cuyo perfil de migración tenga nombre nomperfil
    def poblacion_perfil_migracion_ids(nomperfil)
      idp += personas_asistentes_condicion {|a| 
        a.perfilorgsocial &&
          a.perfilorgsocial.nombre == nomperfil
      }
      idp.uniq!
      idp.join(",")
    end

   
    def poblacion_pendulares_ids
      poblacion_perfil_migracion_ids('PENDULAR')
    end

    def poblacion_pendulares
      poblacion_pendulares_ids.split(",").count
    end


    def poblacion_transito_ids
      poblacion_perfil_migracion_ids('EN TRÁNSITO')
    end

    def poblacion_transito
      poblacion_transito_ids.split(",").count
    end

    def poblacion_vocacion_permanencia_ids
      poblacion_perfil_migracion_ids('CON VOCACIÓN DE PERMANENCIA')
    end

    def poblacion_vocacion_permanencia
      poblacion_vocacion_permanencia_ids.split(",").count
    end


    def  poblacion_r_g(sexo, num)
      idp = personas_victimas_condicion {|v| 
        if v.persona.sexo == sexo
          e = Sivel2Gen::RangoedadHelper.edad_de_fechanac_fecha(
            v.persona.anionac, v.persona.mesnac, v.persona.dianac,
            fecha.year, fecha.month, fecha. day)
          r = Sivel2Gen::RangoedadHelper.buscar_rango_edad(
            e, 'Cor1440Gen::Rangoedadac')
          r == num
        else
          false
        end
      }
      idp += personas_asistentes_condicion {|a| 
        if a.persona && a.persona.sexo == sexo
          e = Sivel2Gen::RangoedadHelper.edad_de_fechanac_fecha(
            a.persona.anionac, a.persona.mesnac, a.persona.dianac,
            fecha.year, fecha.month, fecha. day)
          r = Sivel2Gen::RangoedadHelper.buscar_rango_edad(
            e, 'Cor1440Gen::Rangoedadac')
          r == num
        else
          false
        end
      }
      idp.uniq!
      idp.join(",")
    end

    def poblacion_mujeres_r_g_ids(num)
      poblacion_r_g(Msip::Persona::convencion_sexo[:sexo_femenino], num)
    end

    def poblacion_hombres_r_g_ids(num)
      poblacion_r_g(Msip::Persona::convencion_sexo[:sexo_masculino], num)
    end

    def poblacion_intersexuales_g_ids(num)
      poblacion_r_g(Msip::Persona::convencion_sexo[:sexo_intersexual], num)
    end


    def poblacion_sinsexo_g_ids(num)
      poblacion_r_g(Msip::Persona::convencion_sexo[:sexo_sininformacion], num)
    end


    def poblacion_gen_infijo(infijo, num = nil)
      puts "** OJO poblacion_gen_infijo(infijo = #{infijo}, num = #{num})"
      p1 = nil
      p2 = nil
      if num.nil?
        p1 = send("poblacion_#{infijo}_solore")
        if respond_to?("poblacion_#{infijo}_ids")
          p2 = send("poblacion_#{infijo}_ids").split(",").count
        end
      else
        p1 = send("poblacion_#{infijo}_solore", num)
        if respond_to?("poblacion_#{infijo}_ids")
          p2 = send("poblacion_#{infijo}_ids", num).split(",").count
        end
      end
      if p2.nil? || p1 >= p2
        p1.to_i
      else
        "#{p1} pero se esperaban al menos #{p2}"
      end
    end

    def poblacion_hombres_adultos_ids
      l = poblacion_hombres_r_g_ids(4).split(",") +
        poblacion_hombres_r_g_ids(5).split(",") +
        poblacion_hombres_r_g_ids(6).split(",")
      l.join(",")
    end

    def poblacion_hombres_r_g_4_5_ids
      l = poblacion_hombres_r_g_ids(4).split(",") + 
        poblacion_hombres_r_g_ids(5).split(",")
      l.join(",")
    end

    def poblacion_mujeres_adultas_ids
      l = poblacion_mujeres_r_g_ids(4).split(",") +
        poblacion_mujeres_r_g_ids(5).split(",") +
        poblacion_mujeres_r_g_ids(6).split(",")
      l.join(",")
    end

    def poblacion_mujeres_r_g_4_5_ids
      l = poblacion_mujeres_r_g_ids(4).split(",") + 
        poblacion_mujeres_r_g_ids(5).split(",")
      l.join(",")
    end

    def poblacion_ninas_adolescentes_y_se_ids
      l = poblacion_mujeres_r_g_ids(1).split(",") +
        poblacion_mujeres_r_g_ids(2).split(",") +
        poblacion_mujeres_r_g_ids(3).split(",") +
        poblacion_mujeres_r_g_ids(7).split(",")
      l.join(",")
    end

    def poblacion_ninos_adolescentes_y_se_ids
      l = poblacion_hombres_r_g_ids(1).split(",") +
        poblacion_hombres_r_g_ids(2).split(",") +
        poblacion_hombres_r_g_ids(3).split(",") +
        poblacion_hombres_r_g_ids(7).split(",")
      l.join(",")
    end

    def poblacion_intersexuales_adultos_ids
      l = poblacion_intersexuales_g_ids(4).split(",") +
        poblacion_intersexuales_g_ids(5).split(",") +
        poblacion_intersexuales_g_ids(6).split(",")
      l.join(",")
    end

    def poblacion_intersexuales_menores_ids
      l = poblacion_intersexuales_g_ids(1).split(",") +
        poblacion_intersexuales_g_ids(2).split(",") +
        poblacion_intersexuales_g_ids(3).split(",") +
        poblacion_intersexuales_g_ids(7).split(",")
      l.join(",")
    end


    def poblacion_sinsexo_adultos_ids
      l = poblacion_sinsexo_g_ids(4).split(",") +
        poblacion_sinsexo_g_ids(5).split(",") +
        poblacion_sinsexo_g_ids(6).split(",")
      l.join(",")
    end

    def poblacion_sinsexo_menores_ids
      l = poblacion_sinsexo_g_ids(1).split(",") +
        poblacion_sinsexo_g_ids(2).split(",") +
        poblacion_sinsexo_g_ids(3).split(",") +
        poblacion_sinsexo_g_ids(7).split(",")
      l.join(",")
    end

    def presenta(atr)
      case atr.to_s
      when 'beneficiarios_com_acogida'
        self.asistencia.select{|a| a.perfilorgsocial_id == 13}.count

      when 'covid19'
        if self.covid
          'Si'
        else
          'No'
        end

      when 'departamento'
        if ubicacionpre && ubicacionpre.departamento
          ubicacionpre.departamento.nombre
        else
          ''
        end

      when 'departamento_altas_bajas'
        if ubicacionpre && ubicacionpre.departamento
          ubicacionpre.departamento.nombre.altas_bajas
        else
          ''
        end

      when 'listado_casos_ids'
        ''

      when 'numero_detalles_financieros'
        detallefinanciero.count

      when 'detalles_financieros_ids'
        detallefinanciero_ids.join(', ')

      when 'organizaciones_sociales_ids'
        orgsocial_ids.join(', ')

      when 'mes'
        if fecha
          Msip::FormatoFechaHelper::MESES[fecha.month]
        else
          ''
        end

      when 'municipio'
        if ubicacionpre && ubicacionpre.municipio
          ubicacionpre.municipio.nombre
        else
          ''
        end

      when 'municipio_altas_bajas'
        if ubicacionpre && ubicacionpre.municipio
          ubicacionpre.municipio.nombre.altas_bajas
        else
          ''
        end


      when 'num_afrodescendientes'
        cuenta_victimas_condicion {|v|
          v.etnia.nombre  == 'AFRODESCENDIENTE' || 
          v.etnia.nombre == 'NEGRO'
        }

      when 'num_con_discapacidad'
        cuenta_victimas_condicion { |v|
          vs = Sivel2Sjr::Victimasjr.where(victima_id: v.id)
          vs.count > 0 && vs.take.discapacidad &&
            vs.take.discapacidad && vs.take.discapacidad.nombre != 'NINGUNA'
        }

      when 'num_con_discapacidad_ids'
        idp = personas_victimas_condicion { |v|
          vs = Sivel2Sjr::Victimasjr.where(victima_id: v.id)
          vs.count > 0 && vs.take.discapacidad &&
            vs.take.discapacidad && vs.take.discapacidad.nombre != 'NINGUNA'
        }
        idp += personas_asistentes_condicion {|a|
          if Sivel2Gen::Victima.where(persona_id: a.persona_id).count > 0
            v = Sivel2Gen::Victima.where(persona_id: a.persona_id).take
            vs = Sivel2Sjr::Victimasjr.where(victima_id: v.id)
            vs.count > 0 && vs.take.discapacidad &&
              vs.take.discapacidad && vs.take.discapacidad.nombre != 'NINGUNA'
          else
            false
          end
        }
        idp.uniq!
        idp.join(",")
 
      when 'num_indigenas'
        cuenta_victimas_condicion { |v|
          v.etnia.nombre  != 'AFRODESCENDIENTE' &&
          v.etnia.nombre != 'NEGRO' &&
          v.etnia.nombre != 'ROM' &&
          v.etnia.nombre != 'MESTIZO' &&
          v.etnia.nombre != 'SIN INFORMACIÓN'
        }

      when 'num_lgbti'
        cuenta_victimas_condicion { |v|
          v.orientacionsexual != 'H'
        }

      when 'num_otra_etnia'
        cuenta_victimas_condicion { |v|
          v.etnia.nombre == 'ROM' ||
          v.etnia.nombre == 'MESTIZO' ||
          v.etnia.nombre == 'SIN INFORMACIÓN'
        }

      when 'poblacion_hombres_adultos'
        p1 = poblacion_hombres_r_g_solore(4) +
          poblacion_hombres_r_g_solore(5) + poblacion_hombres_r_g_solore(6)
        p2 = poblacion_hombres_adultos_ids.split(",").count
        if p1 >= p2
          p1.to_s
        else
          "#{p1} pero se esperaban al menos #{p2}"
        end

      when 'poblacion_hombres_l'
        poblacion_gen_infijo('hombres_l')

      when 'poblacion_hombres_l_r'
        actividad_rangoedadac.inject(0) { |memo, r|
          memo += r.fl ? r.fl : 0
          memo += r.fr ? r.fr : 0
          memo
        }

      when /^poblacion_hombres_l_g[0-9]*$/
        g = atr[21..-1].to_i
        poblacion_gen_infijo('hombres_l_g', g)

      when 'poblacion_hombres_r'
        poblacion_gen_infijo('hombres_r')

      when /^poblacion_hombres_r_g[0-9]*$/
        g = atr[21..-1].to_i
        poblacion_gen_infijo('hombres_r_g', g)

      when /^poblacion_hombres_r_g[0-9]*_ids$/
        g = atr[21..-4].to_i
        poblacion_hombres_r_g_ids(g)

      when /^poblacion_hombres_r_g_4_5*$/
        p1 = poblacion_hombres_r_g_solore(4)+poblacion_hombres_r_g_solore(5)
        p2 = poblacion_hombres_r_g_4_5_ids.split(",").count
        if p1 >= p2
          p1.to_s
        else
          "#{p1} pero se esperaban al menos #{p2}"
        end

      when 'poblacion_mujeres_adultas'
        p1 = poblacion_mujeres_r_g_solore(4) +
          poblacion_mujeres_r_g_solore(5) + poblacion_mujeres_r_g_solore(6)
        p2 = poblacion_mujeres_adultas_ids.split(",").count
        if p1 >= p2
          p1.to_s
        else
          "#{p1} pero se esperaban al menos #{p2}"
        end

      when 'poblacion_mujeres_l'
        poblacion_gen_infijo('mujeres_l')

      when 'poblacion_mujeres_l_r'
        actividad_rangoedadac.inject(0) { |memo, r|
          memo += r.fl ? r.fl : 0
          memo += r.fr ? r.fr : 0
          memo
        }

      when 'poblacion_mujeres_r'
        poblacion_gen_infijo('mujeres_r')

      when /^poblacion_mujeres_l_g[0-9]*$/
        g = atr[21..-1].to_i
        poblacion_gen_infijo('mujeres_l_g', g)

      when /^poblacion_mujeres_r_g[0-9]*$/
        g = atr[21..-1].to_i
        poblacion_gen_infijo('mujeres_r_g', g)

      when /^poblacion_mujeres_r_g[0-9]*_ids$/
        g = atr[21..-4].to_i
        poblacion_mujeres_r_g_ids(g)

      when /^poblacion_mujeres_r_g_4_5*$/
        p1 = poblacion_mujeres_r_g_solore(4)+poblacion_mujeres_r_g_solore(5)
        p2 = poblacion_mujeres_r_g_4_5_ids.split(",").count
        if p1 >= p2
          p1.to_s
        else
          "#{p1} pero se esperaban al menos #{p2}"
        end

      when 'poblacion_niñas_adolescentes_y_se'
        p1 = poblacion_mujeres_r_g_solore(1) +
          poblacion_mujeres_r_g_solore(2) + poblacion_mujeres_r_g_solore(3) +
          poblacion_mujeres_r_g_solore(7)
        p2 = poblacion_ninas_adolescentes_y_se_ids.split(",").count
        if p1 >= p2
          p1.to_s
        else
          "#{p1} pero se esperaban al menos #{p2}"
        end

      when 'poblacion_niñas_adolescentes_y_se_ids'
        poblacion_ninas_adolescentes_y_se_ids

      when 'poblacion_niños_adolescentes_y_se'
        p1 = poblacion_hombres_r_g_solore(1) +
          poblacion_hombres_r_g_solore(2) + poblacion_hombres_r_g_solore(3) +
          poblacion_hombres_r_g_solore(7)
        p2 = poblacion_ninos_adolescentes_y_se_ids.split(",").count
        if p1 >= p2
          p1.to_s
        else
          "#{p1} pero se esperaban al menos #{p2}"
        end

      when 'poblacion_niños_adolescentes_y_se_ids'
        poblacion_ninos_adolescentes_y_se_ids.split(",").count

      when 'poblacion_intersexuales'
        poblacion_gen_infijo('intersexuales')

      when 'poblacion_intersexuales_adultos'
        p1 = poblacion_intersexuales_g_solore(4) +
          poblacion_intersexuales_g_solore(5) + poblacion_intersexuales_g_solore(6)
        p2 = poblacion_intersexuales_adultos_ids.split(",").count
        if p1 >= p2
          p1.to_s
        else
          "#{p1} pero se esperaban al menos #{p2}"
        end

      when 'poblacion_intersexuales_menores'
        p1 = poblacion_intersexuales_g_solore(1) +
          poblacion_intersexuales_g_solore(2) + poblacion_intersexuales_g_solore(3) +
          poblacion_intersexuales_g_solore(7)
        p2 = poblacion_intersexuales_menores_ids.split(",").count
        if p1 >= p2
          p1.to_s
        else
          "#{p1} pero se esperaban al menos #{p2}"
        end

      when 'poblacion_sinsexo'
        poblacion_gen_infijo('sinsexo')

      when 'poblacion_sinsexo_adultos'
        p1 = poblacion_sinsexo_g_solore(4) +
          poblacion_sinsexo_g_solore(5) + poblacion_sinsexo_g_solore(6)
        p2 = poblacion_sinsexo_adultos_ids.split(",").count
        if p1 >= p2
          p1.to_s
        else
          "#{p1} pero se esperaban al menos #{p2}"
        end

      when 'poblacion_sinsexo_menores'
        p1 = poblacion_sinsexo_g_solore(1) +
          poblacion_sinsexo_g_solore(2) + poblacion_sinsexo_g_solore(3) +
          poblacion_sinsexo_g_solore(7)
        p2 = poblacion_sinsexo_menores_ids.split(",").count
        if p1 >= p2
          p1.to_s
        else
          "#{p1} pero se esperaban al menos #{p2}"
        end

      when /^poblacion_sinsexo_g[0-9]*$/
        g = atr[19..-1].to_i
        poblacion_gen_infijo('sinsexo_g', g)

      when 'observaciones'
        self.observaciones
      else
        presenta_actividad(atr)
      end
    end


    def self.vista_reporte_completo_excel(
      plant, registros, narch, parsimp, extension, params)

      ruta = File.join(Rails.application.config.x.heb412_ruta, 
                       plant.ruta).to_s

      p = Axlsx::Package.new
      lt = p.workbook
      e = lt.styles

      estilo_base = e.add_style sz: 12
      estilo_titulo = e.add_style sz: 20
      estilo_encabezado = e.add_style sz: 12, b: true
      #, fg_color: 'FF0000', bg_color: '00FF00'

      lt.add_worksheet do |hoja|
        hoja.add_row ['Reporte Completo de Actividades'], 
          height: 30, style: estilo_titulo
        hoja.add_row []
        hoja.add_row [
          'Fecha inicial', params['filtro']['busfechaini'], 
          'Fecha final', params['filtro']['busfechafin'] ], style: estilo_base
        idpf = (!params['filtro'] || 
                !params['filtro']['busproyectofinanciero_nombre'] || 
                params['filtro']['busproyectofinanciero_nombre'] == ''
               ) ? nil : params['filtro']['busproyectofinanciero_nombre']
        idaml = (!params['filtro'] || 
                 !params['filtro']['busactividadpf_nombre'] || 
                 params['filtro']['busactividadpf_nombre'] == ''
                ) ? nil : params['filtro']['busactividadpf_nombre']

        npf = idpf.nil? ? '' :
          Cor1440Gen::Proyectofinanciero.where(id: idpf).
          pluck(:nombre).join('; ')
        naml = idaml.nil? ? '' :
          Cor1440Gen::Actividadpf.where(id: idaml).
          pluck(:titulo).join('; ')

        hoja.add_row ['Convenio financiero', npf, 'Actividad de marco lógico', naml], style: estilo_base
        hoja.add_row []
        l = [
          'Id',
          'Nombre',
          'Fecha',
          'Lugar',
          'Oficina',
          'Convenios financiados',
          'Actividad(es) de convenio',
          'Área(s)',
          'Subárea(s) de actividad',
          'Responsable',
          'Corresponsables',
          'Objetivo',
          'Resultado',
          'Población',
          'Observaciones',
          'Fecha Creación',
          'Fecha actualización',
          'Total mujeres beneficiadas',
          'Total hombres beneficiados',
          'Total beneficiarios sin sexo',
          'Total beneficiarios otro sexo',
          'Equipo mujeres JRS',
          'Equipo hombres JRS',
          'Mujeres 0-5',
          'Mujeres 6-12',
          'Mujeres 13-17',
          'Mujeres 18-26',
          'Mujeres 27-59',
          'Mujeres 60+',
          'Mujeres SRE',
          'Hombres 0-5',
          'Hombres 6-12',
          'Hombres 13-17',
          'Hombres 18-26',
          'Hombres 27-59',
          'Hombres 60+',
          'Hombres SRE',
          'Sin sexo 0-5',
          'Sin sexo 6-12',
          'Sin sexo 13-17',
          'Sin sexo 18-26',
          'Sin sexo 27-59',
          'Sin sexo 60+',
          'Sin sexo SRE',
          'Otro sexo 0-15',
          'Otro sexo 6-12',
          'Otro sexo 13-17',
          'Otro sexo 18-26',
          'Otro sexo 27-59',
          'Otro sexo 60+',
          'Otro sexo SRE'
        ]
        numcol = l.length
        colfin = Heb412Gen::PlantillaHelper.numero_a_columna(numcol)

        hoja.merge_cells("A1:#{colfin}1")

        l2 = ([''] * 23) + ['Mujeres'] + ([''] * 6) + ['Hombres'] + ([''] * 6) +
          ['Sin sexo'] + ([''] * 6) + ['Otro sexo'] + ([''] * 6)
        hoja.add_row l2, style: [estilo_encabezado] * numcol
        hoja.merge_cells("X6:AD6")
        hoja.merge_cells("AE6:AK6")
        hoja.merge_cells("AL6:AR6")
        hoja.merge_cells("AS6:AY6")

        hoja.add_row l, style: [estilo_encabezado] * numcol

        registros.each do |reg|
          l = [
            reg.id.to_s,
            reg.nombre,
            reg.presenta('fecha'),
            reg.presenta('lugar'),
            reg.presenta('oficina'),
            reg.presenta('proyectofinanciero'),
            reg.presenta('actividadpf'),
            reg.presenta('proyecto'),
            reg.presenta('subarea'),
            reg.presenta('responsable'),
            reg.presenta('corresponsables'),
            reg.presenta('objetivo'),
            reg.presenta('resultado'),
            reg.presenta('poblacion'),
            reg.presenta('observaciones'),
            reg.created_at.to_s,
            reg.updated_at.to_s,
            reg.presenta('poblacion_mujeres_r'),
            reg.presenta('poblacion_hombres_r'),
            reg.presenta('poblacion_sinsexo'),
            reg.presenta('poblacion_intersexuales'),
            reg.presenta('poblacion_mujeres_l'),
            reg.presenta('poblacion_hombres_l'),
            reg.presenta('poblacion_mujeres_r_g1'),
            reg.presenta('poblacion_mujeres_r_g2'),
            reg.presenta('poblacion_mujeres_r_g3'),
            reg.presenta('poblacion_mujeres_r_g4'),
            reg.presenta('poblacion_mujeres_r_g5'),
            reg.presenta('poblacion_mujeres_r_g6'),
            reg.presenta('poblacion_mujeres_r_g7'),
            reg.presenta('poblacion_hombres_r_g1'),
            reg.presenta('poblacion_hombres_r_g2'),
            reg.presenta('poblacion_hombres_r_g3'),
            reg.presenta('poblacion_hombres_r_g4'),
            reg.presenta('poblacion_hombres_r_g5'),
            reg.presenta('poblacion_hombres_r_g6'),
            reg.presenta('poblacion_hombres_r_g7'),
            reg.presenta('poblacion_sinsexo_g1'),
            reg.presenta('poblacion_sinsexo_g2'),
            reg.presenta('poblacion_sinsexo_g3'),
            reg.presenta('poblacion_sinsexo_g4'),
            reg.presenta('poblacion_sinsexo_g5'),
            reg.presenta('poblacion_sinsexo_g6'),
            reg.presenta('poblacion_sinsexo_g7'),
            reg.presenta('poblacion_intersexuales_g1'),
            reg.presenta('poblacion_intersexuales_g2'),
            reg.presenta('poblacion_intersexuales_g3'),
            reg.presenta('poblacion_intersexuales_g4'),
            reg.presenta('poblacion_intersexuales_g5'),
            reg.presenta('poblacion_intersexuales_g6'),
            reg.presenta('poblacion_intersexuales_g7')
          ]
          hoja.add_row l, style: estilo_base
        end
        anchos = [20] * numcol
        hoja.column_widths(*anchos)
        ultf = 0
        hoja.rows.last.tap do |row|
          ultf = row.row_index
        end
        if ultf>0
          l = [nil] * numcol
          hoja.add_row l
        end
      end

      n=File.join('/tmp', File.basename(narch + ".xlsx"))
      p.serialize n
      FileUtils.rm(narch + "#{extension}-0")

      return n
    end

    def self.vista_reporte_extracompleto_excel(
      plant, registros, narch, parsimp, extension, params)

      ruta = File.join(Rails.application.config.x.heb412_ruta, 
                       plant.ruta).to_s

      p = Axlsx::Package.new
      lt = p.workbook
      e = lt.styles

      estilo_base = e.add_style sz: 12
      estilo_titulo = e.add_style sz: 20
      estilo_titulo2 = e.add_style sz: 16
      estilo_encabezado = e.add_style sz: 12, b: true
      #, fg_color: 'FF0000', bg_color: '00FF00'

      logo = File.expand_path('app/assets/images/logo.jpg')
      l = [
        'Id',
        'Fecha',
        'Nombre',
        'Área(s)',
        'Actividad(es) de marco lógico',
        'Convenios financiados',
        'Oficina',
        'Responsable',
        'Objetivo',
        'Resultado',
        'Población',
        'Lugar',
        'Subárea(s)',
        'Corresponsables',
        'Observaciones',
        'Fecha de creación',
        'Fecha de actualización',
        'Total mujeres beneficiadas',
        'Total hombres beneficiados',
        'Total beneficiarios sin sexo',
        'Total beneficiarios otro sexo',
        'Mujeres JRS',
        'Hombres JRS',
        '0-5',
        '6-12',
        '13-17',
        '18-26',
        '27-59',
        '60+',
        'Sin RE',
        '0-5',
        '6-12',
        '13-17',
        '18-26',
        '27-59',
        '60+',
        'Sin RE',
        '0-5',
        '6-12',
        '13-17',
        '18-26',
        '27-59',
        '60+',
        'Sin RE',
        '0-5',
        '6-12',
        '13-17',
        '18-26',
        '27-59',
        '60+',
        'Sin RE',
        'Descr. Anexo 1',
        'Descr. Anexo 2',
        'Descr. Anexo 3',
        'Descr. Anexo 4',
        'Descr. Anexo 5',
        'Covid19',
        'Departamento',
        'Municipio',
        'Lugar',
        'Población ids',
        'DVRE – Derechos Vulnerados',
        'DVRE – Se brindo informaciones',
        'DVRE – Acciones persona_id',
        'DVRE – Ayuda del estadounidenses',
        'DVRE – Cantidad Ayuda Estadounidenses',
        'DVRE – Instituciones que ayudaron',
        'DVRE – Programas respuesta Estado',
        'DVRE – Dificultades y observaciones',
        'DVRE – Asistencia Humanitaria',
        'DVRE – Detalle Asistencia Humanitaria',
        'ASJ – Asesoria Juridica',
        'ASJ – Detalle Asesoria Juridica',
        'ACJ - Accion Juridica 1',
        'ACJ – Respuesta 1',
        'ACJ – Accion juridica 2',
        'ACJ – Respuesta 2',
        'OSA – Otros servicios y asesorias',
        'OSA – Detalle otros servicios y asesorias',
        'Organizaciones sociales',
        'Ids de organizaciones sociales',
        'Ids de casos asociados',
        'Numero de anexos',
        'Ids de Anexos',
        'Núm. Detalles Financieros',
        'Ids de detalles Financieros'
      ]
      numcol = l.length
      colfin = Heb412Gen::PlantillaHelper.numero_a_columna(numcol)
      anchos = [18, 12, 25] + ([20] * (numcol-3))


      lt.add_worksheet do |hoja|
        hoja.add_image(image_src: logo, start_at: 'A1', end_at: 'C3')
        hoja.add_row [nil, nil, 'Servicio Jesuita a Refugiados - Colombia'] +
          [nil]*(numcol-3), height: 30, style: estilo_titulo
        hoja.add_row [nil, nil, 'Reporte Extracompleto de Actividades', nil, nil, 'SI-JRSCOL'] + [nil]*(numcol-6), height: 30, style: estilo_titulo2
        hoja.add_row []
        idpf = (!params['filtro'] || 
                !params['filtro']['busproyectofinanciero_nombre'] || 
                params['filtro']['busproyectofinanciero_nombre'] == ''
               ) ? nil : params['filtro']['busproyectofinanciero_nombre']
        npf = idpf.nil? ? '' :
          Cor1440Gen::Proyectofinanciero.where(id: idpf).
          pluck(:nombre).join('; ')

        hoja.add_row ['Fecha inicial', params['filtro']['busfechaini'], 
          'Convenio financiero', npf],  style: estilo_base

        idaml = (!params['filtro'] || 
                 !params['filtro']['busactividadpf_nombre'] || 
                 params['filtro']['busactividadpf_nombre'] == ''
                ) ? nil : params['filtro']['busactividadpf_nombre']
        naml = idaml.nil? ? '' :
          Cor1440Gen::Actividadpf.where(id: idaml).
          pluck(:titulo).join('; ')
        hoja.add_row ['Fecha final', params['filtro']['busfechafin'], 
          'Actividades de marco lógico', naml],  style: estilo_base


        hoja.add_row []

        hoja.merge_cells("A1:B2")
        hoja.merge_cells("C1:#{colfin}1")
        hoja.merge_cells("C2:E2")
        hoja.merge_cells("F2:#{colfin}2")

        hoja.add_border "A1:B2"
        hoja.add_border "C1:#{colfin}1"
        hoja.add_border "C2:E2"
        hoja.add_border "F2:H2"
        hoja.add_border "A4:D5"
        # hoja.add_border "B3:D3", { edges: [:top], style: :thick }

        l2 = ([''] * 23) + ['Mujeres'] + ([''] * 6) + ['Hombres'] + ([''] * 6) +
          ['Sin sexo'] + ([''] * 6) + ['Otro sexo'] + ([''] * 6)
        hoja.add_row l2, style: [estilo_encabezado] * numcol

        hoja.merge_cells("X7:AD7")
        hoja.merge_cells("AE7:AK7")
        hoja.merge_cells("AL7:AR7")
        hoja.merge_cells("AS7:AY7")

        hoja.add_row l, style: [estilo_encabezado] * numcol
        hoja.add_border "A4:D5"

        registros.each do |reg|
          l = [
            reg.id.to_s,
            reg.presenta('fecha'),
            reg.nombre,
            reg.presenta('áreas_de_actividad'),
            reg.presenta('actividad_del_marco_lógico'),
            reg.presenta('convenio_financiado'),
            reg.presenta('oficina'),
            reg.presenta('responsable'),
            reg.presenta('objetivo'),
            reg.presenta('resultado'),
            reg.presenta('poblacion'),
            reg.presenta('lugar'),
            reg.presenta('subáreas'),
            reg.presenta('corresponsables'),
            reg.presenta('observaciones'),
            reg.presenta('creacion'),
            reg.presenta('actualizacion'),
            reg.presenta('poblacion_mujeres_r'),
            reg.presenta('poblacion_hombres_r'),
            reg.presenta('poblacion_sinsexo'),
            reg.presenta('poblacion_intersexuales'),
            reg.presenta('poblacion_mujeres_l'),
            reg.presenta('poblacion_hombres_l'),
            reg.presenta('poblacion_mujeres_r_g1'),
            reg.presenta('poblacion_mujeres_r_g2'),
            reg.presenta('poblacion_mujeres_r_g3'),
            reg.presenta('poblacion_mujeres_r_g4'),
            reg.presenta('poblacion_mujeres_r_g5'),
            reg.presenta('poblacion_mujeres_r_g6'),
            reg.presenta('poblacion_mujeres_r_g7'),
            reg.presenta('poblacion_hombres_r_g1'),
            reg.presenta('poblacion_hombres_r_g2'),
            reg.presenta('poblacion_hombres_r_g3'),
            reg.presenta('poblacion_hombres_r_g4'),
            reg.presenta('poblacion_hombres_r_g5'),
            reg.presenta('poblacion_hombres_r_g6'),
            reg.presenta('poblacion_hombres_r_g7'),
            reg.presenta('poblacion_sinsexo_g1'),
            reg.presenta('poblacion_sinsexo_g2'),
            reg.presenta('poblacion_sinsexo_g3'),
            reg.presenta('poblacion_sinsexo_g4'),
            reg.presenta('poblacion_sinsexo_g5'),
            reg.presenta('poblacion_sinsexo_g6'),
            reg.presenta('poblacion_sinsexo_g7'),
            reg.presenta('poblacion_intersexuales_g1'),
            reg.presenta('poblacion_intersexuales_g2'),
            reg.presenta('poblacion_intersexuales_g3'),
            reg.presenta('poblacion_intersexuales_g4'),
            reg.presenta('poblacion_intersexuales_g5'),
            reg.presenta('poblacion_intersexuales_g6'),
            reg.presenta('poblacion_intersexuales_g7'),
            reg.presenta('anexo_1_desc'),
            reg.presenta('anexo_2_desc'),
            reg.presenta('anexo_3_desc'),
            reg.presenta('anexo_4_desc'),
            reg.presenta('anexo_5_desc'),
            reg.presenta('covid19'),
            reg.presenta('departamento'),
            reg.presenta('municipio'),
            reg.presenta('lugar'),
            reg.presenta('poblacion_ids'),
            reg.presenta('derechos_vulnerados_respuesta_estado.derechos_vulnerados'),
            reg.presenta('derechos_vulnerados_respuesta_estado.se_brindo_informacion'),
            reg.presenta('derechos_vulnerados_respuesta_estado.acciones_persona'),
            reg.presenta('derechos_vulnerados_respuesta_estado.ayuda_del_estado'),
            reg.presenta('derechos_vulnerados_respuesta_estado.cantidad_ayuda_estado'),
            reg.presenta('derechos_vulnerados_respuesta_estado.instituciones_que_ayudaron'),
            reg.presenta('derechos_vulnerados_respuesta_estado.programas_respuesta_estado'),
            reg.presenta('derechos_vulnerados_respuesta_estado.Comentarios adicionales frente a la respuesta del EStado'),
            reg.presenta('asistencia_humanitaria.asistencia_humanitaria'),
            reg.presenta('asistencia_humanitaria.detalle_asistencia_humanitaria'),
            reg.presenta('asesoria_juridica.asesoria_juridica'),
            reg.presenta('asesoria_juridica.detalle_asesoria_juridica'),
            reg.presenta('accion_juridica.accion_juridica_1'),
            reg.presenta('accion_juridica.respuesta_1'),
            reg.presenta('accion_juridica.accion_juridica_2'),
            reg.presenta('accion_juridica.respuesta_2'),
            reg.presenta('otros_servicios_asesorias_caso.otros_servicios_asesorias'),
            reg.presenta('otros_servicios_asesorias_caso.detalle_otros_servicios_asesorias'),
            reg.presenta('organizaciones_sociales'),
            reg.presenta('organizaciones_sociales_ids'),
            reg.presenta('casos_asociados'),
            reg.presenta('numero_anexos'),
            reg.presenta('anexos_ids'),
            reg.presenta('numero_detalles_financieros'),
            reg.presenta('detalles_financieros_ids'),
          ]
          hoja.add_row l, style: estilo_base
        end

        hoja.column_widths(*anchos)
        ultf = 0
        hoja.rows.last.tap do |row|
          ultf = row.row_index
        end
        if ultf>0
          l = [nil] * numcol
          hoja.add_row l
        end
      end

      n=File.join('/tmp', File.basename(narch + ".xlsx"))
      p.serialize n
      FileUtils.rm(narch + "#{extension}-0")

      return n
    end


    def self.vista_reporte_psu_excel(
      plant, registros, narch, parsimp, extension, params)

      ruta = File.join(Rails.application.config.x.heb412_ruta, 
                       plant.ruta).to_s

      p = Axlsx::Package.new
      lt = p.workbook
      e = lt.styles

      estilo_base = e.add_style sz: 12
      estilo_titulo = e.add_style sz: 20
      estilo_encabezado = e.add_style sz: 12, b: true
      #, fg_color: 'FF0000', bg_color: '00FF00'

      lt.add_worksheet do |hoja|
        hoja.add_row ['Reporte PSU de Actividades'], 
          height: 30, style: estilo_titulo
        hoja.add_row []
        hoja.add_row [
          'Fecha inicial', params['filtro']['busfechaini'], 
          'Fecha final', params['filtro']['busfechafin'] ], style: estilo_base
        idpf = (!params['filtro'] || 
                !params['filtro']['busproyectofinanciero_nombre'] || 
                params['filtro']['busproyectofinanciero_nombre'] == ''
               ) ? nil : params['filtro']['busproyectofinanciero_nombre']
        idaml = (!params['filtro'] || 
                 !params['filtro']['busactividadpf_nombre'] || 
                 params['filtro']['busactividadpf_nombre'] == ''
                ) ? nil : params['filtro']['busactividadpf_nombre']

        npf = idpf.nil? ? '' :
          Cor1440Gen::Proyectofinanciero.where(id: idpf).
          pluck(:nombre).join('; ')
        naml = idaml.nil? ? '' :
          Cor1440Gen::Actividadpf.where(id: idaml).
          pluck(:titulo).join('; ')

        hoja.add_row ['Convenio financiero', npf, 'Actividad de marco lógico', naml], style: estilo_base
        hoja.add_row []
        l = [
          'Id',
          'Fecha',
          'Nombre',
          'Área(s)',
          'Actividad(es) de convenio',
          'Convenios financiados',
          'Oficina',
          'Responsable',
          'Objetivo',
          'Resultado',
          'Población',
          'Anexos',
        ]
        numcol = l.length
        colfin = Heb412Gen::PlantillaHelper.numero_a_columna(numcol)

        hoja.merge_cells("A1:#{colfin}1")

        hoja.add_row l, style: [estilo_encabezado] * numcol

        registros.each do |reg|
          l = [
            reg.id.to_s,
            reg.presenta('fecha'),
            reg.nombre,
            reg.presenta('proyecto'),
            reg.presenta('actividadpf'),
            reg.presenta('proyectofinanciero'),
            reg.presenta('oficina'),
            reg.presenta('responsable'),
            reg.presenta('objetivo'),
            reg.presenta('resultado'),
            reg.presenta('poblacion'),
            reg.presenta('numero_anexos'),
          ]
          hoja.add_row l, style: estilo_base
        end
        anchos = [20] * numcol
        hoja.column_widths(*anchos)
        ultf = 0
        hoja.rows.last.tap do |row|
          ultf = row.row_index
        end
        if ultf>0
          l = [nil] * numcol
          hoja.add_row l
        end
      end

      n=File.join('/tmp', File.basename(narch + ".xlsx"))
      p.serialize n
      FileUtils.rm(narch + "#{extension}-0")

      return n
    end


  end
end
