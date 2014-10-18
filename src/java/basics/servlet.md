---
layout: page

title: Servlet 
---

## ServletConfig 

`web.xml`:

{% highlight xml %}
<servlet>
  <servlet-name>Index</servlet-name>
  <servlet-class>net.example.servlet.IndexServlet</servlet-class>
  <init-param>
    <param-name>foo</param-name>
    <param-value>bar</param-value>
  </init-param>
</servlet>
{% endhighlight %}

`IndexServlet.java`:

{% highlight java %}
public class IndexServlet extends HttpServlet {
    @Override
    public void init() throws ServletException {
        ServletConfig config = super.getServletConfig();
        System.out.println(config.getInitParameter("foo")); // "bar"
    }
}
{% endhighlight %}
