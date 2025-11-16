defmodule Hackaton.Services.ServicioEquipo do
  alias Hackaton.Domain.Equipo
  alias Hackaton.Adapter.BaseDatos.BdEquipo
  alias Hackaton.Util.GeneradorID

  # -------------------------
  # REGISTRAR EQUIPO
  # -------------------------
  def registrar_equipo(nombre_archivo, nombre, tema) do
    with :ok <- Equipo.validar_campos_obligatorios(nombre, tema),
         :ok <- validar_nombre_unico(nombre_archivo, nombre) do
      nuevo_equipo = Equipo.crear_equipo(GeneradorID.generar_id_unico("eqp", fn nuevo_id ->
        Enum.any?(BdEquipo.leer_equipos(nombre_archivo), fn u -> u.id == nuevo_id end)end), nombre, tema)
      BdEquipo.escribir_equipo(nombre_archivo, nuevo_equipo)
      {:ok, nuevo_equipo}

    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end

  # -------------------------
  # VALIDACIÓN DE ENTORNO
  # -------------------------
  defp validar_nombre_unico(nombre_archivo, nombre) do
    equipos = BdEquipo.leer_equipos(nombre_archivo)

    if Enum.any?(equipos, fn e -> String.downcase(e.nombre) == String.downcase(nombre) end) do
      {:error, "Ya existe un equipo con ese nombre."}
    else
      :ok
    end
  end

  # -------------------------
  # OPERACIONES DE SERVICIO
  # -------------------------
  def obtener_equipos(nombre_archivo), do: BdEquipo.leer_equipos(nombre_archivo)

  def obtener_equipo(nombre_archivo, id) do
    equipo = BdEquipo.leer_equipo(nombre_archivo, id)
    if not equipo do
      {:error, "No se pudo encontrar el equipo con ese id"}
    else
      {:ok,equipo}
    end
  end

  def obtener_equipo_nombre(nombre_archivo, nombre) do
    equipo =  BdEquipo.leer_equipo_nombre(nombre_archivo, nombre)
    if not equipo do
      {:error, "No se pudo encontrar el equipo con el nombre #{nombre}"}
    else
      {:ok,equipo}
    end
  end


  def eliminar_equipo(nombre_archivo, id) do
    equipo = obtener_equipo(nombre_archivo, id)
    case equipo do
      {:error, reason} -> {:error, reason}
      _ -> BdEquipo.borrar_equipo(nombre_archivo, id)
    end

  end


  def actualizar_equipo(nombre_archivo, equipo_actualizado) do

    equipo = obtener_equipo(nombre_archivo, equipo_actualizado.id)
    case equipo do
      {:error, reason} -> {:error, reason}
      _ ->

        with :ok <- Equipo.validar_campos_obligatorios(equipo_actualizado.nombre, equipo_actualizado.tema),
         :ok <- validar_nombre_id_unico_para_actualizacion(nombre_archivo, equipo_actualizado.id, equipo_actualizado.nombre) do
          BdEquipo.actualizar_equipo(nombre_archivo, equipo_actualizado)
          {:ok, equipo_actualizado}
        else
          {:error, mensaje} -> {:error, mensaje}
        end
    end

  end


  # Evita conflicto al actualizar (permite el mismo nombre si es el mismo equipo)
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
