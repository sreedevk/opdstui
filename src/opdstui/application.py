import os

from textual.app import App
from textual.binding import Binding
from urllib.parse import urlparse

from .page import Page


class Application(App):
    BORDER_TITLE = "OPDS TUI"
    BINDINGS = [
        Binding("q", "quit", "quit", show=True),
    ]

    def on_mount(self):
        url = urlparse(os.getenv("OPDS_URL"))
        self.screen.styles.layout = "vertical"
        self.screen.styles.padding = 4
        self.push_screen(Page(f"{url.scheme}://{url.netloc}", url.path))
