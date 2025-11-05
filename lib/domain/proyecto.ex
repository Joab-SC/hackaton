defmodule Hackaton.Domain.Proyecto do

  defstruct id: "", nombre: "", descripcion: "", categoria: "", estado: "", id_equipo: "", fecha_creacion: ""

  def crear_proyecto(id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion) do
    %__MODULE__{id: id, nombre: nombre, descripcion: descripcion, categoria: categoria,
    estado: estado, id_equipo: id_equipo, fecha_creacion: fecha_creacion}
  end

  def validar_campos_obligatorios(nombre, descripcion, categoria, estado, id_equipo, fecha_creacion) do
    if Enum.any?([nombre, descripcion, categoria, estado, id_equipo, fecha_creacion], &(&1 in ["", nil])) do
      {:error, "Todos los campos obligatorios deben estar llenos."}
    else
      :ok
    end
  end
end
