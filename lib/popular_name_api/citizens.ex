defmodule PopularNameApi.Citizens do
  @moduledoc """
  The Citizens context.
  """

  import Ecto.Query, warn: false
  alias PopularNameApi.Repo

  alias PopularNameApi.Citizens.PersonQueries
  alias PopularNameApi.Citizens.Person

  @doc """
  Returns the list of persons.

  ## Examples

      iex> list_persons()
      [%Person{}, ...]

  """
  def list_persons do
    Repo.all(Person)
  end

  @doc """
  Returns the list of persons filtered by some params.

  ## Examples

      iex> list_filtered_persons([], [])
      [%Person{}, ...]

  """
  def list_filtered_persons(filters, sorters) do
    Person
    |> PersonQueries.maybe_filter_by_first_name(filters)
    |> PersonQueries.maybe_filter_by_last_name(filters)
    |> PersonQueries.maybe_filter_by_sex(filters)
    |> PersonQueries.maybe_filter_by_birth_from(filters)
    |> PersonQueries.maybe_filter_by_birth_to(filters)
    |> PersonQueries.maybe_sort_by(sorters)
    |> Repo.all()
  end

  @doc """
  Gets a single person.

  ## Examples

      iex> get_person!(123)
      %Person{}

      iex> get_person!(456)
      nil

  """
  def get_person(id), do: Repo.get(Person, id)

  @doc """
  Creates a person.

  ## Examples

      iex> create_person(%{field: value})
      {:ok, %Person{}}

      iex> create_person(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_person(attrs \\ %{}) do
    %Person{}
    |> Person.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a person.

  ## Examples

      iex> update_person(person, %{field: new_value})
      {:ok, %Person{}}

      iex> update_person(person, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_person(%Person{} = person, attrs) do
    person
    |> Person.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a person.

  ## Examples

      iex> delete_person(person)
      {:ok, %Person{}}

      iex> delete_person(person)
      {:error, %Ecto.Changeset{}}

  """
  def delete_person(%Person{} = person) do
    Repo.delete(person)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person changes.

  ## Examples

      iex> change_person(person)
      %Ecto.Changeset{data: %Person{}}

  """
  def change_person(%Person{} = person, attrs \\ %{}) do
    Person.changeset(person, attrs)
  end

  @doc """
  Returns an `{amount, nil}` for tracking amount of inserted people.

  ## Examples

      iex> insert_multiple_people([])
      {0, nil}

  """
  def insert_multiple_people(attrs_list) do
    Repo.insert_all(
      Person,
      attrs_list,
      on_conflict: :nothing,
      conflict_target: [:last_name, :first_name, :birth_date]
    )
  end
end
