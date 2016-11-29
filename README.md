# nombres-argentinos

Proyecto de visualización de estadísticas sobre nombres de nacimientos argentinos de 1922 a 2015.

<!-- NO MODIFICAR NI INDICE NI TITULOS -->
## Índice

* [Instalación](#instalacion)
	* [Dependencias](#dependencias)
	* [Verificación de instalación](#verificacion-de-instalacion)
* [Créditos](#creditos)
* [Contacto](#contacto)

## Instalación

#### Generación de data

1. Cambiar el path del archivo csv con la data de nombres por el correpondiente en `data_generator.rb`.
2. Correr `data_generator.rb`:
```
ruby data_generator.rb
```

#### Iniciar el servidor 

Iniciar el servidor en modo dev en el puerto 9393:

```
bundle exec shotgun -p 9393
```

### Dependencias

* Ruby

### Verificación de instalación

Ir a `127.0.0.1:9393/` y confirmar que la web está corriendo correctamente.

## Créditos

Este proyecto estuvo inspirado en el proyecto de [DATA Uruguay](http://data.180.com.uy/) hecho con los nombres de nacimiento de Montevideo. Agradecemos su ayuda, colaboración y código abierto :)

## Contacto

<!-- TEXTO FIJO - NO MODIFICAR -->
Te invitamos a [creanos un issue](https://github.com/datosgobar/nombres-argentinos/issues/new?title=Encontre un bug en nombre-del-repo) en caso de que encuentres algún bug o tengas feedback de alguna parte de `nombres-argentinos`.

Para todo lo demás, podés mandarnos tu comentario o consulta a [datos@modernizacion.gob.ar](mailto:datos@modernizacion.gob.ar).