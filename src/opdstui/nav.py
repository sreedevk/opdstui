from textual.binding import Binding
from textual.widgets import ListView, ListItem, Label

from .entry import Entry

NAMESPACE = {"atom": "http://www.w3.org/2005/Atom"}


class Nav(ListView):
    BINDINGS = [
        Binding("down,j", "cursor_down", "Cursor down", show=True),
        Binding("up,k", "cursor_up", "Cursor up", show=True),
    ]

    DEFAULT_CSS = """
        Nav { padding: 2 }
    """

    def __init__(self, entries: list[Entry]):
        if len(entries) < 1:
            super().__init__(*[ListItem(Label("No Entries"))])
        else:
            super().__init__(*[ListItem(Label(entry.text)) for entry in entries])
