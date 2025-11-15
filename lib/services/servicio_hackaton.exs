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


  def registrar_usuario(nombre_archivo, rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo) do
    ServicioUsuario.registrar_usuario(nombre_archivo, rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo)
  end

  def iniciar_sesion(nombre_archivo, usuario, contrasena) do
    ServicioUsuario.iniciar_sesion(nombre_archivo, usuario, contrasena)
  end



  def unirse_por_nombre(archivo_usuarios, archivo_equipos, id_participante, nombre_equipo) do
    equipo_ = ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)
    case equipo_ do
      {:error, reason} -> {:error, reason}
      {:ok, equipo} -> asignar_participante_a_equipo(archivo_usuarios, archivo_equipos, id_participante, equipo.id)
    end
  end







  # =======================================================
  # 2. QUITAR PARTICIPANTE DE EQUIPO
  # =======================================================
  def quitar_participante_de_equipo(archivo_usuarios, id_participante) do
    participante = ServicioUsuario.obtener_usuario(archivo_usuarios, id_participante)

    case participante do
      {:error, reason} ->
        {:error, reason}

      {:ok, usuario} ->
        if participante.id_equipo == "" do
          {:error, "El participante no pertenece a ningún equipo."}
        else
          actualizado = %{participante | id_equipo: ""}
          ServicioUsuario.actualizar_usuario(archivo_usuarios, actualizado)
          {:ok, actualizado}
        end
    end
  end

  # =======================================================
  # 3. LISTAR EQUIPOS REGISTRADOS (/teams)
  # =======================================================
  def listar_equipos(archivo_equipos) do
    ServicioEquipo.obtener_equipos(archivo_equipos)
  end

  # =======================================================
  # 4. BUSCAR EQUIPO POR NOMBRE (para /join)
  # =======================================================


  # =======================================================
  # 5. OBTENER PARTICIPANTES DE UN EQUIPO
  # =======================================================
  def obtener_participantes_equipo(archivo_equipos, archivo_usuarios, nombre_equipo, :nombre) do
    equipo = ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)

    case equipo do
      {:error, reason} -> {:error, reason}
      _ -> ServicioUsuario.obtener_participantes_equipo(archivo_usuarios, equipo.id)
    end
  end

  def obtener_participantes_equipo(archivo_usuarios, id_equipo, :id_equipo) do
    ServicioUsuario.obtener_participantes_equipo(archivo_usuarios, id_equipo)
  end

  # =======================================================
  # 6. OBTENER EQUIPO Y SUS MIEMBROS
  # =======================================================
  def obtener_equipo_con_miembros(archivo_usuarios, archivo_equipos, nombre) do
    equipo = ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)

    case equipo do
      {:error, reason} -> {:error, reason}
      {:ok, equipo} ->
        miembros = obtener_participantes_equipo(archivo_usuarios, equipo.id, :id_equipo)
        {:ok, %{equipo: equipo, miembros: miembros}}
    end
  end


  def registrar_equipo(nombre_archivo, nombre, tema) do
  end



   defp asignar_participante_a_equipo(archivo_usuarios, archivo_equipos, id_participante, id_equipo) do
    equipo_ = ServicioEquipo.obtener_equipo(archivo_equipos, id_equipo)

    participante_ = ServicioUsuario.obtener_usuario(archivo_usuarios, id_participante)

    case {equipo_, participante_} do
      {{:error, reason}, _} ->
        {:error, reason}

      {_, {:error, reason}} ->
        {:error, reason}

      {{:ok, equipo}, {:ok, participante}} ->
        if participante.id_equipo != "" do
          {:error, "El participante ya pertenece a un equipo."}
        else
          actualizado = %{participante | id_equipo: id_equipo}
          ServicioUsuario.actualizar_usuario(archivo_usuarios, actualizado)
          {:ok, actualizado}
        end
    end
  end

    defp obtener_equipo_nombre(archivo_equipos, nombre_equipo) do
    ServicioEquipo.obtener_equipo_nombre(archivo_equipos, nombre_equipo)
  end
end
