from .page import Page


class Application:
    def __init__(self, url: str):
        self.url = url
        self.stack: list[Page] = [Page(url, "/")]
