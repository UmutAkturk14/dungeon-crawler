module DungeonCrawler
  module GameObjects
    class Item
      attr_reader :id, :name, :type, :description, :tags

      def initialize(id:, name:, type:, description:, tags: [], on_use: nil, on_acquire: nil)
        @id = id
        @name = name
        @type = type
        @description = description
        @tags = tags
        @on_use = on_use
        @on_acquire = on_acquire
      end

      def duplicate
        Item.new(
          id: @id,
          name: @name,
          type: @type,
          description: @description,
          tags: @tags.dup,
          on_use: @on_use,
          on_acquire: @on_acquire
        )
      end

      def on_acquire(player, game)
        @on_acquire&.call(player, game)
      end

      def use(player, game)
        return nil unless usable?

        @on_use.call(player, game)
      end

      def usable?
        !@on_use.nil?
      end

      def healing?
        @tags.include?(:healing)
      end

      def consumable?
        @type == :consumable
      end

      def to_s
        @name
      end
    end

    # Represents a monster template that can spawn living instances.
    class Monster
      attr_reader :id, :name, :max_hp, :attack, :loot_ids, :description, :tags, :rarity, :min_level, :xp_reward

      def initialize(id:, name:, max_hp:, attack:, loot_ids:, description:, tags: [], rarity: :common, min_level: 1, xp_reward: 10)
        @id = id
        @name = name
        @max_hp = max_hp
        @attack = attack
        @loot_ids = loot_ids
        @description = description
        @tags = tags
        @rarity = rarity
        @min_level = min_level
        @xp_reward = xp_reward
      end

      def spawn
        MonsterInstance.new(template: self)
      end
    end

    # Instance of a monster with mutable HP.
    class MonsterInstance
      attr_reader :template
      attr_accessor :hp

      def initialize(template:)
        @template = template
        @hp = template.max_hp
      end

      def name
        @template.name
      end

      def attack
        @template.attack
      end

      def loot_ids
        @template.loot_ids
      end

      def description
        @template.description
      end

      def xp_reward
        @template.xp_reward
      end

      def threat_level
        @template.min_level
      end

      def id
        @template.id
      end
    end

    module_function

    def spawn_monster(level: 1)
      pick_monster(level: level).spawn
    end

    def loot_for(monster_instance)
      ids = monster_instance&.loot_ids
      return nil unless ids && !ids.empty?

      build_item(ids.sample)
    end

    def xp_for(monster_instance)
      monster_instance&.xp_reward.to_i
    end

    def random_world_item(level: 1)
      table = world_loot_table(level)
      return nil unless table && !table.empty?

      id = table.sample
      build_item(id)
    end

    def build_item(id)
      template = item_catalog[id]
      return nil unless template

      template.duplicate
    end

    def monster_catalog
      @monster_catalog ||= build_monster_catalog.freeze
    end

    def final_guardian
      monster_catalog.find { |monster| monster.tags.include?(:final_boss) }
    end

    def item_catalog
      @item_catalog ||= build_item_catalog.freeze
    end

    def build_monster_catalog
      [
        Monster.new(
          id: :goblin_scout,
          name: "Goblin Scout",
          max_hp: 12,
          attack: 3,
          loot_ids: [:minor_potion, :lucky_coin],
          description: "A quick nuisance that carries pilfered trinkets.",
          tags: [:goblin],
          rarity: :common,
          min_level: 1,
          xp_reward: 15
        ),
        Monster.new(
          id: :cave_troll,
          name: "Cave Troll",
          max_hp: 26,
          attack: 6,
          loot_ids: [:greater_potion, :stout_shield],
          description: "Lumbering brute with a thick hide.",
          tags: [:giant],
          rarity: :uncommon,
          min_level: 2,
          xp_reward: 32
        ),
        Monster.new(
          id: :venom_spider,
          name: "Venomous Spider",
          max_hp: 16,
          attack: 5,
          loot_ids: [:energizing_tonic, :minor_potion],
          description: "Its bite burns and its silk glows sickly green.",
          tags: [:beast],
          rarity: :uncommon,
          min_level: 2,
          xp_reward: 24
        ),
        Monster.new(
          id: :skeleton_archer,
          name: "Skeleton Archer",
          max_hp: 14,
          attack: 4,
          loot_ids: [:ancient_quiver, :minor_potion],
          description: "Bones held together by grudges and old bowstrings.",
          tags: [:undead],
          rarity: :common,
          min_level: 1,
          xp_reward: 18
        ),
        Monster.new(
          id: :flame_imp,
          name: "Flame Imp",
          max_hp: 12,
          attack: 5,
          loot_ids: [:embershard, :minor_potion],
          description: "Cackling fiend leaving embers in its wake.",
          tags: [:demon],
          rarity: :uncommon,
          min_level: 2,
          xp_reward: 28
        ),
        Monster.new(
          id: :wraith,
          name: "Restless Wraith",
          max_hp: 18,
          attack: 7,
          loot_ids: [:mystic_amulet, :shadow_cloak],
          description: "A chill presence that drains the warmth from the air.",
          tags: [:undead],
          rarity: :rare,
          min_level: 3,
          xp_reward: 44
        ),
        Monster.new(
          id: :stone_sentinel,
          name: "Stone Sentinel",
          max_hp: 22,
          attack: 5,
          loot_ids: [:berserker_charm, :stout_shield],
          description: "Animated ruin-guardian with grinding joints.",
          tags: [:construct],
          rarity: :uncommon,
          min_level: 3,
          xp_reward: 36
        ),
        Monster.new(
          id: :ghoul_packleader,
          name: "Ghoul Packleader",
          max_hp: 24,
          attack: 6,
          loot_ids: [:ironroot_brew, :smoke_bomb],
          description: "A ravenous ghoul directing a slavering horde.",
          tags: [:undead],
          rarity: :uncommon,
          min_level: 3,
          xp_reward: 40
        ),
        Monster.new(
          id: :rune_guardian,
          name: "Rune Guardian",
          max_hp: 28,
          attack: 7,
          loot_ids: [:focus_scroll, :stout_shield],
          description: "An ancient construct etched with glowing sigils.",
          tags: [:construct],
          rarity: :rare,
          min_level: 3,
          xp_reward: 48
        ),
        Monster.new(
          id: :frost_wyrmling,
          name: "Frost Wyrmling",
          max_hp: 34,
          attack: 8,
          loot_ids: [:phoenix_ash, :resonant_shard],
          description: "A young dragon that exhales shards of winter.",
          tags: [:dragon],
          rarity: :rare,
          min_level: 4,
          xp_reward: 66
        ),
        Monster.new(
          id: :abyssal_knight,
          name: "Abyssal Knight",
          max_hp: 38,
          attack: 9,
          loot_ids: [:void_essence, :focus_scroll],
          description: "A warrior clad in void-warped armor.",
          tags: [:undead, :elite],
          rarity: :rare,
          min_level: 5,
          xp_reward: 86
        ),
        Monster.new(
          id: :dungeon_warden,
          name: "Eclipsed Warden",
          max_hp: 52,
          attack: 11,
          loot_ids: [:void_essence, :phoenix_ash],
          description: "The dungeon's final sentinel, its starless armor drinks the light around you.",
          tags: [:elite, :final_boss],
          rarity: :rare,
          min_level: 6,
          xp_reward: 120
        )
      ]
    end

    def build_item_catalog
      {
        minor_potion: Item.new(
          id: :minor_potion,
          name: "Minor Healing Potion",
          type: :consumable,
          description: "Restores 12 HP when used.",
          tags: [:healing],
          on_use: lambda do |player, _game|
            before = player.hp
            player.hp = [player.hp + 12, player.max_hp].min
            player.hp - before
          end
        ),
        greater_potion: Item.new(
          id: :greater_potion,
          name: "Greater Healing Draught",
          type: :consumable,
          description: "Restores 25 HP and fortifies you slightly.",
          tags: [:healing],
          on_use: lambda do |player, game|
            before = player.hp
            player.hp = [player.hp + 25, player.max_hp].min
            player.max_hp += 2
            player.hp += 2
            player.hp = [player.hp, player.max_hp].min
            game.log "You feel tougher. Max HP increased by 2."
            player.hp - before
          end
        ),
        ironroot_brew: Item.new(
          id: :ironroot_brew,
          name: "Ironroot Brew",
          type: :consumable,
          description: "Restores 18 HP and hardens your frame (+2 max HP).",
          tags: [:healing],
          on_use: lambda do |player, game|
            before = player.hp
            player.hp = [player.hp + 18, player.max_hp].min
            player.max_hp += 2
            player.hp += 2
            player.hp = [player.hp, player.max_hp].min
            game.log "Your veins thrum with earthen strength. Max HP increases by 2."
            player.hp - before
          end
        ),
        energizing_tonic: Item.new(
          id: :energizing_tonic,
          name: "Energizing Tonic",
          type: :consumable,
          description: "Restores 8 HP and sharpens your strike (+1 attack).",
          tags: [:healing],
          on_use: lambda do |player, game|
            before = player.hp
            player.hp = [player.hp + 8, player.max_hp].min
            player.attack += 1
            game.log "Adrenaline surges through you. Attack increased by 1."
            player.hp - before
          end
        ),
        focus_scroll: Item.new(
          id: :focus_scroll,
          name: "Scroll of Focus",
          type: :consumable,
          description: "Meditative glyphs raise your attack by 2.",
          tags: [:attack_buff],
          on_use: lambda do |player, game|
            player.attack += 2
            game.log "Clarity sharpens your strikes. Attack increased by 2."
            nil
          end
        ),
        stout_shield: Item.new(
          id: :stout_shield,
          name: "Stout Shield",
          type: :trinket,
          description: "A reliable shield that raises max HP by 4.",
          tags: [:defense],
          on_acquire: lambda do |player, game|
            player.max_hp += 4
            player.hp += 4
            game.log "You strap on the Stout Shield. Max HP increases by 4."
          end
        ),
        berserker_charm: Item.new(
          id: :berserker_charm,
          name: "Berserker Charm",
          type: :trinket,
          description: "A carved charm that boosts your attack by 2.",
          tags: [:attack_buff],
          on_acquire: lambda do |player, game|
            player.attack += 2
            game.log "Rage boils in your veins. Attack increases by 2."
          end
        ),
        smoke_bomb: Item.new(
          id: :smoke_bomb,
          name: "Smoke Bomb",
          type: :consumable,
          description: "Creates cover, improving your ability to escape (+2 escape bonus).",
          tags: [:evasion],
          on_use: lambda do |player, game|
            bonus = player.respond_to?(:escape_bonus) ? player.escape_bonus.to_i : 0
            player.escape_bonus = bonus + 2
            game.log "You hone your exit strategy. Escape bonus increases by 2."
            nil
          end
        ),
        lucky_coin: Item.new(
          id: :lucky_coin,
          name: "Lucky Coin",
          type: :trinket,
          description: "Increases your odds of finding loot.",
          tags: [:fortune],
          on_acquire: lambda do |player, game|
            current = player.respond_to?(:luck) ? player.luck.to_i : 0
            player.luck = current + 1
            game.log "Fortune smiles upon you. Loot chance increased."
          end
        ),
        mystic_amulet: Item.new(
          id: :mystic_amulet,
          name: "Mystic Amulet",
          type: :trinket,
          description: "Ancient charm that grants +1 attack and +3 max HP.",
          tags: [:attack_buff, :defense],
          on_acquire: lambda do |player, game|
            player.attack += 1
            player.max_hp += 3
            player.hp += 3
            game.log "Arcane warmth fills you. Stats improved."
          end
        ),
        shadow_cloak: Item.new(
          id: :shadow_cloak,
          name: "Shadow Cloak",
          type: :trinket,
          description: "A cloak that lets you slip away from danger more easily.",
          tags: [:evasion],
          on_acquire: lambda do |player, game|
            escapes = player.respond_to?(:escape_bonus) ? player.escape_bonus.to_i : 0
            player.escape_bonus = escapes + 1
            game.log "You meld with the darkness. Escaping combat becomes easier."
          end
        ),
        phoenix_ash: Item.new(
          id: :phoenix_ash,
          name: "Phoenix Ash",
          type: :consumable,
          description: "Ignites vitality, fully restoring HP and granting +1 attack.",
          tags: [:healing, :attack_buff],
          on_use: lambda do |player, game|
            before = player.hp
            player.hp = player.max_hp
            player.attack += 1
            game.log "Flame surges through you. Attack increases by 1."
            player.hp - before
          end
        ),
        ancient_quiver: Item.new(
          id: :ancient_quiver,
          name: "Ancient Quiver",
          type: :trinket,
          description: "Faded fletching lends precision (+1 attack).",
          tags: [:attack_buff],
          on_acquire: lambda do |player, game|
            player.attack += 1
            game.log "You notch ghostly arrows. Attack increases by 1."
          end
        ),
        embershard: Item.new(
          id: :embershard,
          name: "Embershard",
          type: :trinket,
          description: "Crackling shard that scorches foes (+1 attack, +1 max HP).",
          tags: [:attack_buff, :defense],
          on_acquire: lambda do |player, game|
            player.attack += 1
            player.max_hp += 1
            player.hp += 1
            game.log "Flames lick at your weapon. Attack and max HP rise."
          end
        ),
        resonant_shard: Item.new(
          id: :resonant_shard,
          name: "Resonant Shard",
          type: :trinket,
          description: "A humming crystal that sharpens your senses (+1 attack, +1 luck).",
          tags: [:attack_buff, :fortune],
          on_acquire: lambda do |player, game|
            player.attack += 1
            player.luck += 1
            game.log "The shard vibrates in tune with your pulse. Attack and luck rise."
          end
        ),
        void_essence: Item.new(
          id: :void_essence,
          name: "Void Essence",
          type: :trinket,
          description: "Shadowed energy that empowers aggression (+2 attack, +1 escape bonus).",
          tags: [:attack_buff, :evasion],
          on_acquire: lambda do |player, game|
            player.attack += 2
            bonus = player.respond_to?(:escape_bonus) ? player.escape_bonus.to_i : 0
            player.escape_bonus = bonus + 1
            game.log "The essence clings to your blade. Attack rises by 2, escape bonus by 1."
          end
        )
      }
    end

    def world_loot_table(level)
      case level
      when 1..2
        [
          :minor_potion,
          :minor_potion,
          :minor_potion,
          :energizing_tonic,
          :lucky_coin,
          :smoke_bomb
        ]
      when 3..4
        [
          :minor_potion,
          :energizing_tonic,
          :greater_potion,
          :ironroot_brew,
          :stout_shield,
          :focus_scroll,
          :resonant_shard,
          :smoke_bomb
        ]
      else
        [
          :greater_potion,
          :ironroot_brew,
          :phoenix_ash,
          :focus_scroll,
          :resonant_shard,
          :void_essence
        ]
      end
    end

    def pick_monster(level:)
      base_pool = monster_catalog.reject { |monster| monster.tags.include?(:final_boss) }
      base_pool = monster_catalog if base_pool.empty?

      candidates = base_pool.select { |monster| monster.min_level <= level + 1 }
      candidates = base_pool if candidates.empty?

      weighted_pool = candidates.flat_map do |monster|
        rarity_weight = case monster.rarity
                        when :common then 5
                        when :uncommon then 3
                        when :rare then 1
                        else 2
                        end
        level_gap = level - monster.min_level
        level_weight = if level_gap >= 0
                         [[2 + level_gap, 6].min, 1].max
                       else
                         1
                       end
        Array.new([rarity_weight * level_weight, 1].max, monster)
      end

      weighted_pool.sample || candidates.sample || base_pool.sample || monster_catalog.sample
    end
  end
end
