defmodule Hackaton.Services.ServicioMensaje do
  @moduledoc """
  Servicio que gestiona la creación y filtrado de mensajes.
  """

  alias Hackaton.Domain.Mensaje
  alias Hackaton.Adapter.BaseDatos.BdMensaje
  alias Util.GeneradorID

  # ======================================================
  # CREAR MENSAJE
  # ======================================================
  def crear_mensaje(nombre_archivo, tipo_mensaje, tipo_receptor, id_receptor, id_emisor, contenido, id_equipo \\ "", id_proyecto \\ "") do
    id =
      GeneradorID.generar_id_unico("msg", fn nuevo_id ->
        Enum.any?(BdMensaje.leer_mensajes(nombre_archivo), fn m -> m.id == nuevo_id end)
      end)

    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()

    with :ok <- Mensaje.validar_campos_obligatorios(tipo_mensaje, tipo_receptor, id_receptor, contenido) do
      nuevo_mensaje =
        Mensaje.crear_mensaje(id, tipo_mensaje, tipo_receptor, id_receptor, id_emisor, contenido, timestamp, id_equipo, id_proyecto)

      BdMensaje.escribir_mensaje(nombre_archivo, nuevo_mensaje)
      {:ok, nuevo_mensaje}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  # ======================================================
  # FILTRAR MENSAJES
  # ======================================================
  def listar_mensajes(nombre_archivo), do: BdMensaje.leer_mensajes(nombre_archivo)
  def filtrar_por_tipo(nombre_archivo, tipo_mensaje), do: BdMensaje.filtrar_mensajes(nombre_archivo, tipo_mensaje)
  def filtrar_por_receptor(nombre_archivo, tipo_receptor), do: BdMensaje.filtrar_mensajes(nombre_archivo, tipo_receptor)
  def filtrar_por_proyecto(nombre_archivo, tipo_mensaje, id_proyecto), do: BdMensaje.filtrar_mensajes_proyecto(nombre_archivo, tipo_mensaje, id_proyecto)
  def filtrar_por_receptor_y_tipo(nombre_archivo, tipo_mensaje, id_receptor), do: BdMensaje.filtrar_mensajes(nombre_archivo, tipo_mensaje, id_receptor)
end
