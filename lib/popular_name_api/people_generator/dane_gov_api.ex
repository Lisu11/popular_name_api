defmodule PopularNameApi.PeopleGenerator.DaneGovApi do
  @female_surname_data_id "54110"
  @female_lastname_data_id "54098"
  @male_surname_data_id "54109"
  @male_lastname_data_id "54097"
  @dane_gov_address "https://api.dane.gov.pl/1.4/resources/"

  def male_surnames_path(amount) do
    generate_path(@male_surname_data_id, amount)
  end

  def female_surnames_path(amount) do
    generate_path(@female_surname_data_id, amount)
  end

  def male_lastnames_path(amount) do
    generate_path(@male_lastname_data_id, amount)
  end

  def female_lastnames_path(amount) do
    generate_path(@female_lastname_data_id, amount)
  end

  defp generate_path(dataset, amount) do
    @dane_gov_address
    |> Path.join(dataset)
    |> Path.join("data?per_page=#{amount}")
  end
end
