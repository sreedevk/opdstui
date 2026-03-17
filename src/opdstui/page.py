import xml.etree.ElementTree as ET

import requests
from .link import Link

NAMESPACE = {"atom": "http://www.w3.org/2005/Atom"}


class Page:
    def __init__(self, url: str, path: str):
        self.url = url
        self.path = path
        self.links: list[Link] = []
        self.subsections: list[Link] = []

        req = requests.get(self.url + self.path)
        root = ET.fromstring(req.text)

        subsections = root.findall("atom:entry", NAMESPACE)
        links = root.findall("atom:link", NAMESPACE)

        for link in links:
            linkattr = link.attrib

            self.links.append(Link(linkattr['rel'], linkattr['href'], linkattr['rel']))

        for subsection in subsections:
            link = subsection.find("atom:link", NAMESPACE)
            title = subsection.find('atom:title', NAMESPACE).text
            linkattr = link.attrib

            self.subsections.append(Link(title, linkattr['href'], linkattr['rel']))

        print(repr(self.subsections))
