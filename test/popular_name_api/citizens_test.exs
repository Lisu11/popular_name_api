defmodule PopularNameApi.CitizensTest do
  use PopularNameApi.DataCase

  alias PopularNameApi.Citizens

  describe "persons" do
    alias PopularNameApi.Citizens.Person

    @invalid_attrs_sex %{
      first_name: "Julia",
      last_name: "Smith",
      sex: :fluid,
      birth_date: ~D[1999-01-01]
    }
    @invalid_attrs_birth %{
      first_name: "Julia",
      last_name: "Smith",
      sex: :female,
      birth_date: ~D[2024-01-01]
    }
    @invalid_attrs_name %{
      first_name: "Julia",
      last_name: nil,
      sex: :female,
      birth_date: ~D[1999-01-01]
    }

    test "list_persons/0 returns all persons" do
      person = insert(:person)
      assert Citizens.list_persons() == [person]
    end

    test "get_person!/1 returns the person with given id" do
      person = insert(:person)
      assert Citizens.get_person(person.id) == person
    end

    test "create_person/1 with valid data creates a person" do
      valid_attrs = %{
        first_name: "Julia",
        last_name: "Smith",
        sex: :female,
        birth_date: ~D[1999-01-01]
      }

      assert {:ok, %Person{} = person} = Citizens.create_person(valid_attrs)
      assert person.first_name == "Julia"
      assert person.last_name == "Smith"
      assert person.sex == :female
      assert person.birth_date == ~D[1999-01-01]
    end

    test "create_person/1 with invalid sex returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Citizens.create_person(@invalid_attrs_sex)
    end

    test "create_person/1 with invalid birth_date returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Citizens.create_person(@invalid_attrs_birth)
    end

    test "create_person/1 with nil name returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Citizens.create_person(@invalid_attrs_name)
    end

    test "update_person/2 with valid data updates the person" do
      person = insert(:person)

      update_attrs = %{
        first_name: "Julia",
        last_name: "Smith",
        sex: :female,
        birth_date: ~D[1999-01-01]
      }

      assert {:ok, %Person{} = person} = Citizens.update_person(person, update_attrs)
      assert person.first_name == "Julia"
      assert person.last_name == "Smith"
      assert person.sex == :female
      assert person.birth_date == ~D[1999-01-01]
    end

    test "update_person/2 with invalid name returns error changeset" do
      person = insert(:person)
      assert {:error, %Ecto.Changeset{}} = Citizens.update_person(person, @invalid_attrs_name)
      assert person == Citizens.get_person(person.id)
    end

    test "update_person/2 with invalid sex returns error changeset" do
      person = insert(:person)
      assert {:error, %Ecto.Changeset{}} = Citizens.update_person(person, @invalid_attrs_sex)
      assert person == Citizens.get_person(person.id)
    end

    test "update_person/2 with invalid birth returns error changeset" do
      person = insert(:person)
      assert {:error, %Ecto.Changeset{}} = Citizens.update_person(person, @invalid_attrs_birth)
      assert person == Citizens.get_person(person.id)
    end

    test "delete_person/1 deletes the person" do
      person = insert(:person)
      assert {:ok, %Person{}} = Citizens.delete_person(person)
      assert is_nil(Citizens.get_person(person.id))
    end

    test "change_person/1 returns a person changeset" do
      person = insert(:person)
      assert %Ecto.Changeset{} = Citizens.change_person(person)
    end
  end
end
