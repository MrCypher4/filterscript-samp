# Filterscript SAMP - Modular & Complete Filterscripts for SA-MP

**Maker:** Vatiera  
**Version:** 0.1flash  
**Project Type:** Filterscript Collection for San Andreas Multiplayer (SA-MP)  
**License:** MIT  
**Status:** Active Development  

## Overview
This repository contains a **complete and modular collection of filterscripts** developed for SA-MP (San Andreas Multiplayer). Designed with performance, compatibility, and clean structure in mind, each script is optimized to be plug-and-play while maintaining high customization potential.

Whether you're building a freeroam server, an RP environment, or a unique custom gamemode, these filterscripts can serve as either a direct implementation or a base to build upon.
---
## Features
### Core Filterscripts Included
- `notif_system.pwn` – Dynamic notification system (TextDraw & Chat)
- `checkpoint_multi.pwn` – Interactive checkpoints for missions, warps, etc.
- `safezone.pwn` – Area-based PvP protection & visual indicators
- `login_basic.pwn` – Simple non-MySQL login/register system
- `antispam.pwn` – Anti-flood & chat spam filter
- `dialog_helper.pwn` – Create menus, confirmation dialogs, and info windows
- `cmd_admin_player.pwn` – Modular admin & player command utilities
- `auto_help.pwn` – Smart help dialog based on player status
- `hud_basic.pwn` – Minimalist HUD with player stats using TextDraw
- `speedometer.pwn` – Vehicle speed display + additional info
- `time_weather.pwn` – Dynamic world time & weather control
- `teleport.pwn` – Quick preset teleport system
- `player_stats.pwn` – Player kill/death and stat tracking
- `vfx_sfx.pwn` – Basic visual and sound effects for interaction
- `devtools.pwn` – Developer toolkit: position viewer, ID scanner, debug text

### Additional Highlights
- **Structured Codebase** – Organized and readable, uses standard SA-MP best practices.
- **Commented Functions** – Each script contains clear inline documentation.
- **No External Dependencies** – Most scripts run independently of MySQL or plugins.
- **Lightweight** – Designed to be CPU-efficient and fast to load.
- **High Compatibility** – Easily integrates into most gamemodes.
---
## Installation
1. Download or clone the repository:
   ```bash
   git clone https://github.com/MrCypher4/filterscript-samp.git
2. Add the .pwn files you need to your server's filterscripts/ directory.
3. Compile each .pwn file using the PAWN compiler (included with SA-MP server package).
4. Edit your server.cfg:
filterscripts notif_system checkpoint_multi safezone ...
5. Restart your SA-MP server.
---
Roadmap
[ ] Add configuration file support
[ ] Add advanced login with MySQL support
[ ] Refactor for better modular separation
[ ] Add filterscript auto-loader
[ ] Add inline unit test example
[ ] Localization support
---
Contributing
Pull requests are welcome! If you have improvements or new modular filterscripts to add, feel free to fork this project and submit a PR. Please ensure your code is clean and well-commented.
---

**Author**
Vatiera
Creator of XMC Language & Dev Tools for SA-MP
Discord: coming soon
Website: coming soon


---
License
This project is licensed under the MIT License. You are free to use, modify, and distribute it with attribution.
---
