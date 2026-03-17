import os

from textual.app import App
from textual.binding import Binding

from .page import Page


class Application(App):
    BORDER_TITLE = "OPDS TUI"
    OPDS_URL = os.getenv("OPDS_URL")
    BINDINGS = [
        Binding("q", "quit", "quit", show=True),
    ]

    def on_mount(self):
        self.screen.styles.layout = "vertical"
        self.screen.styles.padding = 4
        self.push_screen(Page(self.OPDS_URL, "/"))
