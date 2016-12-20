# nombres-argentinos

Proyecto de visualización de estadísticas sobre nombres de nacimientos argentinos de 1922 a 2015.

<!-- NO MODIFICAR NI INDICE NI TITULOS -->
## Índice

* [Instalación](#instalación)
	* [Dependencias](#dependencias)
	* [Generación de data](#generación-de-data)
    * [Iniciar el servidor](#iniciar-el-servidor-en-development)
* [Créditos](#créditos)
* [Contacto](#contacto)

## Instalación

### Dependencias

* Ruby
* Python
  * pip
  * pandas

#### Generación de data

1. Instalar `pandas`: `pip install pandas`
2. Cambiar el path del archivo csv con la data de nombres por el correpondiente en `process_names.py`.
3. Correr `process_names.py`: `python process_names.py`
4. Verificar que los jsons fueron generados en `public/names/` y `public/years/`

##### Nota sobre los datos

En `data/` pueden encontrar:
- Una muestra de los datos usados para el proyecto de nombres argentinos.
- Todos los datos de nombres argentinos, pero sin la columna de género, ya que la misma fue calculada de manera predictiva.

#### Iniciar el servidor en development

1. Asegurarse que el host está correctamente configurado en `app.rb`
2. Iniciar el servidor en el puerto 9393: `bundle exec shotgun -p 9393`
3. Ir a `127.0.0.1:9393/` y confirmar que la web está corriendo correctamente.

## Créditos

Este proyecto estuvo inspirado en el proyecto de [DATA Uruguay](http://data.180.com.uy/) hecho con los nombres de nacimiento de Montevideo. Agradecemos su ayuda, colaboración y código abierto :)

## Contacto

<!-- TEXTO FIJO - NO MODIFICAR -->
Te invitamos a [creanos un issue](https://github.com/datosgobar/nombres-argentinos/issues/new?title=Encontre un bug en nombre-del-repo) en caso de que encuentres algún bug o tengas feedback de alguna parte de `nombres-argentinos`.

Para todo lo demás, podés mandarnos tu comentario o consulta a [datos@modernizacion.gob.ar](mailto:datos@modernizacion.gob.ar).