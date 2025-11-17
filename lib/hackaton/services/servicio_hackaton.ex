defmodule Hackaton.Services.ServicioHackathon do
  @moduledoc """
  Servicio general que coordina la interacción entre usuarios, equipos y otras entidades
  del sistema de la Hackathon.

  Se encarga de:
    - Asignar participantes a equipos (/join)
    - Quitar participantes de equipos
    - Listar equipos y sus miembros
    - Buscar equipos por nombre o ID
  """
  alias Hackaton.Services.{ServicioEquipo, ServicioMensaje, ServicioProyecto, ServicioUsuario}

  # =======================================================
  # 3. para usuarios
  # =======================================================
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

  def actualizar_usuario(nombre_archivo, usuario_actualizado) do
    ServicioUsuario.actualizar_usuario(nombre_archivo, usuario_actualizado)
  end

  def iniciar_sesion(nombre_archivo, usuario, contrasena) do
    ServicioUsuario.iniciar_sesion(nombre_archivo, usuario, contrasena)
  end

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

  def obtener_mentores(nombre_archivo) do
    ServicioUsuario.obtener_mentores(nombre_archivo)
  end

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

  def actualizar_estado_proyecto(nombre_archivo, id_equipo, nuevo_estado) do
    proyecto_ = ServicioProyecto.obtener_proyecto_id_equipo(nombre_archivo, id_equipo)

    case proyecto_ do
      {:error, reason} ->
        {:error, reason}

      {:ok, proyecto} ->
        ServicioProyecto.actualizar_estado(nombre_archivo, proyecto.id, nuevo_estado)
    end
  end

  def obtener_proyecto_nombre(nombre_archivo, nombre_proyecto) do
    ServicioProyecto.obtener_proyecto_nombre(nombre_archivo, nombre_proyecto)
  end

  def obtener_usuario(nombre_archivo, id) do
    ServicioUsuario.obtener_usuario(nombre_archivo, id)
  end

  def obtener_usuario_user(nombre_archivo, id) do
    ServicioUsuario.obtener_usuario_user(nombre_archivo, id)
  end

  def listar_equipos(archivo_equipos) do
    ServicioEquipo.obtener_equipos(archivo_equipos)
  end

  def registrar_equipo(nombre_archivo, nombre, tema) do
    ServicioEquipo.registrar_equipo(nombre_archivo, nombre, tema)
  end

  def obtener_equipo_nombre(archivo_equipos, nombre_equipo) do
    ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)
  end

  def obtener_equipo_id(archivo_equipos, id_equipo) do
    ServicioEquipo.obtener_equipo(archivo_equipos, id_equipo)
  end

  def actualizar_campo_usuario(nombre_archivo, id_usuario, valor, tipo_campo) do
    ServicioUsuario.actualizar_campo(nombre_archivo, id_usuario, valor, tipo_campo)
  end

  def obtener_proyecto_id_equipo(nombre_archivo, id_equipo) do
    ServicioProyecto.obtener_proyecto_id_equipo(nombre_archivo, id_equipo)
  end

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

  # Crear avance de proyecto
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

  def marcar_leidos(nombre_archivo, mensajes) do
    ServicioMensaje.marcar_leidos(nombre_archivo, mensajes)
  end

  # =======================================================
  # 5. OBTENER PARTICIPANTES DE UN EQUIPO
  # =======================================================
  def obtener_participantes_equipo_nombre(archivo_equipos, archivo_usuarios, nombre_equipo) do
    equipo_ = ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)

    case equipo_ do
      {:error, reason} -> {:error, reason}
      {:ok, equipo} -> ServicioUsuario.obtener_participantes_equipo(archivo_usuarios, equipo.id)
    end
  end

  # =======================================================
  # 6. OBTENER EQUIPO Y SUS MIEMBROS
  # =======================================================
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

  # =======================================================
  # Por ahora inutil
  # =======================================================
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
end
