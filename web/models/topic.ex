defmodule Discuss.Topic do
  use Discuss.Web, :model

  schema "topics" do
    field :title, :string

    belongs_to :users, Discuss.User, foreign_key: :user_id
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end
