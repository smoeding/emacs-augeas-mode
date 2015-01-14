# Emacs major mode for Augeas

This is a small hack to provide an Emacs major mode to write [Augeas](http://augeas.net/) code. I'm using this mode to write my own Augeas lenses to be used in Puppet.

The mode is still at an early stage.

## Features

Currently the following features are available:

- Font lock for Augeas code

## Installation

Put the file `augeas-mode.el` somewhere in your `load-path`. Also add the following code to your init file (e.g. `~/.emacs.d/init.el`):

```elisp
(autoload 'augeas-mode "augeas-mode" "Major mode for editing augeas files." t)

(add-to-list 'auto-mode-alist '("\\.aug\\'" . augeas-mode))
```

This will switch to `augeas-mode` for Augeas files.

## License

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
