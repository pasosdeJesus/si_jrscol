/* eslint no-console:0 */

// Este archivo de compila automaticamente con Webpack, junto con otros
// archivos presentes en este directorio.  Lo animamos a poner la lógica
// de su aplicación en una estructura relevante en app/javascript y usar
// solo estos archivos pack para referenciar ese código de manera que sea
// compilado.
//
// Para referenciar este archivo agregue 
// <%= javascript_pack_tag 'application' %> 
// en el archivo de maquetación adecuado, como 
// app/views/layouts/application.html.erb


// Quite el comentario para copiar todas las imágenes estáticas de
// ../images en la carpeta de salida y referencielas con el auxiliar
// image_pack_tag en las vistas (e.g <%= image_pack_tag 'rails.png' %>)
// o con el siguiente auxiliar `imagePath`:
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

console.log('Hola Mundo desde Webpacker')

import Rails from "@rails/ujs"
window.Rails = Rails
Rails.start()

import Turbolinks from "turbolinks"
Turbolinks.start()

import './jquery'
import '../../vendedor/recursos/javascripts/jquery-ui'

import Asistentes from './asistentes'
Asistentes.iniciar()

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
