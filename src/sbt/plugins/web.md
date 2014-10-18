---
layout: page

title: xsbt-web-plugin
---

## Build Definitions

### 0.9.x

`project/plugins.sbt`:

    addSbtPlugin("com.earldouglas" % "xsbt-web-plugin" % "0.9.0")
    // for sbt-0.12.x
    //addSbtPlugin("com.earldouglas" % "xsbt-web-plugin" % "0.5.0")

_0.9.x_ は sbt-0.13.0 以上が必要です。sbt-0.12.x 系の場合は _0.5.x_ を利用します。

`build.sbt`:

    seq(webSettings :_*)

    libraryDependencies ++= Seq(
      "javax.servlet" % "javax.servlet-api" % "3.0.1" % "provided",
      "org.eclipse.jetty" % "jetty-webapp" % "9.1.0.v20131115" % "container",
      "org.eclipse.jetty" % "jetty-plus"   % "9.1.0.v20131115" % "container",
      //"org.apache.tomcat.embed" % "tomcat-embed-core"         % "7.0.22" % "container",
      //"org.apache.tomcat.embed" % "tomcat-embed-logging-juli" % "7.0.22" % "container",
      //"org.apache.tomcat.embed" % "tomcat-embed-jasper"       % "7.0.22" % "container"
    )

    host in container.Configuration := "0.0.0.0"

    port in container.Configuration := 8080

### 0.2.x

`project/plugins.sbt`:

    libraryDependencies <+= sbtVersion(v => v match {
      case "0.11.0" => "com.github.siasia" %% "xsbt-web-plugin" % "0.11.0-0.2.8"
      case "0.11.1" => "com.github.siasia" %% "xsbt-web-plugin" % "0.11.1-0.2.10"
      case "0.11.2" => "com.github.siasia" %% "xsbt-web-plugin" % "0.11.2-0.2.11"
      case "0.11.3" => "com.github.siasia" %% "xsbt-web-plugin" % "0.11.3-0.2.11.1"
      case x if (x.startsWith("0.12")) => "com.github.siasia" %% "xsbt-web-plugin" % "0.12.0-0.2.11.1"
    })

`build.sbt`:

    seq(webSettings :_*)

    libraryDependencies ++= Seq(
      "org.mortbay.jetty" % "jetty" % "6.1.22" % "container",
      "javax.servlet" % "servlet-api" % "2.5" % "provided"
    )

## Usage

`net.example.servlets.SandboxServlet` を作成してみます。ソースは `src/main/scala/net/example/servlets/SandboxServlet.scala` に設置します。

{% highlight scala %}
package net.example.servlets

import javax.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}

class SandboxServlet extends HttpServlet {
  override def doGet(request:HttpServletRequest, response:HttpServletResponse) {
    response.setContentType("text/plain")
    response.setCharacterEncoding("UTF-8")
    response.getWriter().write("Hello World")
  }
}
{% endhighlight %}

`src/main/webpp/WEB-INF/web.xml` を配置します。

{% highlight xml %}
<web-app>
  <servlet>
    <servlet-name>sandbox</servlet-name>
    <servlet-class>net.example.servlets.SandboxServlet</servlet-class>
  </servlet>
  <servlet-mapping>
    <servlet-name>sandbox</servlet-name>
    <url-pattern>/sandbox</url-pattern>
  </servlet-mapping>
</web-app>
{% endhighlight %}

sbt コンソールから `container:start` で Jetty を起動します。

    % sbt
    [info] Loading project definition from ....
    [info] Set current project to sandbox (in build file:...)
    > container:start
    [info] Compiling 1 Scala source to ...
    ...:INFO::Logging to STDERR via org.mortbay.log.StdErrLog
    [info] jetty-6.1.22
    [info] NO JSP Support for /, did not find org.apache.jasper.servlet.JspServlet
    [info] Started SelectChannelConnector@0.0.0.0:8080
    ....


`http://localhost:8080/sandbox` にアクセスすると応答が確認できます。

    % telnet localhost 8080
    Trying ::1...
    Connected to localhost.
    Escape character is '^]'.
    GET /sandbox HTTP/1.1
    Host: localhost

    HTTP/1.1 200 OK
    Content-Type: text/plain; charset=utf-8
    ....

    Hello World


`container:reload /` でソース変更を反映できます。`~` 付きの以下のコマンドではソース更新を検知して自動で反映を行ってくれます。

    > ~; container:start; container:reload /


`container:stop` でサーバを停止します。

    > container:stop


`package` で .war パッケージが `target/(パッケージ名).war` に作成されます。

    > package


生成される .war ファイル名にバージョン情報が付与されるのを回避するには、`build.sbt` に以下の行を追加して `artifactName` 値でパッケージ名のフォーマットを変更します。

sbt-0.12.x 系では artifactName の型は `(ScalaVersion, ModuleID, Artifact) => String` になります。

    artifactName := { (config:ScalaVersion, module:ModuleID, artifact:Artifact) =>
      artifact.name + "." + artifact.extension
    }

sbt-0.11.x 系では artifactName の型は `(String, ModuleID, Artifact) => String` になります。

    artifactName := { (config:String, module:ModuleID, artifact:Artifact) =>
      artifact.name + "." + artifact.extension
    }

