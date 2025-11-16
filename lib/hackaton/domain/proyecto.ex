defmodule Hackaton.Domain.Proyecto do

  @tipos_estado ["proceso", "finalizado"]
  @categorias ["educacion", "salud", "sostenibilidad", "productividad", "innovación"]

  defstruct id: "", nombre: "", descripcion: "", categoria: "", estado: "", id_equipo: "", fecha_creacion: ""

  def crear_proyecto(id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion) do
    %__MODULE__{id: id, nombre: nombre, descripcion: descripcion, categoria: categoria,
    estado: estado, id_equipo: id_equipo, fecha_creacion: fecha_creacion}
  end

  def validar_campos_obligatorios(nombre, descripcion, categoria, id_equipo) do
    if Enum.any?([nombre, descripcion, categoria, id_equipo], &(&1 in ["", nil])) do
      {:error, "Todos los campos obligatorios deben estar llenos."}
    else
      :ok
    end
  end

  def validar_estado(estado) do
    if estado in @tipos_estado do
      :ok
    else
      {:error, "Estado no válido, los estados permitidos son: (proceso, finalizado)"}
    end
  end

  def validar_categoria(categoria) do
    if categoria in @categorias do
      :ok
    else
      {:error, "Estado no válido, los estados permitidos son: (proceso, finalizado)"}
    end
  end
end
