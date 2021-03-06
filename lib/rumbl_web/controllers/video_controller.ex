defmodule RumblWeb.VideoController do
  use RumblWeb, :controller

  alias Rumbl.Videos
  alias Rumbl.Videos.Video
  alias Rumbl.Videos.Categories

  plug :load_categories when action in [:new, :create, :edit, :update]

  def action(conn, _) do  # modify the default action function of the controller to pass the current_user
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    videos = Videos.all_user_videos(user)
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, user) do
    changeset =
    user
    |> Ecto.build_assoc(:videos) # build the assoc of the users with videos
    |> Video.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, user) do
    case Videos.create_video_assoc_with_user(user, video_params) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    video = Videos.get_user_video(user, id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    video = Videos.get_user_video(user, id)
    changeset = Videos.change_video(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    video = Videos.get_user_video(user, id)

    case Videos.update_video(video, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    video = Videos.get_user_video(user, id)
    {:ok, _video} = Videos.delete_video(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end

  defp load_categories(conn, _) do
    categories = Categories.load_categories
    assign(conn, :categories, categories)
  end

end
