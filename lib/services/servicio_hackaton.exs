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
alias Hackaton.Adapter.BaseDatos.{BdEquipo, BdUsuario}

  # =======================================================
  # 1. ASIGNAR PARTICIPANTE A EQUIPO  (/join)
  # =======================================================
  def asignar_participante_a_equipo(archivo_usuarios, archivo_equipos, id_participante, id_equipo) do
    equipo = BdEquipo.leer_equipo(archivo_equipos, id_equipo)
    participante = BdUsuario.leer_usuario(archivo_usuarios, id_participante)

    cond do
      equipo == nil ->
        {:error, "El equipo con id #{id_equipo} no existe."}

      participante == nil ->
        {:error, "El participante con id #{id_participante} no existe."}

      participante.rol != "PARTICIPANTE" ->
        {:error, "Solo los usuarios con rol PARTICIPANTE pueden unirse a equipos."}

      participante.id_equipo != "" ->
        {:error, "El participante ya pertenece a un equipo."}

      true ->
        actualizado = %{participante | id_equipo: id_equipo}
        BdUsuario.actualizar_usuario(archivo_usuarios, actualizado)
        {:ok, actualizado}
    end
  end

  # =======================================================
  # 2. QUITAR PARTICIPANTE DE EQUIPO
  # =======================================================
  def quitar_participante_de_equipo(archivo_usuarios, id_participante) do
    participante = BdUsuario.leer_usuario(archivo_usuarios, id_participante)

    cond do
      participante == nil ->
        {:error, "El participante con id #{id_participante} no existe."}

      participante.id_equipo == "" ->
        {:error, "El participante no pertenece a ningún equipo."}

      true ->
        actualizado = %{participante | id_equipo: ""}
        BdUsuario.actualizar_usuario(archivo_usuarios, actualizado)
        {:ok, actualizado}
    end
  end

  # =======================================================
  # 3. LISTAR EQUIPOS REGISTRADOS (/teams)
  # =======================================================
  def listar_equipos(archivo_equipos) do
    BdEquipo.leer_equipos(archivo_equipos)
    |> Enum.map(fn e -> %{id: e.id, nombre: e.nombre, tema: e.tema} end)
  end

  # =======================================================
  # 4. BUSCAR EQUIPO POR NOMBRE (para /join)
  # =======================================================
  def buscar_equipo_por_nombre(archivo_equipos, nombre_equipo) do
    BdEquipo.leer_equipos(archivo_equipos)
    |> Enum.find(fn e -> String.downcase(e.nombre) == String.downcase(nombre_equipo) end)
  end

  # =======================================================
  # 5. OBTENER PARTICIPANTES DE UN EQUIPO
  # =======================================================
  def obtener_participantes_equipo(archivo_usuarios, id_equipo) do
    BdUsuario.leer_participantes_equipo(archivo_usuarios, id_equipo)
  end

  # =======================================================
  # 6. OBTENER EQUIPO Y SUS MIEMBROS
  # =======================================================
  def obtener_equipo_con_miembros(archivo_usuarios, archivo_equipos, id_equipo) do
    equipo = BdEquipo.leer_equipo(archivo_equipos, id_equipo)

    if equipo do
      miembros = obtener_participantes_equipo(archivo_usuarios, id_equipo)
      {:ok, %{equipo: equipo, miembros: miembros}}
    else
      {:error, "El equipo con id #{id_equipo} no existe."}
    end
  end

  # =======================================================
  # 7. COMANDO /JOIN (versión con nombre de equipo)
  # =======================================================
  def unirse_por_nombre(archivo_usuarios, archivo_equipos, id_participante, nombre_equipo) do
    equipo = buscar_equipo_por_nombre(archivo_equipos, nombre_equipo)

    if equipo do
      asignar_participante_a_equipo(archivo_usuarios, archivo_equipos, id_participante, equipo.id)
    else
      {:error, "No se encontró un equipo con el nombre '#{nombre_equipo}'."}
    end
  end
end
