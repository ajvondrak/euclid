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

### Description

This icon indicates the left prompt and changes colors to convey different information. By default, it's not colored (it's just the same as normal foreground text). If the last command exited with an error, it will be highlighted red. If you go into [`vicmd`](http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Keymaps) mode, it will toggle to orange.

### Optics

| Setting        | Default | Notes                                             |
|----------------|---------|---------------------------------------------------|
| `logo:ok`      | -       | Normal text; indicates last exit status was zero  |
| `logo:error`   | `"red"` | Indicates last exit status was non-zero           |
| `logo:vicmd`   | `"214"` | Orange; indicates vi mode                         |

### Data

| Setting        | Default    | Notes                                          |
|----------------|------------|------------------------------------------------|
| `logo`         | `"\ufa62"` | Sets default logo for all three of the below   |
| `logo:ok`      | -          | Logo when the last exit status was zero        |
| `logo:error`   | -          | Logo when the last exit status was non-zero    |
| `logo:vicmd`   | -          | Logo when you're in vi mode                    |

## `path`

### Description

The current working directory with `$HOME` replaced by a tilde, `~`. The path is followed by a space, leaving a gap between it and your cursor in the default left prompt.

### Optics

| Setting        | Default   | Notes                                           |
|----------------|-----------|-------------------------------------------------|
| `path`         | `"green"` | -                                               |

### Data

| Setting        | Default  | Notes                                            |
|----------------|----------|--------------------------------------------------|
| `path`         | `"%%~ "` | `%` must be `printf`-escaped; hard-coded space   |

## `git:ref`

### Description

When you're in a git directory, this element will display the symbolic reference for `HEAD`. If it's a tagged commit, the tag name will be shown. If `HEAD` is detached, it will show up as an abbreviated commit hash. 99% of the time, though, it'll just be the name of the branch you're currently on.

### Optics

| Setting          | Default | Notes                                           |
|------------------|---------|-------------------------------------------------|
| `git:ref`        | `"13"`  | Magenta; sets default for all the below         |
| `git:ref:tag`    | -       | Specific color for tags                         |
| `git:ref:branch` | -       | Specific color for branches                     |
| `git:ref:commit` | -       | Specific color for commits                      |

### Data

| Setting          | Default       | Notes                                     |
|------------------|---------------|-------------------------------------------|
| `git:ref:tag`    | `"\uf412 %s"` | A tag icon with the tag's name            |
| `git:ref:branch` | `"\uf418 %s"` | A branch icon with the branch's name      |
| `git:ref:commit` | `"\uf417 %s"` | A commit icon with the commit's hash      |

## `git:tracking`

### Description

If your local branch is tracking a remote branch, this element will tell you the relative difference between their histories. This falls into four possible states:
* even - local branch has all the same commits as the remote (neither ahead nor behind)
* ahead - local branch has more commits than the remote; you can `git push`
* behind - remote branch has more commits than the local; you can `git pull`
* diverged - each branch has some commits that the other one doesn't (simultaneously ahead and behind)

### Optics

| Setting                 | Default | Notes                                    |
|-------------------------|---------|------------------------------------------|
| `git:tracking`          | `"214"` | Orange; sets default for all the below   |
| `git:tracking:even`     | -       | Specific color for even tracking         |
| `git:tracking:ahead`    | -       | Specific color for ahead tracking        |
| `git:tracking:behind`   | -       | Specific color for behind tracking       |
| `git:tracking:diverged` | -       | Specific color for diverged tracking     |

### Data

| Setting                 | Default    | Notes                                 |
|-------------------------|------------|---------------------------------------|
| `git:tracking:even`     | `""`       | No indicator shown for even branches  |
| `git:tracking:ahead`    | `"\uf44d"` | A heavy plus sign                     |
| `git:tracking:behind`   | `"\uf48b"` | A heavy minus sign                    |
| `git:tracking:diverged` | `"\uf467"` | A heavy x mark                        |

**N.B.** Although none of the default format strings use these, they are always given two `printf` arguments:
1. the number of commits ahead
2. the number of commits behind

For example, you could set

```zsh
euclid::data "git:tracking:ahead"    "+%d"       # +10 (ignores behind)
euclid::data "git:tracking:behind"   "%0.0s-%d"  # -20 (ignores ahead)
euclid::data "git:tracking:diverged" "+%d|-%d"   # +10|-20
```

## `git:index`

TODO

## `git:stash`

TODO
