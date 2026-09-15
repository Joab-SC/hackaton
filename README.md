# Hackaton

Sistema de gestión de una **hackathon** escrito en **Elixir**, con una arquitectura
**cliente–servidor distribuida** (nodos de Erlang) y una interfaz de **consola basada en comandos** (`/comando`).

Permite que participantes, mentores y administradores se registren, inicien sesión,
formen equipos, creen proyectos, suban avances, chateen (personal, grupal, con mentor
y por salas temáticas), reciban retroalimentación y vean anuncios globales.

---

## Requisitos

- **Elixir** `~> 1.15` (instala también Erlang/OTP).
- **Sin dependencias externas**: `mix.exs` no declara ninguna.
- Dos terminales (una para el servidor, una o más para los clientes).

---

## Cómo ejecutarlo

El sistema necesita **dos nodos**:

| Nodo | Rol | Qué hace |
|------|-----|----------|
| `nodoservidor` | Servidor | Procesa todas las operaciones (usuarios, equipos, proyectos, mensajes) y persiste en CSV. |
| `nodocliente` | Cliente | Interfaz de consola: lee los comandos y se los envía al servidor. |

### Terminal 1 — Servidor

```bash
elixir --sname nodoservidor -S mix run --no-halt lib/main_servidor.exs
```

### Terminal 2 — Cliente

```bash
elixir --sname nodocliente -S mix run lib/main.exs
```

Y ya: **no hay que editar ningún archivo** para probar el programa en tu máquina.

> Ejecuta los comandos **desde la raíz del proyecto** (donde está `mix.exs`): la persistencia
> en CSV se resuelve con rutas relativas, como `lib/hackaton/adapter/persistencia/usuario.csv`.

- La **cookie** de Erlang se fija sola en tiempo de ejecución (`:hackaton`), así que no hace
  falta pasar `--cookie`. Si quieres otra, define `HACKATON_COOKIE=mi_cookie` en ambos nodos.
- El **nodo servidor se resuelve automáticamente**: el cliente asume que el servidor corre en
  la misma máquina y busca `nodoservidor@<host de tu máquina>`. Todo eso vive en
  `Hackaton.Comunicacion.Conexion`, no hay nombres *hardcodeados*.
- Los dos nodos deben arrancarse **distribuidos** (`--sname` o `--name`). Si te olvidas del
  flag, el programa te lo dice con instrucciones en vez de quedarse colgado.

### Servidor en otra máquina (opcional)

El servidor imprime su propio nombre al arrancar. Para que un cliente de otra máquina se
conecte, pásale ese nombre en la variable `HACKATON_SERVIDOR`:

```bash
# Máquina del servidor
elixir --sname nodoservidor -S mix run --no-halt lib/main_servidor.exs
# => Nombre de este nodo: nodoservidor@mi-servidor

# Máquina del cliente
HACKATON_SERVIDOR=nodoservidor@mi-servidor elixir --sname nodocliente -S mix run lib/main.exs
```

Con `HACKATON_SERVIDOR=nodoservidor` (sin `@host`) se asume el host local.
Requiere que los **hostnames se resuelvan** entre ambas máquinas y que el puerto `4369`
(epmd) esté abierto.

### Uso

1. En el cliente verás el prompt `> `.
2. Escribe `/help` para ver los comandos disponibles según tu rol.
3. Sin sesión iniciada arrancas como **INCOGNITO**: solo `/registrarse`, `/login`, `/help` y `/salir`.
4. La base ya incluye un usuario **ADMIN** semilla (`usuario admin`, contraseña `admin`) para
   poder entrar la primera vez y registrar mentores.

> El proyecto **no trae pruebas** (la carpeta `test/` está vacía). Puedes verificar que
> todo compila con `mix compile` o `mix compile --warnings-as-errors`.

---

## Arquitectura

El proyecto sigue una **arquitectura por capas** con el patrón **Adapter**.
Un comando de consola atraviesa las capas así:

