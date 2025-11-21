defmodule Hackaton.Adapter.BaseDatos.BdEquipo do
  @moduledoc """
  Módulo adaptador encargado de manejar la persistencia de los equipos en archivos CSV.

  Este módulo permite:
    - Leer todos los equipos desde un archivo.
    - Buscar un equipo por ID.
    - Buscar un equipo por nombre.
    - Registrar (escribir) un nuevo equipo.
    - Borrar un equipo existente.
    - Actualizar un equipo reemplazando su línea en el archivo.

  Todos los datos se manejan en archivos de texto plano con formato CSV:
    id,nombre,tema
  """

  alias Hackaton.Domain.Equipo

  @doc """
  Lee todos los equipos registrados en un archivo CSV.
  """
  def leer_equipos(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |> Enum.map(fn linea ->
          case String.split(String.replace(linea, "\r", ""), ",") do
            ["id", "Nombre", "Tema"] ->
              nil

            [id, nombre, tema] ->
              %Equipo{id: id, nombre: nombre, tema: tema}

            _ ->
              nil
          end
        end)
        |> Enum.filter(fn x -> x end)

      {:error, reason} ->
        IO.puts("NO SE PUDO REALIZAR POR #{reason}")
        []
    end
  end

  @doc """
  Busca y retorna un equipo por su ID.


  """
  def leer_equipo(nombre_archivo, id_equipo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem =
          String.split(lista, "\n")
          |> Enum.map(fn linea ->
            case String.split(String.replace(linea, "\r", ""), ",") do
              ["id", "Nombre", "Tema"] ->
                nil

              [id, nombre, tema] ->
                if id == id_equipo,
                  do: %Equipo{id: id, nombre: nombre, tema: tema},
                  else: nil

              _ ->
                nil
            end
          end)
          |> Enum.filter(& &1)

        case lista_elem do
          [equipo | _] -> equipo
          [] -> nil
        end

      {:error, reason} ->
        IO.puts("NO SE PUDO REALIZAR POR  #{reason}")
        []
    end
  end

  @doc """
  Busca un equipo por su nombre exacto.

  """
  def leer_equipo_nombre(nombre_archivo, nombre_equipo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem =
          String.split(lista, "\n")
          |> Enum.map(fn linea ->
            case String.split(String.replace(linea, "\r", ""), ",") do
              ["id", "Nombre", "Tema"] ->
                nil

              [id, nombre, tema] ->
                if nombre == nombre_equipo,
                  do: %Equipo{id: id, nombre: nombre, tema: tema},
                  else: nil

              _ ->
                nil
            end
          end)
          |> Enum.filter(& &1)

        case lista_elem do
          [equipo | _] -> equipo
          [] -> nil
        end

      {:error, reason} ->
        IO.puts("NO SE PUDO REALIZAR POR  #{reason}")
        []
    end
  end

  @doc """
  Escribe un nuevo equipo en el archivo CSV.
  """
  def escribir_equipo(nombre_archivo, %Equipo{id: id, nombre: nombre, tema: tema}) do
    File.write(nombre_archivo, "\n#{id},#{nombre},#{tema}", [:append, :utf8])
  end

  @doc """
  Elimina un equipo del archivo, manteniendo la cabecera intacta.


  """
  def borrar_equipo(nombre_archivo, id_a_borrar) do
    case File.read(nombre_archivo) do
      {:ok, contenido} ->
        lineas = String.split(contenido, "\n", trim: true)

        [cabecera | datos] = lineas

        nuevos_datos =
          Enum.reject(datos, fn linea ->
            case String.split(linea, ",") do
              [id | _] -> id == id_a_borrar
              _ -> false
            end
          end)

        nuevo_contenido = Enum.join([cabecera | nuevos_datos], "\n")

        case File.write(nombre_archivo, nuevo_contenido, [:utf8]) do
          :ok ->
            IO.puts("Equipo con id #{id_a_borrar} eliminado correctamente.")
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
  Actualiza los datos de un equipo en el archivo CSV.

  """
  def actualizar_equipo(nombre_archivo, equipo) do
    borrar_equipo(nombre_archivo, equipo.id)
    escribir_equipo(nombre_archivo, equipo)
  end
end
