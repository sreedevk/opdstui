import std/xmltree
import link

type Page* = ref object of RootObj
  title*: string
  entries*: seq[Link]
  entryPtr*: int

proc newPage*(content: XmlNode): Page =
  new(result)
  result.title = content.child("title").innerText
  result.entries = @[]
  result.entryPtr = 0
  for entry in content.findAll("entry"):
    for clink in entry.findAll("link"):
      if clink.attr("rel") == "subsection":
        let parsedLink = newLink(entry.child("title").innerText, clink.attr("href"), LinkType.Navigation)
        result.entries.add(parsedLink)
      elif clink.attr("rel") == "http://opds-spec.org/acquisition/open-access":
        let parsedLink = newLink(entry.child("title").innerText, clink.attr("href"), LinkType.Media)
        result.entries.add(parsedLink)
      else:
        discard
