defmodule Hackaton.Adapter.BaseDatos.BdMensaje do
  alias Hackaton.Domain.Mensaje

  def leer_mensajes(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |> Enum.map(fn linea ->
          case String.split(String.replace(linea, "\r", ""), ",") do
            [
              "id",
              "Tipo_mensaje",
              "Tipo_receptor",
              "id_receptor",
              "id_emisor",
              "Contenido",
              "id_equipo",
              "Fecha",
              "id_proyecto",
              "Estado"
            ] ->
              nil

            [
              id,
              tipo_mensaje,
              tipo_receptor,
              id_receptor,
              id_emisor,
              contenido,
              id_equipo,
              fecha,
              id_proyecto,
              estado
            ] ->
              %Mensaje{
                id: id,
                tipo_mensaje: String.to_atom(tipo_mensaje),
                tipo_receptor: String.to_atom(tipo_receptor),
                id_receptor: id_receptor,
                id_emisor: id_emisor,
                contenido: contenido,
                id_equipo: id_equipo,
                fecha: fecha,
                id_proyecto: id_proyecto,
                estado: estado
              }

            _ ->
              nil
          end
        end)
        |> Enum.filter(fn x -> x end)

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end

  def leer_mensaje(nombre_archivo, id_mensaje) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem =
          String.split(lista, "\n")
          |> Enum.map(fn linea ->
            case String.split(String.replace(linea, "\r", ""), ",") do
              [
                "id",
                "Tipo_mensaje",
                "Tipo_receptor",
                "id_receptor",
                "id_emisor",
                "Contenido",
                "id_equipo",
                "Fecha",
                "id_proyecto",
                "Estado"
              ] ->
                nil

              [
                id,
                tipo_mensaje,
                tipo_receptor,
                id_receptor,
                id_emisor,
                contenido,
                id_equipo,
                fecha,
                id_proyecto,
                estado
              ] ->
                if id == id_mensaje do
                  %Mensaje{
                    id: id,
                    tipo_mensaje: String.to_atom(tipo_mensaje),
                    tipo_receptor: String.to_atom(tipo_receptor),
                    id_receptor: id_receptor,
                    id_emisor: id_emisor,
                    contenido: contenido,
                    id_equipo: id_equipo,
                    fecha: fecha,
                    id_proyecto: id_proyecto,
                    estado: estado
                  }
                else
                  nil
                end

              _ ->
                nil
            end
          end)
          |> Enum.filter(& &1)

        case lista_elem do
          [mensaje | _] -> mensaje
          [] -> nil
        end

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        nil
    end
  end

  def escribir_mensaje(nombre_archivo, %Mensaje{
        id: id,
        tipo_mensaje: tipo_mensaje,
        tipo_receptor: tipo_receptor,
        id_receptor: id_receptor,
        id_emisor: id_emisor,
        contenido: contenido,
        id_equipo: id_equipo,
        fecha: fecha,
        id_proyecto: id_proyecto,
        estado: estado
      }) do
    File.write(
      nombre_archivo,
      "\n#{id},#{Atom.to_string(tipo_mensaje)},#{Atom.to_string(tipo_receptor)},#{id_receptor},#{id_emisor},#{contenido},#{id_equipo},#{fecha},#{id_proyecto},#{estado}",
      [:append, :utf8]
    )
  end

  def borrar_mensaje(nombre_archivo, id_a_borrar) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lineas = String.split(lista, "\n", trim: true)

        [cabecera | datos] = lineas

        nuevos_datos =
          datos
          |> Enum.reject(fn linea ->
            case String.split(linea, ",") do
              [id | _resto] -> id == id_a_borrar
              _ -> false
            end
          end)

        nuevo_contenido = Enum.join([cabecera | nuevos_datos], "\n")

        case File.write(nombre_archivo, nuevo_contenido, [:utf8]) do
          :ok ->
            IO.puts("Mensaje con id #{id_a_borrar} eliminado correctamente.")
            :ok

          {:error, reason} ->
            IO.puts("Error al escribir archivo: #{reason}")
            {:error, reason}
        end

      {:error, reason} ->
        IO.puts("Error al leer archivo: #{reason}")
        {:error, reason}
    end
  end

  def actualizar_mensaje(nombre_archivo, mensaje_nuevo) do
    borrar_mensaje(nombre_archivo, mensaje_nuevo.id)
    escribir_mensaje(nombre_archivo, mensaje_nuevo)
  end

  def filtrar_mensajes_proyecto(nombre_archivo, tipo_buscar, id_proyecto_buscar) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.tipo_mensaje == tipo_buscar and mensaje.id_proyecto == id_proyecto_buscar
    end)
  end

  def filtrar_mensajes_personal(nombre_archivo, id_emisor_buscar, id_receptor_buscar) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.id_emisor == id_emisor_buscar and mensaje.id_receptor == id_receptor_buscar
    end)
  end

  def filtrar_mensajes_personal_pendiente(nombre_archivo, id_emisor_buscar, id_receptor_buscar) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.id_emisor == id_emisor_buscar and mensaje.id_receptor == id_receptor_buscar and
        mensaje.estado == "pendiente"
    end)
  end

  def filtrar_mensajes_equipo(nombre_archivo, id_equipo) do
    IO.inspect(id_equipo)
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.id_equipo == id_equipo
    end)
  end

  def filtrar_mensajes_equipo_pendiente(nombre_archivo, id_equipo) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.id_equipo == id_equipo and
        mensaje.estado == "pendiente"
    end)
  end










  def filtrar_mensajes(nombre_archivo, tipo_buscar, id_receptor_buscar) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.tipo_mensaje == tipo_buscar and mensaje.id_receptor == id_receptor_buscar
    end)
  end

  def filtrar_mensajes(nombre_archivo, tipo_buscar)
      when tipo_buscar in [:avance, :chat, :consulta, :retroalimentacion, :anuncio] do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.tipo_mensaje == tipo_buscar
    end)
  end

  def filtrar_mensajes(nombre_archivo, tipo_receptor)
      when tipo_receptor in [:equipo, :sala, :usuario, :todos] do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje ->
      mensaje.tipo_receptor == tipo_receptor
    end)
  end
end
