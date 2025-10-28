defmodule Bd_Mentor do

  def leer_mentores(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Rol","Nombre","Apellido","Cedula","Correo","Telefono","Usuario","Contrasena"] -> nil
          [rol, id,nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
            %Mentor{rol: rol, id: id, nombre: nombre, apellido: apellido, cedula: cedula,
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

  def leer_mentor(nombre_archivo, id_mentor) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem = String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","rol","Nombre","Apellido","Cedula","Correo","Telefono","Usuario","Contrasena"] -> nil
          [rol, id,nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
          if id == id_mentor do
            %Mentor{rol: rol, id: id, nombre: nombre, apellido: apellido, cedula: cedula,
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


  def escribir_mentor(nombre_archivo, %Mentor{id: id, rol: rol, nombre: nombre, apellido: apellido, cedula: cedula,
  correo: correo, telefono: telefono, usuario: usuario, contrasena: contrasena}) do
    File.write(nombre_archivo, "\n#{id},#{rol},#{nombre},#{apellido},#{cedula},#{correo},#{telefono},#{usuario},#{contrasena}", [:append, :utf8])
  end


  def borrar_mentor(nombre_archivo, id_a_borrar) do
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
            IO.puts("Mentor con id #{id_a_borrar} eliminado correctamente.")
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


  def actualizar_mentor(nombre_archivo, mentor) do
    borrar_mentor(nombre_archivo, mentor.id)
    escribir_mentor(nombre_archivo, mentor)
  end
end
