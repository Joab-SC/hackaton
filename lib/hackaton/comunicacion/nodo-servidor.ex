defmodule Hackaton.Comunicacion.NodoServidor do
  @moduledoc """
    Servicio Hackaton que maneja las operaciones principales del sistema,
    incluyendo la gestión de usuarios, equipos, proyectos y mensajes.

    Funcionalidades:
    - Registro e inicio de sesión de usuarios
    - Creación y gestión de equipos
    - Creación y gestión de proyectos
    - Envío y recepción de mensajes entre usuarios
    - Listar equipos y sus miembros
    - Buscar equipos por nombre o ID
  """
  @nombre_servicio_local :servicio_hackaton
  alias Hackaton.Services.{ServicioEquipo, ServicioMensaje, ServicioProyecto, ServicioUsuario}



  def main() do
    IO.puts("=== Nodo Servidor Iniciado ===")

    registrar_servicio(@nombre_servicio_local)
    ejectar_comandos()
  end

  defp registrar_servicio(nombre_servicio_local) do
    Process.register(self(), nombre_servicio_local)
  end

  defp ejectar_comandos() do
    receive do
      {productor, funcion, args} ->
        retorno = apply(Hackaton.Services.ServicioHackathon, funcion, args)
        send(productor, retorno)
        ejectar_comandos()
    end
  end
end
