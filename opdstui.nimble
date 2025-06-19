# Package

version = "0.1.0"
author = "sreedevk"
description = "tui interface for browsing opds catalogs"
license = "MIT"
srcDir = "src"
bin = @["opdstui"]

# Dependencies

requires "nim >= 2.2.4"
requires "illwill >= 0.4.1"

requires "docopt >= 0.7.1"