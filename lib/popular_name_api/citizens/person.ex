defmodule PopularNameApi.Citizens.Person do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

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
    |> validate_format(:first_name, ~r/[a-z]+/i)
    |> validate_format(:last_name, ~r/[a-z]+[ a-z]*/i)
    |> validate_inclusion(:sex, [:male, :female, "male", "female"])
    |> validate_birth_date()
  end

  def changeset_without_required(attrs) do
    %Person{}
    |> cast(attrs, [:first_name, :last_name, :sex, :birth_date])
    |> validate_format(:first_name, ~r/[a-z]+/i)
    |> validate_format(:last_name, ~r/[a-z]+[ a-z]*/i)
    |> validate_inclusion(:sex, [:male, :female, "male", "female"])
    |> validate_birth_date()
  end

  defp validate_birth_date(changeset) do
    changeset
    |> validate_change(:birth_date, fn
      :birth_date, %Date{} = date ->
        check_if_date_between(date)

      :birth_date, date when is_binary(date) ->
        case Date.from_iso8601(date) do
          {:ok, date} ->
            check_if_date_between(date)

          _ ->
            [birth_date: "Birth date must be %Date{} struct or binary in iso8601 format"]
        end

      :birth_date, _date ->
        [birth_date: "Birth date must be %Date{} struct or binary in iso8601 format"]
    end)
  end

  defp check_if_date_between(%Date{} = date) do
    case {Date.compare(date, ~D[1969-12-31]), Date.compare(date, ~D[2024-01-01])} do
      {:gt, :lt} -> []
      _ -> [birth_date: "Birth date must be between 1970-01-01 and 2023-12-31"]
    end
  end
end
