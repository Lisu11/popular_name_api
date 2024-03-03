defmodule PopularNameApi.Citizens.PersonQueries do
  @moduledoc false

  import Ecto.Query

  # def maybe_filter_by_first_name(query, %{"first_name" => name}) do
  #   name_pattern = "%#{name}%"

  #   query
  #   |> where([p], ilike(p.first_name, ^name_pattern))
  # end
  def maybe_filter_by_first_name(query, %{"first_name" => name}) do
    query
    |> where([p], p.first_name == ^name)
  end

  def maybe_filter_by_first_name(query, _),
    do: query

  # def maybe_filter_by_last_name(query, %{"last_name" => name}) do
  #   name_pattern = "%#{name}%"

  #   query
  #   |> where([p], ilike(p.last_name, ^name_pattern))
  # end
  def maybe_filter_by_last_name(query, %{"last_name" => name}) do
    query
    |> where([p], p.last_name == ^name)
  end

  def maybe_filter_by_last_name(query, _),
    do: query

  def maybe_filter_by_sex(query, %{"sex" => sex}) when sex in ["male", "female"] do
    query
    |> where([p], p.sex == ^sex)
  end

  def maybe_filter_by_sex(query, _),
    do: query

  def maybe_filter_by_birth_from(query, %{"birth_date_from" => date}) do
    query
    |> where([p], p.birth_date >= ^date)
  end

  def maybe_filter_by_birth_from(query, _),
    do: query

  def maybe_filter_by_birth_to(query, %{"birth_date_to" => date}) do
    query
    |> where([p], p.birth_date <= ^date)
  end

  def maybe_filter_by_birth_to(query, _),
    do: query

  def maybe_sort_by(query, [{field_atom, :asc} | rest]) do
    query
    |> order_by([p], asc: field(p, ^field_atom))
    |> maybe_sort_by(rest)
  end

  def maybe_sort_by(query, [{field_atom, :desc} | rest]) do
    query
    |> order_by([p], desc: field(p, ^field_atom))
    |> maybe_sort_by(rest)
  end

  def maybe_sort_by(query, []),
    do: query
end
