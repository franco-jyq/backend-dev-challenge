# Backend Dev Challenge

Dependencias:

- Ruby 3.3.0
- Rails 7.1.3

## Instalacion

La aplicación está configurada para responder a las solicitudes entrantes a través del protocolo HTTP en el puerto 3000 del entorno de desarrollo local (localhost:3000).

#### Ejecución con Docker

Clonar el repositorio y setear la variable de entorno `RAILS_MASTER_KEY` utilizando como valor la clave compartida en el mail.<br>
Con el siguiente comando se levanta el servidor y se corren las pruebas.

```bash
 docker-compose up
```

#### Ejecución local

Descargar el repositorio y las dependencias. <br>
Dentro de la carpeta ejecutar el comando `rails s` para levantar el servidor y sincronizar la base de datos.

#### Tests

Dentro de la carpeta ejecutar el comando `rails test` para ejecutar los `tests unitarios` y los `tests de integración`. Los mismos se encuentran en los directorios `test/models` y `test/controllers`.

## Endpoints

A continuación se listaran los endpoints disponibles y algunos de los comportamientos que fueron validados y se proporcionan ejemplos que utilizan la herramienta curl para ilustrar cómo se deben especificar los parámetros necesarios.<br>

### Creación de usuario

```bash
curl -X POST http://localhost:3000/users -H "Content-Type: application/json" \
-d '{"user": {"email": "fudo@example.com", "password": "fudo-secret"}}'
```

- Crear usuario exitosamente.
- Crear usuario que ya existe.
- Crear usuario sin mail.
- Crear usuario sin contraseña.

### Login de usuario

El logueo exitoso devolvera un token que luego puede ser usado para crear y obtener una lista de los productos creados.

```bash
curl POST http://localhost:3000/users/login -H "Content-Type: application/json" \
-d '{"user": {"email":"fudo@example.com", "password":"fudo-secret"}}'
```

- Loguear usuario exitosamente.
- Loguear con contraseña incorrecta.
- Loguear usuario que no existe.
- Loguear sin mail.
- Loguear sin contraseña.

### Deslogueo de usuario

El deslogueo del usuario invalidara el token asociado al usuario que fue creado/logueado.

```bash
curl POST http://localhost:3000/users/logout -H "Content-Type: application/json" \
-d '{"user": {"email":"fudo@example.com", "password":"fudo-secret" }  }'
```

- Token de usuario deslogueado ya no es valido
- Desloguear usuario exitosamente
- Desloguear con contraseña incorrecta.
- Desloguear usuario inexistente.
- Desloguear sin mail.
- Desloguear sin contraseña.

### Creación de productos

Donde dice `token` reemplazar por uno de los tokens obtenidos a la hora de crear o loguear un usuario.

```bash
curl -X POST http://localhost:3000/products
-H 'Authorization: Bearer token'
-H 'Content-Type: application/json'
-d '{ "product": { "product_name": "fudo product" } }'
```

- Crear producto exitosamente.
- Crear producto sin token.
- Crear producto sin nombre.
- Crear producto con caracteres invalidos. (solo se permiten letras, espacios y números).

### Listado de productos creados

Donde dice `token`` reemplazar por uno de los tokens obtenidos a la hora de crear o loguear un usuario.

```bash
curl -X GET http://localhost:3000/products \
-H 'Authorization: Bearer token'
```

- Listar productos exitosamente.
- Listar productos con token invalido.
- Listar productos sin token.

## Autenticación

La autenticación de los endpoints se implementó siguiendo los principios y recomendaciones del artículo "How to Implement API Key Authentication in Rails without Devise" disponible en https://keygen.sh/blog/how-to-implement-api-key-authentication-in-rails-without-devise/.

### Generación de token

La generación de tokens para la autenticación se llevó a cabo utilizando la REST API de Firebase, aprovechando los endpoints proporcionados por Firebase Authentication.

- Se utilizó el endpoint https://identitytoolkit.googleapis.com/v1/accounts:signUp para crear nuevos usuarios mediante la especificación de credenciales como correo electrónico y contraseña.

- Para iniciar sesión y obtener el token de acceso, se empleó el endpoint https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword.
