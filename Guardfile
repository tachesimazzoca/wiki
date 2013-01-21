# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Add files and commands to this file, like the example:
#   watch(%r{file/path}) { `command(s)` }
#
guard 'shell' do
  watch(%r{src/*}) do |m|
    unless m[0].start_with?('src/_site/')
      `make`
    end
  end
end
