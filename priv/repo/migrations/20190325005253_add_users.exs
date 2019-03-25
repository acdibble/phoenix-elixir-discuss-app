defmodule Discuss.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :provider, :string
      add :token, :string
      add :nickname, :string
      add :external_id, :integer

      timestamps()
    end
  end
end
