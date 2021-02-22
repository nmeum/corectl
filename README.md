# corectl

CHICKEN egg for controlling LEDs on the [project 0001][project 0001] keyboard.

## Installation

Requires [libusb-1.0][libusb website] to be installed. Afterwards just run:

	$ chicken-install

This should install both the `corectl` CHICKEN egg and the `corectl`
command line tool.

## Usage

The command-line tool is inspired by the proprietary
`CoreController.exe` and allows you to turn on/off or restore the
original state of all six LEDs. Example usage:

	$ corectl LED0:on LED2:off LED5:restore

The CHICKEN egg can simply be imported from `csi(1)` and can be used to
conveniently program the LEDs. As an example, take a look at the LED
pattern generator in `contrib/led-pattern.scm`.

## License

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along
with this program. If not, see <http://www.gnu.org/licenses/>.

[project 0001]: https://core-mechanics.com/produkt/project-0001/
[libusb website]: https://libusb.info/
