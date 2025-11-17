defmodule Hackaton.Domain.Mensaje do
  @moduledoc """
  Define la estructura de un mensaje dentro del sistema Hackaton y las reglas
  de negocio necesarias para validar su creación.
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
            fecha: "",
            id_proyecto: "",
            estado: ""


  @doc """
  Crea una estructura `%Mensaje{}` con todos los campos del dominio.

  """
  def crear_mensaje(id, tipo_mensaje, tipo_receptor, id_receptor, id_emisor, contenido,
                      id_equipo, fecha, id_proyecto, estado) do
    %__MODULE__{
      id: id,
      tipo_mensaje: tipo_mensaje,
      tipo_receptor: tipo_receptor,
      id_receptor: id_receptor,
      id_emisor: id_emisor,
      contenido: contenido,
      id_equipo: id_equipo,
      fecha: fecha,
      id_proyecto: id_proyecto,
      estado: estado
    }
  end


  @doc """
  Valida que un campo obligatorio no sea `nil` ni una cadena vacía.

  """
  def validar_campo_vacio(nil), do: {:error, "No puede estar vacío"}
  def validar_campo_vacio(""), do: {:error, "No puede estar vacío"}
  def validar_campo_vacio(campo) when is_binary(campo), do: {:ok, String.trim(campo)}
  def validar_campo_vacio(campo), do: {:ok, campo}

  @doc """
  Valida los campos obligatorios requeridos para crear un mensaje.

  """
  def validar_campos_obligatorios(tipo_mensaje, tipo_receptor, id_receptor, contenido) do
    with {:ok, _} <- validar_campo_vacio(tipo_mensaje),
         {:ok, _} <- validar_campo_vacio(contenido),
         {:ok, _} <- validar_tipo_mensaje(tipo_mensaje),
         :ok <- validar_tipo_receptor_si_necesario(tipo_mensaje, tipo_receptor),
         :ok <- validar_receptor_id(tipo_mensaje, tipo_receptor, id_receptor) do
      :ok
    end
  end


  @doc """
  Valida que el tipo de mensaje pertenezca a los valores permitidos.

  """
  defp validar_tipo_mensaje(tipo_mensaje) do
    if tipo_mensaje in @tipos_mensaje,
      do: {:ok, tipo_mensaje},
      else: {:error, "Tipo de mensaje inválido"}
  end


  @doc """
  Valida el tipo de receptor solo cuando el mensaje no pertenece a los tipos
  especiales `:avance` o `:retroalimentacion`, los cuales no requieren receptor explícito.

  """
  defp validar_tipo_receptor_si_necesario(tipo_mensaje, tipo_receptor)
       when tipo_mensaje in [:avance, :retroalimentacion], do: :ok

  defp validar_tipo_receptor_si_necesario(_tipo_mensaje, tipo_receptor) do
    if tipo_receptor in @tipos_receptor,
      do: :ok,
      else: {:error, "Tipo de receptor inválido"}
  end


  @doc """
  Valida el campo `id_receptor` dependiendo del tipo de mensaje y del tipo de receptor.

  """
  defp validar_receptor_id(tipo_mensaje, _tipo_receptor, _id_receptor)
       when tipo_mensaje in [:avance, :retroalimentacion], do: :ok

  defp validar_receptor_id(_, :todos, _), do: :ok
  defp validar_receptor_id(_, _, nil), do: {:error, "ID de receptor obligatorio"}
  defp validar_receptor_id(_, _, ""), do: {:error, "ID de receptor obligatorio"}
  defp validar_receptor_id(_, _, _), do: :ok
end
