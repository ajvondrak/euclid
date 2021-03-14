# Euclid

![logo](logo.svg)

A minimalist zsh prompt inspired by [geometry](https://github.com/geometry-zsh/geometry).

**Features**
* powered by [gitstatus](https://github.com/romkatv/gitstatus)
* uses [nerd font](https://www.nerdfonts.com) icons
* flexible api for easy extension & customization
* information dense prompts through careful use of colors & icons

## Installation

For icon support, install one of the [Nerd Fonts](https://www.nerdfonts.com/). You could also just customize the icons if you prefer something friendlier to your font.

Manually install by cloning this repo with its submodules and sourcing the plugin:

```console
$ git clone --recurse-submodules https://github.com/ajvondrak/euclid
$ source euclid/euclid.zsh
```

You could also use your [plugin manager of choice](https://gist.github.com/olets/06009589d7887617e061481e22cf5a4a).

## Documentation

* [Settings](doc/settings.md)
* [Architecture](doc/architecture.md)
