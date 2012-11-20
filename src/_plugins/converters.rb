module Jekyll

  require 'sass'

  class SassConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /scss/i
    end

    def output_ext(ext)
      '.css'
    end

    def convert(content)
      begin
        engine = Sass::Engine.new(content, :syntax => :scss, :load_paths => ["./_sass/"])
        engine.render
      rescue StandardError => e
        puts e.message
      end
    end
  end
end
