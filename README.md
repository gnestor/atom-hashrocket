# Hashrocket: Inline Code Debugger with Markers

New way of easy debugging for **JavaScript, CoffeeScript, Python, Ruby, PHP and Bash** developers.

```bash
apm install hashrocket
```

What is a Marker:

```
#=> {expression}
```

Features:
  - Easiest way of debugging.
  - Watching variables on comments.
  - Helper menus.
  - **JavaScript, CoffeeScript, Python, Ruby, PHP and Bash** support.
  - Unreachable code detection.
  - Extensible. (You can add another language support very easily)
  - Realtime mode.

## Key Bindings
Darwin(Mac)
  - `CMD + ;`: Run current file's Hashrocket.
  - `CMD + :`: Insert Hashrocket Marker.
  - `CMD + \`: Insert Hashrocket Marker and run immediately.
  - `CMD + ALT + ;`: Toggle watching current file's Hashrocket Markers realtime.

Win32 (Windows) and linux
  - `CTRL + ;`: Run current file's Hashrocket.
  - `ALT + ;`: Insert Hashrocket Marker.
  - `CTRL + ALT + ;`: Insert Hashrocket Marker and run immediately.
  - `CTRL + W`: Toggle watching current file's Hashrocket Markers

Watch code Realtime:

![Atom Hashrocket](https://dl.dropboxusercontent.com/u/20947008/webbox/atom/atom-hashrocket.gif)


Use menu support:

![Atom Hashrocket](https://dl.dropboxusercontent.com/u/20947008/webbox/atom/atom-breakline.gif)


### Warning

Don't use "watch" feature in Bash scripts. It may hurt your feelings if you write `#=> rm -rf *` while watching since
it runs all the `#=>` code.

Remember, your code is working itself with this plugin.
