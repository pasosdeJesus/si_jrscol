# frozen_string_literal: true

module SevenzHelper

  # Trata de normalizar cadenas con UTF-8 problematico debido a
  # codificación errada o a problemas de 7z
  def normaliza_utf8 l
    l
      .gsub(["c383c283c382c281"].pack('H*').force_encoding('UTF-8'), 'Á')
      .gsub(["c383c283c382c289"].pack('H*').force_encoding('UTF-8'), 'É')
      .gsub(["c383c283c382c28d"].pack('H*').force_encoding('UTF-8'), 'Í')
      .gsub(["c383c283c382c291"].pack('H*').force_encoding('UTF-8'), 'Ñ')
      .gsub(["c383c283c382c293"].pack('H*').force_encoding('UTF-8'), 'Ó')
      .gsub(["c383c28cc382c281"].pack('H*').force_encoding('UTF-8'), 'ó')
      .gsub(["c383c28cc382c283"].pack('H*').force_encoding('UTF-8'), 'Ì')
      .gsub(["c383c283c382c2ad"].pack('H*').force_encoding('UTF-8'), 'í')
      .gsub(["c383c281"].pack('H*').force_encoding('UTF-8'), 'Á')
      .gsub(["c383c289"].pack('H*').force_encoding('UTF-8'), 'É')
      .gsub(["c383c28d"].pack('H*').force_encoding('UTF-8'), 'Í')
      .gsub(["c383c291"].pack('H*').force_encoding('UTF-8'), 'Ñ')
      .gsub(["c383c293"].pack('H*').force_encoding('UTF-8'), 'Ó')
      .gsub(["6fc38cc281"].pack('H*').force_encoding('UTF-8'), 'ó')
      .gsub(["c38cc281"].pack('H*').force_encoding('UTF-8'), 'ó')
      .gsub(["c383c2ad"].pack('H*').force_encoding('UTF-8'), 'í')
      .gsub(["cc83"].pack('H*').force_encoding('UTF-8'), 'Ì')
      .gsub('ÃÂ¡', 'á')
      .gsub('ÃÂ©', 'é')
      .gsub('ÃÂ±', 'ñ')
      .gsub('ÃÂ³', 'ó')
      .gsub('ÃÂº', 'ú')
      .gsub('ÂÂ°', '°')
      .gsub('ÃÂ²', 'ò')
      .gsub('Ã¡', 'á')
      .gsub('Ã©', 'é')
      .gsub('Ã±', 'ñ')
      .gsub('Ã³', 'ó')
      .gsub('Ãº', 'ú')
      .gsub('Â°', '°')
      .gsub('Ã²', 'ò')
  end
  module_function :normaliza_utf8

end
