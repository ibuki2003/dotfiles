import importlib.util
import sqlite3
import tempfile
import unittest
from contextlib import closing
from pathlib import Path
from unittest.mock import patch


# Load the index without importing Albert's native module.
spec = importlib.util.spec_from_file_location(
    "eijiro_dictionary", Path(__file__).with_name("dictionary.py")
)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
Dictionary = module.Dictionary


class DictionaryTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.source = self.root / "dictionary.txt"
        self.write(
            "■banana : バナナ\n"
            "■apple  {名-1} : リンゴ\n"
            "■application : 応用\n"
            "■Apple  {名-2} : 会社\n"
            "■apple : 発音\n"
            "■app : アプリ\n"
            "■apply : 適用\n"
            "■approach : 接近\n"
            "■approve : 承認\n"
            "■app_ : 下線\n"
            "■app% : パーセント\n"
            "■日本 : Japan\n"
        )
        self.dictionary = Dictionary(self.source, self.root / "cache")

    def write(self, text):
        self.source.write_bytes(text.replace("\n", "\r\n").encode("cp932"))

    def test_prefix_order_limit_and_aggregation(self):
        results = self.dictionary.lookup(" APP ")
        self.assertEqual(
            [head for head, _ in results],
            ["app", "app%", "app_", "apple", "application"],
        )
        self.assertEqual(results[3][1], "{名-1} : リンゴ\n{名-2} : 会社\n発音")
        self.assertEqual(self.dictionary.lookup("banana"), [("banana", "バナナ")])
        self.assertEqual(self.dictionary.lookup("日本"), [("日本", "Japan")])
        self.assertEqual(self.dictionary.lookup("pp"), [])
        self.assertEqual(self.dictionary.lookup(""), [])

    def test_sql_wildcards_are_literal(self):
        self.assertEqual(self.dictionary.lookup("app%"), [("app%", "パーセント")])
        self.assertEqual(self.dictionary.lookup("app_"), [("app_", "下線")])

    def test_index_is_reused_by_new_instance(self):
        self.dictionary.lookup("app")
        another = Dictionary(self.source, self.root / "cache")
        with patch.object(another, "_build", side_effect=AssertionError("rebuilt")):
            self.assertEqual(another.lookup("banana"), [("banana", "バナナ")])

    def test_source_update_rebuilds(self):
        self.dictionary.lookup("app")
        self.write("■apricot : アンズ\n")
        self.assertEqual(self.dictionary.lookup("app"), [])
        self.assertEqual(self.dictionary.lookup("ap"), [("apricot", "アンズ")])

    def test_bad_input_preserves_previous_index(self):
        self.dictionary.lookup("app")
        self.write("invalid line\n")
        with self.assertRaisesRegex(ValueError, "line 1"):
            self.dictionary.lookup("app")
        with closing(sqlite3.connect(self.dictionary.database)) as connection:
            count = connection.execute("SELECT COUNT(*) FROM entries").fetchone()[0]
            self.assertEqual(count, 12)
        self.assertEqual(
            list(self.dictionary.database.parent.glob("*.sqlite3")),
            [self.dictionary.database],
        )

    def test_missing_source(self):
        self.source.unlink()
        with self.assertRaises(FileNotFoundError):
            self.dictionary.lookup("app")


if __name__ == "__main__":
    unittest.main()