```text
Consola (comando /xxx)
   │
   ▼
Adapter ── Comandos         valida rol, argumentos y despacha con apply/3
   │
   ▼
Adapter ── Adapters.Adapter casos de uso (IO + llamada al nodo remoto)
   │
   ▼
Comunicacion.NodoCliente    envía {self(), funcion, args} al servicio remoto
   │        ══ red distribuida (Erlang) ══
   ▼
Comunicacion.NodoServidor   recibe, hace apply/3 y responde por mensaje
   │
   ▼
Services                    reglas de negocio y validaciones
   │
   ▼
Domain                      structs y validaciones puras
   │
   ▼
Adapter.BaseDatos           lectura / escritura en archivos CSV
```

Capas:

- **Domain** — entidades puras (`%Usuario{}`, `%Equipo{}`, `%Proyecto{}`, `%Mensaje{}`, `%Sala{}`)
  y sus validaciones (campos obligatorios, formatos, roles, categorías, estados).
- **Services** — lógica de negocio: unicidad de datos, hashing de contraseñas, generación de
  IDs y reglas (un proyecto por equipo, un equipo por participante, etc.).
- **Adapter/BaseDatos** — persistencia en archivos `.csv` (no hay motor de base de datos).
- **Adapter/Comandos** — el *router*: lee la entrada, valida rol + aridad y ejecuta el comando.
- **Adapter/Adapters** — casos de uso del cliente (toda la interacción por `IO`).
- **Adapter/Mensajes** — motor de chat (lector y escritor concurrentes con `Task`).
- **Comunicacion** — nodos Erlang distribuidos (cliente y servidor).
- **Util** — utilidades transversales (sesión global, encriptado, generación de IDs).

---

## Estructura de carpetas

```text
.
├── mix.exs                     # Definición del proyecto (app :hackathon, sin dependencias)
├── README.md                   # Este archivo
├── lib/
│   ├── main.exs                # Punto de entrada del CLIENTE (conecta al nodo servidor)
│   ├── main_servidor.exs       # Punto de entrada del SERVIDOR (supervisor + servicio)
│   └── hackaton/
│       ├── app_cliente.ex      # Supervisor del cliente (levanta SesionGlobal)
│       ├── app_servidor.ex     # Supervisor del servidor (SesionGlobal + NodoServidor)
│       │
│       ├── domain/             # #domain — Entidades y validaciones puras
│       │   ├── usuario.ex      #   %Usuario{}: roles, correo, teléfono, campos válidos
│       │   ├── equipo.ex       #   %Equipo{}: nombre + tema
│       │   ├── proyecto.ex     #   %Proyecto{}: categorías permitidas y estados
│       │   ├── mensaje.ex      #   %Mensaje{}: tipos de mensaje y de receptor
│       │   └── sala.ex         #   %Sala{}: tema + descripción
│       │
│       ├── services/           # #services — Lógica de negocio
│       │   ├── servicio_hackaton.ex   # Fachada que expone al servidor todas las operaciones
│       │   ├── servicio_usuario.ex    # Registro, login, unicidad, actualización, expulsión
│       │   ├── servicio_equipo.ex     # Registro, consulta y actualización de equipos
│       │   ├── servicio_proyecto.ex   # Proyectos, estados y búsquedas por categoría
│       │   ├── servicio_mensaje.ex    # Creación y filtrado de mensajes de todo tipo
│       │   └── servicio_sala.ex       # Salas temáticas
│       │
│       ├── adapter/            # #adapters #base_datos #comandos #mensajes #persistencia
│       │   ├── adapters/
│       │   │   └── adapter.ex         # Casos de uso: imprime por consola y llama al servidor
│       │   ├── comandos/
│       │   │   └── comandos.ex        # #comandos — Lee el prompt, valida permisos y despacha
│       │   ├── mensajes/
│       │   │   └── manejo_mensaje.ex  # #mensajes #comunicacion — Motor de chat (Task)
│       │   ├── base_datos/            # #base_datos — Acceso a CSV (leer/escribir/borrar/actualizar)
│       │   │   ├── base_datos_usuario.ex
│       │   │   ├── base_datos_equipo.ex
│       │   │   ├── base_datos_proyecto.ex
│       │   │   ├── base_datos_mensaje.ex
│       │   │   └── base_datos_sala.ex
│       │   └── persistencia/          # #persistencia — Los "datos" del sistema (CSV planos)
│       │       ├── usuario.csv        #   id,Rol,Nombre,Apellido,Cedula,Correo,Telefono,Usuario,Contrasena,id_equipo
│       │       ├── equipo.csv         #   id,Nombre,Tema
│       │       ├── proyecto.csv       #   id,Nombre,Descripcion,Categoria,Estado,id_equipo,Fecha_creacion
│       │       ├── mensaje.csv        #   id,Tipo_mensaje,Tipo_receptor,id_receptor,id_emisor,Contenido,id_equipo,Fecha,id_proyecto,Estado
│       │       ├── sala.csv           #   id,tema,descripcion
│       │       └── consulta.csv       #   archivo reservado
│       │
│       ├── comunicacion/       # #comunicacion — Nodos distribuidos de Erlang
│       │   ├── conexion.ex       # Cookie + nodo servidor resueltos en runtime (nada hardcodeado)
│       │   ├── nodo-servidor.ex  # Registra :servicio_hackaton y atiende el loop de peticiones
│       │   └── nodo-cliente.ex   # Envía peticiones al servicio remoto y espera la respuesta
│       │
│       └── util/
│           ├── sesion.ex       # SesionGlobal (Agent): guarda el usuario logueado
│           ├── encriptador.ex  # SHA-256 para hashear y verificar contraseñas
│           └── generador_id.ex # IDs aleatorios con prefijo (adm-, ptc-, mtr-, eqp-, pryt-, sal-)
│
├── test/                       # Reservado para pruebas (vacío actualmente)
├── _build/                     # Artefactos de compilación (generado por mix)
└── .elixir_ls/                 # Caché de ElixirLS (generado)
```

