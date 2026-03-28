# TUI OPDS Browser
## Introduction
This project aims to provide an easy way to navigate OPDS catalogs through a simple tui interface.
Opdstui also enables you to open books served via opds catalogs using a locally installed text editor
like Zathura.

## Dependencies
### Required
- [Python >= v3.12](https://www.python.org/downloads/)

### Optional
- [Zathura](https://pwmt.org/projects/zathura/)

## Configuration
Configuration of opdstui is done using ENV variables.
```
export OPDS_URL="https://kavita.your-server.com/api/opds/0993c2af-f7bc-44d3-9929-138866db7954"
export OPDS_READER="zathura"
```

| ENV var | Description |
|:--|:--|
| OPDS_URL | OPDS Server URL (Required) |
| OPDS_READER | The application that opds the book binary stream. (Optional. defaults to zathura) |

## Install
```
curl -fsSL https://raw.githubusercontent.com/sreedevk/opdstui/main/install.sh | bash
```
