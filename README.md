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
OPDS TUI Browser v0.1.0
Author: Sreedev Kodichath <sreedev@icloud.com>
OPDS Feed TUI Browser

Usage: opdstui [-h] [-v] [-c=configfile] [-u=opdsurl] [-g]

Required arguments:


Optional arguments:
    -h, --help                          Show this help message and exit.
    -v, --version                       Show version number and exit.
    -c=configfile, --config=configfile  configuration file
    -u=opdsurl, --url=opdsurl           opds url
    -g, --generate-conf                 generate & store configuration
```

## Examples

### Persist the options passed, in a configuration file for reuse
```bash
opdstui -g -u="https://kavita.selfhosted.something/opds/not-accidentally-leaking-my-key-again/"
```

### Launch OPDS TUI using a url other than the configured url
```bash
opdstui -u="https://kavita.selfhosted.something/opds/not-accidentally-leaking-my-key-again/"
```

### Launch OPDS TUI with the url and options in configuration
```bash
opdstui
```
