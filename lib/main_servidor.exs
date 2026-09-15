defmodule Hackaton.MainServidor do
  alias Hackaton.Comunicacion.Conexion

  def main do
    IO.puts("Iniciando servidor Hackaton...")

    case Conexion.configurar_cookie() do
      :ok ->
        iniciar()

      {:error, _motivo} ->
        IO.puts(Conexion.mensaje_no_distribuido(:servidor))
    end
  end

  defp iniciar do
    {:ok, pid} = Hackaton.AppServidor.start_link(nil)

    IO.puts("Servidor iniciado correctamente. Pid #{inspect(pid)}")
    IO.puts("Nombre de este nodo: #{Node.self()}")

    IO.puts("""
    Los clientes de esta misma máquina ya lo encuentran solos.
    Si algún cliente corre en OTRA máquina, que use este nombre al arrancar:

        HACKATON_SERVIDOR=#{Node.self()} #{Conexion.comando_cliente()}
    """)

    Process.sleep(:infinity)
  end
end

Hackaton.MainServidor.main()
