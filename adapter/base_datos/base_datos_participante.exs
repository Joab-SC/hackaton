defmodule Bd_Participante do

  def leer_participantes(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Nombre","Apellido","Cedula","Correo","Telefono","Usuario","Contrasena","id_equipo"] -> nil
          [id,nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
            %Participante{id: id, nombre: nombre, apellido: apellido, cedula: cedula,
            correo: correo, telefono: telefono, usuario: usuario, id_equipo: id_equipo}
          _ -> []
        end
      end)
      |> Enum.map(fn x -> x  end)

      {:error, reason} ->
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end

  def leer_participante(nombre_archivo, id_participante) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem = String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Nombre","Apellido","Cedula","Correo","Telefono","Usuario","Contrasena","id_equipo"] -> nil
          [id,nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
          if id == id_participante do
            %Participante{id: id, nombre: nombre, apellido: apellido, cedula: cedula,
            correo: correo, telefono: telefono, usuario: usuario, id_equipo: id_equipo}
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
