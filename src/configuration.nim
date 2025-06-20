import os, jsony, std/tables

type Configuration* = object
  initialUrl*: string

proc configPath(args: Table[string, string]): string =
  if args.hasKey("file"):
    return joinPath($args["file"])
  elif existsEnv("XDG_CONFIG_HOME"):
    var configDirectory = joinPath(getEnv("XDG_CONFIG_HOME"), "opdstui")
    createDir(configDirectory)
    return joinPath(configDirectory, "config.json")
  elif existsEnv("HOME"):
    var configDirectory = joinPath(getEnv("HOME"), ".config", "opdstui", "config.json")
    createDir(configDirectory)
    return joinPath(configDirectory, "config.json")
  elif existsEnv("USER"):
    var configDirectory = joinPath("/", "home", getEnv("USER"), ".config", "opdstui", "config.json")
    createDir(configDirectory)
    return joinPath(configDirectory, "config.json")
  else:
    write(stderr, "unable to locate configuration directory")

proc generateConfig*(args: Table[string, string]) =
  var 
    defaultConfiguration = Configuration(initialUrl: args["url"])
    defaultConfigurationJson = defaultConfiguration.toJson()
    confPath = configPath(args)
    f = open(confPath, fmWrite)

  defer: f.close()
  f.write(defaultConfigurationJson)

proc loadConfig*(args: Table[string, string]): Configuration =
  var 
    confpath = configPath(args)
    rawConfig = readFile(confpath)

  result = fromJson(rawConfig, Configuration)
  if args.hasKey("url") and args["url"].len() > 0:
    result.initialUrl = $args["url"]
