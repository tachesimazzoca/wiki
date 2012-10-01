require 'yaml'

module Jekyll

  class AppTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @attributes = {}
      if text =~ Liquid::TagAttributes
          text.scan(Liquid::TagAttributes) do |key, value|
            @attributes[key] = value.gsub(/^"([^"]*)"$/, '\1').gsub(/^'([^']*)'$/, '\1')
          end
      end
    end
  end

  class DirectoryIndexTag < AppTag

    def render(context)
      site = context.registers[:site]
      page = context['page']

      dirs = File.dirname(page['url']).gsub(/^\//, "").split("/")
      dirs.pop if File.basename(page['url']) == "index.html"

      html = ""

      if dirs.size > 0

        dir = ("/" + dirs.join("/")).gsub(/\/+$/, "")
        yml = "#{site.source}#{dir}/_index.yml"

        contents = []
        if File.exists?(yml)
          contents = YAML.load_file(yml) rescue []
        else
          contents = Dir.glob("#{site.source}#{dir}/*").reject { |f|
            File.basename(f).match(/^(?:[\._].*|index(?:\..*)?)$/)
          }.sort.map! { |f|
            name = File.basename(f, ".*")
            File.directory?(f) ? "#{name}/" : name
          }
        end

        html << sprintf("<ul%s>", @attributes.key?('ul') ? " #{@attributes['ul']}" : "")
        contents.each do |content|
          content = content.gsub(/\/.*$/, "/index")
          site.pages.each do |pg|
            if "#{dir}/#{content}.html" == pg.destination("")
              dest = pg.destination("")
              attr = (page['url'] != dest) ? "" : (@attributes.key?('active') ? " #{@attributes['active']}" : "")
              html << sprintf('<li%s><a href="%s%s">%s</a></li>', attr, site.config['baseurl'], dest, pg.data['title'])
              break
            end
          end
        end
        html << '</ul>'
      end

      html
    end
  end

  class ToctreeTag < AppTag

    def initialize(tag_name, text, tokens)
      super
      @attributes['recursive'] = 'true' unless @attributes.key?('recursive')
    end

    def render(context)
      site = context.registers[:site]
      page = context['page']

      dir = File.dirname(page['url']).gsub(/\/+$/, "")
      _render_toctree(dir, site, page)
    end

    def _render_toctree(dir, site, page)
      html = sprintf("<ul%s>", @attributes.key?('ul') ? " #{@attributes['ul']}" : "")

      yml = "#{site.source}#{dir}/_index.yml"
      contents = []
      if File.exists?(yml)
        contents = YAML.load_file(yml) rescue []
      else
        contents = Dir.glob("#{site.source}#{dir}/*").reject { |f|
          File.basename(f).match(/^(?:[\._].*|index(?:\..*)?)$/)
        }.sort.map! { |f|
          name = File.basename(f, ".*")
          File.directory?(f) ? "#{name}/" : name
        }
      end

      contents.each do |content|
        content = content.gsub(/\/.*$/, "/index")
        site.pages.each do |pg|
          if "#{dir}/#{content}.html" == pg.destination("")
            dest = pg.destination("")
            attr = (page['url'] != dest) ? "" : (@attributes.key?('active') ? " #{@attributes['active']}" : "")
            html << sprintf('<li%s><a href="%s%s">%s</a></li>', attr, site.config['baseurl'], dest, pg.data['title'])
            break
          end
        end
        if content.match(/\/index$/) && !@attributes['recursive'].match(/^(false|no|0+|)$/i)
          html << _render_toctree((dir + "/" + content.gsub(/\/index$/, "")), site, page)
        end
      end
      html << '</ul>'
    end
  end

  class TocrootTag < AppTag

    def render(context)
      site = context.registers[:site]
      page = context['page']

      html = ""

      dirs = File.dirname(page['url']).gsub(/^\//, "").split("/")
      dirs.pop if File.basename(page['url']) == "index.html"

      if dirs.size > 0
        dir = dirs[0]
        url = "/#{dir}/index.html"
        site.pages.each do |pg|
          if url == pg.destination("")
            pagename = pg.data.key?('title') ? pg.data['title'] : dir
            html << sprintf('<a href="%s%s">%s</a>', site.config['baseurl'], url, pagename)
            break
          end
        end
      end

      html
    end
  end

  class BreadcrumbTag < AppTag

    def render(context)
      site = context.registers[:site]
      page = context['page']

      divider = @attributes.key?('divider') ? "#{@attributes['divider']}" : "&nbsp;/&nbsp;"

      dirs = File.dirname(page['url']).gsub(/^\//, "").split("/")
      dirs.pop if File.basename(page['url']) == "index.html"

      html = ""
      indexdir = ""
      dirs.each do |dir|
        indexdir << "/#{dir}"
        url = "#{indexdir}/index"
        site.pages.each do |pg|
          if url == (File.dirname(pg.destination("")).gsub(/\/+$/, "") + "/#{pg.basename}")
            pagename = pg.data.key?('title') ? pg.data['title'] : dir
            html << sprintf('<li><a href="%s%s/index.html">%s</a>%s</li>', site.config['baseurl'], indexdir, pagename, divider)
            break
          end
        end
      end
      html << sprintf('<li>%s</li>', page['title'])

      html
    end
  end
end

Liquid::Template.register_tag('directory_index', Jekyll::DirectoryIndexTag)
Liquid::Template.register_tag('toctree', Jekyll::ToctreeTag)
Liquid::Template.register_tag('tocroot', Jekyll::TocrootTag)
Liquid::Template.register_tag('breadcrumb', Jekyll::BreadcrumbTag)