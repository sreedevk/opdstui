import page, link
import std/uri
import std/httpclient
import std/xmlparser
import std/xmltree
import std/options

type Session* = ref object of RootObj
  opdsUrl*: Uri
  pages*: seq[Page]

proc generateBaseUrl(r: Uri): Uri =
  return parseUri(r.scheme & "://" & r.hostname & ":" & r.port)

proc loadContent(
    e: var Session, path: string, query: openArray[(string, string)] = []
): XmlNode =
  var client = newHttpClient()
  defer:
    client.close()
  let content = client.getContent(e.opdsUrl / path ? query)
  return parseXml(content)

proc pageNav(e: var Session, backward: bool) =
  var
    cpage = e.pages[^1]
    newPageNum: int

  if cpage.canPaginate:
    if backward and cpage.pageNum > 0:
      newPageNum = cpage.pageNum - 1
    else:
      newPageNum = cpage.pageNum + 1

    let parsedContent = e.loadContent(cpage.pagePath, {"pageNumber": $newPageNum})

    if parsedContent.findAll("entry").len() > 1:
      cpage.pageNum = newPageNum
      cpage.updateEntries(parsedContent)

proc nextPage*(e: var Session) =
  pageNav(e, backward = false)

proc prevPage*(e: var Session) =
  pageNav(e, backward = true)

proc navigateTo*(e: var Session, path: string) =
  e.pages.add(newPage(loadContent(e, path), path))

proc navigateBack*(e: var Session) =
  if len(e.pages) > 0:
    discard pop(e.pages)

proc newSession*(url: string): Session =
  var fullUrl = parseUri(url)
  new(result)
  result.opdsUrl = generateBaseUrl(fullUrl)
  result.pages = @[]
  result.navigateTo(fullUrl.path)

proc loadFile*(e: var Session, url: string): string =
  var client = newHttpClient()
  defer:
    client.close()
  return client.getContent(e.opdsUrl / url)

proc getSearchPath(e: var Session, searchSpecPath: Link, curr_page: var Page): Link =
  var client = newHttpClient()
  defer:
    client.close()

  var searchSpec = parseXml(client.getContent(e.opdsUrl / searchSpecPath.url))
  for link in searchSpec.findAll("Url"):
    if link.attr("rel") == "results":
      return newLink("search", parseUri(link.attr("template")), LinkType.Navigation)


proc performSearch*(e: var Session, search_term: string) =
  var curr_page = e.pages[^1]
  if not curr_page.canSearch or isNil curr_page.searchSpecPath:
    return

  if isNil curr_page.searchPath:
    curr_page.searchPath = e.getSearchPath(curr_page.searchSpecPath, curr_page)

  var navlink = curr_page.searchPath ? {"query": search_term}
  e.navigateTo(navlink.url)
