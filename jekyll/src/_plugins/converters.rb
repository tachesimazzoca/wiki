require 'pygments'

module Pygments
  module Popen
    # Skip Process.kill(0, @pid) for the re-generation performance.
    # It might cause any exception, but we rely on the PID.
    def alive?
      !!@pid
    end
  end
end
