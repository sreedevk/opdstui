import os

from opdstui.application import Application


def main():
    Application(os.getenv("OPDS_URL"))


if __name__ == "__main__":
    main()
