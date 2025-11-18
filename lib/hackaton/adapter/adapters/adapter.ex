defmodule Hackaton.Adapter.Adapters.Adapter do

  @moduledoc """
  Módulo principal del *cliente local* encargado de interactuar con el usuario final.

  Este módulo actúa como la capa de **adaptación de comandos**, recibiendo entradas desde
  consola e invocando al nodo remoto (`NodoCliente`) para ejecutar acciones distribuidas.

  Responsabilidades:
    - Registro, autenticación y administración de usuarios.
    - Creación y administración de equipos y proyectos.
    - Comunicación en tiempo real mediante chats personales, grupales y con mentores.
    - Gestión de salas temáticas.
    - Despliegue de información: proyectos, avances, anuncios, historial, etc.
    - Ejecución de comandos según el rol del usuario (ADMIN, PARTICIPANTE, MENTOR, INCOGNITO).
  """
  alias Hackaton.Util.SesionGlobal
  alias Hackaton.Comunicacion.NodoCliente
  alias Hackaton.Adapter.Comandos
  alias Hackaton.Adapter.Mensajes.ManejoMensajes

  @doc """
  Permite que un usuario administrador registre un nuevo mentor.

  El proceso solicita todos los datos por consola, los envía al nodo remoto
  usando `:registrar_usuario` y muestra el resultado final.
  """

  def registrar_mentor(:admin) do
    IO.puts("------ REGISTRANDO MENTOR------ ")

    nombre =
      IO.gets("Ingrese su nombre: ")
      |> String.trim()

    apellido =
      IO.gets("Ingrese su apellido: ")
      |> String.trim()

    cedula =
      IO.gets("Ingrese su cedula: ")
      |> String.trim()

    correo =
      IO.gets("Ingrese su correo: ")
      |> String.trim()

    telefono =
      IO.gets("Ingrese su telefono: ")
      |> String.trim()

    usuario =
      IO.gets("Ingrese su usuario: ")
      |> String.trim()

    contrasena =
      IO.gets("Ingrese su contraseña: ")
      |> String.trim()

    usuario =
      NodoCliente.ejecutar(:registrar_usuario, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        "MENTOR",
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena
      ])

    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se registró correctamente el usuario")
    end
  end

  @doc """
  Permite que un usuario anónimo se registre como PARTICIPANTE.

  """

  def registrarse(:incognito) do
    IO.puts("------ REGISTRANDO PARTICIPANTE------ ")

    nombre =
      IO.gets("Ingrese su nombre: ")
      |> String.trim()

    apellido =
      IO.gets("Ingrese su apellido: ")
      |> String.trim()

    cedula =
      IO.gets("Ingrese su cedula: ")
      |> String.trim()

    correo =
      IO.gets("Ingrese su correo: ")
      |> String.trim()

    telefono =
      IO.gets("Ingrese su telefono: ")
      |> String.trim()

    usuario =
      IO.gets("Ingrese su usuario: ")
      |> String.trim()

    contrasena =
      IO.gets("Ingrese su contraseña: ")
      |> String.trim()

    usuario =
      NodoCliente.ejecutar(:registrar_usuario, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        "PARTICIPANTE",
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena
      ])

    case usuario do
      {:error, reason} -> IO.puts(reason)
      {:ok, _usuario} -> IO.puts("Se registró correctamente el usuario")
    end
  end

   @doc """
  Permite el inicio de sesión de un usuario en estado INCOGNITO.

  """
  def login(:incognito) do
    IO.puts("------ INICIANDO SESIÓN ------ ")

    usuario =
      IO.gets("Ingrese su usuario: ")
      |> String.trim()

    contrasena =
      IO.gets("Ingrese su contrasena: ")
      |> String.trim()

    usuario =
      NodoCliente.ejecutar(:iniciar_sesion, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        usuario,
        contrasena
      ])

    case usuario do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, u} ->
        SesionGlobal.iniciar_sesion(u)
        IO.puts("Se inició sesion correctamente")
    end
  end


  @doc """
  Permite que un PARTICIPANTE registre un nuevo equipo.

  """
  def registrar_equipo(:participante) do
    IO.puts("------ REGISTRANDO EQUIPO ------ ")

    nombre =
      IO.gets("Ingrese el nombre del equipo: ")
      |> String.trim()

    tema =
      IO.gets("Ingrese el tema del equipo: ")
      |> String.trim()

    equipo =
      NodoCliente.ejecutar(:registrar_equipo, [
        "lib/hackaton/adapter/persistencia/equipo.csv",
        nombre,
        tema
      ])

    case equipo do
      {:error, reason} -> IO.puts(reason)
      {:ok, _equipo} -> IO.puts("Se registró el equipo correctamente")
    end
  end


   @doc """
  Permite que un PARTICIPANTE cree un proyecto para su equipo.

  - Requiere que el usuario pertenezca a un equipo.
  - Solicita nombre, descripción y categoría por consola.
  - Llama al nodo remoto mediante `:crear_proyecto`.
  """
  def crear_proyecto(:participante) do
    usuario = SesionGlobal.usuario_actual()

    if usuario.id_equipo == "" do
      IO.puts(
        "No puedes crear un proyecto si no perteneces a un equipo. Únete o crea un equipo primero."
      )
    else
      IO.puts("------ CREANDO PROYECTO ------ ")

      nombre =
        IO.gets("Ingrese el nombre de su proyecto: ")
        |> String.trim()

      descripcion =
        IO.gets("Ingrese la descripcion: ")
        |> String.trim()

      categoria =
        IO.gets("Elija categoria: ")
        |> String.trim()

      id_equipo = usuario.id_equipo

      proyecto =
        NodoCliente.ejecutar(:crear_proyecto, [
          "lib/hackaton/adapter/persistencia/proyecto.csv",
          nombre,
          descripcion,
          categoria,
          id_equipo
        ])

      case proyecto do
        {:error, reason} ->
          IO.puts(reason)

        {:ok, _proyecto} ->
          IO.puts("Se creo el proyecto exitosamente")
      end
    end
  end

  @doc """
  Permite que un PARTICIPANTE abandone la hackathon.

  Elimina su registro en el archivo CSV usando `:eliminar_usuario`.
  """
  def salir_hackaton(:participante) do
    usuario =
      NodoCliente.ejecutar(:eliminar_usuario, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        SesionGlobal.usuario_actual().id,
        :id
      ])

    case usuario do
      {:error, reason} -> IO.puts(reason)
      :ok -> IO.puts("Se salio correctamente de la hackaton")
    end
  end

  @doc """
  Permite que un ADMIN expulse un usuario del sistema mediante su *username*.

  Se ejecuta usando `:eliminar_usuario` con bandera `:user`.
  """
  def expulsar_usuario(:admin, user) do
    usuario =
      NodoCliente.ejecutar(:eliminar_usuario, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        user,
        :user
      ])

    case usuario do
      {:error, reason} -> IO.puts(reason)
      :ok -> IO.puts("Se expulsó correctamente de la hackaton")
    end
  end

  @doc """
  Muestra todos los equipos registrados. Solo disponible para ADMIN.
  """
  def teams(:admin) do
    IO.puts("------ Lista de equipos ------")

    equipos =
      NodoCliente.ejecutar(:listar_equipos, ["lib/hackaton/adapter/persistencia/equipo.csv"])

    Enum.each(equipos, fn equipo ->
      IO.puts("#{equipo.nombre} — Tema: #{equipo.tema}")
    end)
  end

  @doc """
  Permite que un PARTICIPANTE se una a un equipo mediante su nombre.

  Usa `NodoCliente.ejecutar(:unirse_por_nombre)` y actualiza la sesión.
  """

  def join(:participante, nombre_equipo) do
    ingreso =
      NodoCliente.ejecutar(:unirse_por_nombre, [
        "lib/hackaton/adapter/persistencia/usuario.csv",
        "lib/hackaton/adapter/persistencia/equipo.csv",
        SesionGlobal.usuario_actual().id,
        nombre_equipo
      ])

    case ingreso do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, u} ->
        IO.puts("Se ingresó al equipo correctamente")
        SesionGlobal.iniciar_sesion(u)
    end
  end

  @doc """
  Lista todos los mentores registrados. Disponible para PARTICIPANTE.
  """

  def mentores(:participante) do
    mentores =
      NodoCliente.ejecutar(:obtener_mentores, ["lib/hackaton/adapter/persistencia/usuario.csv"])

    Enum.each(mentores, fn m ->
      IO.puts("""
      ----------------------------------------
      Rol:           #{m.rol}
      Nombre:        #{m.nombre} #{m.apellido}
      Cédula:        #{m.cedula}
      Correo:        #{m.correo}
      Teléfono:      #{m.telefono}
      Usuario:       #{m.usuario}
      ----------------------------------------
      """)
    end)
  end

  @doc """
  Cierra la sesión actual sin eliminar al usuario del sistema.
  """

  def log_out(_) do
    SesionGlobal.logout()
    IO.puts("Se cerró sesión correctamente")
  end

  @doc """
  Muestra los comandos disponibles según el rol actual del usuario.

  Roles soportados:
    - ADMIN
    - PARTICIPANTE
    - MENTOR
    - INCOGNITO
  """
  def help(_) do
    IO.puts("------ COMANDOS DISPONIBLES ------")

    rol =
      if SesionGlobal.usuario_actual() != nil, do: SesionGlobal.usuario_actual().rol, else: nil

    case rol do
      "ADMIN" ->
        Enum.each(Comandos.comandos_admin(), fn comando ->
          IO.puts("/#{comando}")
        end)

      "PARTICIPANTE" ->
        Enum.each(Comandos.comandos_participante(), fn comando ->
          IO.puts("/#{comando}")
        end)

      "MENTOR" ->
        Enum.each(Comandos.comandos_mentor(), fn comando ->
          IO.puts("/#{comando}")
        end)

      nil ->
        Enum.each(Comandos.comandos_incognito(), fn comando ->
          IO.puts("/#{comando}")
        end)
    end
  end

  @doc """
  Muestra la información de un proyecto identificado por nombre.

  Además, consulta el equipo asociado para desplegar más detalles.
  """
  def project(_, nombre) do
    case NodoCliente.ejecutar(:obtener_proyecto_nombre, [
           "lib/hackaton/adapter/persistencia/proyecto.csv",
           nombre
         ]) do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, p} ->
        case NodoCliente.ejecutar(:obtener_equipo_id, [
               "lib/hackaton/adapter/persistencia/equipo.csv",
               p.id_equipo
             ]) do
          {:error, reason} ->
            IO.puts(reason)

          {:ok, e} ->
            IO.puts("""
            ----------------------------------------
            Nombre:         #{p.nombre}
            Descripción:    #{p.descripcion}
            Categoría:      #{p.categoria}
            Estado:         #{p.estado}
            Equipo:         #{e.nombre}
            Tema:           #{e.tema}
            Fecha creación: #{p.fecha_creacion}
            ----------------------------------------
            """)
        end
    end
  end

  @doc """
  Muestra el equipo del participante actual.
  """
  def my_team(:participante) do
    equipo =
      NodoCliente.ejecutar(:obtener_equipo_id, [
        "lib/hackaton/adapter/persistencia/equipo.csv",
        SesionGlobal.usuario_actual().id_equipo
      ])

    case equipo do
      {:error, reason} -> IO.puts(reason)
      {:ok, e} -> IO.puts("#{e.nombre} — Tema: #{e.tema}")
    end
  end

  @doc """
  Permite cambiar el estado del proyecto asociado al equipo del participante.
  """

  def cambiar_estado_proyecto(:participante) do
    nuevo_estado =
      IO.gets("Ingrese el nuevo estado (proceso finalizado): ")
      |> String.trim()

    actualizado =
      NodoCliente.ejecutar(:actualizar_estado_proyecto, [
        "lib/hackaton/adapter/persistencia/proyecto.csv",
        SesionGlobal.usuario_actual().id_equipo,
        nuevo_estado
      ])

    case actualizado do
      {:error, reason} -> IO.puts(reason)
      {:ok, _proyecto} -> IO.puts("Se actualizó el estado del proyecto correctamente")
    end
  end

  @doc """
  Permite actualizar dinámicamente un campo del usuario actual.

  Los cambios se delegan a `NodoCliente` usando `:actualizar_campo_usuario`.
  """
  def actualizar_campo(_rol, tipo_campo, campo_nuevo) do
    case NodoCliente.ejecutar(:actualizar_campo_usuario, [
           "lib/hackaton/adapter/persistencia/usuario.csv",
           SesionGlobal.usuario_actual().id,
           campo_nuevo,
           String.to_atom(tipo_campo)
         ]) do
      {:ok, _usuario} ->
        IO.puts("Se actualizó el usuario correctamente")

      {:error, reason} ->
        IO.puts(reason)
    end
  end

  @doc """
  Muestra toda la información disponible del usuario actual, incluyendo su equipo.
  """

  def mi_info(_rol) do
    usuario = SesionGlobal.usuario_actual()

    equipo =
      case NodoCliente.ejecutar(:obtener_equipo_id, [
             "lib/hackaton/adapter/persistencia/equipo.csv",
             usuario.id_equipo
           ]) do
        {:ok, e} -> e.nombre
        {:error, _} -> "Sin equipo"
      end

    IO.puts("""
    ----------------------------------------
    Nombre:         #{usuario.nombre}
    Apellido:       #{usuario.apellido}
    Cedula:         #{usuario.cedula}
    Correo:         #{usuario.correo}
    Telefono:       #{usuario.telefono}
    Usuario:        #{usuario.usuario}
    Equipo:         #{equipo}
    ----------------------------------------
    """)
  end

  @doc """
  Cierra el programa completamente.
  """

  def salir(_rol) do
    IO.puts("Cerrando cliente...")
    System.halt(0)
  end

   @doc """
  Muestra el historial de retroalimentaciones asociado a un proyecto (ADMIN).
  """
  def mostrar_historial(:admin, nombre) do
    proyecto =
      NodoCliente.ejecutar(:obtener_proyecto_nombre, [
        "lib/hackaton/adapter/persistencia/proyecto.csv",
        nombre
      ])

    case proyecto do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, p} ->
        IO.puts("------ Historial de retroalimentaciones del proyecto #{p.nombre} ------")

        retroalimentaciones =
          NodoCliente.ejecutar(:obtener_retroalimentaciones_proyecto, [
            "lib/hackaton/adapter/persistencia/proyecto.csv",
            "lib/hackaton/adapter/persistencia/mensaje.csv",
            p.id
          ])

        case retroalimentaciones do
          {:error, reason} ->
            IO.puts(reason)

          {:ok, r} ->
            Enum.each(r, fn retroalimentacion ->
              IO.puts("""
              ----------------------------------------
              De:            #{NodoCliente.ejecutar(:obtener_usuario, ["lib/hackaton/adapter/persistencia/usuario.csv", retroalimentacion.id_emisor]) |> case do
                {:ok, u} -> u.nombre <> " " <> u.apellido
                {:error, _} -> "Usuario desconocido"
              end}
              Mensaje:       #{retroalimentacion.contenido}
              Fecha:         #{retroalimentacion.fecha}
              ----------------------------------------
              """)
            end)
        end
    end
  end

  @doc """
  Muestra el historial de retroalimentaciones del proyecto del equipo del PARTICIPANTE.
  """
  def mostrar_historial(:participante) do
    usuario = SesionGlobal.usuario_actual()

    proyecto =
      NodoCliente.ejecutar(:obtener_proyecto_id_equipo, [
        "lib/hackaton/adapter/persistencia/proyecto.csv",
        usuario.id_equipo
      ])

    case proyecto do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, p} ->
        IO.puts("------ Historial de retroalimentaciones del proyecto #{p.nombre} ------")

        retroalimentaciones =
          NodoCliente.ejecutar(:obtener_retroalimentaciones_proyecto, [
            "lib/hackaton/adapter/persistencia/proyecto.csv",
            "lib/hackaton/adapter/persistencia/mensaje.csv",
            p.id
          ])

        case retroalimentaciones do
          {:error, reason} ->
            IO.puts(reason)

          {:ok, r} ->
            Enum.each(r, fn retroalimentacion ->
              IO.puts("""
              ----------------------------------------
              De:            #{NodoCliente.ejecutar(:obtener_usuario, ["lib/hackaton/adapter/persistencia/usuario.csv", retroalimentacion.id_emisor]) |> case do
                {:ok, u} -> u.nombre <> " " <> u.apellido
                {:error, _} -> "Usuario desconocido"
              end}
              Mensaje:       #{retroalimentacion.contenido}
              Fecha:         #{retroalimentacion.fecha}
              ----------------------------------------
              """)
            end)
        end
    end
  end

  @doc """
  Crea un avance sobre el proyecto del equipo del PARTICIPANTE.
  """

  def crear_avance(:participante) do
    usuario = SesionGlobal.usuario_actual()

    if usuario.id_equipo == "" do
      IO.puts("No puedes crear un avance si no perteneces a un equipo")
    else
      case NodoCliente.ejecutar(:obtener_proyecto_id_equipo, [
             "lib/hackaton/adapter/persistencia/proyecto.csv",
             usuario.id_equipo
           ]) do
        {:error, reason} ->
          IO.puts(reason)

        {:ok, p} ->
          IO.puts("------ CREANDO AVANCE DEL PROYECTO #{p.nombre} ------ ")

          contenido =
            IO.gets("Ingrese el contenido del avance: ")
            |> String.trim()

          avance =
            NodoCliente.ejecutar(:crear_avance, [
              "lib/hackaton/adapter/persistencia/mensaje.csv",
              usuario.id,
              contenido,
              p.id
            ])

          case avance do
            {:error, reason} ->
              IO.puts(reason)

            {:ok, _avance} ->
              IO.puts("Se creó el avance correctamente")
          end
      end
    end
  end

  @doc """
  Permite que un MENTOR cree una retroalimentación para el proyecto indicado por nombre.
  """
  def crear_retroalimentacion(:mentor, nombre) do
    NodoCliente.ejecutar(:obtener_proyecto_nombre, [
      "lib/hackaton/adapter/persistencia/proyecto.csv",
      nombre
    ])
    |> case do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, p} ->
        IO.puts("------ CREANDO RETROALIMENTACIÓN DEL PROYECTO #{p.nombre} ------ ")

        contenido =
          IO.gets("Ingrese el contenido de la retroalimentación: ")
          |> String.trim()

        retroalimentacion =
          NodoCliente.ejecutar(:crear_retroalimentacion, [
            "lib/hackaton/adapter/persistencia/mensaje.csv",
            SesionGlobal.usuario_actual().id,
            contenido,
            p.id
          ])

        case retroalimentacion do
          {:error, reason} ->
            IO.puts(reason)

          {:ok, _retroalimentacion} ->
            IO.puts("Se creó la retroalimentación correctamente")
        end
    end
  end

   @doc """
  Abre un chat personal entre el usuario actual y otro usuario.

  Solo permite chatear si ambos pertenecen al mismo equipo.
  """
  def abrir_chat(_, otro_usuario_user) do
    usuario_actual = SesionGlobal.usuario_actual()
    case NodoCliente.ejecutar(:obtener_usuario_user, [
           "lib/hackaton/adapter/persistencia/usuario.csv",
           otro_usuario_user
         ]) do
      {:ok, otro_usuario} ->
        cond do
          usuario_actual.id_equipo == otro_usuario.id_equipo ->
          IO.puts("""
        ┌──────────────────────────────────────────────────────────────┐
        │ CHAT PERSONAL CON #{otro_usuario.usuario}                    |
        └──────────────────────────────────────────────────────────────┘
        """)

        ManejoMensajes.chatear(
          usuario_actual,
          otro_usuario,
          :crear_mensaje_personal,
          :obtener_mensajes_personal,
          :obtener_mensajes_personal_pendientes
        )
        true -> IO.puts("No puedes chatear con el usuario #{otro_usuario_user} porque pertecene a otro equipo")
        end
      {:error, reason} ->
        IO.puts(reason)
    end
  end

  @doc """
  Abre el chat grupal del equipo del PARTICIPANTE.
  """
  def chat_grupo(:participante) do
    usuario_actual = SesionGlobal.usuario_actual()

    case NodoCliente.ejecutar(:obtener_equipo_id, [
           "lib/hackaton/adapter/persistencia/equipo.csv",
           SesionGlobal.usuario_actual().id_equipo
         ]) do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, equipo} ->
        IO.puts("""
        ┌──────────────────────────────────────────────────────────────┐
        │ CHAT GRUPAL DE - #{equipo.nombre} -                          |
        └──────────────────────────────────────────────────────────────┘
        """)

        ManejoMensajes.chatear(
          usuario_actual,
          equipo,
          :crear_mensaje_equipo,
          :obtener_mensajes_equipo,
          :obtener_mensajes_equipo_pendientes
        )
    end
  end

  @doc """
  Abre un chat grupal entre PARTICIPANTE y MENTOR designado.
  """
  def chat_grupo_mentor(:participante, mentor_user) do
    usuario_actual = SesionGlobal.usuario_actual()

    case NodoCliente.ejecutar(:obtener_usuario_user, [
           "lib/hackaton/adapter/persistencia/usuario.csv",
           mentor_user
         ]) do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, mentor} ->
        case NodoCliente.ejecutar(:obtener_equipo_id, [
               "lib/hackaton/adapter/persistencia/equipo.csv",
               usuario_actual.id_equipo
             ]) do
          {:error, reason} ->
            IO.puts(reason)

          {:ok, equipo} ->
            IO.puts("""
            ┌─────────────────────────────────────────────────────────────────────┐
            │ CHAT GRUPAL DE - #{equipo.nombre} -  CON EL MENTOR #{mentor.usuario}
            └─────────────────────────────────────────────────────────────────────┘
            """)


            ManejoMensajes.chatear(
              usuario_actual,
              mentor,
              equipo,
              :crear_consulta_equipo,
              :obtener_consultas_equipo,
              :obtener_consultas_equipo_pendientes
            )
        end
    end
  end

  @doc """
  Abre el chat grupal donde un MENTOR se comunica con un equipo específico.
  """
  def chat_grupo(:mentor, nombre_equipo) do
    mentor = SesionGlobal.usuario_actual()

    case NodoCliente.ejecutar(:obtener_equipo_nombre, [
           "lib/hackaton/adapter/persistencia/equipo.csv",
           nombre_equipo
         ]) do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, equipo} ->
        IO.puts("""
        ┌─────────────────────────────────────────────────────────────────────┐
        │ CHAT GRUPAL DE - #{equipo.nombre} -  CON EL MENTOR #{mentor.usuario}
        └─────────────────────────────────────────────────────────────────────┘
        """)

        ManejoMensajes.chatear(
          mentor,
          equipo,
          equipo,
          :crear_consulta_equipo_mentor,
          :obtener_consultas_equipo_mentor,
          :obtener_consultas_equipo_mentor_pendientes
        )
    end
  end

  @doc """
  Permite que un PARTICIPANTE visualice los avances de su proyecto.
  """
  def ver_avances(:participante) do
    usuario = SesionGlobal.usuario_actual()

    if usuario.id_equipo == "" do
      IO.puts("No puedes ver avances si no perteneces a un equipo")
    else
      case NodoCliente.ejecutar(:obtener_proyecto_id_equipo, [
             "lib/hackaton/adapter/persistencia/proyecto.csv",
             usuario.id_equipo
           ]) do
        {:error, reason} ->
          IO.puts(reason)

        {:ok, p} ->
          IO.puts("------ Avances del proyecto #{p.nombre} ------ ")

          avances =
            NodoCliente.ejecutar(:obtener_avances_proyecto, [
              "lib/hackaton/adapter/persistencia/mensaje.csv",
              p.id
            ])

          case avances do
            {:error, reason} ->
              IO.puts(reason)

            {:ok, a} ->
              Enum.each(a, fn avance ->
                IO.puts("""
                ----------------------------------------
                De:            #{NodoCliente.ejecutar(:obtener_usuario, ["lib/hackaton/adapter/persistencia/usuario.csv", avance.id_emisor]) |> case do
                  {:ok, u} -> u.nombre <> " " <> u.apellido
                  {:error, _} -> "Usuario desconocido"
                end}
                Mensaje:       #{avance.contenido}
                Fecha:         #{avance.fecha}
                ----------------------------------------
                """)
              end)
          end
      end
    end
  end

  @doc """
  Permite a un ADMIN crear una nueva sala temática.
  """
  def crear_sala(:admin) do
    IO.puts("------ CREANDO SALA ------ ")

    tema =
      IO.gets("Ingrese el tema de la sala: ")
      |> String.trim()

    descripcion =
      IO.gets("Ingrese la descripcion de la sala: ")
      |> String.trim()

    sala =
      NodoCliente.ejecutar(:crear_sala, [
        "lib/hackaton/adapter/persistencia/sala.csv",
        tema,
        descripcion
      ])

    case sala do
      {:error, reason} -> IO.puts(reason)
      {:ok, _sala} -> IO.puts("Se creó la sala correctamente")
    end
  end

  @doc """
  Permite que un PARTICIPANTE entre a una sala temática existente.
  """
  def entrar_sala(:participante) do
    tema =
      IO.gets("Ingrese el tema de la sala a la que desea entrar: ")
      |> String.trim()
    usuario_actual = SesionGlobal.usuario_actual()

    case NodoCliente.ejecutar(:obtener_sala_tema, [
        "lib/hackaton/adapter/persistencia/sala.csv",
        tema
      ]) do
        {:error, reason} -> IO.puts(reason)
        {:ok, sala} ->
          IO.puts("""
      ┌──────────────────────────────────────────────────────────────┐
      │ SALA DE DISCRUSION DE - #{tema} -                          |
      └──────────────────────────────────────────────────────────────┘
      """)
          ManejoMensajes.chatear(
          usuario_actual,
          sala,
          :crear_mensaje_sala,
          :obtener_mensajes_sala,
          :obtener_mensajes_sala_pendiente
        )
      end
  end

  @doc """
  Permite que un ADMIN consulte todos los proyectos por una categoría específica.
  """
  def consultar_proyecto_categoria(:admin, categoria) do
    proyectos =
      NodoCliente.ejecutar(:buscar_proyectos_por_categoria, [
        "lib/hackaton/adapter/persistencia/proyecto.csv",
        categoria
      ])

    case proyectos do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, ps} ->
        Enum.each(ps, fn p ->
          IO.puts("""
          ----------------------------------------
          Nombre:         #{p.nombre}
          Descripción:    #{p.descripcion}
          Categoría:      #{p.categoria}
          Estado:         #{p.estado}
          Equipo:         #{NodoCliente.ejecutar(:obtener_equipo_id, ["lib/hackaton/adapter/persistencia/equipo.csv", p.id_equipo]) |> case do
            {:ok, e} -> e.nombre
            {:error, _} -> "Equipo desconocido"
          end}
          Fecha creación: #{p.fecha_creacion}
          ----------------------------------------
          """)
        end)
    end
  end

  @doc """
  Permite que un ADMIN consulte proyectos según su estado.
  """
  def conultar_proyecto_estado(:admin, estado) do
    proyectos =
      NodoCliente.ejecutar(:buscar_proyectos_por_estado, [
        "lib/hackaton/adapter/persistencia/proyecto.csv",
        estado
      ])

    case proyectos do
      {:error, reason} ->
        IO.puts(reason)

      {:ok, ps} ->
        Enum.each(ps, fn p ->
          IO.puts("""
          ----------------------------------------
          Nombre:         #{p.nombre}
          Descripción:    #{p.descripcion}
          Categoría:      #{p.categoria}
          Estado:         #{p.estado}
          Equipo:         #{NodoCliente.ejecutar(:obtener_equipo_id, ["lib/hackaton/adapter/persistencia/equipo.csv", p.id_equipo]) |> case do
            {:ok, e} -> e.nombre
            {:error, _} -> "Equipo desconocido"
          end}
          Fecha creación: #{p.fecha_creacion}
          ----------------------------------------
          """)
        end)
    end
  end

  @doc """
  Permite que el ADMIN envíe un anuncio global a todos los usuarios.
  """

  def enviar_anuncio(:admin) do
    ver_anuncios(:nada)

    anuncio =
      IO.gets("- Nuevo anuncio: ")
      |> String.trim()

    NodoCliente.ejecutar(:enviar_anuncio, [
      "lib/hackaton/adapter/persistencia/mensaje.csv",
      SesionGlobal.usuario_actual().id,
      anuncio
    ])
  end

  @doc """
  Muestra todos los anuncios del sistema.
  """
  def ver_anuncios(_) do
    IO.puts("""
    ┌──────────────────────────────────────────────────────────────┐
    │                        ANUNCIOS                              |
    └──────────────────────────────────────────────────────────────┘
    """)

    case NodoCliente.ejecutar(:ver_anuncios, [
           "lib/hackaton/adapter/persistencia/mensaje.csv"]) do
      {:ok, anuncios} ->
        Enum.each(anuncios, fn anuncio ->
          IO.puts("""
          ----------------------------------------
          Mensaje:        #{anuncio.contenido}
          Fecha:          #{anuncio.fecha}
          ----------------------------------------
          """)
        end)

      {:error, reason} ->
        IO.puts(reason)
    end
  end
end
