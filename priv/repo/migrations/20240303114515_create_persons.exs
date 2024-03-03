defmodule PopularNameApi.Repo.Migrations.CreatePersons do
  use Ecto.Migration

  def change do
    create table(:persons) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :sex, :string, null: false
      add :birth_date, :date, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:persons, [:last_name, :first_name, :sex, :birth_date])
  end
end
