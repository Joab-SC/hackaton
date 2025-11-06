defmodule Hackaton.Service.ProyectoService do
  alias Hackaton.Domain.Proyecto
  alias Hackaton.Adapter.BaseDatos.BdProyecto

  # Crear un proyecto nuevo
  def crear_proyecto(nombre_archivo, id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion) do
    case Proyecto.validar_campos_obligatorios(nombre, descripcion, categoria, estado, id_equipo, fecha_creacion) do
      :ok ->
        nuevo = Proyecto.crear_proyecto(id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion)
        BdProyecto.escribir_proyecto(nombre_archivo, nuevo)
        {:ok, nuevo}

      {:error, msg} ->
        {:error, msg}
    end
  end

  # Leer todos los proyectos
  def listar_proyectos(nombre_archivo) do
    BdProyecto.leer_proyectos(nombre_archivo)
  end

  # Buscar un proyecto por su ID
  def obtener_proyecto(nombre_archivo, id_proyecto) do
    case BdProyecto.leer_proyecto(nombre_archivo, id_proyecto) do
      nil -> {:error, "No se encontró el proyecto con ID #{id_proyecto}"}
      proyecto -> {:ok, proyecto}
    end
  end

  # Actualizar un proyecto existente
  def actualizar_proyecto(nombre_archivo, id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion) do
    case Proyecto.validar_campos_obligatorios(nombre, descripcion, categoria, estado, id_equipo, fecha_creacion) do
      :ok ->
        proyecto_actualizado = Proyecto.crear_proyecto(id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion)
        BdProyecto.actualizar_proyecto(nombre_archivo, proyecto_actualizado)
        {:ok, proyecto_actualizado}

      {:error, msg} ->
        {:error, msg}
    end
  end

  # Eliminar un proyecto
  def eliminar_proyecto(nombre_archivo, id_proyecto) do
    case BdProyecto.borrar_proyecto(nombre_archivo, id_proyecto) do
      :ok -> {:ok, "Proyecto con ID #{id_proyecto} eliminado correctamente."}
      {:error, reason} -> {:error, reason}
    end
  end

  # Buscar proyectos por categoría
  def buscar_por_categoria(nombre_archivo, categoria) do
    listar_proyectos(nombre_archivo)
    |> Enum.filter(fn %Proyecto{categoria: cat} -> cat == categoria end)
  end

  # Buscar proyectos por estado
  def buscar_por_estado(nombre_archivo, estado) do
    listar_proyectos(nombre_archivo)
    |> Enum.filter(fn %Proyecto{estado: est} -> est == estado end)
  end
end
