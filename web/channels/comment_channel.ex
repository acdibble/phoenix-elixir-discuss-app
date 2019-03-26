defmodule Discuss.CommentsChannel do
  use Discuss.Web, :channel

  alias Discuss.{Topic, Comment, User}

  def join("comments:" <> id, _params, socket) do
    topic_id = String.to_integer(id)
    topic = Topic
      |> Repo.get(topic_id)
      |> Repo.preload(comments: [:user])

    Poison.encode(topic.comments)
    |> IO.inspect()

    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  def handle_in("comments:" <> action, message, socket) do
    topic = socket.assigns.topic
    user = Repo.get(User, socket.assigns.user_id)

    result = case action do
      "add" ->
        topic
        |> build_assoc(:comments)
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:user, user)
        |> Comment.changeset(message)
        |> Repo.insert()
    end

    case result do
      {:ok, comment} ->
        broadcast!(socket, "comments:#{topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}

      {:error, _reason} ->
        {:reply, {:error, %{errors: result}}, socket}
    end
    {:reply, :ok, socket}
  end
end
