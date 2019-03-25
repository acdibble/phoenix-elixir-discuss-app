defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug Ueberauth

  alias Discuss.User

  def sign_out(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: topic_path(conn, :index))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{
      external_id: auth.uid,
      token: auth.credentials.token,
      nickname: auth.info.nickname,
      provider: "github"
    }

    changeset = User.changeset(%User{}, user_params)

    sign_in(conn, changeset)
  end

  defp sign_in(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome!")
        |> put_session(:user_id, user.id)

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Sign In Error")
    end
    |> redirect(to: topic_path(conn, :index))
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, external_id: changeset.changes.external_id) do
      nil ->
        Repo.insert(changeset)

      user ->
        {:ok, user}
    end
  end
end
