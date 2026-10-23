"""Prefix lookup in a local EIJIRO dictionary."""

import logging
from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path

from albert import (
    Action,
    GeneratorQueryHandler,
    PluginInstance,
    StandardItem,
    setClipboardText,
)

# Albert's loader does not expose plugins as normal Python packages.
_dictionary_spec = spec_from_file_location(
    "_eijiro_dictionary", Path(__file__).with_name("dictionary.py")
)
_dictionary_module = module_from_spec(_dictionary_spec)
_dictionary_spec.loader.exec_module(_dictionary_module)
Dictionary = _dictionary_module.Dictionary


md_iid = "5.0"
md_version = "1.0"
md_name = "EIJIRO"
md_description = "Prefix lookup in a local EIJIRO text dictionary"
md_license = "MIT"
md_url = "https://fuwa.dev"
md_authors = ["fuwa"]

DEFAULT_DICTIONARY = "~/Documents/data/EIJIRO-1446.TXT"


class Plugin(PluginInstance, GeneratorQueryHandler):
    def __init__(self):
        PluginInstance.__init__(self)
        GeneratorQueryHandler.__init__(self)
        self._dictionary_path = (
            self.readConfig("dictionary_path", str) or DEFAULT_DICTIONARY
        )
        self._dictionary = Dictionary(self._dictionary_path, self.cacheLocation())

    @property
    def dictionary_path(self):
        return self._dictionary_path

    @dictionary_path.setter
    def dictionary_path(self, value):
        self._dictionary_path = value.strip() or DEFAULT_DICTIONARY
        self.writeConfig("dictionary_path", self._dictionary_path)
        self._dictionary = Dictionary(self._dictionary_path, self.cacheLocation())

    def configWidget(self):
        return [
            {
                "type": "lineedit",
                "label": "Dictionary TXT (Shift_JIS)",
                "property": "dictionary_path",
            },
            {
                "type": "label",
                "text": "初回検索時に索引を作成します。辞書更新後は自動で再作成します。",
            },
        ]

    def defaultTrigger(self):
        return "ej "

    def synopsis(self, query):
        return "<英語の前方一致検索>"

    def items(self, context):
        if not context.query.strip() or not context.isValid:
            return
        try:
            entries = self._dictionary.lookup(context.query)
        except Exception as error:
            logging.warning("EIJIRO: %s", error)
            if context.isValid:
                yield [
                    StandardItem(
                        id="eijiro-error",
                        text="EIJIRO: 辞書を検索できません",
                        subtext=str(error),
                    )
                ]
            return
        if not context.isValid:
            return
        yield [
            StandardItem(
                id=headword,
                text=headword,
                subtext=definition,
                input_action_text=headword,
                actions=[
                    Action(
                        "copy-entry",
                        "見出しと語義をコピー",
                        lambda text=f"{headword}\n{definition}": setClipboardText(text),
                    ),
                    Action(
                        "copy-headword",
                        "見出しをコピー",
                        lambda text=headword: setClipboardText(text),
                    ),
                ],
            )
            for headword, definition in entries
        ]
