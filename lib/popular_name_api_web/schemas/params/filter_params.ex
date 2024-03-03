defmodule PopularNameApiWeb.Schemas.FilterParams do
  alias OpenApiSpex.Schema
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "FilterParams",
    description: "Query params for filtering a person",
    type: :object,
    properties: %{
      first_name: %Schema{type: :string, description: "Persons first name"},
      last_name: %Schema{type: :string, description: "Persons last name"},
      birth_date_from: %Schema{
        type: :string,
        description: "Persons birth date lower bound",
        format: :date
      },
      birth_date_to: %Schema{
        type: :string,
        description: "Persons birth date upper bound",
        format: :date
      },
      sex: %Schema{
        type: :string,
        description: "Persons gender. One of 'male', 'female'",
        pattern: ~r/(male)|(female)/
      }
    }
  })
end
