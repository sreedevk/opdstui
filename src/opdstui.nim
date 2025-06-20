import configuration
import app
import docopt
import std/tables

const doc: string = staticRead("../doc/readme.txt")

proc main() =
  var args: Table[string, docopt.Value] = docopt(doc, version = "opdstui 0.1.1")

  if args["open"]:
    var
      conf = Configuration(initialUrl: $args["<url>"])
      app = newApp(conf)
    app.start()
  elif args["configure"]:
    generateConfig(args)
    
main()
