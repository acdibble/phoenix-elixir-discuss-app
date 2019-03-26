defmodule Discuss.Plugs.SetUser do
  import Plug.Conn

  alias Discuss.Repo
  alias Discuss.User

  def init(_params) do
  end

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)

    user = user_id && Repo.get(User, user_id)

    assign(conn, :user, user)
  end
end
