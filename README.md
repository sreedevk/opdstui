# TUI OPDS Browser
## Introduction
I wanted a way to browse my E-Book library hosted on self-hosted instance of [kavita](https://www.kavitareader.com/) via a TUI interface and
read the books using [zathura](https://pwmt.org/projects/zathura/), thus eliminating the need to download books from kavita web interface before being able to read them
using zathura. I couldn't find a tool that offered a TUI interface to browser OPDS catalogs, so i decided to write one myself.

This project does not aim to implement the whole [OPDS specification](https://opds.io/).

## Sources
This project is hosted on
- [Github](https://github.com/sreedevk/opdstui) - [sreedevk/opdstui](https://github.com/sreedevk/opdstui)
- [Radicle](https://radicle.xyz/) - `rad:z4QBXcbUuZuJKkN57ysdWbr5iGGZK`

## Pre Requisites
#### Runtime Dependencies
1. [zathura](https://pwmt.org/projects/zathura/)
2. [An OPDS Source](https://opds.io/)

#### Build Dependencies
1. [Nim Compiler](https://nim-lang.org/)
2. [GNU Make](https://www.gnu.org/software/make/)

## Caveats
I consider this tool feature complete for my own use and any development would just be small improvements to the tool.
But if things don't work as expected for you, feel free to open an issue, I'll try and fix / improve things.
Please refer to the [TODO](#todo) section on this page to make sure you're not reporting already known issues.
As always, pull requests are welcome, but please open an issue before you start working.

## Installation
### Build From Source
```bash
# clone the repository from radicle
rad clone rad:z4QBXcbUuZuJKkN57ysdWbr5iGGZK

# or clone the repository from github
git clone https://github.com/sreedev/opdstui

# cd into opdstui directory
cd opdstui

# run make to ensure that you're able to build the tool first
make 

# copy the binary to /usr/local/bin
sudo make install
```

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

## TODO
1. \[BUG\] Graceful exit after zathura process has been kicked off
2. \[BUG\] List Overflows the UI boundary
3. \[IMPROVE\] Write Unit Tests
3. \[FEAT\] Add a Search Filter
