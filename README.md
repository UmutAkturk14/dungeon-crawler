# Dungeon Crawler CLI (Final Snapshot)

A compact, turn-based dungeon crawl built in Ruby while brushing up on language fundamentals. Battle randomly spawned monsters, gather loot, and level your adventurer until you topple the Eclipsed Warden and escape the depths.

---

## Highlights

- **Modular codebase** – namespaced under `DungeonCrawler`, organized inside `lib/`.
- **Colorized terminal output** for quick visual cues (info, danger, loot, XP, etc.).
- **Dynamic encounters** – tougher enemies unlock as you level, culminating in a final guardian.
- **Inventory & consumables** – potions, buffs, and passive trinkets affect stats, loot chance, and escape chances.
- **Level-up path** – XP rewards grant HP, attack, luck, and evasive bonuses over time.

---

## Commands

| Command                | Alias(es)             | Description                             |
|------------------------|-----------------------|-----------------------------------------|
| `move <direction>`     | `m`, `n`, `s`, `e`, `w` | Explore the dungeon / trigger encounters |
| `attack`               | `a`                   | Strike the current monster               |
| `heal`                 | –                     | Use the best available healing option    |
| `use <item>`           | –                     | Consume or activate an inventory item    |
| `inspect`              | `look`, `l`           | View current foe details (if any)        |
| `inventory`            | `inv`                 | List held items with descriptions        |
| `stats`                | `status`              | Show level, XP, HP, attack, luck, etc.   |
| `help`                 | –                     | Print command help                       |
| `quit`                 | `q`, `exit`           | Leave the dungeon                        |

---

## Requirements

- Ruby 3.0 or newer
- A terminal that supports ANSI colors (optional but recommended)

---

## Getting Started

```bash
# clone (or copy) the project directory
cd dungeon-crawler

# run the adventure
ruby play.rb
```

You are dropped straight into the CLI loop. Type `help` to view available commands, explore the dungeon, and survive long enough to reach level 6 for the final showdown.

---

## Project Structure

```
.
├── lib/
│   ├── dungeon_crawler.rb          # convenience require file
│   └── dungeon_crawler/
│       ├── actions.rb              # command handling and gameplay logic
│       ├── game.rb                 # main Game class / loop
│       ├── game_objects.rb         # monsters, loot, spawn helpers
│       └── helpers.rb              # logging + ANSI color utilities
└── play.rb                         # entry point (require + start Game)
```

All runtime logic lives under `DungeonCrawler::`. `play.rb` simply requires the library and calls `DungeonCrawler::Game.new.start`.

---

## Notes

- This is the final iteration; no further work is planned.
- The game was created as a personal Ruby refresher—feel free to borrow or build on it.
- If you run into ANSI color issues, set `TERM` to a color-capable value (e.g., `xterm-256color`).

Happy crawling!
