from textual.widgets import Markdown

from .utils import dig

NAMESPACE = {"atom": "http://www.w3.org/2005/Atom"}


class BookDetails(Markdown):
    BINDINGS = []

    DEFAULT_CSS = """
        Nav { padding: 2 }
    """

    def __init__(self, book):
        self.book = book
        super().__init__(self.content())

    def content(self):
        return f"""
        ## {repr(dig(self.book, "text"))}
        ## Author: {repr(dig(self.book, "details", "author", "name"))}
        """
