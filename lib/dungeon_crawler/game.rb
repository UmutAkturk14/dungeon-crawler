require_relative "helpers"
require_relative "actions"

module DungeonCrawler
  class Game
    include Helpers

    attr_reader :player, :dungeon, :running, :won

    def initialize(player: nil, dungeon: nil)
      @player = player
      @dungeon = dungeon
      @running = false
      @won = false
    end

    def start
      @running = true
      @won = false
      log "Welcome to Dungeon Crawler. Type 'help' for available commands.", color: :info
      main_loop
    end

    def stop
      @running = false
      log "Exiting game...", color: :warning
    end

    def win(message = "You escape the dungeon victorious!")
      @running = false
      @won = true
      log message, color: :success
      log "Fresh air floods your lungs as daylight spills in. Thanks for playing!", color: :info
    end

    def main_loop
      while @running
        print "> "
        input = STDIN.gets
        unless input
          stop
          break
        end

        input = input.chomp.strip
        next if input.empty?

        dispatch(input)
      end
    end

    def dispatch(input)
      cmd, *args = input.split(/\s+/)
      cmd = cmd.downcase

      if defined?(Actions) && Actions.respond_to?(:handle)
        Actions.handle(self, cmd, args)
      else
        handle_builtin(cmd, args)
      end
    rescue => e
      log "Error: #{e.class}: #{e.message}", color: :danger
    end

    def handle_builtin(cmd, _args)
      case cmd
      when "quit", "exit", "q"
        stop
      when "help", "h"
        log "Commands: help, quit (aliases: q), (Actions module will add: move, attack, heal, inspect, inventory)", color: :info
      else
        log "Unknown command: #{cmd}. Type 'help' for commands.", color: :warning
      end
    end
  end
end
