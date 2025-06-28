import configuration
import app
import clapfn, tables, strutils

proc parseArgs(): Table[string, string] = 
  var parser = ArgumentParser(
    programName: "opdstui",
    fullName: "OPDS TUI Browser",
    description: "OPDS Feed TUI Browser",
    version: "0.1.4",
    author: "Sreedev K <sreedev@icloud.com>")

  parser.addSwitchArgument(shortName="-g", longName="--generate-conf", help="generate & store configuration", default = false)
  parser.addStoreArgument(shortName="-u", longName="--url", usageInput="opdsurl", help="opds url", default = "")
  parser.addStoreArgument(shortName="-c", longName="--config", usageInput="configfile", help="configuration file", default="")
  return parser.parse()

proc main() =
  var args = parseArgs()
  if parseBool(args["generateconf"]):
    generateConfig(args)
  else:
    var
      conf = loadConfig(args)
      app = newApp(conf)

    app.start()
    
    
main()
