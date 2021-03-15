# Euclid's Settings

Euclid's elements can be customized using two main functions:
* `euclid::optics` to control colors
* `euclid::data` to control format strings

You pass two arguments into each function: the name and value of the setting. For example, the [path](../elements/path) element could be colored red by saying

```zsh
euclid::optics "path" "red"
```

This document describes the possible settings for all of the elements that come built into Euclid. For more details on how these functions fit together, read up on [Euclid's architecture](architecture.md). However, you can still just plug in the values given below without needing to know the design.

## `PROMPT` and `RPROMPT`

The default elements that make up the prompts are defined with

```zsh
setopt prompt_subst
PROMPT='$(euclid::elements "logo" "path")'
RPROMPT='$(euclid::elements "git:ref" "git:tracking" "git:index" "git:stash")'
```

You can customize these prompts by following the same basic structure. Calling `euclid::elements` lets you arrange any given elements in any given order, each separated by a space. Just make sure to use a single-quoted string, then let [`prompt_subst`](http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting) expand the `euclid::elements` expression whenever the prompt gets reset.

The built-in elements available to you are all documented below.

## `logo`

TODO

## `path`

TODO

## `git:ref`

TODO

## `git:tracking`

TODO

## `git:index`

TODO

## `git:stash`

TODO