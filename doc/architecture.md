# Euclid's Architecture

Euclid constructs prompts out of discrete [elements](https://en.wikipedia.org/wiki/Euclid%27s_Elements) using the `euclid::elements` function. For example, the default `PROMPT` is defined by

```zsh
setopt prompt_subst
PROMPT='$(euclid::elements "logo" "path")'
```

Note the quotation marks, since we're perform command substitution with the [`prompt_subst`](http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting) option.

An element is a function registered under a specific name by `euclid::element`. For example, the `"path"` element we saw above is defined using

```zsh
euclid::element "path" euclid::elements::path

euclid::elements::path() {
  # ...
}
```

You may have arbitrary logic inside your element, since it's just a function. This becomes important for more complex elements like `"logo"` or any of the git-related ones. However, for our example, `euclid::elements::path` is defined trivially as

```zsh
euclid::elements::path() {
  euclid::fragment "path"
}
```

Conceptually, elements are made up of some number of [fragments](https://en.wikipedia.org/wiki/Papyrus_Oxyrhynchus_29). Here, `"path"` always consists of just one fragment. Each fragment combines some specific [optics](https://en.wikipedia.org/wiki/Euclid%27s_Optics) with its associated [data](https://en.wikipedia.org/wiki/Data_%28Euclid%29).

The `euclid::optics` function controls the color of a fragment. For example, the color of the `"path"` fragment is set using

```zsh
euclid::optics "path" "green"
```

Under the hood, the optics will be wrapped in the [`%F` directive](http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Visual-effects) for later [prompt expansion](http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html).

The `euclid::data` function sets the format string used by the fragment. Under the hood, fragments use the `printf` [builtin](http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html): the format comes from the `euclid::data` and the arguments come from any additional parameters passed to `euclid::fragment`. The output should be suitable for use in prompt expansion.

For example, we want the `"path"` fragment to result in the string `"%~ "` for prompt expansion. But we need to write that as a format string, so we must escape the extra percent sign. Thus, the data for `"path"` is defined as

```zsh
euclid::data "path" "%%~ "
```

Taken all together, the definition of the `"path"` element looks like this:

```zsh
euclid::optics "path" "green"
euclid::data "path" "%%~ "
euclid::element "path" euclid::elements::path

euclid::elements::path() {
  euclid::fragment "path"
}
```

Calling `euclid::elements "path"` would then be equivalent to

```zsh
echo -n "%F{green}"
printf "%%~ "
echo -n "%f"
```

The advantage of exposing these abstractions is that it's easier for the user to
* customize the color & format of existing elements, and
* define their own custom elements, possibly using existing fragments

You can more complex element definitions under the [elements/](../elements) directory.
