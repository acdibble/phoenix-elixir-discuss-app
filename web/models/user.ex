defmodule Discuss.User do
  use Discuss.Web, :model

  schema "users" do
    field :provider, :string
    field :token, :string
    field :nickname, :string
    field :external_id, :integer

    has_many :topics, Discuss.Topic

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:provider, :token, :nickname, :external_id])
    |> validate_required([:provider, :token, :nickname, :external_id])
  end

end
