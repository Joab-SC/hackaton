defmodule Hackaton.Services.ServicioEquipo do
  @moduledoc """
  Servicio encargado de gestionar la lógica de negocio relacionada con equipos:
  registro, consulta, actualización, eliminación y validaciones de unicidad.

  """

  alias Hackaton.Domain.Equipo
  alias Hackaton.Adapter.BaseDatos.BdEquipo
  alias Hackaton.Util.GeneradorID

  @doc """
  Registra un nuevo equipo en el archivo indicado.

  Flujo:
    1. Valida campos obligatorios del equipo.
    2. Valida que no exista otro equipo con el mismo nombre.
    3. Genera un ID único usando `GeneradorID`.
    4. Crea la estructura del equipo.
    5. La escribe en la base de datos.
    6. Devuelve `{:ok, equipo}` si todo sale bien.
  """
  def registrar_equipo(nombre_archivo, nombre, tema) do
    with :ok <- Equipo.validar_campos_obligatorios(nombre, tema),
         :ok <- validar_nombre_unico(nombre_archivo, nombre) do
      nuevo_equipo =
        Equipo.crear_equipo(
          GeneradorID.generar_id_unico("eqp", fn nuevo_id ->
            Enum.any?(BdEquipo.leer_equipos(nombre_archivo), fn u -> u.id == nuevo_id end)
          end),
          nombre,
          tema
        )

      BdEquipo.escribir_equipo(nombre_archivo, nuevo_equipo)
      {:ok, nuevo_equipo}
    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end


  @doc """
  Valida que no exista un equipo con el mismo nombre (ignorando mayúsculas/minúsculas).
  """
  defp validar_nombre_unico(nombre_archivo, nombre) do
    equipos = BdEquipo.leer_equipos(nombre_archivo)

    existe =
      Enum.any?(equipos, fn
        %Equipo{nombre: n} ->
          String.downcase(n) == String.downcase(nombre)

        _ ->
          false
      end)

    if existe do
      {:error, "Ya existe un equipo con ese nombre."}
    else
      :ok
    end
  end

  @doc """
  Obtiene la lista completa de equipos almacenados en el archivo dado.
  """
  def obtener_equipos(nombre_archivo), do: BdEquipo.leer_equipos(nombre_archivo)

  @doc """
  Obtiene un equipo por ID.
  """
  def obtener_equipo(nombre_archivo, id) do
    equipo = BdEquipo.leer_equipo(nombre_archivo, id)

    if is_nil(equipo) do
      {:error, "No se pudo encontrar el equipo con ese id"}
    else
      {:ok, equipo}
    end
  end

  @doc """
  Obtiene un equipo por su nombre.
  """
  def obtener_equipo_nombre(nombre_archivo, nombre) do
    equipo = BdEquipo.leer_equipo_nombre(nombre_archivo, nombre)

    if is_nil(equipo) do
      {:error, "No se pudo encontrar el equipo con el nombre #{nombre}"}
    else
      {:ok, equipo}
    end
  end

  @doc """
  Elimina un equipo por su ID.

  Primero valida que el equipo exista antes de solicitar su eliminación.

  """
  def eliminar_equipo(nombre_archivo, id) do
    equipo = obtener_equipo(nombre_archivo, id)

    case equipo do
      {:error, reason} -> {:error, reason}
      _ -> BdEquipo.borrar_equipo(nombre_archivo, id)
    end
  end

  @doc """
  Actualiza un equipo existente.

  Flujo:
    1. Valida que el equipo exista.
    2. Valida campos obligatorios.
    3. Valida que el nombre no esté duplicado por otro equipo.
    4. Actualiza el registro en la base de datos.
  """
  def actualizar_equipo(nombre_archivo, equipo_actualizado) do
    equipo = obtener_equipo(nombre_archivo, equipo_actualizado.id)

    case equipo do
      {:error, reason} ->
        {:error, reason}

      _ ->
        with :ok <- Equipo.validar_campos_obligatorios(equipo_actualizado.nombre, equipo_actualizado.tema),
             :ok <-
               validar_nombre_id_unico_para_actualizacion(
                 nombre_archivo,
                 equipo_actualizado.id,
                 equipo_actualizado.nombre
               ) do
          BdEquipo.actualizar_equipo(nombre_archivo, equipo_actualizado)
          {:ok, equipo_actualizado}
        else
          {:error, mensaje} -> {:error, mensaje}
        end
    end
  end

  @doc """
  Valida unicidad del nombre al actualizar.

  """
  defp validar_nombre_id_unico_para_actualizacion(nombre_archivo, id_equipo, nombre) do
    equipos = BdEquipo.leer_equipos(nombre_archivo)

    if Enum.any?(equipos, fn e ->
         e.id != id_equipo and String.downcase(e.nombre) == String.downcase(nombre)
       end) do
      {:error, "Ya existe otro equipo con ese nombre."}
    else
      :ok
    end
  end
end
