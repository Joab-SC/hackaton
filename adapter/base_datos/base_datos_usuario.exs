defmodule Bd_Usuario do

  def leer_usuarios(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Rol", "Nombre","Apellido","Cedula","Correo","Telefono","Usuario","Contrasena","id_equipo"] -> nil
          [id,rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
            %Usuario{id: id, rol: rol, nombre: nombre, apellido: apellido, cedula: cedula,
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

  def leer_participantes(nombre_archivo) do
    leer_usuarios(nombre_archivo)
    |> Enum.filter(fn usuario -> usuario.rol == "PARTICIPANTE" end)
  end

  def leer_mentores(nombre_archivo) do
    leer_usuarios(nombre_archivo)
    |> Enum.filter(fn usuario -> usuario.rol == "MENTOR" end)
  end

  def leer_usuario(nombre_archivo, id_participante) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem = String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(linea, ",") do
          ["id","Rol","Nombre","Apellido","Cedula","Correo","Telefono","Usuario","Contrasena","id_equipo"] -> nil
          [id, rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
          if id == id_participante do
            %Usuario{id: id, rol: rol, nombre: nombre, apellido: apellido, cedula: cedula,
            correo: correo, telefono: telefono, usuario: usuario, contrasena: contrasena, id_equipo: id_equipo}
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

  def escribir_usuario(nombre_archivo, %Usuario{id: id, rol: rol, nombre: nombre, apellido: apellido, cedula: cedula,
  correo: correo, telefono: telefono, usuario: usuario, contrasena: contrasena, id_equipo: id_equipo}) do
    File.write(nombre_archivo, "\n#{id},#{rol},#{nombre},#{apellido},#{cedula},#{correo},#{telefono},#{usuario},#{contrasena},#{id_equipo}", [:append, :utf8])
  end


  def borrar_usuario(nombre_archivo, id_a_borrar) do
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
            IO.puts("Usuario con id #{id_a_borrar} eliminado correctamente.")
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


  def actualizar_usuario(nombre_archivo, usuario) do
    borrar_usuario(nombre_archivo, usuario.id)
    escribir_usuario(nombre_archivo, usuario)
  end

  def leer_participantes_equipo(nombre_archivo, id_equipo_buscar) do
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
end
