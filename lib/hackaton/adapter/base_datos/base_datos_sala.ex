defmodule Hackaton.Adapter.BaseDatos.BdSala do
  alias Hackaton.Domain.Sala

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
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end

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
        IO.puts("AMO A JOAB, PAPASOTE  RICO  #{reason}")
        []
    end
  end

  def escribir_sala(nombre_archivo, %Sala{id: id, tema: tema, descripcion: descripcion}) do
    File.write(nombre_archivo, "\n#{id},#{tema},#{descripcion}", [:append, :utf8])
  end
end
