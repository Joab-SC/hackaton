defmodule Bd_Participante do

  def leer_participantes(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Rol", "Nombre","Apellido","Cedula","Correo","Telefono","Usuario","Contrasena","id_equipo"] -> nil
          [id,nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
            %Participante{id: id, rol: rol, nombre: nombre, apellido: apellido, cedula: cedula,
            correo: correo, telefono: telefono, usuario: usuario, id_equipo: id_equipo}
          _ -> []
        end
      end)
      |> Enum.filter(fn x -> x  end)

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
          ["id","Rol","Nombre","Apellido","Cedula","Correo","Telefono","Usuario","Contrasena","id_equipo"] -> nil
          [id,nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
          if id == id_participante do
            %Participante{id: id, rol: rol, nombre: nombre, apellido: apellido, cedula: cedula,
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

  def escribir_participante(nombre_archivo, %Participante{id: id, rol: rol, nombre: nombre, apellido: apellido, cedula: cedula,
  correo: correo, telefono: telefono, usuario: usuario, contrasena: contrasena, id_equipo: id_equipo}) do
    File.write(nombre_archivo, "\n#{id},#{rol},#{nombre},#{apellido},#{cedula},#{correo},#{telefono},#{usuario},#{contrasena},#{id_equipo}", [:append, :utf8])
  end


  def borrar_participante(nombre_archivo, id_a_borrar) do
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
            IO.puts("Participante con id #{id_a_borrar} eliminado correctamente.")
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


  def actualizar_participante(nombre_archivo, participante) do
    borrar_participante(nombre_archivo, participante.id)
    escribir_participante(nombre_archivo, participante)
  end
end
