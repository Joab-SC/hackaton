defmodule Hackaton.Adapter.BaseDatos.BdProyecto do
  @moduledoc """
  Módulo encargado de manejar la persistencia de proyectos en archivos.
  Proporciona funciones para leer, buscar, escribir, actualizar y borrar
  proyectos almacenados en un archivo CSV simple.
  """

  alias Hackaton.Domain.Proyecto

  @doc """
  Lee todos los proyectos almacenados en `nombre_archivo`.

  - Ignora la cabecera del archivo.
  - Convierte cada línea en un struct `Proyecto`.
  - Filtra líneas nulas o mal formateadas.
  """
  def leer_proyectos(nombre_archivo) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        String.split(lista, "\n")
        |> Enum.map(fn linea ->
          case String.split(String.replace(linea, "\r", ""), ",") do
            ["id", "Nombre", "Descripción", "Categoria", "Estado", "id_equipo", "Fecha_creacion"] ->
              nil

            [id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion] ->
              %Proyecto{
                id: id,
                nombre: nombre,
                descripcion: descripcion,
                categoria: categoria,
                estado: estado,
                id_equipo: id_equipo,
                fecha_creacion: fecha_creacion
              }

            _ ->
              nil
          end
        end)
        |> Enum.filter(fn x -> x end)

      {:error, reason} ->
        IO.puts("NO SE PUDO REALIZAR POR  #{reason}")
        nil
    end
  end

  @doc """
  Busca un proyecto por su `id_proyecto`.

  - Lee todas las líneas del archivo.
  - Mapea cada una en un struct Proyecto si coincide el id.
  - Filtra valores nulos.
  - Retorna el primer proyecto encontrado o `nil`.

  """
  def leer_proyecto(nombre_archivo, id_proyecto) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem =
          String.split(lista, "\n")
          |> Enum.map(fn linea ->
            case String.split(String.replace(linea, "\r", ""), ",") do
              [
                "id",
                "Nombre",
                "Descripción",
                "Categoria",
                "Estado",
                "id_equipo",
                "Fecha_creacion"
              ] ->
                nil

              [id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion] ->
                if id == id_proyecto do
                  %Proyecto{
                    id: id,
                    nombre: nombre,
                    descripcion: descripcion,
                    categoria: categoria,
                    estado: estado,
                    id_equipo: id_equipo,
                    fecha_creacion: fecha_creacion
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
          [proyecto | _] -> proyecto
          [] -> nil
        end

      {:error, reason} ->
        IO.puts("NO SE PUDO REALIZAR POR  #{reason}")
        []
    end
  end

  @doc """
  Busca un proyecto por su nombre (`nombre_`).

  - Compara el campo `nombre` de cada línea.
  - Convierte en struct Proyecto solo si coincide.
  - Filtra nulos y devuelve el primer resultado.

  """
  def leer_proyecto_nombre(nombre_archivo, nombre_) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem =
          String.split(lista, "\n")
          |> Enum.map(fn linea ->
            case String.split(String.replace(linea, "\r", ""), ",") do
              [
                "id",
                "Nombre",
                "Descripción",
                "Categoria",
                "Estado",
                "id_equipo",
                "Fecha_creacion"
              ] ->
                nil

              [id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion] ->
                if nombre_ == nombre do
                  %Proyecto{
                    id: id,
                    nombre: nombre,
                    descripcion: descripcion,
                    categoria: categoria,
                    estado: estado,
                    id_equipo: id_equipo,
                    fecha_creacion: fecha_creacion
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
          [proyecto | _] -> proyecto
          [] -> nil
        end

      {:error, reason} ->
        IO.puts("NO SE PUDO REALIZAR POR  #{reason}")
        []
    end
  end

  @doc """
  Busca un proyecto por su `id_equipo_`.

  - Compara el campo `id_equipo` de cada línea.
  - Devuelve el primer proyecto cuyo id_equipo coincida.

  """
  def leer_proyecto_id_equipo(nombre_archivo, id_equipo_) do
    case File.read(nombre_archivo) do
      {:ok, lista} ->
        lista_elem =
          String.split(lista, "\n")
          |> Enum.map(fn linea ->
            case String.split(linea, ",") do
              [
                "id",
                "Nombre",
                "Descripción",
                "Categoria",
                "Estado",
                "id_equipo",
                "Fecha_creacion"
              ] ->
                nil

              [id, nombre, descripcion, categoria, estado, id_equipo, fecha_creacion] ->
                if id_equipo == id_equipo_ do
                  %Proyecto{
                    id: id,
                    nombre: nombre,
                    descripcion: descripcion,
                    categoria: categoria,
                    estado: estado,
                    id_equipo: id_equipo,
                    fecha_creacion: fecha_creacion
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
          [proyecto | _] -> proyecto
          [] -> nil
        end

      {:error, reason} ->
        IO.puts("NO SE PUDO REALIZAR POR #{reason}")
        []
    end
  end

  @doc """
  Borra un proyecto del archivo basado en su ID (`id_a_borrar`).

  - Lee todas las líneas.
  - Separa la cabecera del resto.
  - Filtra las líneas cuyo ID no coincida.
  - Sobrescribe el archivo con el contenido actualizado.

  """
  def borrar_proyecto(nombre_archivo, id_a_borrar) do
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
            IO.puts("Proyecto con id #{id_a_borrar} eliminado correctamente.")
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
    Agrega un proyecto al final del archivo.

    Escribe una nueva línea en formato CSV:


    Utiliza el modo `:append` para no sobrescribir.
  """
  def escribir_proyecto(nombre_archivo, %Proyecto{
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        categoria: categoria,
        estado: estado,
        id_equipo: id_equipo,
        fecha_creacion: fecha_creacion
      }) do
    File.write(
      nombre_archivo,
      "\n#{id},#{nombre},#{descripcion},#{categoria},#{estado},#{id_equipo},#{fecha_creacion}",
      [:append, :utf8]
    )
  end

  @doc """
  Actualiza un proyecto existente:

  1. Lo borra por ID.
  2. Escribe su nueva versión al final.

  """
  def actualizar_proyecto(nombre_archivo, proyecto) do
    borrar_proyecto(nombre_archivo, proyecto.id)
    escribir_proyecto(nombre_archivo, proyecto)
  end
end
