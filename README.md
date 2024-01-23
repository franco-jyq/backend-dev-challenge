# Backend Dev Challenge

Dependencias:

- Ruby 3.3.0
- Rails 7.1.3

## Instalacion

La aplicacion escucha las peticiones en el localhost:3001

### Docker

Clonar el repositorio y setear la variable de entorno `RAILS_MASTER_KEY` utilizando como valor la clave compartida en el mail.<br>
Ejecutar el comando:

```bash
 docker-compose up
```

### Local

Descargar el repositorio y las dependencias. <br>
Ejecutar el comando:

```bash
rails s
```

### Tests

Ejecutar los test en el entorno local.

```bash
rails test
```
