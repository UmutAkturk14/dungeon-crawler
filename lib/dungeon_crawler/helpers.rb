module DungeonCrawler
  module Helpers
    ANSI_MAP = {
      reset: "\e[0m",
      info: "\e[36m",
      success: "\e[32m",
      warning: "\e[33m",
      danger: "\e[31m",
      loot: "\e[35m",
      xp: "\e[34m",
      level: "\e[95m"
    }.freeze

    def log(message, color: nil)
      puts(apply_color(message, color))
    end

    def log_with_sleep(message, time, color: nil)
      sleep time
      log(message, color: color)
    end

    def colorize(text, color = nil)
      color ? apply_color(text, color) : text
    end

    def supports_color_output?
      $stdout.isatty
    end

    def self.included(base)
      base.extend(self)
    end

    private

    def apply_color(message, color)
      return message unless color && supports_color_output?

      code = ANSI_MAP[color] || color
      return message unless code

      "#{code}#{message}#{ANSI_MAP[:reset]}"
    end
  end
end
