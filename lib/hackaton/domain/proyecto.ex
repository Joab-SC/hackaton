defmodule Hackaton.Domain.Proyecto do
  @moduledoc """
  Módulo del dominio encargado de representar un proyecto dentro de la
  plataforma Hackaton y realizar validaciones sobre sus datos principales.

  """

  @tipos_estado ["proceso", "finalizado"]
  @categorias ["educacion", "salud", "sostenibilidad", "productividad", "innovación"]

  defstruct id: "",
            nombre: "",
            descripcion: "",
            categoria: "",
            estado: "",
            id_equipo: "",
            fecha_creacion: ""

  @doc """
  Crea una estructura `%Proyecto{}` con los valores suministrados.
  """
  def crear_proyecto(id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      categoria: categoria,
      estado: estado,
      id_equipo: id_equipo,
      fecha_creacion: fecha_creacion
    }
  end

  @doc """
  Valida que todos los campos obligatorios del proyecto estén llenos:
  `nombre`, `descripcion`, `categoria` e `id_equipo`.

  """
  def validar_campos_obligatorios(nombre, descripcion, categoria, id_equipo) do
    if Enum.any?([nombre, descripcion, categoria, id_equipo], &(&1 in ["", nil])) do
      {:error, "Todos los campos obligatorios deben estar llenos."}
    else
      :ok
    end
  end

  @doc """
  Valida que el estado del proyecto sea uno de los permitidos
  (`"proceso"` o `"finalizado"`).

  """
  def validar_estado(estado) do
    if estado in @tipos_estado do
      :ok
    else
      {:error, "Estado no válido, los estados permitidos son: (proceso, finalizado)"}
    end
  end

  @doc """
  Valida que la categoría del proyecto pertenezca a la lista de categorías
  permitidas definidas en `@categorias`.

  """
  def validar_categoria(categoria) do
    if categoria in @categorias do
      :ok
    else
      {:error, "Estado no válido, los estados permitidos son: (proceso, finalizado)"}
    end
  end
end
