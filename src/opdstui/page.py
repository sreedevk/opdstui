import os
import requests
import subprocess
import xml.etree.ElementTree as ET
import math

from .entry import Entry
from .nav import Nav
from .bookdetails import BookDetails

from textual.screen import Screen
from textual.widgets import Footer, Header, ListView, Label
from urllib.parse import urlparse, parse_qs, urljoin, urlunparse, urlencode


NAMESPACE = {
    "atom": "http://www.w3.org/2005/Atom",
    "opensearch": "http://a9.com/-/spec/opensearch/1.1/",
}


class Page(Screen):
    BINDINGS = [
        ("q", "pop_or_quit", "Quit"),
        ("p", "paginate_prev", "Previous Page"),
        ("n", "paginate_next", "Next Page"),
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
            self.set_pag_attrs(root)
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

    def action_paginate_prev(self):
        if self.current_page <= 1:
            return

        parseduri = urlparse(self.path)
        params = parse_qs(parseduri.query)
        params["pageNumber"] = self.current_page - 1
        next_path = urlunparse(parseduri._replace(query=urlencode(params, doseq=True)))

        self.app.push_screen(
            Page(self.url, next_path),
        )

    def action_paginate_next(self):
        if self.current_page >= self.page_count:
            return

        parseduri = urlparse(self.path)
        params = parse_qs(parseduri.query)
        params["pageNumber"] = self.current_page + 1
        next_path = urlunparse(parseduri._replace(query=urlencode(params, doseq=True)))

        self.app.push_screen(
            Page(self.url, next_path),
        )

    def set_pag_attrs(self, page_root):
        self.current_page = 1
        self.page_count = 1

        total_results_node = page_root.find(".//opensearch:totalResults", NAMESPACE)
        items_per_page_node = page_root.find(".//opensearch:itemsPerPage", NAMESPACE)
        if total_results_node is None or items_per_page_node is None:
            return

        total_items = int(total_results_node.text[0])
        items_per_page = int(items_per_page_node.text[0])
        page_count = math.ceil(total_items / items_per_page)

        if page_count > 1:
            self_ref_node = page_root.find(".//atom:link[@rel='self']", NAMESPACE)
            current_link = parse_qs(urlparse(self_ref_node.attrib["href"]).query)
            self.current_page = int(current_link["pageNumber"][0])
            self.page_count = page_count

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
        # yield Label(content=repr(self.debug))
        yield Footer()
