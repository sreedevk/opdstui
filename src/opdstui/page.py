import xml.etree.ElementTree as ET

import os
import requests

from .link import Link
from .nav import Nav
from .debug import Debug

from textual.screen import Screen
from textual.widgets import Footer, Header, ListView
from urllib.parse import urljoin


NAMESPACE = {"atom": "http://www.w3.org/2005/Atom"}


class Page(Screen):
    BINDINGS = [
        ("escape", "app.pop_screen", "Pop screen"),
    ]

    def on_list_view_selected(self, event: ListView.Selected):
        self.app.push_screen(
            Page(self.url, self.subsections[event.index].path),
        )

    def __init__(self, url, path):
        self.url = url
        self.path = path
        self.links: list[Link] = []
        self.subsections: list[Link] = []

        req = requests.get(urljoin(self.url, self.path))
        self.debug = {"url": self.path}

        root = ET.fromstring(req.text)

        subsections = root.findall("atom:entry", NAMESPACE)
        links = root.findall("atom:link", NAMESPACE)

        for subsection in subsections:
            link = subsection.find("atom:link", NAMESPACE)
            title = subsection.find("atom:title", NAMESPACE).text
            linkattr = link.attrib

            self.subsections.append(Link(title, linkattr["href"], linkattr["rel"]))

        for link in links:
            linkattr = link.attrib

            self.links.append(Link(linkattr["rel"], linkattr["href"], linkattr["rel"]))

        super().__init__()

    def compose(self):
        yield Header()
        yield Nav(self.subsections)
        yield Debug(self.debug)
        yield Footer()
