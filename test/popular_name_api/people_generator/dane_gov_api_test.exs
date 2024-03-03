defmodule PopularNameApi.PeopleGenerator.DaneGovApiTest do
  use PopularNameApi.DataCase

  alias PopularNameApi.PeopleGenerator.DaneGovApi

  describe "male_surnames_path/1" do
    test "returns proper url" do
      random_amount = :rand.uniform(2000)
      url = DaneGovApi.male_surnames_path(random_amount)

      assert url == "https://api.dane.gov.pl/1.4/resources/54109/data?per_page=#{random_amount}"
    end
  end

  describe "male_lastnames_path/1" do
    test "returns proper url" do
      random_amount = :rand.uniform(2000)
      url = DaneGovApi.male_lastnames_path(random_amount)

      assert url == "https://api.dane.gov.pl/1.4/resources/54097/data?per_page=#{random_amount}"
    end
  end

  describe "female_surnames_path/1" do
    test "returns proper url" do
      random_amount = :rand.uniform(2000)
      url = DaneGovApi.female_surnames_path(random_amount)

      assert url == "https://api.dane.gov.pl/1.4/resources/54110/data?per_page=#{random_amount}"
    end
  end

  describe "female_lastnames_path/1" do
    test "returns proper url" do
      random_amount = :rand.uniform(2000)
      url = DaneGovApi.female_lastnames_path(random_amount)

      assert url == "https://api.dane.gov.pl/1.4/resources/54098/data?per_page=#{random_amount}"
    end
  end
end
