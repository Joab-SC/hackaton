defmodule Hackaton.Adapter.BaseDatos.BdSala do
  @moduledoc """
  Módulo encargado de la lectura, consulta y escritura de salas (temáticas)
  desde un archivo plano con formato CSV simple.

  Permite:
    - Leer todas las salas.
    - Buscar una sala por ID.
    - Buscar una sala por su tema.
    - Registrar nuevas salas.
  """

  alias Hackaton.Domain.Sala

  @doc """
  Lee todas las salas desde el archivo `nombre_archivo`.

  - Separa las líneas por salto de línea.
  - Omite la cabecera `"id,tema,descripcion"`.
  - Convierte cada línea válida en un struct `%Sala{}`.
  - Filtra valores `nil`.

  """
  def leer_salas(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |> Enum.map(fn linea ->
          case String.split(String.replace(linea, "\r", ""), ",") do
            ["id", "tema", "descripcion"] ->
              nil

            [id, tema, descripcion] ->
              %Sala{id: id, tema: tema, descripcion: descripcion}

            _ ->
              nil
          end
        end)
        |> Enum.filter(fn x -> x end)

      {:error, reason} ->
        IO.puts("No se pudo leer por  #{reason}")
        nil
    end
  end

  @doc """
  Busca una sala específica por su ID (`id_sala`).

  - Lee el archivo completo.
  - Convierte cada línea en un struct Sala solo si el ID coincide.
  - Filtra valores nulos.
  - Retorna la primera coincidencia o `nil`.

  """
  def leer_sala(nombre_archivo, id_sala) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem = String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(String.replace(linea, "\r", ""), ",") do
          ["id", "tema", "descripcion"]-> nil
          [id, tema, descripcion] ->
          if id == id_sala do
            %Sala{id: id, tema: tema, descripcion: descripcion}
          else
            nil
          end
          _ -> nil
        end
      end)
      |> Enum.filter(& &1)

      case lista_elem do
        [sala | _] -> sala
        [] -> nil
      end

      {:error, reason} ->
        IO.puts("No se pudo leer por   #{reason}")
        []
    end
  end

  @doc """
  Busca una sala por su tema (`tema_buscar`).

  - Compara el campo `tema` de cada registro.
  - Convierte en `%Sala{}` solo si coincide.
  - Retorna la primera coincidencia.
  """
  def leer_sala_tema(nombre_archivo, tema_buscar) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem = String.split(lista, "\n")
        |>Enum.map(fn linea ->
        case String.split(String.replace(linea, "\r", ""), ",") do
          ["id", "tema", "descripcion"]-> nil
          [id, tema, descripcion] ->
          if tema == tema_buscar do
            %Sala{id: id, tema: tema, descripcion: descripcion}
          else
            nil
          end
          _ -> nil
        end
      end)
      |> Enum.filter(& &1)

      case lista_elem do
        [sala | _] -> sala
        [] -> nil
      end

      {:error, reason} ->
        IO.puts("No se pudo leer por   #{reason}")
        []
    end
  end

  @doc """
  Escribe una nueva sala al final del archivo `nombre_archivo`.

  - Agrega una línea en formato CSV:
    `id,tema,descripcion`
  - No modifica información previa.

  """
  def escribir_sala(nombre_archivo, %Sala{id: id, tema: tema, descripcion: descripcion}) do
    File.write(nombre_archivo, "\n#{id},#{tema},#{descripcion}", [:append, :utf8])
  end
end
