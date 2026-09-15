defmodule Hackaton.Comunicacion.NodoServidor do
  @moduledoc """
  Nodo servidor del sistema: registra el servicio local y atiende en un bucle las
  peticiones enviadas por los clientes, despachando cada operación contra la fachada
  `Hackaton.Services.ServicioHackathon`.
  """
  alias Hackaton.Comunicacion.Conexion
  alias Hackaton.Services.ServicioHackathon

  def main() do
    IO.puts("=== Nodo Servidor Iniciado ===")

    registrar_servicio(Conexion.nombre_servicio())
    ejecutar_comandos()
  end

  defp registrar_servicio(nombre_servicio_local) do
    Process.register(self(), nombre_servicio_local)
  end

  defp ejecutar_comandos() do
    receive do
      {productor, funcion, args} ->
        retorno = apply(ServicioHackathon, funcion, args)
        send(productor, retorno)
        ejecutar_comandos()
    end
  end
end
