# Material Symbols subset

Self-hosted **7-glyph** Material Symbols Outlined font for sidebar / profile icons.

| File | Purpose |
|---|---|
| `material-symbols-outlined-subset.woff2` | Bundled icon font (~2.6KB) |

## Included glyphs

`account_circle`, `auto_stories`, `calendar_month`, `group`, `help`, `home`, `psychology`

(`icon_names` must stay **alphabetically sorted** when regenerating.)

## Regenerate

```bash
UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
CSS='https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0&icon_names=account_circle,auto_stories,calendar_month,group,help,home,psychology&display=block'
curl -fsSL -A "$UA" "$CSS" -o /tmp/ms-subset.css
# Copy the fonts.gstatic.com url(...) from that CSS, then:
curl -fsSL -A "$UA" '<fonts.gstatic.com url>' -o material-symbols-outlined-subset.woff2
```

Add any new icon name to `icon_names` (sorted), regenerate, and update this list.
