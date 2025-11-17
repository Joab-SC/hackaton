defmodule Hackaton.Services.ServicioProyecto do
  @moduledoc """
  Servicio encargado de gestionar la lógica de negocio relacionada con proyectos:
  creación, consulta, actualización, eliminación y validaciones de unicidad.
  """

  alias Hackaton.Domain.Proyecto
  alias Hackaton.Adapter.BaseDatos.BdProyecto
  alias Hackaton.Util.GeneradorID

  @doc """
  Crea un nuevo proyecto validando previamente:

    - Campos obligatorios
    - Unicidad del nombre
    - Categoría válida

  Luego genera un ID único, asigna estado `"Nuevo"` y fecha de creación actual.
  """
  def crear_proyecto(nombre_archivo, nombre, descripcion, categoria, id_equipo) do
    with  :ok <- Proyecto.validar_campos_obligatorios(nombre, descripcion, categoria, id_equipo),
          :ok <- validar_nombre_unico(nombre_archivo, nombre),
          :ok <- Proyecto.validar_categoria(categoria) do
            nuevo =
              Proyecto.crear_proyecto(
                GeneradorID.generar_id_unico("pryt", fn nuevo_id ->
                  Enum.any?(BdProyecto.leer_proyectos(nombre_archivo), fn u -> u.id == nuevo_id end)
                end),
                nombre,
                descripcion,
                categoria,
                "Nuevo",
                id_equipo,
                DateTime.utc_now() |> Calendar.strftime("%Y-%m-%d %H:%M:%S")
              )

            BdProyecto.escribir_proyecto(nombre_archivo, nuevo)
            {:ok, nuevo}

    else
      {:error, msg} ->
        {:error, msg}
    end
  end

  @doc """
  Lee y devuelve la lista completa de proyectos almacenados en la base de datos.

  """
  def listar_proyectos(nombre_archivo) do
    BdProyecto.leer_proyectos(nombre_archivo)
  end

  @doc """
  Obtiene un proyecto según su ID.
  """
  def obtener_proyecto(nombre_archivo, id_proyecto) do
    case BdProyecto.leer_proyecto(nombre_archivo, id_proyecto) do
      nil -> {:error, "No se encontró el proyecto con ID #{id_proyecto}"}
      proyecto -> {:ok, proyecto}
    end
  end

  @doc """
  Obtiene un proyecto buscando por su nombre.
  """
  def obtener_proyecto_nombre(nombre_archivo, nombre) do
    case BdProyecto.leer_proyecto_nombre(nombre_archivo, nombre) do
      nil -> {:error, "No hay ningún proyecto registrado con el nombre #{nombre}"}
      proyecto -> {:ok, proyecto}
    end
  end

  @doc """
  Valida que el nombre del proyecto no esté en uso dentro del archivo indicado.
  """
  defp validar_nombre_unico(nombre_archivo, nombre) do
    if Enum.any?(BdProyecto.leer_proyectos(nombre_archivo), fn u -> u.nombre == nombre end) do
      {:error, "El nombre del proyecto ya está en uso."}
    else
      :ok
    end
  end

  @doc """
  Obtiene un proyecto a partir del ID del equipo al que pertenece.

  """
  def obtener_proyecto_id_equipo(nombre_archivo, id_equipo_) do
    case BdProyecto.leer_proyecto_id_equipo(nombre_archivo, id_equipo_) do
      nil -> {:error, "No se encontró el proyecto esa id asociada"}
      proyecto -> {:ok, proyecto}
    end
  end

  @doc """
  Actualiza los datos de un proyecto existente.

  Valida:
    - Campos obligatorios
    - Categoría válida
    - Estado válido

  Luego crea una estructura nueva y la guarda en persistencia.

  """
  def actualizar_proyecto(nombre_archivo, id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion) do
    with  :ok <- Proyecto.validar_campos_obligatorios(nombre, descripcion, categoria, id_equipo),
          :ok <- Proyecto.validar_categoria(categoria),
          :ok <- Proyecto.validar_estado(estado)
    do
      proyecto_actualizado =
        Proyecto.crear_proyecto(
          id,
          nombre,
          descripcion,
          categoria,
          estado,
          id_equipo,
          fecha_creacion
        )

      BdProyecto.actualizar_proyecto(nombre_archivo, proyecto_actualizado)
      {:ok, proyecto_actualizado}

    else
      {:error, msg} -> {:error, msg}
    end
  end

  @doc """
  Cambia el estado de un proyecto existente.
  """
  def actualizar_estado(nombre_archivo, id_proyecto, nuevo_estado) do
    case BdProyecto.leer_proyecto(nombre_archivo, id_proyecto) do
      nil ->
        {:error, "No se encontró el proyecto con ID #{id_proyecto}"}

      proyecto ->
        case Proyecto.validar_estado(nuevo_estado) do
          {:error, reason} -> {:error, reason}
          :ok ->
            proyecto_actualizado = %{proyecto | estado: nuevo_estado}
            BdProyecto.actualizar_proyecto(nombre_archivo, proyecto_actualizado)
            {:ok, proyecto_actualizado}
        end
    end
  end

  @doc """
  Elimina un proyecto según su ID.
  """
  def eliminar_proyecto(nombre_archivo, id_proyecto) do
    case BdProyecto.borrar_proyecto(nombre_archivo, id_proyecto) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Busca proyectos por categoría.

  """
  def buscar_por_categoria(nombre_archivo, categoria) do
    listar_proyectos(nombre_archivo)
    |> Enum.filter(fn %Proyecto{categoria: cat} -> cat == categoria end)
  end

  @doc """
  Busca proyectos por estado.

  """
  def buscar_por_estado(nombre_archivo, estado) do
    listar_proyectos(nombre_archivo)
    |> Enum.filter(fn %Proyecto{estado: est} -> est == estado end)
  end
end
