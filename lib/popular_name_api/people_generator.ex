defmodule PopularNameApi.PeopleGenerator do
  @moduledoc false

  alias PopularNameApi.PeopleGenerator.DaneGovApi
  alias PopularNameApi.Citizens
  require Logger

  @default_amount 100
  @default_generate_from_amount 100
  @last_possible_birth 1_704_067_199

  def async_generation(amount \\ @default_amount) do
    # Task.start(fn -> generate_people(amount) end)

    Task.Supervisor.start_child(
      PopularNameApi.TaskSupervisor,
      fn ->
        generate_people(amount)
      end,
      restart: :transient
    )
  end

  def generate_people(amount \\ @default_amount) do
    task_first_male_names = Task.async(fn -> fetch_most_common_male_first_names() end)
    task_last_male_names = Task.async(fn -> fetch_most_common_male_last_names() end)
    task_first_female_names = Task.async(fn -> fetch_most_common_female_first_names() end)
    task_last_female_names = Task.async(fn -> fetch_most_common_female_last_names() end)
    births = Enum.map(1..amount, fn _ -> generate_random_birth_date() end)

    [male_fns, male_lns, female_fns, female_lns] =
      Task.await_many([
        task_first_male_names,
        task_last_male_names,
        task_first_female_names,
        task_last_female_names
      ])

    ensure_valid_amount_is_inserted(
      &generate_random_people(male_fns, male_lns, female_fns, female_lns, births, &1),
      amount
    )
  end

  defp ensure_valid_amount_is_inserted(generator, amount) do
    generator.(amount)
    |> Citizens.insert_multiple_people()
    |> case do
      {inserted, _} when inserted == amount ->
        :ok

      {inserted, _} ->
        Logger.debug(
          "Some conflicts occurred during insertion. Generated only #{inserted} instead of #{amount} people."
        )

        ensure_valid_amount_is_inserted(generator, amount - inserted)
    end
  end

  defp generate_random_people(male_fns, male_lns, female_fns, female_lns, births, amount) do
    for _ <- 1..amount do
      case :rand.uniform(2) do
        1 ->
          generate_random_person_from_data(male_fns, male_lns, births, :male)

        _ ->
          generate_random_person_from_data(female_fns, female_lns, births, :female)
      end
    end
  end

  defp generate_random_person_from_data(first_names, last_names, births, sex) do
    %{
      first_name: Enum.random(first_names),
      last_name: Enum.random(last_names),
      sex: sex,
      birth_date: Enum.random(births),
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
  end

  defp generate_random_birth_date do
    @last_possible_birth
    |> Kernel.+(1)
    |> :rand.uniform()
    |> Kernel.-(1)
    |> DateTime.from_unix!()
    |> case do
      %{day: day, year: year, month: month} ->
        Date.new!(year, month, day)
    end
  end

  defp fetch_most_common_male_first_names(amount \\ @default_generate_from_amount) do
    amount
    |> DaneGovApi.male_surnames_path()
    |> fetch_most_common_names()
  end

  defp fetch_most_common_female_first_names(amount \\ @default_generate_from_amount) do
    amount
    |> DaneGovApi.female_surnames_path()
    |> fetch_most_common_names()
  end

  defp fetch_most_common_male_last_names(amount \\ @default_generate_from_amount) do
    amount
    |> DaneGovApi.male_lastnames_path()
    |> fetch_most_common_names()
  end

  defp fetch_most_common_female_last_names(amount \\ @default_amount) do
    amount
    |> DaneGovApi.female_lastnames_path()
    |> fetch_most_common_names()
  end

  defp fetch_most_common_names(path) do
    path
    |> HTTPoison.get()
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200} = response} ->
        parse_result(response.body)

      response ->
        Logger.error("Unable to fetch names error #{inspect(response)}")

        raise "Unable to fetch names from dane.gov.pl. Check logs"
    end
  end

  defp parse_result(data) do
    data
    |> Jason.decode!()
    |> Map.fetch!("data")
    |> Stream.map(& &1["attributes"]["col1"]["val"])
    |> Enum.map(&String.capitalize/1)
  end
end
