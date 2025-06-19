import page
import std/uri
import std/httpclient
import std/xmlparser
import std/options

type Session* = ref object of RootObj
  opdsUrl*: Uri
  pages*: seq[Page]

proc generateBaseUrl(r: Uri): Uri =
  return parseUri(r.scheme & "://" & r.hostname & ":" & r.port)

proc navigateTo*(e: var Session, path: string) =
  var client = newHttpClient()
  defer:
    client.close()
  let content = client.getContent(e.opdsUrl / path)
  let parsedContent = parseXml(content)

  e.pages.add(newPage(parsedContent))

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

