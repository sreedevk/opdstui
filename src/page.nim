import std/xmltree
import link
import std/parseutils

type Page* = ref object of RootObj
  title*: string
  entries*: seq[Link]
  entryPtr*: int
  pageNum*: int
  pagePath*: string
  canPaginate*: bool

proc updateEntries*(e: var Page, content: XmlNode) = 
  e.entries = @[]
  let contentEntries = content.findAll("entry")
  if contentEntries.len() >= 1:
    for entry in contentEntries:
      for clink in entry.findAll("link"):
        if clink.attr("rel") == "subsection":
          let parsedLink = newLink(entry.child("title").innerText, clink.attr("href"), LinkType.Navigation)
          e.entries.add(parsedLink)
        elif clink.attr("rel") == "http://opds-spec.org/acquisition/open-access":
          let parsedLink = newLink(entry.child("title").innerText, clink.attr("href"), LinkType.Media)
          e.entries.add(parsedLink)
        else:
          discard
  else:
    discard

proc checkCanPaginate(content: XmlNode): bool = 
  var totalResults = content.child("totalResults")
  var itemsPerPage = content.child("itemsPerPage")
  if totalResults.isNil:
    return false
  else:
    var 
      tres: int
      ipp: int  

    discard parseInt(itemsPerPage.innerText, ipp)
    discard parseInt(totalResults.innerText, tres)

    return tres > ipp
    
proc newPage*(content: XmlNode, path: string): Page =
  new(result)
  result.title = content.child("title").innerText
  result.entryPtr = 0
  result.pageNum = 1
  result.pagePath = path
  result.updateEntries(content)
  result.canPaginate = checkCanPaginate(content)

