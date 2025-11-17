defmodule Hackaton.Domain.Sala do
  defstruct id: "", tema: "", descripcion: ""


  def crear_sala(id, tema, descripcion) do
    %__MODULE__{
      id: id,
      tema: tema,
      descripcion: descripcion
    }
  end

  def validar_campos_vacios(tema, descripcion) do
    if Enum.any?([tema, descripcion], fn campo ->
         elem(validar_campo_vacio(campo), 0) == :error
       end) do
      {:error, "Todos los campos son obligatorios"}
    else
      :ok
    end
  end

  defp validar_campo_vacio(campo) do
    campo_validar = if is_nil(campo), do: nil, else: String.trim(campo)

    if campo_validar in ["", nil] do
      {:error, "El campo #{campo} no puede estar vacío."}
    else
      {:ok, campo}
    end
  end
end
