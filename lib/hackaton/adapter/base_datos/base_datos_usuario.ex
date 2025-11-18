defmodule Hackaton.Adapter.BaseDatos.BdUsuario do
  @moduledoc """
  Módulo encargado de la gestión y persistencia de usuarios dentro del sistema.
  Opera sobre archivos CSV simples para almacenar y recuperar la información
  de los usuarios.

  Permite:
    - Leer todos los usuarios.
    - Filtrar participantes o mentores.
    - Buscar usuarios por ID o por nombre de usuario.
    - Escribir nuevos usuarios al archivo.
    - Borrar y actualizar usuarios.
    - Obtener participantes pertenecientes a un equipo.
  """

  alias Hackaton.Domain.Usuario

  @doc """
  Lee todos los usuarios desde el archivo `nombre_archivo`.

  - Divide el contenido en líneas.
  - Ignora la cabecera del archivo CSV.
  - Convierte cada línea en un struct `%Usuario{}`.
  - Filtra valores `nil`.

  """
  def leer_usuarios(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |> Enum.map(fn linea ->
          case String.split(String.replace(linea, "\r", ""), ",") do
            [
              "id",
              "Rol",
              "Nombre",
              "Apellido",
              "Cedula",
              "Correo",
              "Telefono",
              "Usuario",
              "Contrasena",
              "id_equipo"
            ] ->
              nil

            [id, rol, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
              %Usuario{
                id: id,
                rol: rol,
                nombre: nombre,
                apellido: apellido,
                cedula: cedula,
                correo: correo,
                telefono: telefono,
                usuario: usuario,
                contrasena: contrasena,
                id_equipo: id_equipo
              }

            _ ->
              nil
          end
        end)
        |> Enum.filter(fn x -> x end)

      {:error, reason} ->
        IO.puts("No se pudo realizar por  #{reason}")
        []
    end
  end

  @doc """
  Retorna únicamente los usuarios cuyo rol sea `"PARTICIPANTE"`.

  """
  def leer_participantes(nombre_archivo) do
    leer_usuarios(nombre_archivo)
    |> Enum.filter(fn usuario -> usuario.rol == "PARTICIPANTE" end)
  end

  @doc """
  Retorna únicamente los usuarios cuyo rol sea `"MENTOR"`.


  """
  def leer_mentores(nombre_archivo) do
    leer_usuarios(nombre_archivo)
    |> Enum.filter(fn usuario -> usuario.rol == "MENTOR" end)
  end

  @doc """
  Busca un usuario por su ID (`id_participante`).

  - Lee el archivo línea por línea.
  - Convierte una línea a `%Usuario{}` solo si el ID coincide.
  - Filtra valores nulos.
  - Retorna el primer usuario encontrado.
  """
  def leer_usuario(nombre_archivo, id_participante) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem =
          String.split(lista, "\n")
          |> Enum.map(fn linea ->
            case String.split(String.replace(linea, "\r", ""), ",") do
              [
                "id",
                "Rol",
                "Nombre",
                "Apellido",
                "Cedula",
                "Correo",
                "Telefono",
                "Usuario",
                "Contrasena",
                "id_equipo"
              ] ->
                nil

              [
                id,
                rol,
                nombre,
                apellido,
                cedula,
                correo,
                telefono,
                usuario,
                contrasena,
                id_equipo
              ] ->
                if id == id_participante do
                  %Usuario{
                    id: id,
                    rol: rol,
                    nombre: nombre,
                    apellido: apellido,
                    cedula: cedula,
                    correo: correo,
                    telefono: telefono,
                    usuario: usuario,
                    contrasena: contrasena,
                    id_equipo: id_equipo
                  }
                else
                  nil
                end

              _ ->
                []
            end
          end)
          |> Enum.filter(& &1)

        case lista_elem do
          [participante | _] -> participante
          [] -> nil
        end

      {:error, reason} ->
        IO.puts("No se pudo realizar por #{reason}")
        []
    end
  end

  @doc """
  Busca un usuario por su nombre de usuario (`Usuario` en el CSV).

  - Compara el campo `usuario`.
  - Retorna el primero que coincida.

  """
  def leer_usuario_user(nombre_archivo, user) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem =
          String.split(lista, "\n")
          |> Enum.map(fn linea ->
            case String.split(String.replace(linea, "\r", ""), ",") do
              [
                "id",
                "Rol",
                "Nombre",
                "Apellido",
                "Cedula",
                "Correo",
                "Telefono",
                "Usuario",
                "Contrasena",
                "id_equipo"
              ] ->
                nil

              [
                id,
                rol,
                nombre,
                apellido,
                cedula,
                correo,
                telefono,
                usuario,
                contrasena,
                id_equipo
              ] ->
                if usuario == user do
                  %Usuario{
                    id: id,
                    rol: rol,
                    nombre: nombre,
                    apellido: apellido,
                    cedula: cedula,
                    correo: correo,
                    telefono: telefono,
                    usuario: usuario,
                    contrasena: contrasena,
                    id_equipo: id_equipo
                  }
                else
                  nil
                end

              _ ->
                []
            end
          end)
          |> Enum.filter(& &1)

        case lista_elem do
          [participante | _] -> participante
          [] -> nil
        end

      {:error, reason} ->
        IO.puts("No se pudo realizar por  #{reason}")
        []
    end
  end

  @doc """
    Agrega un nuevo usuario al final del archivo.

    Escribe una línea en formato CSV:

    id,rol,nombre,apellido,cedula,correo,telefono,usuario,contrasena,id_equipo

  """
  def escribir_usuario(nombre_archivo, %Usuario{
        id: id,
        rol: rol,
        nombre: nombre,
        apellido: apellido,
        cedula: cedula,
        correo: correo,
        telefono: telefono,
        usuario: usuario,
        contrasena: contrasena,
        id_equipo: id_equipo
      }) do
    File.write(
      nombre_archivo,
      "\n#{id},#{rol},#{nombre},#{apellido},#{cedula},#{correo},#{telefono},#{usuario},#{contrasena},#{id_equipo}",
      [:append, :utf8]
    )
  end

  @doc """
  Borra un usuario del archivo según su ID (`id_a_borrar`).

  Procedimiento:
    - Separa cabecera y datos.
    - Filtra el usuario cuyo ID coincida.
    - Escribe nuevamente el contenido sin ese usuario.

  """
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

  @doc """
  Actualiza un usuario ya existente:

  1. Elimina el usuario anterior mediante `borrar_usuario/2`.
  2. Lo vuelve a escribir con los nuevos datos vía `escribir_usuario/2`.

  """
  def actualizar_usuario(nombre_archivo, usuario) do
    borrar_usuario(nombre_archivo, usuario.id)
    escribir_usuario(nombre_archivo, usuario)
  end

  @doc """
  Retorna todos los usuarios que pertenezcan a un equipo específico (`id_equipo_buscar`).

  - Compara el campo `id_equipo`.
  - Solo retorna usuarios cuyo id_equipo coincida.

  """
  def leer_participantes_equipo(nombre_archivo, id_equipo_buscar) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |> Enum.map(fn linea ->
          case String.split(String.replace(linea, "\r", ""), ",") do
            [
              "id",
              "Nombre",
              "Apellido",
              "Cedula",
              "Correo",
              "Telefono",
              "Usuario",
              "Contrasena",
              "id_equipo"
            ] ->
              nil

            [id, nombre, apellido, cedula, correo, telefono, usuario, contrasena, id_equipo] ->
              cond do
                id_equipo == id_equipo_buscar ->
                  %Usuario{
                    id: id,
                    nombre: nombre,
                    apellido: apellido,
                    cedula: cedula,
                    correo: correo,
                    telefono: telefono,
                    usuario: usuario,
                    contrasena: contrasena,
                    id_equipo: id_equipo
                  }

                true ->
                  nil
              end

            _ ->
              nil
          end
        end)
        |> Enum.filter(fn x -> x end)

      {:error, reason} ->
        IO.puts("No se pudo realizar por #{reason}")
        []
    end
  end
end