---

## Funcionalidades principales

### Roles y permisos

- **INCOGNITO** — usuario sin sesión: solo registrarse, iniciar sesión, ver ayuda y salir.
- **PARTICIPANTE** — forma/entra a equipos, crea su proyecto, sube avances, chatea y consulta mentores.
- **MENTOR** — revisa proyectos y deja retroalimentación; conversa con los equipos.
- **ADMIN** — gestiona mentores y usuarios, crea salas y anuncios, consulta proyectos y expulsa usuarios.

### 1. Usuarios y sesión
- Registro de **PARTICIPANTE** (público) y de **MENTOR** (solo admin).
- Validaciones: campos obligatorios, formato de correo, rol válido, usuario y cédula únicos.
- Contraseñas guardadas como **hash SHA-256** (nunca en texto plano).
- `SesionGlobal` (un `Agent`) mantiene el usuario logueado durante toda la sesión de consola.
- Actualización de campos del propio perfil y cierre de sesión.

### 2. Equipos
- Creación de equipos con **nombre único** y tema.
- Unión a un equipo por nombre (un participante no puede pertenecer a más de uno).
- Listado de equipos (admin) y consulta de "mi equipo".

### 3. Proyectos
- Un proyecto **por equipo** (nombre único, descripción y categoría de una lista cerrada).
- Estados: `Nuevo`, `Proceso`, `Finalizado`.
- Búsqueda por categoría y por estado (admin); consulta por nombre para cualquier rol.

### 4. Comunicación en tiempo real (chat)
- **Chat personal** — uno a uno, solo entre compañeros del mismo equipo.
- **Chat grupal de equipo** — todos los integrantes del equipo.
- **Chat equipo ↔ mentor** — consultas del equipo a un mentor designado.
- **Salas temáticas** — espacios de discusión abiertos que crea el admin.
- Implementación: un `Task` asíncrono **lee** los mensajes entrantes mientras el usuario
  **escribe** (se sale con `/salir`). Cada mensaje nace como `pendiente` y pasa a `leido`
  al mostrarse.

### 5. Retroalimentación, avances y anuncios
- El **mentor** deja retroalimentaciones ligadas a un proyecto.
- El **participante** registra **avances** de su proyecto y consulta el historial de ambos.
- El **admin** publica **anuncios globales**, visibles para todos los roles.

---

## Comandos disponibles

Se escriben con `/` en el prompt. `Hackaton.Adapter.Comandos` valida el rol y la cantidad
de argumentos **antes** de ejecutar, y avisa con un mensaje claro cuando te equivocas.

**Incognito**

