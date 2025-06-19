import configuration
import app
import docopt

const doc: string = staticRead("../doc/readme.txt")

proc main() =
  var args = docopt(doc, version = "opdstui 0.1.1")

  if args["open"]:
    var
      conf = newConfiguration(initialUrl = $args["<url>"])
      app = newApp(conf)
    app.start()
  elif args["configure"]:
    discard

main()
