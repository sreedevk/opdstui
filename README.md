# TUI OPDS Browser
## Introduction
I wanted a way to browser my E-Book library hosted on [kavita](https://www.kavitareader.com/) via a TUI interface and
read the books using [zathura](https://pwmt.org/projects/zathura/), thus eliminating the need to interact with the kavita web interface. 
I was unable to find a tool that quite did this, so I decided to write one myself.

## Pre Requisites
1. [zathura](https://pwmt.org/projects/zathura/)

## Caveats
I consider this tool feature complete for my own use and any development would just be slight improvements to the tool.
But if things don't work as expected for you, feel free to open an issue, I'll try and fix / improve things. As always, pull requests are welcome, but please open an issue before you start working.

## TODO
1. Graceful exit after zathura process has been kicked off

## Usage

```
opdstui - Tui Interface to Browser OPDS Catalogs

Usage:
  opdstui open <url>
  opdstui configure

Options:
  -h --help                   Show this screen  
  --version                   Show version
  --config=<path>             Load json config from path [default: "$XDG_CONFIG_DIR/opdstui/config.json"]
```