| Comando | Descripción |
|---|---|
| `/registrarse` | Registrarse como PARTICIPANTE |
| `/login` | Iniciar sesión |
| `/help` | Ver los comandos disponibles |
| `/salir` | Cerrar el cliente |

**Participante**

| Comando | Argumentos | Descripción |
|---|---|---|
| `/join` | `nombre_equipo` | Unirse a un equipo |
| `/registrar_equipo` | — | Crear un equipo |
| `/my_team` | — | Ver tu equipo |
| `/crear_proyecto` | — | Crear el proyecto del equipo |
| `/cambiar_estado_proyecto` | — | Cambiar el estado del proyecto |
| `/crear_avance` | — | Subir un avance |
| `/ver_avances` | — | Ver los avances del proyecto |
| `/mostrar_historial` | — | Ver las retroalimentaciones del proyecto |
| `/project` | `nombre_proyecto` | Ver el detalle de un proyecto |
| `/mentores` | — | Listar mentores |
| `/abrir_chat` | `otro usuario` | Chat personal |
| `/chat_grupo` | — | Chat del equipo |
| `/chat_grupo_mentor` | `user mentor` | Chat con un mentor |
| `/entrar_sala` | — | Entrar a una sala temática |
| `/ver_anuncios` | — | Ver anuncios |
| `/mi_info` | — | Ver tus datos |
| `/actualizar_campo` | `campo valor` | Editar tu perfil |
| `/salir_hackaton` | — | Darse de baja |
| `/log_out`, `/help`, `/salir` | — | Sesión y salida |

**Mentor**

| Comando | Argumentos | Descripción |
|---|---|---|
| `/crear_retroalimentacion` | `nombre_proyecto` | Dejar retroalimentación |
| `/chat_grupo` | `nombre_equipo` | Chat con un equipo |
| `/ver_anuncios` | — | Ver anuncios |
| `/mi_info`, `/actualizar_campo`, `/log_out`, `/help`, `/salir` | — | Perfil y sesión |

**Admin**

| Comando | Argumentos | Descripción |
|---|---|---|
| `/registrar_mentor` | — | Crear un mentor |
| `/expulsar_usuario` | `usuario` | Eliminar a un usuario |
| `/teams` | — | Listar los equipos |
| `/project` | `nombre_proyecto` | Ver el detalle de un proyecto |
| `/mostrar_historial` | `nombre_proyecto` | Ver retroalimentaciones |
| `/crear_sala` | — | Crear una sala temática |
| `/consultar_proyecto_categoria` | `categoria` | Filtrar proyectos |
| `/consultar_proyecto_estado` | `estado` | Filtrar proyectos |
| `/enviar_anuncio` | — | Publicar un anuncio global |
| `/ver_anuncios`, `/mi_info`, `/actualizar_campo`, `/log_out`, `/help`, `/salir` | — | Consulta y sesión |

---

## Persistencia

No hay motor de base de datos: cada entidad se guarda como **una línea CSV**, con la
primera línea como cabecera. Los archivos viven en
`lib/hackaton/adapter/persistencia/` y se leen/escriben con `File.read/1` y `File.write/3`.

- El **cliente** no toca los CSV: solo envía comandos al servidor.
- El **servidor** es el único que lee y escribe, por lo que todos los clientes ven los mismos datos.
- Actualizar un registro = borrarlo y volver a escribirlo (usuarios, equipos y proyectos).
- Los IDs usan prefijo por tipo: `adm-`, `ptc-`, `mtr-`, `eqp-`, `pryt-`, `sal-`, seguido
  de 6 caracteres aleatorios.

⚠️ Al ser un proyecto académico la persistencia es simple: no hay *locking* cuando varios
clientes escriben a la vez y los valores no se escapan, así que conviene **no usar comas
dentro de los textos** que se guardan en los CSV.

---

## Notas y limitaciones conocidas

- Por defecto se asume que el servidor corre en la **misma máquina** que el cliente; para un
  servidor remoto hay que definir `HACKATON_SERVIDOR` (ver "Cómo ejecutarlo").
- No hay autenticación distribuida real: cualquier cliente con la cookie puede invocar
  cualquier función expuesta por el servicio.
- No hay pruebas automatizadas ni pipeline de CI.
