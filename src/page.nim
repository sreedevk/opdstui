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
  canSearch*: bool
  searchSpecPath*: Link
  searchPath*: Link

proc updateEntries*(e: var Page, content: XmlNode) =
  e.entries = @[]
  let contentEntries = content.findAll("entry")
  let navEntries = content.findAll("link")
  for navlink in navEntries:
    if navlink.attr("rel") == "search":
      e.canSearch = true
      e.searchSpecPath = newLink("search", navlink.attr("href"), LinkType.Navigation)
    else:
      discard

  if contentEntries.len() >= 1:
    for entry in contentEntries:
      for clink in entry.findAll("link"):
        case clink.attr("rel")
        of "subsection":
          e.entries.add(
            newLink(
              entry.child("title").innerText, clink.attr("href"), LinkType.Navigation
            )
          )
        of "http://opds-spec.org/acquisition/open-access":
          e.entries.add(
            newLink(entry.child("title").innerText, clink.attr("href"), LinkType.Media)
          )
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
  result.canPaginate = checkCanPaginate(content)
  result.updateEntries(content)
