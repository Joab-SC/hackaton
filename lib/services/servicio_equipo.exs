defmodule Hackaton.Services.ServicioEquipo do
  alias Hackaton.Domain.Equipo
  alias Hackaton.Adapter.BaseDatos.BdEquipo
  alias Hackaton.Util.GeneradorID

  # -------------------------
  # REGISTRAR EQUIPO
  # -------------------------
  def registrar_equipo(nombre_archivo, nombre, tema) do
    with :ok <- Equipo.validar_campos_obligatorios(id, nombre, tema),
         :ok <- validar_nombre_unico(nombre_archivo, nombre) do
      nuevo_equipo = Equipo.crear_equipo(GeneradorID.generar_id_unico("eqp", fn nuevo_id ->
        Enum.any?(BdEquipo.leer_equipos(nombre_archivo), fn u -> u.id == nuevo_id end)end), nombre, tema)
      Bd_equipo.escribir_equipo(nombre_archivo, nuevo_equipo)
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
  def obtener_todos(nombre_archivo), do: BdEquipo.leer_equipos(nombre_archivo)

  def obtener_por_id(nombre_archivo, id), do: BdEquipo.leer_equipo(nombre_archivo, id)

  def eliminar_equipo(nombre_archivo, id), do: BdEquipo.borrar_equipo(nombre_archivo, id)

  def actualizar_equipo(nombre_archivo, equipo) do
    with :ok <- Equipo.validar_campos_obligatorios(equipo.id, equipo.nombre, equipo.tema),
         :ok <- validar_nombre_unico_para_actualizacion(nombre_archivo, equipo.id, equipo.nombre) do
          BdEquipo.actualizar_equipo(nombre_archivo, equipo)
      {:ok, equipo}
    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end

  # Evita conflicto al actualizar (permite el mismo nombre si es el mismo equipo)
  defp validar_nombre_unico_para_actualizacion(nombre_archivo, id_equipo, nombre) do
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
