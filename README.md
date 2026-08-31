# chaochunhsu.github.io

Personal site — Hugo, with a fork of the [Cupper](https://github.com/ThePacielloGroup/cupper)
theme in `themes/cupper/` reworked for reading.

## Writing

Posts live in `content/blog/`. Front matter:

```toml
+++
title = "Post title"
subtitle = "One or two sentences shown under the title."
description = "One line, used on the blog index and in link previews."
date = 2026-01-31
toc = true
tags = ["retrieval", "llm"]
+++
```

Use `##` for sections and `###` for sub-sections — the contents rail is built
from those. Images become numbered figures automatically:

```markdown
![Alt text describing the image.](/images/thing.png "Caption shown under the figure.")
```

Append `?wide` to the path to let a figure break out past the text column:

```markdown
![Alt text.](/images/wide-diagram.png?wide "Caption.")
```

## Layouts

- `layouts/_default/baseof.html` — identity sidebar. Home, Publications, tags.
- `layouts/blog/baseof.html` — slim top bar, for the full-width reading view.

## Running it

```bash
hugo server
```

Build and publish (writes to `docs/`, then mirrors to the sibling
`ChaoChunHsu.github.io` repo):

```bash
./publish.sh "commit message"
```
