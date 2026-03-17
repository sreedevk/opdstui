import xml.etree.ElementTree as ET

import requests
from .link import Link
from textual.widgets import ListView, ListItem, Label
from textual.binding import Binding

NAMESPACE = {"atom": "http://www.w3.org/2005/Atom"}


class Nav(ListView):
    BINDINGS = [
        Binding("down,j", "cursor_down", "Cursor down", show=True),
        Binding("up,k", "cursor_up", "Cursor up", show=True),
    ]

    DEFAULT_CSS = """
    Nav {
        padding: 2
    }
    """

    def selected_subsection(self) -> Link:
        return self.subsections[self.index]

    def __init__(self, subsections: list[Link]):
        self.subsections = subsections

        list_subsections = [
            ListItem(Label(subsection.text)) for subsection in subsections
        ]

        super().__init__(*list_subsections)
