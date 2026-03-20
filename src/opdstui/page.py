import os
import requests
import subprocess
import xml.etree.ElementTree as ET

from .entry import Entry
from .nav import Nav

from urllib.parse import urljoin
from textual.screen import Screen
from textual.widgets import Footer, Header, ListView
from textual.widgets import Pretty


NAMESPACE = {"atom": "http://www.w3.org/2005/Atom"}


class Page(Screen):
    BINDINGS = [
        ("q", "app.pop_screen", "Pop screen"),
    ]

    def on_list_view_selected(self, event: ListView.Selected):
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
        entries = root.findall("atom:entry", NAMESPACE)

        for entry in entries:
            self.entries.append(Entry(entry))

        super().__init__()

    def compose(self):
        yield Header()
        yield Nav(self.entries)
        if self.debug is not None:
            yield Pretty("")
        yield Footer()
