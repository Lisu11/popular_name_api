defmodule PopularNameApi.Citizens.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "persons" do
    field :first_name, :string
    field :last_name, :string
    field :sex, Ecto.Enum,
      values: [
        :male,
        :female
      ]
    field :birth_date, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:first_name, :last_name, :sex, :birth_date])
    |> validate_required([:first_name, :last_name, :sex, :birth_date])
    |> validate_inclusion(:sex, [:male, :female, "male", "female"])
    |> validate_birth_date()

  end

  defp validate_birth_date(changeset) do
    changeset
    |> validate_change(:birth_date, fn
      :birth_date, %Date{} = date ->
        case {Date.compare(date, ~D[1969-12-31]), Date.compare(date, ~D[2024-01-01])} do
          {:gt, :lt} -> []
          _ -> [birth_date: "Birth date must be between 1970-01-01 and 2023-12-31"]
        end
      :birth_date, _ -> [birth_date: "Birth date must be %Date{} struct"]
    end)
  end
end