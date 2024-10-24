

console.log('Hola Mundo desde Webpacker')

import Rails from "@rails/ujs";
if (typeof window.Rails == 'undefined') {
  Rails.start();
  window.Rails = Rails;
}

import * as Turbo from '@hotwired/turbo-rails'

import './jquery'
import '../../vendor/assets/javascripts/jquery-ui'

import 'gridstack'

import {AutocompletaAjaxExpreg, AutocompletaAjaxCampotexto} from '@pasosdejesus/autocompleta_ajax'
window.AutocompletaAjaxExpreg = AutocompletaAjaxExpreg  // Requerido por cor1440_gen para autocompletación en listado de asistencia
window.AutocompletaAjaxCampotexto = AutocompletaAjaxCampotexto // Requerido por cor1440_gen para autocompletación en listado de asistencia

import 'popper.js'              // Dialogos emergentes usados por bootstrap
import * as bootstrap from 'bootstrap'              // Maquetacion y elementos de diseño

import TomSelect from 'tom-select';
window.TomSelect = TomSelect; 
window.configuracionTomSelect = {
  create: false,
  diacritics: true, //no sensitivo a acentos
  sortField: {
    field: "text",
    direction: "asc"
  }
}

import Msip__Motor from "./controllers/msip/motor"
window.Msip__Motor = Msip__Motor
Msip__Motor.iniciar()
import Mr519Gen__Motor from "./controllers/mr519_gen/motor"
window.Mr519Gen__Motor = Mr519Gen__Motor
import Heb412Gen__Motor from "./controllers/heb412_gen/motor"
window.Heb412Gen__Motor = Heb412Gen__Motor
import Cor1440Gen__Motor from "./controllers/cor1440_gen/motor"
window.Cor1440Gen__Motor = Cor1440Gen__Motor
import Sivel2Gen__Motor from "./controllers/sivel2_gen/motor"
window.Sivel2Gen__Motor = Sivel2Gen__Motor
import Jos19__Motor from "./controllers/jos19/motor"
window.Jos19__Motor = Jos19__Motor

var L = require('leaflet');
var mc= require('leaflet.markercluster');

import ApexCharts from 'apexcharts'
window.ApexCharts = ApexCharts
import apexes from 'apexcharts/dist/locales/es.json'
Apex.chart = {
  locales: [apexes],
  defaultLocale: 'es',
}

import "./caso_m"

import AutocompletaAjaxRapidobenefcaso from './AutocompletaAjaxRapidobenefcaso'
window.AutocompletaAjaxRapidobenefcaso = AutocompletaAjaxRapidobenefcaso 
// https://turbo.hotwired.dev/handbook/building
// dice
// When possible, avoid using the turbo:load event to add other event listeners
// directly to elements on the page body. 
//
// Por eso cargamos una vez desde aquí una vez el resto de recursos manejados por
// sprockets hayan cargado

let esperarRecursosSprocketsYDocumento = function (resolver) {
  if (typeof window.puntomontaje == 'undefined') {
    setTimeout(esperarRecursosSprocketsYDocumento, 100, resolver)
    return false
  }
  if (document.readyState !== 'complete') {
    setTimeout(esperarRecursosSprocketsYDocumento, 100, resolver)
    return false
  }
  resolver("Recursos manejados con sprockets cargados y documento presentado en navegador")
    return true
  }

let promesaRecursosSprocketsYDocumento = new Promise((resolver, rechazar) => {
  esperarRecursosSprocketsYDocumento(resolver)
})

promesaRecursosSprocketsYDocumento.then((mensaje) => {
  console.log(mensaje)
  var root = window;

  // Antes de iniciar motor sivel2_gen ponemos este, para que se ejecute antes del incluido en ese motor
  $(document).on('change', 
    '[id^=caso_victima_attributes][id$=persona_attributes_anionac]', function(event) {

      root = window
      anionac = $(this).val()
      prefIdVic = $(this).attr('id').slice(0, -27)
      r = $("[id=" + prefIdVic + "_rangoedadactual_id]")
      prefIdPer = $(this).attr('id').slice(0, -8)
      ponerVariablesEdad(root)
      if (anionac != '')  {
        edadActual = edadDeFechaNac(prefIdPer, 
          root.anioactual, root.mesactual, 
          root.diaactual)
        if (edadActual != '') {
          rid = buscarRangoEdad(+edadActual); 
          r.val(rid)
        }
      } else {
        r.val(6)
      }
      r.prop('disabled', true)
    })

  msip_prepara_eventos_comunes(root)
  heb412_gen_prepara_eventos_comunes(root)
  mr519_gen_prepara_eventos_comunes(root)
  sivel2_gen_prepara_eventos_comunes(root,'antecedentes/causas')
  sivel2_sjr_prepara_eventos_comunes(root)
  cor1440_gen_prepara_eventos_comunes(root, 
    {'sin_eventos_recalcular_poblacion': 1})
  sivel2_sjr_prepara_eventos_unicos(root)
  msip_registra_cambios_para_bitacora(root)

  window.AutocompletaAjaxRapidobenefcaso.iniciar()

})


document.addEventListener('turbo:load', (e) => {
 /* Lo que debe ejecutarse cada vez que turbo cargue una página,
 * tener cuidado porque puede dispararse el evento turbo varias
 * veces consecutivas al cargar una página.
 *
 * Ha resultado un método no confiable es más confiable 
 * el controlador stimulus app/controllers/inicializa_controller.js
 * y en el método `connect` poner lo que debe ejecutarse
 * cada vez que se cargue body de una página.
 * Aunque ese podría ejecutarse antes de que termine de
 * ejecutarse este app/javascript/application (y que se inicialicen
 * recurso sprockets).
 */
  
  console.log('Escuchador turbo:load')

  msip_ejecutarAlCargarPagina(window) // Establece root.puntomontaje
  Msip__Motor.ejecutarAlCargarPagina()
  Mr519Gen__Motor.ejecutarAlCargarPagina()
  Heb412Gen__Motor.ejecutarAlCargarPagina()
  Cor1440Gen__Motor.ejecutarAlCargarPagina()
  Sivel2Gen__Motor.ejecutarAlCargarPagina()
  Jos19__Motor.ejecutarAlCargarPagina()
})


document.addEventListener('turbo:frame-load', (e) => {
  document.body.style.cursor = 'default'
})


import "./controllers"
