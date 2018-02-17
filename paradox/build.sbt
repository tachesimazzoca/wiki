lazy val root = (project in file(".")).
  enablePlugins(ParadoxPlugin).
  settings(
    name := "tachesimazzoca - Wiki",
    paradoxTheme := None,
    paradoxNavigationExpandDepth := Some(1)
  )

//paradoxProperties += (
//  "github.base_url" -> s"https://github.com/tachesimazzoca/wiki"
//)
