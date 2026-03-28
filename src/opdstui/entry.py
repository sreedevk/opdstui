import xml.etree.ElementTree as ET

NAMESPACE = {"atom": "http://www.w3.org/2005/Atom"}


class Entry:
    def __init__(self, entry: ET, root: ET):
        title_node = entry.find("atom:title", NAMESPACE)
        self.text = title_node.text if title_node is not None else None
        self.rel = "unknown"

        # This means the entry is a subsection nav entry
        if (link := entry.find("atom:link[@rel='subsection']", NAMESPACE)) is not None:
            self.rel = "subsection"
            self.path = link.attrib["href"]

        # This means the entry is an asset download entry
        elif (
            link := entry.find(
                ".//atom:link[@rel='http://opds-spec.org/acquisition/open-access']",
                NAMESPACE,
            )
        ) is not None:
            author = root.find("atom:author", NAMESPACE)
            self.rel = "ebook"
            self.path = link.attrib["href"]
            self.details = {}
            if author is not None:
                self.details = {
                    "author": {
                        "name": author.find("atom:name", NAMESPACE).text,
                        "uri": author.find("atom:uri", NAMESPACE).text,
                    },
                }
