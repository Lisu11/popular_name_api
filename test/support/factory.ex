defmodule PopularNameApi.Factory do
  use ExMachina.Ecto, repo: PopularNameApi.Repo

  def person_factory do
    %PopularNameApi.Citizens.Person{
      first_name: "Jane",
      last_name: "Smith",
      sex: :female,
      birth_date: sequence(:birth_date, & Date.new!(1970, 1, 1) |> Date.add(&1))
    }
  end
end
