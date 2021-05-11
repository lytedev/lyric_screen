defmodule LyricScreen.Repo.Migrations.AddSongsTables do
  use Ecto.Migration

  def change do
    create table("accounts") do
      add :nickname, :string
      timestamps()
    end

    create table("users") do
      add :username, :string
      add :nickname, :string
      add :first_name, :string
      add :last_name, :string
      add :hashed_password, :string
      timestamps()
    end

    create table("user_emails") do
      add :user_id, references("users")
      add :email, :string
      timestamps()
    end

    create table("accounts_users") do
      add :account_id, references("accounts")
      add :user_id, references("users")
      timestamps()
    end

    create table("account_user_roles") do
      add :account_user_id, references("accounts_users")
      add :role, :string
      timestamps()
    end
  end
end
