defmodule Hackaton.Domain.Mensaje do
  @moduledoc """
  Define la estructura y reglas de negocio para los mensajes dentro del sistema Hackaton.
  """

  @tipos_mensaje [:chat, :consulta, :retroalimentacion, :anuncio, :avance]
  @tipos_receptor [:usuario, :equipo, :sala, :todos]

  defstruct id: "",
            tipo_mensaje: "",
            tipo_receptor: "",
            id_receptor: "",
            id_emisor: "",
            contenido: "",
            id_equipo: "",
            timestamp: "",
            id_proyecto: "",
            estado: "pendiente",
            intentos: 0

  # ======================================================
  # Constructores
  # ======================================================

  # Caso base (sin proyecto ni equipo)
  def crear_mensaje(id, tipo_mensaje, tipo_receptor, id_receptor, id_emisor, contenido, timestamp) do
    %__MODULE__{
      id: id,
      tipo_mensaje: tipo_mensaje,
      tipo_receptor: tipo_receptor,
      id_receptor: id_receptor,
      id_emisor: id_emisor,
      contenido: contenido,
      timestamp: timestamp,
      estado: "pendiente",
      intentos: 0
    }
  end

  # Caso extendido (con id_equipo o id_proyecto opcionales)
  def crear_mensaje(id, tipo_mensaje, tipo_receptor, id_receptor, id_emisor, contenido, timestamp, id_equipo, id_proyecto) do
    %__MODULE__{
      id: id,
      tipo_mensaje: tipo_mensaje,
      tipo_receptor: tipo_receptor,
      id_receptor: id_receptor,
      id_emisor: id_emisor,
      contenido: contenido,
      timestamp: timestamp,
      id_equipo: id_equipo,
      id_proyecto: id_proyecto,
      estado: "pendiente",
      intentos: 0
    }
  end

  # ======================================================
  # Validaciones de negocio
  # ======================================================

  def validar_campos_obligatorios(tipo_mensaje, tipo_receptor, id_receptor, contenido) do
    cond do
      tipo_mensaje == "" or tipo_receptor == "" or contenido == "" ->
        {:error, "Todos los campos obligatorios deben estar completos."}

      not (tipo_mensaje in @tipos_mensaje) ->
        {:error,
         "El tipo de mensaje '#{tipo_mensaje}' no es válido. Debe ser uno de: #{inspect(@tipos_mensaje)}"}

      not (tipo_receptor in @tipos_receptor) ->
        {:error,
         "El tipo de receptor '#{tipo_receptor}' no es válido. Debe ser uno de: #{inspect(@tipos_receptor)}"}

      tipo_receptor != :todos and (id_receptor == "" or is_nil(id_receptor)) ->
        {:error,
         "El ID del receptor es obligatorio para mensajes dirigidos a usuarios, equipos o salas."}

      true ->
        :ok
    end
  end
end
