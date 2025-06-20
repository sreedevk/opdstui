import os, jsony, std/tables, docopt

type Configuration* = object
  initialUrl*: string

proc configPath(args: Table[string, docopt.Value]): string =
  if args.hasKey("path"):
    return joinPath($args["path"])
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

proc generateConfig*(args: Table[string, docopt.Value]) =
  var 
    defaultConfiguration = Configuration(initialUrl: "")
    defaultConfigurationJson = defaultConfiguration.toJson()
    confPath = configPath(args)
    f = open(confPath, fmWrite)

  defer: f.close()
  f.write(defaultConfigurationJson)
