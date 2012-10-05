require 'fileutils'
require 'time'

module Jekyll

  class SitemapFile < StaticFile
    def write(dest)
      false
    end
  end

  class SitemapGenerator < Generator
    safe true
    priority :low

    def initialize(config = {})
      super
      @outfile = 'sitemap.xml'
    end

    def generate(site)

      out = File.join(site.dest, @outfile)

      FileUtils.mkdir_p(File.dirname(out))

      File.open(out, 'w') do |f|

        f.write('<?xml version="1.0" encoding="UTF-8"?>')
        f.write("\n" + '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')

        baseloc = "#{site.config['url']}".gsub(/\/+$/, "")
        baseloc << "#{site.config['baseurl']}".gsub(/\/+$/, "")

        xml = ""

        site.pages.each do |page|
          path = File.dirname(page.destination("")).gsub(/\/+$/, "") + "/" + page.name
          lastmod = (FileTest.exist?(site.source + path) ? File.mtime(site.source + path) : Time.now)
            .strftime("%Y-%m-%dT%H:%M:%S%z").gsub(/00$/, ':00')
          xml << "\n<url><loc>#{baseloc}#{page.destination("")}</loc><lastmod>#{lastmod}</lastmod></url>"
        end

        f.write(xml)
        f.write("\n" + '</urlset>')
      end

      site.static_files << SitemapFile.new(site, site.dest, '/', @outfile) if File.exists?(out)
    end
  end
end
