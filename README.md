# 🧙‍♂️ Dungeon Crawler CLI

A **text-based adventure game** written in **pure Ruby**, designed as a fun way to refresh and demonstrate Ruby fundamentals — OOP, control flow, data structures, and clean CLI architecture.

The project simulates a **turn-based dungeon crawl** where the player explores randomly generated rooms, battles monsters, collects loot, and tries to survive until they find the exit.

---

## 🚀 Overview

**Dungeon Crawler CLI** is built as a modular Ruby project, structured for clarity and scalability.
It can later be extended into a **Rails-powered web app** (with persistent players, leaderboards, and RESTful APIs).

The goal is to:

- Reinforce Ruby fundamentals
- Practice modular design and OOP
- Build a complete, working terminal application
- (Optional) Bridge it into Rails for web integration

---

## 🧩 Features (Phase 1 - CLI Core)

- 🎮 **Turn-based gameplay** – each move matters
- ⚔️ **Combat system** – fight goblins, trolls, and dragons
- 🧱 **Procedural dungeon generation** – random room contents
- 💰 **Inventory and loot** – collect gold, weapons, and potions
- ❤️ **Player stats** – HP, attack, defense, healing
- 🧠 **Command system** – move, attack, heal, inspect, inventory
- ⚗️ **YAML-driven monsters & items** – easily configurable data files
- 🕹️ **Clean CLI loop** – smooth and readable text-based interactions

---

## 🧱 Planned Features (Phase 2 - Expansion)

- 🏰 **Multi-level dungeon** with increasing difficulty
- 💾 **Save & Load** game state using YAML serialization
- 🎨 **Colored text / ASCII art** for immersive visuals
- 🧪 **RSpec tests** for game logic and OOP components
- 🧭 **Command aliases** (`n`, `s`, `e`, `w`, `a`, `h`) for faster navigation
- ⚙️ **Difficulty modes** (Easy, Normal, Hard)
- 🎯 **Special abilities & item types**

---

## 🌐 Phase 3 - Rails Extension (Optional)

After the CLI version is stable, the project can evolve into a simple **Ruby on Rails web application**, using the CLI core as a foundation.

- 🧑‍💻 **Models:** `Player`, `Monster`, `Battle`, `DungeonRoom`
- 🌍 **Routes:** `/api/start`, `/api/move`, `/api/attack`
- 💾 **Database:** PostgreSQL for persistence
- ⚡ **Frontend (Optional):** React or ERB for browser-based play

This step ties together backend skills, Rails routing, REST APIs, and full-stack design.

---

## 🗂️ Project Structure

```
dungeon_crawler/
├── game.rb # Entry point – main game loop
├── player.rb # Player stats and actions
├── monster.rb # Enemy classes and combat logic
├── dungeon.rb # Map and dungeon generation
├── room.rb # Handles room events and interactions
├── item.rb # Loot and items
├── actions.rb # Command parsing and execution
├── utils.rb # Helper functions (formatting, delays)
└── data/
├── monsters.yml # Monster definitions
├── items.yml # Item definitions
└── rooms.yml # Optional room templates
```

## 🧠 Architecture Notes

- **`Game`** is the orchestrator — runs the main loop and manages state.
- **`Player`** encapsulates player data and logic.
- **`Dungeon`** manages navigation and current room tracking.
- **`Room`** defines what happens when you enter — combat, loot, trap, etc.
- **`Monster`** handles enemy behavior and attacks.
- **`Item`** and **`Inventory`** manage loot and healing.
- **`Actions`** abstracts user commands for clarity.
- **`Utils`** contains optional CLI formatting helpers (e.g., color, delay).

---

## 🧭 Roadmap

| Phase | Goal           | Description                                  |
| ----- | -------------- | -------------------------------------------- |
| **1** | Core CLI game  | Player movement, basic combat, random events |
| **2** | Depth & polish | Inventory, YAML data, colors, saving         |
| **3** | Testing        | Add RSpec tests for Player, Monster, Game    |
| **4** | Rails port     | Create API endpoints and models              |
| **5** | Web front-end  | Optional React interface for online play     |

---

## 🧰 Tech Stack

| Layer                  | Tools                           |
| ---------------------- | ------------------------------- |
| **Language**           | Ruby (>= 3.0)                   |
| **CLI Enhancements**   | colorize, tty-prompt (optional) |
| **Data**               | YAML (for monsters/items)       |
| **Testing**            | RSpec                           |
| **Version Control**    | Git + GitHub                    |
| **Optional Web Layer** | Ruby on Rails + PostgreSQL      |

---

## ⚙️ Installation

```bash
# Clone the repo
gh repo clone https://github.com/UmutAkturk14/dungeon-crawler-cli
cd dungeon-crawler-cli

# Run the game
ruby game.rb
```
