defmodule Bd_equipo do

  def leer_equipos(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Nombre", "Tema"] -> nil
          [id,nombre] ->
            %Equipo{id: id, nombre: nombre, tema: tema}
          _ -> []
        end
      end)
      |> Enum.filter(fn x -> x  end)

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end

  def leer_participantes_equipo(archivo_particiapantes, id_equipo_buscar) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Nombre","Apellido","Cedula","Correo","Telefono","Usuario","Contrasena","id_equipo"] -> nil
          [id,nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
            cond do
              id_equipo == id_equipo_buscar -> %Participante{id: id, nombre: nombre, apellido: apellido, cedula: cedula,
            correo: correo, telefono: telefono, usuario: usuario, id_equipo: id_equipo}
            true -> nil
            end
          _ -> []
        end
      end)
      |> Enum.filter(fn x -> x  end)

      {:error, reason} ->
        IO.puts("AMO A LAURA, MAMASOTA  RICA  #{reason}")
        []
    end
  end

  def leer_equipo(nombre_archivo, id_equipo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem = String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Nombre", "Tema"] -> nil
          [id,nombre] ->
          if id == id_equipo do
           %Equipo{id: id, nombre: nombre, tema: tema}
          else
            nil
          end
          _ -> []
        end
      end)
      |> Enum.filter(& &1)

      case lista_elem do
        [participante | _] -> participante
        [] -> nil
      end

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end

end
