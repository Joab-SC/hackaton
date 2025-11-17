defmodule Hackaton.Services.ServicioHackathon do
  @moduledoc """
  Servicio general que coordina la interacción entre usuarios, equipos, proyectos y mensajes
  dentro del sistema de la Hackathon.
  Servicio general que coordina la interacción entre usuarios, equipos, proyectos y mensajes
  dentro del sistema de la Hackathon.

  """

  alias Hackaton.Services.{
    ServicioEquipo,
    ServicioMensaje,
    ServicioProyecto,
    ServicioUsuario,
    ServicioSala
  }

  @doc """
  Registra un usuario delegando la operación a `ServicioUsuario`.

  """
  @doc """
  Registra un usuario delegando la operación a `ServicioUsuario`.

  """
  def registrar_usuario(
        nombre_archivo,
        rol,
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena
      ) do
    ServicioUsuario.registrar_usuario(
      nombre_archivo,
      rol,
      nombre,
      apellido,
      cedula,
      correo,
      telefono,
      usuario,
      contrasena
    )
  end

  @doc """
  Actualiza un usuario existente delegando la lógica al servicio correspondiente.
  """
  @doc """
  Actualiza un usuario existente delegando la lógica al servicio correspondiente.
  """
  def actualizar_usuario(nombre_archivo, usuario_actualizado) do
    ServicioUsuario.actualizar_usuario(nombre_archivo, usuario_actualizado)
  end

  @doc """
  Inicia sesión validando usuario y contraseña mediante `ServicioUsuario`.
  """
  @doc """
  Inicia sesión validando usuario y contraseña mediante `ServicioUsuario`.
  """
  def iniciar_sesion(nombre_archivo, usuario, contrasena) do
    ServicioUsuario.iniciar_sesion(nombre_archivo, usuario, contrasena)
  end

  @doc """
  Permite a un participante unirse a un equipo especificando su nombre.

  Flujo:
    1. Busca el equipo por nombre.
    2. Si existe, llama a `asignar_participante_a_equipo/4`.
  """
  @doc """
  Permite a un participante unirse a un equipo especificando su nombre.

  Flujo:
    1. Busca el equipo por nombre.
    2. Si existe, llama a `asignar_participante_a_equipo/4`.
  """
  def unirse_por_nombre(archivo_usuarios, archivo_equipos, id_participante, nombre_equipo) do
    equipo_ = ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)

    case equipo_ do
      {:error, reason} ->
        {:error, reason}

      {:ok, equipo} ->
        asignar_participante_a_equipo(
          archivo_usuarios,
          archivo_equipos,
          id_participante,
          equipo.id
        )
    end
  end

  @doc """
  Elimina un usuario usando su nombre de usuario (`:user`) o su ID (`:id`).
  """
  @doc """
  Elimina un usuario usando su nombre de usuario (`:user`) o su ID (`:id`).
  """
  def eliminar_usuario(nombre_archivo, user, :user) do
    usuario_ = ServicioUsuario.obtener_usuario_user(nombre_archivo, user)

    case usuario_ do
      {:error, reason} -> {:error, reason}
      {:ok, usuario} -> ServicioUsuario.eliminar_usuario(nombre_archivo, usuario.id)
    end
  end

  def eliminar_usuario(nombre_archivo, id, :id) do
    ServicioUsuario.eliminar_usuario(nombre_archivo, id)
  end

  @doc """
  Obtiene la lista de mentores registrados.
  """
  @doc """
  Obtiene la lista de mentores registrados.
  """
  def obtener_mentores(nombre_archivo) do
    ServicioUsuario.obtener_mentores(nombre_archivo)
  end

  @doc """
  Crea un proyecto siempre que el equipo no tenga ya uno asignado.

  """
  @doc """
  Crea un proyecto siempre que el equipo no tenga ya uno asignado.

  """
  def crear_proyecto(archivo_proyectos, nombre, descripcion, categoria, id_equipo) do
    proyectos = ServicioProyecto.listar_proyectos(archivo_proyectos)

    if Enum.any?(proyectos, fn p -> p.id_equipo == id_equipo end) do
      {:error, "El equipo ya tiene un proyecto registrado."}
    else
      ServicioProyecto.crear_proyecto(
        archivo_proyectos,
        nombre,
        descripcion,
        categoria,
        id_equipo
      )
    end
  end

  @doc """
  Actualiza el estado del proyecto asociado a un equipo.
  """
  @doc """
  Actualiza el estado del proyecto asociado a un equipo.
  """
  def actualizar_estado_proyecto(nombre_archivo, id_equipo, nuevo_estado) do
    proyecto_ = ServicioProyecto.obtener_proyecto_id_equipo(nombre_archivo, id_equipo)

    case proyecto_ do
      {:error, reason} ->
        {:error, reason}

      {:ok, proyecto} ->
        ServicioProyecto.actualizar_estado(nombre_archivo, proyecto.id, nuevo_estado)
    end
  end

  @doc """
  Obtiene un proyecto por su nombre.
  """
  @doc """
  Obtiene un proyecto por su nombre.
  """
  def obtener_proyecto_nombre(nombre_archivo, nombre_proyecto) do
    ServicioProyecto.obtener_proyecto_nombre(nombre_archivo, nombre_proyecto)
  end

  @doc """
  Obtiene un usuario por ID.
  """
  @doc """
  Obtiene un usuario por ID.
  """
  def obtener_usuario(nombre_archivo, id) do
    ServicioUsuario.obtener_usuario(nombre_archivo, id)
  end

  def obtener_usuario_user(nombre_archivo, id) do
    ServicioUsuario.obtener_usuario_user(nombre_archivo, id)
  end

  @doc """
  Lista todos los equipos registrados.
  """
  @doc """
  Lista todos los equipos registrados.
  """
  def listar_equipos(archivo_equipos) do
    ServicioEquipo.obtener_equipos(archivo_equipos)
  end

  @doc """
  Registra un nuevo equipo.
  """
  @doc """
  Registra un nuevo equipo.
  """
  def registrar_equipo(nombre_archivo, nombre, tema) do
    ServicioEquipo.registrar_equipo(nombre_archivo, nombre, tema)
  end

  @doc """
  Obtiene un equipo usando su nombre.
  """
  @doc """
  Obtiene un equipo usando su nombre.
  """
  def obtener_equipo_nombre(archivo_equipos, nombre_equipo) do
    ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)
  end

  @doc """
  Obtiene un equipo por su ID.
  """
  @doc """
  Obtiene un equipo por su ID.
  """
  def obtener_equipo_id(archivo_equipos, id_equipo) do
    ServicioEquipo.obtener_equipo(archivo_equipos, id_equipo)
  end

  @doc """
  Actualiza un campo específico de un usuario, delegando a `ServicioUsuario`.
  """
  @doc """
  Actualiza un campo específico de un usuario, delegando a `ServicioUsuario`.
  """
  def actualizar_campo_usuario(nombre_archivo, id_usuario, valor, tipo_campo) do
    ServicioUsuario.actualizar_campo(nombre_archivo, id_usuario, valor, tipo_campo)
  end

  @doc """
  Obtiene un proyecto asociado a un equipo.
  """
  @doc """
  Obtiene un proyecto asociado a un equipo.
  """
  def obtener_proyecto_id_equipo(nombre_archivo, id_equipo) do
    ServicioProyecto.obtener_proyecto_id_equipo(nombre_archivo, id_equipo)
  end

  @doc """
  Crea una retroalimentación asociada a un proyecto.
  """
  @doc """
  Crea una retroalimentación asociada a un proyecto.
  """
  def crear_retroalimentacion(nombre_archivo, id_emisor, contenido, id_proyecto) do
    ServicioMensaje.crear_mensaje(
      nombre_archivo,
      :retroalimentacion,
      nil,
      "",
      id_emisor,
      contenido,
      "",
      id_proyecto,
      ""
    )
  end


  def crear_mensaje_personal(nombre_archivo, id_emisor, id_receptor, contenido) do
    ServicioMensaje.crear_mensaje(
      nombre_archivo,
      :chat,
      :usuario,
      id_receptor,
      id_emisor,
      contenido,
      "",
      "",
      "pendiente"
    )
  end

  @doc """
  Obtiene todas las retroalimentaciones de un proyecto validando que dicho proyecto exista.
  """
  def obtener_retroalimentaciones_proyecto(
        nombre_archivo_proyectos,
        archivo_mensajes,
        id_proyecto
      ) do
    retroalimentaciones =
      ServicioMensaje.filtrar_por_proyecto(archivo_mensajes, :retroalimentacion, id_proyecto)

    case ServicioProyecto.obtener_proyecto(nombre_archivo_proyectos, id_proyecto) do
      {:error, reason} ->
        {:error, reason}

      {:ok, proyecto} ->
        case retroalimentaciones do
          [] -> {:error, "No hay retroalimentaciones para el proyecto #{proyecto.nombre}"}
          _ -> {:ok, retroalimentaciones}
        end
    end
  end

  @doc """
  Obtiene todos los avances de un proyecto validando previamente la existencia del proyecto.
  """
  @doc """
  Obtiene todos los avances de un proyecto validando previamente la existencia del proyecto.
  """
  def obtener_avances_proyecto(nombre_archivo, id_proyecto) do
    avances =
      ServicioMensaje.filtrar_por_proyecto(nombre_archivo, :avance, id_proyecto)

    case ServicioProyecto.obtener_proyecto(nombre_archivo, id_proyecto) do
      {:error, reason} ->
        {:error, reason}

      {:ok, proyecto} ->
        case avances do
          [] -> {:error, "No hay avances para el proyecto #{proyecto.nombre}"}
          _ -> {:ok, avances}
        end
    end
  end

  @doc """
  Obtiene los participantes de un equipo dado su nombre.
  """

  # =======================================================
  # 5. OBTENER PARTICIPANTES DE UN EQUIPO
  # =======================================================

  @doc """
  Obtiene los participantes de un equipo dado su nombre.
  """

  # =======================================================
  # 5. OBTENER PARTICIPANTES DE UN EQUIPO
  # =======================================================

  def obtener_participantes_equipo_nombre(archivo_equipos, archivo_usuarios, nombre_equipo) do
    equipo_ = ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)

    case equipo_ do
      {:error, reason} ->
        {:error, reason}

      {:ok, equipo} ->
        ServicioUsuario.obtener_participantes_equipo(archivo_usuarios, equipo.id)

      {:error, reason} ->
        {:error, reason}

      {:ok, equipo} ->
        ServicioUsuario.obtener_participantes_equipo(archivo_usuarios, equipo.id)
    end
  end

  @doc """
  Devuelve un map con el equipo y su lista de miembros:

      %{equipo: equipo, miembros: lista}
  """
  @doc """
  Devuelve un map con el equipo y su lista de miembros:

      %{equipo: equipo, miembros: lista}
  """
  def obtener_equipo_con_miembros(archivo_usuarios, archivo_equipos, nombre_equipo) do
    equipo_ = ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)

    case equipo_ do
      {:error, reason} ->
        {:error, reason}

      {:ok, equipo} ->
        miembros =
          obtener_participantes_equipo_nombre(archivo_equipos, archivo_usuarios, nombre_equipo)

        case miembros do
          {:error, reason} ->
            {:error, reason}

          {:ok, m} ->
            {:ok, %{equipo: equipo, miembros: m}}
        end
    end
  end

  @doc """
  Asigna un participante a un equipo si:

    - Ambos existen
    - El participante no está asignado ya a otro equipo


  """
  @doc """
  Asigna un participante a un equipo si:

    - Ambos existen
    - El participante no está asignado ya a otro equipo


  """
  defp asignar_participante_a_equipo(
         archivo_usuarios,
         archivo_equipos,
         id_participante,
         id_equipo
       ) do
    equipo_ = ServicioEquipo.obtener_equipo(archivo_equipos, id_equipo)
    participante_ = ServicioUsuario.obtener_usuario(archivo_usuarios, id_participante)

    case {equipo_, participante_} do
      {{:error, reason}, _} ->
        {:error, reason}

      {_, {:error, reason}} ->
        {:error, reason}

      {{:ok, _equipo}, {:ok, participante}} ->
        if participante.id_equipo != "" do
          {:error, "El participante ya pertenece a un equipo."}
        else
          actualizado = %{participante | id_equipo: id_equipo}
          ServicioUsuario.actualizar_usuario(archivo_usuarios, actualizado)
          {:ok, actualizado}
        end
    end
  end

  @doc """
  Quita un participante de su equipo (si pertenece a alguno).
  """

  @doc """
  Registra un usuario delegando la operación a `ServicioUsuario`.
  """
  def registrar_usuario(
        nombre_archivo,
        rol,
        nombre,
        apellido,
        cedula,
        correo,
        telefono,
        usuario,
        contrasena
      ) do
    ServicioUsuario.registrar_usuario(
      nombre_archivo,
      rol,
      nombre,
      apellido,
      cedula,
      correo,
      telefono,
      usuario,
      contrasena
    )
  end

  @doc """
  Actualiza un usuario existente delegando la lógica al servicio correspondiente.
  """
  def actualizar_usuario(nombre_archivo, usuario_actualizado) do
    ServicioUsuario.actualizar_usuario(nombre_archivo, usuario_actualizado)
  end

  @doc """
  Inicia sesión validando usuario y contraseña mediante `ServicioUsuario`.
  """
  def iniciar_sesion(nombre_archivo, usuario, contrasena) do
    ServicioUsuario.iniciar_sesion(nombre_archivo, usuario, contrasena)
  end

  @doc """
  Permite a un participante unirse a un equipo especificando su nombre.
  """
  def unirse_por_nombre(archivo_usuarios, archivo_equipos, id_participante, nombre_equipo) do
    equipo_ = ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)

    case equipo_ do
      {:error, reason} ->
        {:error, reason}

      {:ok, equipo} ->
        asignar_participante_a_equipo(
          archivo_usuarios,
          archivo_equipos,
          id_participante,
          equipo.id
        )
    end
  end

  @doc """
  Elimina un usuario usando su nombre de usuario (`:user`) o su ID (`:id`).
  """
  def eliminar_usuario(nombre_archivo, user, :user) do
    usuario_ = ServicioUsuario.obtener_usuario_user(nombre_archivo, user)

    case usuario_ do
      {:error, reason} -> {:error, reason}
      {:ok, usuario} -> ServicioUsuario.eliminar_usuario(nombre_archivo, usuario.id)
    end
  end

  def eliminar_usuario(nombre_archivo, id, :id) do
    ServicioUsuario.eliminar_usuario(nombre_archivo, id)
  end

  @doc """
  Obtiene la lista de mentores registrados.
  """
  def obtener_mentores(nombre_archivo) do
    ServicioUsuario.obtener_mentores(nombre_archivo)
  end

  @doc """
  Crea un proyecto siempre que el equipo no tenga ya uno asignado.
  """
  def crear_proyecto(archivo_proyectos, nombre, descripcion, categoria, id_equipo) do
    proyectos = ServicioProyecto.listar_proyectos(archivo_proyectos)

    if Enum.any?(proyectos, fn p -> p.id_equipo == id_equipo end) do
      {:error, "El equipo ya tiene un proyecto registrado."}
    else
      ServicioProyecto.crear_proyecto(
        archivo_proyectos,
        nombre,
        descripcion,
        categoria,
        id_equipo
      )
    end
  end

  @doc """
  Actualiza el estado del proyecto asociado a un equipo.
  """
  def actualizar_estado_proyecto(nombre_archivo, id_equipo, nuevo_estado) do
    proyecto_ = ServicioProyecto.obtener_proyecto_id_equipo(nombre_archivo, id_equipo)

    case proyecto_ do
      {:error, reason} ->
        {:error, reason}

      {:ok, proyecto} ->
        ServicioProyecto.actualizar_estado(nombre_archivo, proyecto.id, nuevo_estado)
    end
  end

  @doc """
  Obtiene un proyecto por su nombre.
  """
  def obtener_proyecto_nombre(nombre_archivo, nombre_proyecto) do
    ServicioProyecto.obtener_proyecto_nombre(nombre_archivo, nombre_proyecto)
  end

  @doc """
  Obtiene un usuario por ID.
  """
  def obtener_usuario(nombre_archivo, id) do
    ServicioUsuario.obtener_usuario(nombre_archivo, id)
  end

  def obtener_usuario_user(nombre_archivo, id) do
    ServicioUsuario.obtener_usuario_user(nombre_archivo, id)
  end

  @doc """
  Lista todos los equipos registrados.
  """
  def listar_equipos(archivo_equipos) do
    ServicioEquipo.obtener_equipos(archivo_equipos)
  end

  @doc """
  Registra un nuevo equipo.
  """
  def registrar_equipo(nombre_archivo, nombre, tema) do
    ServicioEquipo.registrar_equipo(nombre_archivo, nombre, tema)
  end

  @doc """
  Obtiene un equipo usando su nombre.
  """
  def obtener_equipo_nombre(archivo_equipos, nombre_equipo) do
    ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)
  end

  @doc """
  Obtiene un equipo por su ID.
  """
  def obtener_equipo_id(archivo_equipos, id_equipo) do
    ServicioEquipo.obtener_equipo(archivo_equipos, id_equipo)
  end

  @doc """
  Actualiza un campo específico de un usuario.
  """
  def actualizar_campo_usuario(nombre_archivo, id_usuario, valor, tipo_campo) do
    ServicioUsuario.actualizar_campo(nombre_archivo, id_usuario, valor, tipo_campo)
  end

  @doc """
  Obtiene un proyecto asociado a un equipo.
  """
  def obtener_proyecto_id_equipo(nombre_archivo, id_equipo) do
    ServicioProyecto.obtener_proyecto_id_equipo(nombre_archivo, id_equipo)
  end

  @doc """
  Crea una retroalimentación asociada a un proyecto.
  """
  def crear_retroalimentacion(nombre_archivo, id_emisor, contenido, id_proyecto) do
    ServicioMensaje.crear_mensaje(
      nombre_archivo,
      :retroalimentacion,
      nil,
      "",
      id_emisor,
      contenido,
      "",
      id_proyecto,
      ""
    )
  end

  @doc """
  Crea un avance asociado a un proyecto.
  """
  def crear_avance(nombre_archivo, id_emisor, contenido, id_proyecto) do
    ServicioMensaje.crear_mensaje(
      nombre_archivo,
      :avance,
      nil,
      "",
      id_emisor,
      contenido,
      "",
      id_proyecto,
      ""
    )
  end

  @doc """
  Obtiene todas las retroalimentaciones de un proyecto validando que dicho proyecto exista.
  """
  def obtener_retroalimentaciones_proyecto(
        nombre_archivo_proyectos,
        archivo_mensajes,
        id_proyecto
      ) do
    retroalimentaciones =
      ServicioMensaje.filtrar_por_proyecto(archivo_mensajes, :retroalimentacion, id_proyecto)

    case ServicioProyecto.obtener_proyecto(nombre_archivo_proyectos, id_proyecto) do
      {:error, reason} ->
        {:error, reason}

      {:ok, proyecto} ->
        case retroalimentaciones do
          [] -> {:error, "No hay retroalimentaciones para el proyecto #{proyecto.nombre}"}
          _ -> {:ok, retroalimentaciones}
        end
    end
  end

  @doc """
  Obtiene todos los avances de un proyecto validando previamente la existencia del proyecto.
  """
  def obtener_avances_proyecto(nombre_archivo, id_proyecto) do
    avances =
      ServicioMensaje.filtrar_por_proyecto(nombre_archivo, :avance, id_proyecto)

    case ServicioProyecto.obtener_proyecto(nombre_archivo, id_proyecto) do
      {:error, reason} ->
        {:error, reason}

      {:ok, proyecto} ->
        case avances do
          [] -> {:error, "No hay avances para el proyecto #{proyecto.nombre}"}
          _ -> {:ok, avances}
        end
    end
  end

  def marcar_leidos(nombre_archivo, mensajes) do
    ServicioMensaje.marcar_leidos(nombre_archivo, mensajes)
  end

  def obtener_mensajes_personal(nombre_archivo, id_emisor, id_receptor) do
    case ServicioMensaje.filtrar_mensajes_personal(nombre_archivo, id_emisor, id_receptor) do
      [] -> {:error, "El usuario no tiene mensajes con el receptor especificado."}
      mensajes -> {:ok, mensajes}
    end
  end

  def obtener_mensajes_personal_pendientes(nombre_archivo, id_emisor, id_receptor) do
    case ServicioMensaje.filtrar_mensajes_personal_pendiente(
           nombre_archivo,
           id_emisor,
           id_receptor
         ) do
      [] -> {:error, "No hay mensajes pendientes con el receptor especificado."}
      mensajes -> {:ok, mensajes}
    end
  end

  def crear_mensaje_personal(nombre_archivo, id_emisor, id_receptor, contenido) do
    ServicioMensaje.crear_mensaje(
      nombre_archivo,
      :chat,
      :usuario,
      id_receptor,
      id_emisor,
      contenido,
      "",
      "",
      "pendiente"
    )
  end

  def obtener_mensajes_equipo(nombre_archivo, id_equipo, _id_emisor) do
    case ServicioMensaje.filtrar_mensajes_equipo(nombre_archivo, id_equipo) do
      [] -> {:error, "El chat del equipo aún no tiene mensajes."}
      mensajes -> {:ok, mensajes}
    end
  end

  def obtener_mensajes_equipo_pendientes(nombre_archivo, id_equipo, _id_emisor) do
    case ServicioMensaje.filtrar_mensajes_equipo_pendiente(nombre_archivo, id_equipo) do
      [] -> {:error, "El chat del equipo aún no tiene mensajes."}
      mensajes -> {:ok, mensajes}
    end
  end

  def crear_mensaje_equipo(nombre_archivo, id_emisor, id_equipo, contenido) do
    ServicioMensaje.crear_mensaje(
      nombre_archivo,
      :chat,
      :equipo,
      "",
      id_emisor,
      contenido,
      id_equipo,
      "",
      "pendiente"
    )
  end

  @doc """
  Obtiene los participantes de un equipo dado su nombre.
  """
  def obtener_participantes_equipo_nombre(archivo_equipos, archivo_usuarios, nombre_equipo) do
    equipo_ = ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)

    case equipo_ do
      {:error, reason} ->
        {:error, reason}

      {:ok, equipo} ->
        ServicioUsuario.obtener_participantes_equipo(archivo_usuarios, equipo.id)
    end
  end

  @doc """
  Devuelve un map con el equipo y su lista de miembros.
  """
  def obtener_equipo_con_miembros(archivo_usuarios, archivo_equipos, nombre_equipo) do
    equipo_ = ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)

    case equipo_ do
      {:error, reason} ->
        {:error, reason}

      {:ok, equipo} ->
        miembros =
          obtener_participantes_equipo_nombre(archivo_equipos, archivo_usuarios, nombre_equipo)

        case miembros do
          {:error, reason} ->
            {:error, reason}

          {:ok, m} ->
            {:ok, %{equipo: equipo, miembros: m}}
        end
    end
  end

  @doc """
  Asigna un participante a un equipo si ambos existen y no pertenece a otro equipo.
  """
  defp asignar_participante_a_equipo(
         archivo_usuarios,
         archivo_equipos,
         id_participante,
         id_equipo
       ) do
    equipo_ = ServicioEquipo.obtener_equipo(archivo_equipos, id_equipo)
    participante_ = ServicioUsuario.obtener_usuario(archivo_usuarios, id_participante)

    case {equipo_, participante_} do
      {{:error, reason}, _} ->
        {:error, reason}

      {_, {:error, reason}} ->
        {:error, reason}

      {{:ok, _equipo}, {:ok, participante}} ->
        if participante.id_equipo != "" do
          {:error, "El participante ya pertenece a un equipo."}
        else
          actualizado = %{participante | id_equipo: id_equipo}
          ServicioUsuario.actualizar_usuario(archivo_usuarios, actualizado)
          {:ok, actualizado}
        end
    end
  end

  @doc """
  Quita un participante de su equipo si pertenece a alguno.
  """
  def quitar_participante_de_equipo(archivo_usuarios, id_participante) do
    participante = ServicioUsuario.obtener_usuario(archivo_usuarios, id_participante)

    case participante do
      {:error, reason} ->
        {:error, reason}

      {:ok, usuario} ->
        if usuario.id_equipo == "" do
          {:error, "El participante no pertenece a ningún equipo."}
        else
          actualizado = %{usuario | id_equipo: ""}
          ServicioUsuario.actualizar_usuario(archivo_usuarios, actualizado)
          {:ok, actualizado}
        end
    end
  end

  @doc """
  Quita un participante de su equipo (si pertenece a alguno).
  """
  def quitar_participante_de_equipo(archivo_usuarios, id_participante) do
    participante = ServicioUsuario.obtener_usuario(archivo_usuarios, id_participante)

    case participante do
      {:error, reason} ->
        {:error, reason}

      {:ok, usuario} ->
        if usuario.id_equipo == "" do
          {:error, "El participante no pertenece a ningún equipo."}
        else
          actualizado = %{usuario | id_equipo: ""}
          ServicioUsuario.actualizar_usuario(archivo_usuarios, actualizado)
          {:ok, actualizado}
        end
    end
  end

  def crear_sala(nombre_archivo, tema, descripcion) do
    ServicioSala.registrar_sala(nombre_archivo, tema, descripcion)
  end

  def obtener_salas(nombre_archivo), do: ServicioSala.obtener_salas(nombre_archivo)

  def obtener_sala(nombre_archivo, id) do
    ServicioSala.obtener_sala(nombre_archivo, id)
  end

  def obtener_sala_tema(nombre_archivo, tema) do
    ServicioSala.obtener_sala_tema(nombre_archivo, tema)
  end

  def buscar_proyectos_por_categoria(nombre_archivo, categoria) do
    case ServicioProyecto.buscar_por_categoria(nombre_archivo, categoria) do
      [] -> {:error, "No se encontraron proyectos en la categoría #{categoria}."}
      proyectos -> {:ok, proyectos}
    end
  end

  def buscar_proyectos_por_estado(nombre_archivo, estado) do
    case ServicioProyecto.buscar_por_estado(nombre_archivo, estado) do
      [] -> {:error, "No se encontraron proyectos con el estado #{estado}."}
      proyectos -> {:ok, proyectos}
    end
  end
end
