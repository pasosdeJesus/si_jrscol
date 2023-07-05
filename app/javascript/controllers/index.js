// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import Msip__CancelarVacioEsEliminarController from "./msip/cancelar_vacio_es_eliminar_controller"
application.register("msip--cancelar-vacio-es-eliminar", Msip__CancelarVacioEsEliminarController)

import Msip__SindocautController from "./msip/sindocaut_controller"
application.register("msip--sindocaut", Msip__SindocautController)

import PersonaPptController from "./persona_ppt_controller"
application.register("persona-ppt", PersonaPptController)

import RapidobenefcasoController from "./rapidobenefcaso_controller"
application.register("rapidobenefcaso", RapidobenefcasoController)

import RespuestacasoController from "./respuestacaso_controller"
application.register("respuestacaso", RespuestacasoController)

import VisibuemController from "./visibuem_controller"
application.register("visibuem", VisibuemController)
