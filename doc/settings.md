# Euclid's Settings

Euclid's built-in elements can be customized primarily using the functions
* `euclid::optics` to control colors
* `euclid::data` to control format strings

For more detail on how these work, read about [Euclid's architecture](architecture.md).

## `PROMPT` and `RPROMPT`

The default elements that make up the prompts are defined with

```zsh
setopt prompt_subst
PROMPT='$(euclid::elements "logo" "path")'
RPROMPT='$(euclid::elements "git:ref" "git:tracking" "git:index" "git:stash")'
```

You may customize these defaults by following the same basic approach. Calling `euclid::elements` lets you arrange any given elements in any given order, each separated by a space. Just make sure to use a single-quoted string, then let [`prompt_subst`](http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting) expand the `euclid::elements` expression whenever the prompt gets reset.

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
