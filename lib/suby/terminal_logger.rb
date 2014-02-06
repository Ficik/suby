require 'colorize'

module Suby

  class TerminalLogger

    def call(severity, time, progname, msg)
      puts colorize(severity, msg)
    end

    def colorize(severity, msg)
      if severity == "DEBUG"
        msg.blue
      elsif severity == "ERROR"
        msg.magenta
      elsif severity == "FATAL"
        msg.red
      elsif severity == "WARN"
        msg.yellow
      elsif severity == "INFO"
        msg.green
      else
        msg
      end
    end

  end

end