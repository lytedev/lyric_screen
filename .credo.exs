%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["**/*.ex"],
        excluded: [~r"/build/"]
      }
    },
    %{
      name: "tests",
      files: %{
        included: [
          "**/*.exs"
        ],
        excluded: [~r"/build/", ~r"/src/data/migrations/"]
      }
    }
  ]
}
