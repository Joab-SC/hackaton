defmodule Hackaton.Services.ServicioSala do

  alias Hackaton.Domain.Sala
  alias Hackaton.Adapter.BaseDatos.BdSala
  alias Hackaton.Util.GeneradorID

  @doc """
  Registra una nueva sala en el archivo indicado.

  Flujo:
    1. Valida campos obligatorios de la sala.
    2. Valida que no exista otro sala con el mismo tema.
    3. Genera un ID único usando `GeneradorID`.
    4. Crea la estructura de sala.
    5. La escribe en la base de datos.
    6. Devuelve `{:ok, equipo}` si todo sale bien.
  """
  def registrar_sala(nombre_archivo, tema, descripcion) do
    with :ok <- Sala.validar_campos_vacios(tema, descripcion),
         :ok <- validar_tema_unico(nombre_archivo, tema) do
      nueva_sala =
        Sala.crear_sala(
          GeneradorID.generar_id_unico("sal", fn nuevo_id ->
            Enum.any?(BdSala.leer_salas(nombre_archivo), fn u -> u.id == nuevo_id end)
          end),
          tema,
          descripcion
        )

      BdSala.escribir_sala(nombre_archivo, nueva_sala)
      {:ok, nueva_sala}
    else
      {:error, mensaje} -> {:error, mensaje}
    end
  end


  defp validar_tema_unico(nombre_archivo, tema) do
    salas = BdSala.leer_salas(nombre_archivo)

    existe =
      Enum.any?(salas, fn
        %Sala{tema: t} ->
          String.downcase(t) == String.downcase(tema)

        _ ->
          false
      end)

    if existe do
      {:error, "Ya existe una sala con ese tema."}
    else
      :ok
    end
  end

  @doc """
  Obtiene la lista completa de salas almacenados en el archivo dado.
  """
  def obtener_salas(nombre_archivo), do: BdSala.leer_salas(nombre_archivo)

  @doc """
  Obtiene una sala  por ID.
  """
  def obtener_sala(nombre_archivo, id) do
    sala = BdSala.leer_sala(nombre_archivo, id)

    if is_nil(sala) do
      {:error, "No se pudo encontrar la sala con ese id"}
    else
      {:ok, sala}
    end
  end


  def obtener_sala_tema(nombre_archivo, tema) do
    sala = BdSala.leer_sala_tema(nombre_archivo, tema)

    if is_nil(sala) do
      {:error, "No se pudo encontrar el equipo con el tema #{tema}"}
    else
      {:ok, sala}
    end
  end
end
