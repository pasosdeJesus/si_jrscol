import { Controller } from "@hotwired/stimulus"
// Inicializa lo necesario tras cargar página

import Msip__Motor from './msip/motor'
import TomSelect from 'tom-select';

export default class extends Controller {

  // Este se ejecuta cuando se presenta el body de la página,
  // Pero eso podría ser antes de que se complete la carga de
  //   javascript/application.js
  static targets = [ ]

  connect() {
    console.log('conectado controlador inicializa_controller')
    document.querySelectorAll('.tom-select').forEach((el)=>{
      new TomSelect(el, window.configuracionTomSelect);
    });

  }

}
