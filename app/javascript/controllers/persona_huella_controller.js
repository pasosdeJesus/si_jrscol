import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Conecta con data-controller="persona-huella"
  // En el boton de leer huella agregar
  // data-persona-huella-action='change->persona-huella#lee_huella
  // En el campo de la huella agregar
  // data-persona-huella-target='huella'

  static targets = [ 
    "huella"
  ]

  connect() {
    console.log('conectado controlador persona_huella_controller')
  }

  
  leer_huella(e) {
    e.preventDefault();
    alert("Cuando se enciena el lector de huellas, "+
      "pon el dedo con la huella más nitida " +
      "y retiralo cuando se apague.\n" +
      "Cuando se vuelva a encender  vuelve a poner " + 
      "el mismo dedo hasta que se apague.\n"); 
    console.log('conectado controlador persona_huella_controller');
    fetch("http://127.0.0.1:8888/v1/servirhuella.json", {
      method: 'GET',
      headers: {
        Accept: 'application/json',
        mode: 'no-cors',
      },
    },
    ).then(response => {
      if (response.ok) {
        response.json().then(json => {
          console.log(json);
          this.huellaTarget.value = json;
        });
      } else {
        alert(response);
      }
    });
      /*  if (response.ok) {
          return response.json();
        }
        alert("Problema: " + response);
      })
      .then((responseJson) => {
        this.huellaTarget.value = responseJson;
        return;
      }) */
  } 
}
