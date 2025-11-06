defmodule Hackaton.Adapter.BaseDatos.BdMensaje do
  def leer_mensajes(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Tipo_mensaje","Tipo_receptor","id_receptor","Contenido","id_equipo","Timestamp","id_proyecto"] -> nil
          [id,tipo_mensaje,tipo_receptor,id_receptor,contenido,id_equipo,timestamp,id_proyecto] ->
            %Mensaje{id: id, tipo_mensaje: String.to_atom(tipo_mensaje), tipo_receptor: String.to_atom(tipo_receptor), id_receptor: id_receptor, contenido: contenido, id_equipo: id_equipo timestamp: timestamp, id_proyecto: id_proyecto}
          _ -> []
        end
      end)
      |> Enum.filter(fn x -> x  end)

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end

  def leer_mensaje(nombre_archivo, id_mensaje) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem = String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Tipo_mensaje","Tipo_receptor","id_receptor","Contenido","id_equipo","Timestamp","id_proyecto"] -> nil
          [id,tipo_mensaje,tipo_receptor,id_receptor,contenido,id_equipo,timestamp,id_proyecto] ->
          if id == id_mensaje do
           %Mensaje{id: id, tipo_mensaje: String.to_atom(tipo_mensaje), tipo_receptor: String.to_atom(tipo_receptor), id_receptor: id_receptor, contenido: contenido, id_equipo: id_equipo timestamp: timestamp, id_proyecto: id_proyecto}
          else
            nil
          end
          _ -> []
        end
      end)
      |> Enum.filter(& &1)

      case lista_elem do
        [mensaje| _] -> mensaje
        [] -> nil
      end

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end


   def escribir_mensaje(nombre_archivo, %Mensaje{id: id, tipo_mensaje: tipo_mensaje, tipo_receptor: tipo_receptor, id_receptor: id_receptor, contenido: contenido, timestamp: timestamp, id_proyecto: id_proyecto}) do
    File.write(nombre_archivo, "\n#{id},#{Atom.to_string(tipo_mensaje)},#{Atom.to_string(tipo_receptor)},#{id_receptor},#{contenido},#{timestamp},#{id_proyecto}", [:append, :utf8])
  end

  def filtrar_mensajes_proyecto(nombre_archivo, tipo_buscar, id_proyecto_buscar) do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje -> mensaje.tipo_mensaje == tipo_buscar and mensaje.id_proyecto == id_proyecto_buscar end)
  end


  def filtrar_mensajes(nombre_archivo, tipo_buscar, id_receptor_buscar) do
      Enum.filter(leer_mensajes(nombre_archivo), fn mensaje -> mensaje.tipo_mensaje == tipo_buscar and mensaje.id_receptor == id_receptor_buscar end)
  end

  def filtrar_mensajes(nombre_archivo, tipo_buscar) when tipo_buscar in [:avance, :chat, :consulta, :retroalimentacion, :anuncio] do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje -> mensaje.tipo_mensaje == tipo_buscar end)
  end

  def filtrar_mensajes(nombre_archivo, tipo_receptor) when tipo_receptor in [:equipo, :sala, :usuario, :todos] do
    Enum.filter(leer_mensajes(nombre_archivo), fn mensaje -> mensaje.tipo_receptor== tipo_receptor end)
  end

end
