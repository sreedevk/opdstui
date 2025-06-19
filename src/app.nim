import session, link, osproc, os
import configuration
import illwill

type App* = ref object of RootObj
  buffer*: TerminalBuffer
  session*: Session
  tw*: int
  th*: int

proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

proc initProc() =
  illwillInit(fullscreen = true)
  setControlCHook(exitProc)
  hideCursor()

proc newApp*(config: Configuration): App =
  var
    tw: int = terminalWidth()
    th: int = terminalHeight()

  initProc()
  new(result)
  result.buffer = newTerminalBuffer(tw, th)
  result.session = newSession(config.initialUrl)
  result.tw = tw
  result.th = th

proc setupDisplayBuffer*(e: var App) =
  var yoffset = 0

  e.buffer.clear()
  e.buffer.setForegroundColor(fgBlack, true)
  e.buffer.drawRect(0, 0, e.tw - 1, e.th - 1)

  e.buffer.setForegroundColor(fgMagenta)
  e.buffer.drawHorizLine(2, e.tw - 3, yoffset + 1, doubleStyle = true)
  e.buffer.write(2, yoffset + 2, "OPDS TUI")
  e.buffer.drawHorizLine(2, e.tw - 3, yoffset + 3, doubleStyle = true)
  e.buffer.write(2, yoffset + 4, fgWhite, "Press ", fgYellow, "Enter", fgWhite, " to select an item.")
  e.buffer.write(2, yoffset + 5, "Press ", fgYellow, "ESC", fgWhite, " or ", fgYellow, "Q", fgWhite, " to quit or navigate back to the previous page")
  e.buffer.write(2, yoffset + 6, "Press ", fgYellow, "N", fgWhite, " or ", fgYellow, "P", fgWhite, " to paginate to the next or previous page.")
  e.buffer.drawHorizLine(2, e.tw - 3, yoffset + 7, doubleStyle = true)

proc handleUserInput(e: var App) =
  var
    key = getKey()
    cpage = e.session.pages[^1]

  case key
  of Key.Escape, Key.Q:
    if len(e.session.pages) > 1:
      e.session.navigateBack()
    else:
      exitProc()
  of Key.Down, Key.J:
    if cpage.entryPtr < len(cpage.entries) - 1:
      cpage.entryPtr += 1
    else:
      cpage.entryPtr = 0
  of Key.ShiftG:
    cpage.entryPtr = len(cpage.entries) - 1
  of Key.G:
    cpage.entryPtr = 0
  of Key.N:
    e.session.nextPage()
  of Key.P:
    e.session.prevPage()
  of Key.Up, Key.K:
    if cpage.entryPtr > 0:
      cpage.entryPtr -= 1
    else:
      cpage.entryPtr = len(cpage.entries) - 1
  of Key.Enter:
    let centry = cpage.entries[cpage.entryPtr]
    case centry.linkType
    of LinkType.Navigation:
      e.session.navigateTo(centry.url)
    of LinkType.Media:
      let content = e.session.loadFile(centry.url)
      let zathproc = "zathura --fork - --"
      discard execCmdEx(zathproc, input = content)
      exitProc()
  else:
    discard

proc renderSession(e: var App) =
  var
    cpage = e.session.pages[^1]
    yoffset = 7

  e.buffer.write(
    2, yoffset + 1, resetStyle, "Title: ", fgGreen, cpage.title, resetStyle
  )
  e.buffer.drawHorizLine(2, e.tw - 3, yoffset + 2, doubleStyle = true)
  for (index, entry) in cpage.entries.pairs:
    if cpage.entryPtr == index:
      e.buffer.write(2, yoffset + 3 + index, bgWhite, fgBlue, entry.title, resetStyle)
    else:
      e.buffer.write(2, yoffset + 3 + index, fgBlue, entry.title, resetStyle)

proc updateWindowVars(e: var App) =
  e.th = terminalHeight()
  e.tw = terminalWidth()

proc start*(e: var App) =
  while true:
    e.updateWindowVars()
    e.setupDisplayBuffer()
    e.handleUserInput()
    e.renderSession()
    e.buffer.display()
    sleep(20)
