from textual.widgets import Pretty


class Debug(Pretty):
    def __init__(self, data: str):
        self.data = data
        super().__init__(data)
