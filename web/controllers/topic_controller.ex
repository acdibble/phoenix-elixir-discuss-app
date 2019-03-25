defmodule Discuss.TopicController do
  use Discuss.Web, :controller

  alias Discuss.Topic

  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    render conn, "index.html", topics: Repo.all(Topic)
  end

  def new(conn, _params) do
    render conn, "new.html", changeset: Topic.changeset(%Topic{}, %{})
  end

  def create(conn, %{"topic" => topic}) do
    changeset = conn.assigns.user
      |> build_assoc(:topics)
      |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Created")
        |> redirect(to: topic_path(conn, :index))

      {:error, rejected} ->
        render conn, "new.html", changeset: rejected
    end
  end

  def edit(conn, _params) do
    topic = conn.assigns.current_topic
    changeset = Topic.changeset(topic)
    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"topic" => topic}) do
    old_topic = conn.assigns.current_topic

    case old_topic |> Topic.changeset(topic) |> Repo.update() do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: topic_path(conn, :index))

      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: old_topic
    end

    redirect conn, to: topic_path(conn, :index)
  end

  def delete(conn, _params) do
    Repo.delete!(conn.assigns.current_topic)

    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  defp check_owner(conn, _params) do
    %{params: %{"id" => topic_id}, assigns: %{user: user}} = conn

    topic = Repo.get(Topic, topic_id)

    cond do
      topic == nil ->
        redirect(conn, to: topic_path(conn, :index)) |> halt()

      topic.user_id == user.id ->
        assign(conn, :current_topic, topic)

      true ->
        conn
        |> put_flash(:error, "You must own this topic in order to modify it")
        |> redirect(to: topic_path(conn, :index))
        |> halt()
    end
  end
end
