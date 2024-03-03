defmodule PopularNameApiWeb.Schemas.Person do
  alias OpenApiSpex.Schema

  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "Person",
    description: "Randomly generated person",
    type: :object,
    properties: %{
      id: %Schema{type: :integer, description: "Person ID"},
      first_name: %Schema{type: :string, description: "Persons first name"},
      last_name: %Schema{type: :string, description: "Persons last name"},
      birth_date: %Schema{type: :string, description: "Persons birth date", format: :date},
      sex: %Schema{
        type: :string,
        description: "Persons gender. One of 'male', 'female'",
        pattern: ~r/(male)|(female)/
      },
      updated_at: %Schema{type: :string, description: "Update timestamp"},
      inserted_at: %Schema{type: :string, description: "Creation timestamp"}
    },
    required: [:id, :first_name, :last_name, :birth_date, :sex, :updated_at, :inserted_at],
    example: %{
      "id" => 666,
      "first_name" => "Thomas",
      "last_name" => "Anderson",
      "birth_date" => "1970-01-01",
      "sex" => "male",
      "inserted_at" => "2017-09-12T12:34:55Z",
      "updated_at" => "2017-09-13T10:11:12Z"
    }
  })
end
