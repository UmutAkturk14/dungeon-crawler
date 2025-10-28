require "ostruct"
require_relative "game_objects"

module DungeonCrawler
  module Actions
    FINAL_BOSS_ID = :dungeon_warden
    FINAL_LEVEL_TRIGGER = 6

    module_function

    def handle(game, cmd, args)
      ensure_player(game)

      case cmd.downcase
      when "help"
        game.log "Commands: move (m), attack (a), heal, use <item>, inspect (look), inventory (inv), stats, help, quit (q)", color: :info
      when "quit", "exit", "q"
        game.stop
      when "move", "m", "n", "s", "e", "w"
        dir = %w[n s e w].include?(cmd) ? cmd : (args.shift || "forward")
        perform_move(game, dir)
      when "attack", "a"
        perform_attack(game)
      when "heal"
        perform_heal(game)
      when "inspect", "look", "l"
        perform_inspect(game)
      when "inventory", "inv"
        perform_inventory(game)
      when "stats", "status"
        perform_stats(game)
      when "use"
        perform_use(game, args)
      else
        game.log "Unknown command: #{cmd}. Type 'help' for commands.", color: :warning
      end
    rescue => e
      game.log "Action error: #{e.class}: #{e.message}", color: :danger
    end

    # -- helpers --

    def ensure_player(game)
      existing = game.instance_variable_get(:@player)
      if existing
        upgrade_player(existing)
        return
      end

      player = OpenStruct.new(
        name: "Hero",
        level: 1,
        xp: 0,
        next_level_xp: experience_threshold_for(1),
        hp: 30,
        max_hp: 30,
        attack: 6,
        inventory: [],
        luck: 0,
        escape_bonus: 0
      )
      game.instance_variable_set(:@player, player)
      game.log "Created player: #{player.name} (HP: #{player.hp})", color: :info
    end

    def upgrade_player(player)
      player.level = (player.respond_to?(:level) && !player.level.nil?) ? player.level : 1
      player.xp = (player.respond_to?(:xp) && !player.xp.nil?) ? player.xp : 0
      player.next_level_xp = if player.respond_to?(:next_level_xp) && player.next_level_xp
                               player.next_level_xp
                             else
                               experience_threshold_for(player.level)
                             end
      player.inventory = [] unless player.respond_to?(:inventory) && player.inventory
      player.luck = (player.respond_to?(:luck) && !player.luck.nil?) ? player.luck : 0
      player.escape_bonus = (player.respond_to?(:escape_bonus) && !player.escape_bonus.nil?) ? player.escape_bonus : 0
      player.max_hp = if player.respond_to?(:max_hp) && player.max_hp
                        player.max_hp
                      else
                        player.respond_to?(:hp) && player.hp ? player.hp : 30
                      end
      player.hp = player.max_hp unless player.respond_to?(:hp) && player.hp
      player.hp = [player.hp, player.max_hp].min if player.hp && player.max_hp
      player.attack = (player.respond_to?(:attack) && player.attack) ? player.attack : 6
    end

    def perform_move(game, dir)
      game.instance_variable_set(:@current_monster, nil)
      player = game.instance_variable_get(:@player)

      if trigger_final_encounter?(game, player)
        monster = begin_final_encounter(game, player, dir)
        return if monster
      end

      if rand < encounter_chance(game)
        monster = spawn_monster(player.level)
        game.instance_variable_set(:@current_monster, monster)
        threat_info = monster.respond_to?(:threat_level) ? " (Threat Lv #{monster.threat_level})" : ""
        game.log "You move #{dir} and encounter a #{monster.name}#{threat_info} (HP: #{monster.hp})!", color: :warning
      else
        loot = maybe_loot(game, player)
        if loot
          grant_item(game, loot, context: "You move #{dir} and discover #{loot.name}.", color: :loot)
        else
          game.log "You move #{dir}. Nothing here.", color: :info
        end
      end
    end

    def perform_attack(game)
      monster = game.instance_variable_get(:@current_monster)
      player = game.instance_variable_get(:@player)
      unless monster
        game.log "There is nothing to attack."
        return
      end

      monster.hp -= player.attack
      game.log "You attack the #{monster.name} for #{player.attack} damage. (#{[monster.hp, 0].max} HP left)", color: :info

      if monster.hp <= 0
        game.log "You defeated the #{monster.name}!", color: :success
        xp = GameObjects.xp_for(monster)
        grant_experience(game, xp, monster)
        loot = GameObjects.loot_for(monster)
        grant_item(game, loot, context: "You loot #{loot.name} from the #{monster.name}.", color: :loot) if loot
        game.instance_variable_set(:@current_monster, nil)
        trigger_victory(game) if final_boss?(monster)
        return
      end

      if player_evades?(player)
        game.log "You slip aside and avoid the #{monster.name}'s strike.", color: :success
      else
        player.hp -= monster.attack
        game.log "The #{monster.name} hits you for #{monster.attack}. (You: #{[player.hp, 0].max}/#{player.max_hp})", color: :danger
      end

      if player.hp <= 0
        game.log "You have been slain. Game over.", color: :danger
        game.stop
      end
    end

    def perform_heal(game)
      player = game.instance_variable_get(:@player)
      healing_item = player.inventory.find { |item| item.respond_to?(:healing?) && item.healing? && item.usable? }

      if healing_item
        healed = healing_item.use(player, game)
        if healing_item.respond_to?(:consumable?) ? healing_item.consumable? : true
          player.inventory.delete(healing_item)
        end
        player.hp = [player.hp, player.max_hp].min
        healed ||= 0
        game.log "You use #{healing_item.name} and recover #{healed} HP. (You: #{player.hp}/#{player.max_hp})", color: :success
      else
        if player.hp >= player.max_hp
          game.log "You are already at full health.", color: :info
          return
        end

        amount = 8
        before = player.hp
        player.hp = [player.max_hp, player.hp + amount].min
        recovered = player.hp - before
        game.log "You catch your breath and recover #{recovered} HP. (You: #{player.hp}/#{player.max_hp})", color: :success
      end
    end

    def perform_inspect(game)
      monster = game.instance_variable_get(:@current_monster)
      if monster
        description = monster.respond_to?(:description) ? monster.description : nil
        threat = monster.respond_to?(:threat_level) ? monster.threat_level : nil
        info = "There is a #{monster.name} here. HP: #{monster.hp}, Attack: #{monster.attack}"
        info += ", Threat Lv #{threat}" if threat
        info += " | #{description}" if description
        game.log info, color: :info
      else
        game.log "You look around. No enemies nearby.", color: :info
      end
    end

    def perform_inventory(game)
      player = game.instance_variable_get(:@player)
      if player.inventory.empty?
        game.log "Your inventory is empty.", color: :info
      else
        lines = []
        lines << "Inventory (#{player.inventory.size} items):"
        player.inventory.each_with_index do |item, idx|
          type = item.respond_to?(:type) ? item.type.to_s.capitalize : "Item"
          usable = item.respond_to?(:usable?) && item.usable?
          tags = item.respond_to?(:tags) && item.tags.any? ? " | Tags: #{item.tags.join(', ')}" : ""
          lines << "#{idx + 1}. #{item.name} [#{type}]#{usable ? ' (usable)' : ''}"
          if item.respond_to?(:description) && item.description
            lines << "   #{item.description}#{tags}"
          elsif tags && !tags.empty?
            lines << "   #{tags}"
          end
          lines << "   Use with 'use #{idx + 1}'." if usable
        end
        lines << "Tip: You can also 'use <item name>' to trigger consumables."
        game.log lines.join("\n"), color: :info
      end
    end

    def perform_stats(game)
      player = game.instance_variable_get(:@player)
      remaining = [player.next_level_xp - player.xp, 0].max
      lines = [
        "#{player.name}'s stats:",
        "Level #{player.level} | XP: #{player.xp}/#{player.next_level_xp} (#{remaining} to next)",
        "HP: #{player.hp}/#{player.max_hp}",
        "Attack: #{player.attack}",
        "Luck: #{player.luck}",
        "Escape bonus: #{player.escape_bonus}",
        "Inventory items: #{player.inventory.size}"
      ]
      game.log lines.join("\n"), color: :info
    end

    def perform_use(game, args)
      player = game.instance_variable_get(:@player)
      if args.nil? || args.empty?
        game.log "Use what? Try 'use 1' or 'use minor potion'.", color: :warning
        return
      end

      query = args.join(" ")
      item = resolve_inventory_item(player, query)
      unless item
        game.log "You do not have that item.", color: :warning
        return
      end

      unless item.respond_to?(:usable?) && item.usable?
        game.log "#{item.name} cannot be actively used.", color: :warning
        return
      end

      game.log "You use #{item.name}.", color: :info
      outcome = item.use(player, game)
      player.hp = [player.hp, player.max_hp].min

      if outcome.is_a?(Numeric) && outcome.positive? && item.respond_to?(:tags) && item.tags.include?(:healing)
        game.log "Healing: +#{outcome} HP (You: #{player.hp}/#{player.max_hp}).", color: :success
      end

      if item.respond_to?(:consumable?) && item.consumable?
        player.inventory.delete(item)
        game.log "#{item.name} is consumed.", color: :warning
      end
    end

    def spawn_monster(player_level = 1)
      GameObjects.spawn_monster(level: player_level)
    end

    def maybe_loot(_game, player = nil)
      player ||= OpenStruct.new(luck: 0, level: 1)
      luck_bonus = player.respond_to?(:luck) ? player.luck.to_i * 0.05 : 0.0
      chance = (0.35 + luck_bonus).clamp(0.05, 0.9)
      rand <= chance ? GameObjects.random_world_item(level: player.level) : nil
    end

    def grant_item(game, item, context:, color: :loot)
      return unless item

      player = game.instance_variable_get(:@player)
      player.inventory << item
      game.log context, color: color
      game.log item.description, color: :info if item.respond_to?(:description) && item.description
      item.on_acquire(player, game) if item.respond_to?(:on_acquire)
    end

    def trigger_final_encounter?(game, player)
      return false if game.instance_variable_get(:@victory_claimed)
      return false if game.instance_variable_get(:@final_encounter_completed)
      return false if game.instance_variable_get(:@final_encounter_triggered)

      player.level >= FINAL_LEVEL_TRIGGER
    end

    def begin_final_encounter(game, _player, dir)
      template = GameObjects.final_guardian
      return false unless template

      monster = template.spawn
      game.instance_variable_set(:@current_monster, monster)
      game.instance_variable_set(:@final_encounter_triggered, true)
      threat_info = monster.respond_to?(:threat_level) ? " (Threat Lv #{monster.threat_level})" : ""
      game.log "As you move #{dir}, the air cracks with power. #{monster.name} bars your way#{threat_info}! (HP: #{monster.hp})", color: :danger
      game.log monster.description, color: :info if monster.respond_to?(:description) && monster.description
      monster
    end

    def final_boss?(monster)
      monster.respond_to?(:id) && monster.id == FINAL_BOSS_ID
    end

    def trigger_victory(game)
      return if game.instance_variable_get(:@victory_claimed)

      game.instance_variable_set(:@victory_claimed, true)
      game.instance_variable_set(:@final_encounter_completed, true)
      game.instance_variable_set(:@current_monster, nil)
      game.log "The dungeon trembles as the final guardian falls!", color: :success
      game.win("A hidden stairway opens. You ascend and escape the dungeon!")
    end

    def grant_experience(game, amount, monster)
      amount = amount.to_i
      return if amount <= 0

      player = game.instance_variable_get(:@player)
      player.xp += amount
      foe = monster.respond_to?(:name) ? monster.name : "foe"
      game.log "You gain #{amount} XP from the #{foe}. (#{player.xp}/#{player.next_level_xp})", color: :xp
      leveled = process_level_ups(game, player)

      unless leveled
        remaining = [player.next_level_xp - player.xp, 0].max
        game.log "#{remaining} XP until level #{player.level + 1}.", color: :info if remaining.positive?
      end
    end

    def process_level_ups(game, player)
      leveled = false

      while player.xp >= player.next_level_xp
        player.xp -= player.next_level_xp
        player.level += 1
        level_up_adjustments(game, player)
        player.next_level_xp = experience_threshold_for(player.level)
        leveled = true
      end

      if leveled
        remaining = [player.next_level_xp - player.xp, 0].max
        game.log "Next level in #{remaining} XP.", color: :info
      end

      leveled
    end

    def experience_threshold_for(level)
      base = 30
      increment = (level - 1) * 25
      base + increment
    end

    def level_up_adjustments(game, player)
      player.luck = player.luck || 0
      player.escape_bonus = player.escape_bonus || 0

      hp_gain = 6 + (player.level / 2)
      attack_gain = player.level.even? ? 2 : 1
      luck_gain = (player.level % 3).zero? ? 1 : 0
      escape_gain = (player.level % 4).zero? ? 1 : 0

      player.max_hp += hp_gain
      player.hp += hp_gain
      player.attack += attack_gain
      player.luck += luck_gain if luck_gain.positive?
      player.escape_bonus += escape_gain if escape_gain.positive?
      player.hp = [player.hp, player.max_hp].min

      message = "Level up! #{player.name} reaches level #{player.level}: +#{hp_gain} max HP, +#{attack_gain} attack"
      message += ", +#{luck_gain} luck" if luck_gain.positive?
      message += ", +#{escape_gain} escape bonus" if escape_gain.positive?
      game.log message + ".", color: :level
    end

    def resolve_inventory_item(player, query)
      return nil unless query

      trimmed = query.strip
      return nil if trimmed.empty?

      if trimmed =~ /^\d+$/
        index = trimmed.to_i
        return nil unless index.positive? && index <= player.inventory.length

        return player.inventory[index - 1]
      end

      down = trimmed.downcase
      player.inventory.find do |item|
        name_match = item.respond_to?(:name) && item.name.downcase == down
        id_match = item.respond_to?(:id) && item.id.to_s.downcase == down.gsub(/\s+/, "_")
        partial_match = down.length >= 3 && item.respond_to?(:name) && item.name.downcase.include?(down)
        name_match || id_match || partial_match
      end
    end

    def encounter_chance(game)
      player = game.instance_variable_get(:@player)
      bonus = player.respond_to?(:escape_bonus) ? player.escape_bonus.to_i * -0.05 : 0.0
      level_bonus = [player.level - 1, 0].max * 0.02
      base = 0.55 + level_bonus + bonus
      base.clamp(0.3, 0.85)
    end

    def player_evades?(player)
      bonus = player.respond_to?(:escape_bonus) ? player.escape_bonus.to_i : 0
      chance = [bonus * 0.1, 0.4].min
      rand < chance
    end
  end
end
