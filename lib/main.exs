defmodule Hackaton.Main do
  alias Hackaton.Adapter.Comandos
  alias Hackaton.Comunicacion.Conexion

  def main do
    # Iniciar supervisor del cliente (incluye SesionGlobal)
    {:ok, _} = Hackaton.AppCliente.start_link(nil)

    # La cookie y el nodo servidor se resuelven en tiempo de ejecución,
    # así que el programa funciona en cualquier máquina sin editar código.
    case Conexion.configurar_cookie() do
      :ok -> conectar()
      {:error, _motivo} -> IO.puts(Conexion.mensaje_no_distribuido(:cliente))
    end
  end

  defp conectar do
    case Conexion.nodo_servidor() do
      {:ok, nodo_servidor} ->
        if Node.connect(nodo_servidor) do
          IO.puts(Conexion.mensaje_conectado(nodo_servidor))
          Comandos.escuchar_comandos()
        else
          IO.puts(Conexion.mensaje_conexion_fallida(nodo_servidor))
        end

      {:error, _motivo} ->
        IO.puts(Conexion.mensaje_no_distribuido(:cliente))
    end
  end
end

Hackaton.Main.main()
