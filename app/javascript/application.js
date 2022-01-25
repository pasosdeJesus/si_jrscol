/* eslint no-console:0 */

console.log('Hola Mundo desde Webpacker')

import Rails from "@rails/ujs";
import "@hotwired/turbo-rails";
Rails.start();
window.Rails = Rails

import './jquery'
import '../../vendedor/recursos/javascripts/jquery-ui'

import 'gridstack'

import {AutocompletaAjaxExpreg} from '@pasosdejesus/autocompleta_ajax'
window.AutocompletaAjaxExpreg = AutocompletaAjaxExpreg  // Requerido por cor1440_gen para autocompletación en listado de asistencia

import AutocompletaAjaxVictimas from './AutocompletaAjaxVictimas.js'

import 'popper.js'              // Dialogos emergentes usados por bootstrap
import * as bootstrap from 'bootstrap'              // Maquetacion y elementos de diseño
import 'chosen-js/chosen.jquery';       // Cuadros de seleccion potenciados
import 'bootstrap-datepicker'
import 'bootstrap-datepicker/dist/locales/bootstrap-datepicker.es.min.js'

var L = require('leaflet');
var mc= require('leaflet.markercluster');

document.addEventListener('change', 
  function (event) {
    var m = event.target.id.match(/^caso_migracion_attributes_([0-9]*)_perfilmigracion_id$/)
    if (m != null) {
      var pd = document.getElementById('caso_migracion_attributes_' + m[1] +
        '_destino_pais_id').parentElement;
      var dd = document.getElementById('caso_migracion_attributes_' + m[1] +
        '_destino_departamento_id').parentElement;
      var md = document.getElementById('caso_migracion_attributes_' + m[1] +
        '_destino_municipio_id').parentElement;
      var cd = document.getElementById('caso_migracion_attributes_' + m[1] +
        '_destino_clase_id').parentElement;
      var fd = document.getElementById('caso_migracion_attributes_' + m[1] +
        '_fechaendestino').parentElement;
      if (event.target.checked) {
        pd.style.display = 'none'
        dd.style.display = 'none'
        md.style.display = 'none'
        cd.style.display = 'none'
        fd.style.display = 'none'
      } else {
        pd.style.display = ''
        dd.style.display = ''
        md.style.display = ''
        cd.style.display = ''
        fd.style.display = ''
      }

    }
  }
)

// https://turbo.hotwired.dev/handbook/building
// dice
// When possible, avoid using the turbo:load event to add other event listeners
// directly to elements on the page body. 
//
// Por eso cargamos una vez desde aquí una vez el resto de recursos manejados por
// sprockets hayan cargado

function otrosRecursosCargados(resolve) {
  if (typeof window.puntomontaje == 'undefined') {
    setTimeout(otrosRecursosCargados, 250, resolve)
    return false
  }
  resolve("otros recursos cargados")
  return true
}

let promesaOtrosRecursosCargados = new Promise((resolve, reject) => {
  otrosRecursosCargados(resolve)
})

promesaOtrosRecursosCargados.then((mensaje) => {
  // Lo que se necesita inicializar después de cargar recursos manejados por
  // sprockets
  console.log('Ejecutando inicialización de otros recursos manejados por sprockets tras suficiente timeout')
  root = window 
  sip_prepara_eventos_comunes(root)
  heb412_gen_prepara_eventos_comunes(root)
  mr519_gen_prepara_eventos_comunes(root)
  sivel2_gen_prepara_eventos_comunes(root,'antecedentes/causas')
  sivel2_sjr_prepara_eventos_comunes(root)
  cor1440_gen_prepara_eventos_comunes(root, 
    {'sin_eventos_recalcular_poblacion': 1})
  sal7711_gen_prepara_eventos_comunes(root)
  sivel2_sjr_prepara_eventos_unicos(root)
  sip_registra_cambios_para_bitacora(root)
  AutocompletaAjaxVictimas.iniciar()

})

document.addEventListener('load', (e) => {
  console.log('Se ejecuta DOMContentLoaded')
})

document.addEventListener('DOMContentLoaded', (e) => {
  console.log('Se ejecuta DOMContentLoaded')
})

document.addEventListener('turbo:load', (e) => {
  console.log('Se ejecuta turbo:load')
})

