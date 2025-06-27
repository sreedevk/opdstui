import uri

type LinkType* = enum
  Navigation
  Media

type Link* = ref object of RootObj
  title*: string
  url*: string
  linkType*: LinkType

proc newLink*(text: string, url: string, ltype: LinkType): Link =
  new(result)
  result.title = text
  result.url = url
  result.linkType = ltype

proc newLink*(text: string, url: Uri, ltype: LinkType): Link =
  new(result)
  result.title = text
  result.url = $url
  result.linkType = ltype

proc `?`*(e: var Link, params: openArray[(string, string)]): Link =
  return newLink(e.title, parseUri(e.url) ? params, e.linkType)

proc `/`*(e: Link, f: Link): Link =
  return newLink(f.title, (parseUri(e.url) / f.url), f.linkType)
