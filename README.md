# Train info

Simple app for getting train information from API provided by ŽSR (Railways of Slovak republic). Currently you can search a train by entering its number or get list of all trains and filter them by their type. Maybe in future I will add functionality for watching and reporting info about chosen trains via push notifications. App is written in QML and JavaScript, Python is used for handling calls to the API and sending data to the app.

## Launching the app
If you don't have Clickable installed, install it via this [link](https://clickable-ut.dev/en/latest/install.html)

Clone the repository: `https://github.com/Jakuko99/traininfo.git`

For launch in desktop mode use: `clickable desktop` or for uploading the app to your phone just run: `clickable`

App has been developed for Xenial (16.04), but it should work on Focal (20.04) as well (untested). Works fine on Xiaomi Redmi Note 9 Pro (OTA-24), on other phones there could be possibly problem with element scaling. For now I'm not going to add this app to the OpenStore because of app icon copyright (will need to change it if I decide to publish the app) and it is just a hobby project for me. If you want to try it you can always find latest version of click package in releases.

## License

Copyright (C) 2023  Jakub Krško

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License version 3, as published
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranties of MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
