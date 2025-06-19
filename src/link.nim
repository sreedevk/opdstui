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
