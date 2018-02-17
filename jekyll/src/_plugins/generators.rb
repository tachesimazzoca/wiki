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

      # Load the patterns of the ignored files via /.noindex
      noindex_f = "#{config['source']}/.noindex"
      if File.exist?(noindex_f)
        @noindex = (File.open(noindex_f).readlines.map! do |v|
          v.strip
        end).select do |v|
          !v.empty?
        end
      else
        @noindex = []
      end
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
          next unless page.destination("").match(/\.html$/)

          next if @noindex.any? do |ptn|
            escaped = Regexp.escape(ptn).gsub('\*','.*?')
            Regexp.new("^#{escaped}$") =~ "/#{page.path}"
          end

          path = File.dirname(page.destination("")).gsub(/\/+$/, "") + "/" + page.name
          lastmod = (File.exist?(site.source + path) ? File.mtime(site.source + path) : Time.now)
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
