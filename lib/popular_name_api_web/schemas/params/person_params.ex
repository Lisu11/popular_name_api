defmodule PopularNameApiWeb.Schemas.PersonParams do
  alias OpenApiSpex.Schema
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "PersonParams",
    description: "Query params for a person",
    type: :object,
    properties: %{
      first_name: %Schema{type: :string, description: "Persons first name"},
      last_name: %Schema{type: :string, description: "Persons last name"},
      birth_date: %Schema{type: :string, description: "Persons birth date", format: :date},
      sex: %Schema{
        type: :string,
        description: "Persons gender. One of 'male', 'female'",
        pattern: ~r/(male)|(female)/
      }
    },
    required: [:first_name, :last_name, :birth_date, :sex]
  })
end
