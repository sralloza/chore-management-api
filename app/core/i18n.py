from pathlib import Path

import i18n

DEFAULT_LANG = "en"


def load_translations():
    translations_path = Path(__file__).parent.parent / "translations"
    i18n.load_path.append(translations_path.as_posix())


load_translations()
