# Quick Stack [quickstack]

[![luacheck](https://github.com/OgelGames/quickstack/workflows/luacheck/badge.svg)](https://github.com/OgelGames/quickstack/actions)
[![License](https://img.shields.io/badge/License-MIT%20and%20CC%20BY--SA%204.0-green.svg)](LICENSE.md)
[![Minetest](https://img.shields.io/badge/Minetest-5.5.0+-blue.svg)](https://www.minetest.net)
[![ContentDB](https://content.minetest.net/packages/OgelGames/quickstack/shields/downloads/)](https://content.minetest.net/packages/OgelGames/quickstack/)

Adds Terraria's "quick stack to nearby chests" feature to Unified Inventory.

![](textures/quickstack_button.png?raw=true)

## Usage

Performing a quick stack is as simple as clicking the button in your inventory. If any items were successfully quick stacked, you will hear a pop sound.

In addition to the quick stack button, another button allows you to configure how the quick stack button works. You can choose to lock inventory slots, lock all tools, enable metadata matching, or show locked slots.

Locking inventory slots functions like Terraria's "favorite" feature, in that any locked slots will not be quick stacked. Locking tools works similarly, preventing any tools from being quick stacked, even if they are not in a locked slot.

## Settings

By default, all nodes with "chest" in their name or description will be automatically detected for quick stacking. To remove wrongly detected nodes, or add other nodes, you can use the following settings:

- `quickstack_exclude_nodes` - A comma separated list of node names to exclude from quick stacking.
- `quickstack_include_nodes` - A comma separated list of node names to include in quick stacking.

## License

License for code: [MIT](LICENSE.md#mit-license)

License for media: [CC BY-SA 4.0](LICENSE.md#cc-by-sa-40-license)

Derivative sources:
- `quickstack_locked.png`: http://www.clker.com/clipart-2687.html
- `quickstack_unlocked.png`: http://www.clker.com/clipart-2981.html
- `quickstack_lock_*.png`: https://www.kenney.nl/assets/game-icons
- `quickstack_settings.png` (gear): https://github.com/minetest/minetest/blob/master/textures/base/pack/gear_icon.png
- `quickstack_pop.ogg`: https://freesound.org/people/MATRIXXX_/sounds/506545

