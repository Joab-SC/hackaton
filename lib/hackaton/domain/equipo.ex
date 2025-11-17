defmodule Hackaton.Domain.Equipo do
  @moduledoc """
  Módulo del dominio encargado de representar y validar la información
  relacionada con un equipo dentro de la plataforma Hackaton.

  Proporciona funciones para crear estructuras de equipo y realizar
  validaciones básicas sobre los datos suministrados.
  """

  defstruct id: "", nombre: "", tema: ""

  @doc """
  Crea una estructura `%Equipo{}` a partir de los parámetros dados.

  """
  def crear_equipo(id, nombre, tema) do
    %__MODULE__{id: id, nombre: nombre, tema: tema}
  end


  @doc """
  Valida que los campos obligatorios `nombre` y `tema` no estén vacíos ni sean `nil`.

  """
  def validar_campos_obligatorios(nombre, tema) do
    if Enum.any?([nombre, tema], &(&1 in ["", nil])) do
      {:error, "El nombre y el tema del equipo son obligatorios."}
    else
      :ok
    end
  end
end
