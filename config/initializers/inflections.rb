# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Podria forzarse orden con:

#['msip', 'mr519_gen', 'heb412_gen', 'cor1440_gen',
# 'sivel2_gen', 'sivel2_sjr'].each do |s| 
#  byebug
#  require_dependency File.join(Gem::Specification.find_by_name(s).gem_dir,
#                             '/config/initializers/inflections.rb')
#end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'accionjuridica', 'accionesjuridicas'
  inflect.irregular 'autoridadrefugio', 'autoridadesrefugio'
  inflect.irregular 'benefactividadpf', 'benefactividadpf'
  inflect.irregular 'categoria', 'categorias'
  inflect.irregular 'categoriaprensa', 'categoriasprensa'
  inflect.irregular 'declaracionruv', 'declaracionesruv'
  inflect.irregular 'migracion', 'migraciones'
  inflect.irregular 'causaagresion', 'causasagresion'
  inflect.irregular 'causamigracion', 'causasmigracion'
  inflect.irregular 'claverespaldo', 'clavesrespaldos'
  inflect.irregular 'consgifmm', 'consgifmm'
  inflect.irregular 'detallefinanciero', 'detallesfinancieros'
  inflect.irregular 'depgifmm', 'depsgifmm'
  inflect.irregular 'dificultadmigracion', 'dificultadesmigracion'
  inflect.irregular 'discapacidad', 'discapacidades'
  inflect.irregular 'espaciopart', 'espaciospart'
  inflect.irregular 'indicadorgifmm', 'indicadoresgifmm'
  inflect.irregular 'frecuenciaentrega', 'frecuenciasentrega'
  inflect.irregular 'lineaorgsocial', 'lineasorgsocial'
  inflect.irregular 'motivosjr', 'motivossjr'
  inflect.irregular 'mecanismodeentrega', 'mecanismosdeentrega'
  inflect.irregular 'miembrofamiliar', 'miembrosfamiliar'
  inflect.irregular 'migracontactopre', 'migracontactospre'
  inflect.irregular 'modalidadentrega', 'modalidadesentrega'
  inflect.irregular 'mungifmm', 'munsgifmm'
  inflect.irregular 'perfilmigracion', 'perfilesmigracion'
  inflect.irregular 'trivalentepositiva', 'trivalentespositiva'
  inflect.irregular 'progestado', 'progsestado'
  inflect.irregular 'sectorgifmm', 'sectoresgifmm'
  inflect.irregular 'tipoorgsocial', 'tiposorgsocial'
  inflect.irregular 'tipoanexo', 'tiposanexo'
  inflect.irregular 'tipoproteccion', 'tiposproteccion'
  inflect.irregular 'tipotransferencia', 'tipostransferencia'
  inflect.irregular 'ubicacionpre', 'ubicacionespre'
  inflect.irregular 'unidadayuda', 'unidadesayuda'
  inflect.irregular 'viadeingreso', 'viasdeingreso'
  inflect.irregular 'agresionmigracion', 'agresionesmigracion'
end
