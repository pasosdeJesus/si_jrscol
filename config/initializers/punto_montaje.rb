SiJrscol::Application.config.relative_url_root = ENV.fetch(
  'RUTA_RELATIVA', '/')
SiJrscol::Application.config.assets.prefix = ENV.fetch(
  'RUTA_RELATIVA', '/') + 'assets'
