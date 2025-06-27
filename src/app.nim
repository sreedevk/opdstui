import session, link, osproc, os
import configuration
import illwill
import illwillWidgets

type AppMode* = enum
  Search
  Browse

type App* = ref object of RootObj
  buffer*: TerminalBuffer
  session*: Session
  tw*: int
  th*: int
  mode*: AppMode
  inputField: string

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
  result.mode = AppMode.Browse
  result.inputField = ""

proc setupDisplayBuffer*(e: var App) =
  var yoffset = 0

  e.buffer.clear()
  e.buffer.setForegroundColor(fgBlack, true)
  e.buffer.drawRect(0, 0, e.tw - 1, e.th - 1)

  e.buffer.setForegroundColor(fgMagenta)
  e.buffer.drawHorizLine(2, e.tw - 3, yoffset + 1, doubleStyle = true)
  e.buffer.write(2, yoffset + 2, "OPDS TUI")
  e.buffer.drawHorizLine(2, e.tw - 3, yoffset + 3, doubleStyle = true)
  e.buffer.write(
    2, yoffset + 4, fgWhite, "Press ", fgYellow, "Enter", fgWhite, " to select an item."
  )
  e.buffer.write(
    2,
    yoffset + 5,
    "Press ",
    fgYellow,
    "ESC",
    fgWhite,
    " or ",
    fgYellow,
    "Q",
    fgWhite,
    " to quit or navigate back to the previous page",
  )
  e.buffer.write(
    2,
    yoffset + 6,
    "Press ",
    fgYellow,
    "N",
    fgWhite,
    " or ",
    fgYellow,
    "P",
    fgWhite,
    " to paginate to the next or previous page.",
  )
  if e.session.pages[^1].canSearch:
    e.buffer.write(2, yoffset + 7, "Press ", fgYellow, "/", fgWhite, " to search")

  e.buffer.drawHorizLine(2, e.tw - 3, yoffset + 8, doubleStyle = true)

proc handleUserInputBrowseMode(e: var App) =
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
  of Key.Slash:
    if cpage.canSearch:
      e.inputField = ""
      e.mode = AppMode.Search
    else:
      discard
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

proc handleUserInputSearchMode(e: var App) =
  var
    key = getKey()
    cpage = e.session.pages[^1]

  case key
  of Key.Escape:
    e.mode = AppMode.Browse
  of Key.None, Key.Slash:
    discard
  of Key.Space:
    e.inputField = e.inputField & " "
  of Key.Enter:
    e.session.performSearch(e.inputField)
    e.mode = AppMode.Browse
  of Key.Backspace:
    var inplen = e.inputField.len()
    if inplen > 0:
      e.inputField = e.inputField[0 ..^ 2]
    else:
      discard
  else:
    if ord(key) in 97 .. 122:
      e.inputField = e.inputField & $key

proc handleUserInput(e: var App) =
  case e.mode
  of AppMode.Browse:
    e.handleUserInputBrowseMode()
  of AppMode.Search:
    e.handleUserInputSearchMode()

proc renderSessionBrowseMode(e: var App) =
  var
    cpage = e.session.pages[^1]
    yoffset = 8

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

# TODO: IMPROVE SEARCH
proc renderSessionSearchMode(e: var App) =
  var
    cpage = e.session.pages[^1]
    yoffset = 8
    new_tb = newTextBox(
      e.inputField,
      3,
      yoffset + 3,
      w = e.tw - 2,
      color = fgBlack,
      bgcolor = bgNone,
      placeholder = "Search",
    )

  e.buffer.write(3, yoffset + 2, fgGreen, "Search:- ")
  new_tb.caretIdx = e.inputField.len()
  e.buffer.render(new_tb)

proc renderSession(e: var App) =
  case e.mode
  of AppMode.Browse:
    e.renderSessionBrowseMode()
  of AppMode.Search:
    e.renderSessionSearchMode()

proc start*(e: var App) =
  while true:
    e.updateWindowVars()
    e.setupDisplayBuffer()
    e.handleUserInput()
    e.renderSession()
    e.buffer.display()
    sleep(20)
