# SI-JRSCOL, Sistema de información del JRS Colombia

[![Revisado por Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com) Pruebas y seguridad:[![Estado Construcción](https://gitlab.com/pasosdeJesus/si_jrscol/badges/main/pipeline.svg)](https://gitlab.com/pasosdeJesus/si_jrscol/-/pipelines?page=1&scope=all&ref=main) [![Estado Construcción 2](https://travis-ci.com/pasosdeJesus/si_jrscol.svg?branch=main)](https://travis-ci.com/gitlab/pasosdeJesus/si_jrscol) [![Clima del Código](https://api.codeclimate.com/v1/badges/7dec7636a89457304fa3/maintainability)](https://codeclimate.com/github/pasosdeJesus/si_jrscol/maintainability) [![Cobertura de Pruebas](https://api.codeclimate.com/v1/badges/7dec7636a89457304fa3/test_coverage)](https://codeclimate.com/github/pasosdeJesus/si_jrscol/test_coverage)

### Documentación para usuarios finales

Disponible en <https://docs.google.com/document/d/1qxJOBzbG_lQPN0nfhlJ1QyeRO4a9hrYlK8Z_bRO3UJU/edit?usp=sharing>


### Requerimientos
* Ruby version >= 3.0.1
* PostgreSQL >= 13.3 con extension unaccent
* Recomendado sobre adJ 6.8 (que incluye todos los componentes mencionados). 
* La cuenta desde la cual se ejecute el servidor o las pruebas debe poder abrir 2048 archivos --en 
adJ se establece en la clase del usuario que ejecuta en `/etc/login.conf` con `:openfiles-cur=2048:`


### Configuración e instalación
Aplican las mismas instrucciones de SIVeL 2
<https://github.com/pasosdeJesus/sivel2>

### Arquitectura
Se ha desarrollado sobre:
* [sip](https://github.com/pasosdeJesus/sip)
* [mr519_gen](https://github.com/pasosdeJesus/mr519_gen)
* [heb412_gen](https://github.com/pasosdeJesus/heb412_gen)
* [sivel2_gen](https://github.com/pasosdeJesus/sivel2_gen)
* [sivel2_sjr](https://github.com/pasosdeJesus/sivel2_sjr)
* [cor1440_gen](https://github.com/pasosdeJesus/cor1440_gen)
* [sal7711_gen](https://github.com/pasosdeJesus/sal7711_gen)


