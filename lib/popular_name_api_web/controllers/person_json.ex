defmodule PopularNameApiWeb.PersonJSON do
  alias PopularNameApi.Citizens.Person

  @doc """
  Renders a list of persons.
  """
  def index(%{persons: persons}) do
    %{data: for(person <- persons, do: data(person))}
  end

  @doc """
  Renders a single person.
  """
  def show(%{person: person}) do
    %{data: data(person)}
  end

  defp data(%Person{} = person) do
    %{
      id: person.id,
      first_name: person.first_name,
      last_name: person.last_name,
      sex: person.sex,
      birth_date: person.birth_date
    }
  end
end
