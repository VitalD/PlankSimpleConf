PlankSimpleConf
===============

Simple configurator for Plank-dock.

First version can just change theme and icon size.

Themes should be placed in /usr/share/plank/themes.

Icon size is limited by interval 32..128 (step 2).

How to build it?
===============
0. Get containt of this repo.
1. Install "valac" (new version prefer)
2. Execute "valac --pkg gtk+-3.0 PlankSimpleConfigurator.vala" in directory with containt

Source code information and style notes
===============
Project include class for working with INI (simple config) files, which can be used separately. (Note! Tested just with plank configuration file).

Source code hasn't any comments, but methods, classes and variables mostly have complex names, which can help to understand what them for. Temperary local variables usually have strange or short name. 

Sorry for desuse of official Vala's style rules.

Road map
==============
1. Add more elements to change configurable parameters of Plank dock (Position, Hiding style or so).
