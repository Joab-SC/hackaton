defmodule Equipo do

  defstruct id: "", nombre: "",  tema: ""

  def crear_equipo(id, nombre, tema) do
    %Equipo{id: id, nombre: nombre,  tema: tema}
  end

  # ===========================
  # VALIDACIONES PURAS
  # ===========================

  # Validar campos obligatorios
  def validar_campos_obligatorios(nombre, tema) do
    if Enum.any?([nombre, tema], &(&1 in ["", nil])) do
      {:error, "El nombre y el tema del equipo son obligatorios."}
    else
      :ok
    end
  end


end
