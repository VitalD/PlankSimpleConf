PlankSimpleConf
===============

Simple configurator for Plank-dock.

First version can just change theme and icon size.

Themes should be placed in /usr/share/plank/themes.

Icon size is limited by interval 32..128.

How to build it?
===============
0. Get containt of this repo.
1. Install "valac" (new version prefer)
2. Install dev-package of plank (for deb-based distros "libplank-dev" pachage)
3. Install dev-package of libbamf3 (for deb-based distros "libbamf3-dev" package)
4. Execute "valac --pkg gtk+-3.0 --pkg plank PlankSimpleConfigurator.vala" in directory with containt

Source code information and style notes
===============

Source code hasn't any comments, but methods, classes and variables mostly have complex names, which can help to understand what them for. Temperary local variables usually have strange or short name. 

Sorry for desuse of official Vala's style rules.

Road map
==============
1. Add more elements to change configurable parameters of Plank dock (Position, Hiding style or so).
