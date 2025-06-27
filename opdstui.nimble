# Package

version = "0.1.1"
author = "sreedevk"
description = "tui interface for browsing opds catalogs"
license = "MIT"
srcDir = "src"
bin = @["opdstui"]

# Tasks

task dev, "compile in dev mode":
  exec "nim c -d:ssl --threads:on --out:bin/opdstui_dev src/opdstui.nim"

task prod, "compile in release mode":
  exec "nim c -d:release --opt:speed -d:ssl --threads:on --out:bin/opdstui src/opdstui.nim"

# Dependencies

requires "nim >= 2.2.4"
requires "illwill >= 0.4.1"
requires "jsony >= 1.1.5"
requires "clapfn >= 1.0.1"
requires "https://github.com/enthus1ast/illwillWidgets"
