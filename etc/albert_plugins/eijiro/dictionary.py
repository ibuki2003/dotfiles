"""Local EIJIRO text dictionary and its disposable SQLite index."""

import os
import sqlite3
import tempfile
from contextlib import closing
from hashlib import sha256
from itertools import islice
from pathlib import Path
from threading import Lock


INDEX_VERSION = 1


def read_entries(source):
    with source.open(encoding="cp932") as stream:
        for number, line in enumerate(stream, 1):
            heading, separator, meaning = line.rstrip("\r\n").partition(" : ")
            if not heading.startswith("■") or not separator:
                raise ValueError(f"Invalid EIJIRO entry at line {number}")
            headword, _, part = heading[1:].partition("  {")
            definition = f"{{{part} : {meaning}" if part else meaning
            yield headword.casefold(), headword, definition


def prefix_end(prefix):
    # The smallest string greater than every string starting with prefix.
    for position in range(len(prefix) - 1, -1, -1):
        codepoint = ord(prefix[position])
        if codepoint < 0x10FFFF:
            return prefix[:position] + chr(codepoint + 1)
    return None


class Dictionary:
    def __init__(self, source, cache_dir):
        self.source = Path(source).expanduser().resolve()
        digest = sha256(str(self.source).encode()).hexdigest()
        self.database = Path(cache_dir) / f"{digest}.sqlite3"
        self._lock = Lock()
        self._signature = None

    def _connect(self):
        return sqlite3.connect(self.database.as_uri() + "?mode=ro", uri=True)

    def prepare(self):
        with self._lock:
            stat = self.source.stat()
            signature = (INDEX_VERSION, stat.st_size, stat.st_mtime_ns)
            if self._signature == signature and self.database.exists():
                return
            if self.database.exists():
                try:
                    with closing(self._connect()) as connection:
                        stored = connection.execute("SELECT * FROM metadata").fetchone()
                    if stored == signature:
                        self._signature = signature
                        return
                except sqlite3.DatabaseError:
                    pass  # A disposable index can be rebuilt.
            self._build(signature)
            self._signature = signature

    def _build(self, signature):
        self.database.parent.mkdir(parents=True, exist_ok=True)
        fd, name = tempfile.mkstemp(dir=self.database.parent, suffix=".sqlite3")
        os.close(fd)
        temporary = Path(name)
        try:
            with closing(sqlite3.connect(temporary)) as connection:
                connection.execute("PRAGMA journal_mode=OFF")
                connection.execute("PRAGMA synchronous=OFF")
                connection.execute(
                    "CREATE TABLE entries (key TEXT, headword TEXT, definition TEXT)"
                )
                entries = read_entries(self.source)
                while batch := list(islice(entries, 10000)):
                    connection.executemany("INSERT INTO entries VALUES (?, ?, ?)", batch)
                connection.execute("CREATE INDEX prefix ON entries (key)")
                connection.execute(
                    "CREATE TABLE metadata (version INTEGER, size INTEGER, mtime INTEGER)"
                )
                connection.execute("INSERT INTO metadata VALUES (?, ?, ?)", signature)
                connection.commit()
            stat = self.source.stat()
            if (stat.st_size, stat.st_mtime_ns) != signature[1:]:
                raise RuntimeError("Dictionary changed during indexing; please search again")
            temporary.replace(self.database)
        finally:
            temporary.unlink(missing_ok=True)

    def lookup(self, prefix, limit=5):
        prefix = prefix.strip().casefold()
        if not prefix:
            return []
        self.prepare()
        upper = prefix_end(prefix)
        condition = "key >= ?" if upper is None else "key >= ? AND key < ?"
        parameters = (prefix,) if upper is None else (prefix, upper)
        with closing(self._connect()) as connection:
            keys = connection.execute(
                f"SELECT key FROM entries WHERE {condition} "
                "GROUP BY key ORDER BY key LIMIT ?",
                (*parameters, limit),
            ).fetchall()
            results = []
            for (key,) in keys:
                rows = connection.execute(
                    "SELECT headword, definition FROM entries WHERE key = ? ORDER BY rowid",
                    (key,),
                ).fetchall()
                results.append((rows[0][0], "\n".join(row[1] for row in rows)))
            return results
