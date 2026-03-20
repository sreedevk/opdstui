import os
import requests
import subprocess
import xml.etree.ElementTree as ET

from .entry import Entry
from .nav import Nav
from .bookdetails import BookDetails

from urllib.parse import urljoin
from textual.screen import Screen
from textual.widgets import Footer, Header, ListView, Label


NAMESPACE = {"atom": "http://www.w3.org/2005/Atom"}


class Page(Screen):
    BINDINGS = [
        ("q", "pop_or_quit", "Quit"),
    ]

    def action_pop_or_quit(self) -> None:
        if len(self.app.screen_stack) > 2:
            self.app.pop_screen()
        else:
            self.app.exit()

    def on_list_view_selected(self, event: ListView.Selected):
        if len(self.entries) < 1:
            return

        selected_link = self.entries[event.index]
        if selected_link.rel == "subsection":
            self.app.push_screen(Page(self.url, selected_link.path))
        elif selected_link.rel == "ebook":
            self.launch_reader(urljoin(self.url, selected_link.path))

    def launch_reader(self, url: str):
        response = requests.get(url, stream=True)
        response.raise_for_status()

        proc = subprocess.Popen(
            [os.getenv("OPDS_READER", default="zathura"), "-"],
            stdin=subprocess.PIPE,
        )
        for chunk in response.iter_content(chunk_size=8192):
            proc.stdin.write(chunk)
        proc.stdin.close()
        proc.wait()

    def __init__(self, url, path):
        self.url = url
        self.path = path
        self.entries: list[Entry] = []
        self.debug = None

        req = requests.get(urljoin(self.url, self.path))

        root = ET.fromstring(req.text)
        if self.is_listing(root):
            self.pagetype = "listing"
            entries = root.findall(".//atom:entry", NAMESPACE)
            for entry in entries:
                self.entries.append(Entry(entry))
        else:
            entry = root.find(".//atom:entry", NAMESPACE)
            self.pagetype = "book"
            if entry:
                self.details = Entry(entry)
            else:
                self.details = {}

        super().__init__()

    def is_listing(self, node) -> bool:
        entries = node.findall(".//atom:entry", NAMESPACE)

        if len(entries) < 2:
            entry = node.find(".//atom:entry", NAMESPACE)
            if entry is None:
                return True

            booknode = entry.find(
                "atom:link[@rel='http://opds-spec.org/acquisition/open-access']",
                NAMESPACE,
            )
            return booknode is None
        return True

    def compose(self):
        yield Header()
        if self.pagetype == "listing":
            yield Nav(self.entries)
        else:
            yield BookDetails(self.details)
        yield Label(content=repr(self.debug))
        yield Footer()
