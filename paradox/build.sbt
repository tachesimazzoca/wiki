lazy val root = (project in file(".")).
  enablePlugins(ParadoxPlugin).
  settings(
    name := "tachesimazzoca - Wiki",
    paradoxTheme := None
  )

paradoxProperties += (
  "github.base_url" -> s"https://github.com/tachesimazzoca/wiki/tree/master/paradox"
)
