"""
Yubikey TOTP source
"""

from pathlib import Path

from albert import *
import time
import subprocess
import traceback
import clipboard

md_iid = "2.0"
md_version = "1.6"
md_name = "Yubikey"
md_description = "Yubikey TOTP source"
md_license = "MIT"
md_url = "https://fuwa.dev"
md_lib_dependencies = ["clipboard"]

def notify_send(title, text):
    subprocess.Popen(["notify-send", title, text])

class Plugin(PluginInstance, GlobalQueryHandler):

    def __init__(self):
        GlobalQueryHandler.__init__(self,
                                    id=md_id,
                                    name=md_name,
                                    description=md_description,
                                    defaultTrigger='yk ',
                                    synopsis='<account name>',
                                    supportsFuzzyMatching=True,
                                    )
        PluginInstance.__init__(self, extensions=[self])
        self.icon = [f"file:{Path(__file__).parent}/yubikey.svg"]

        self.cache = []
        self.cache_at = 0


    CACHE_PATH = Path("~/.cache/albert/yubikey_cache.txt").expanduser()


    def _get_accounts(self):
        t = time.time()
        if t - self.cache_at < 600:
            return self.cache

        p = subprocess.run(
            ["lsusb", "-d", "1050:0407"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        if p.returncode != 0:
            if not self.CACHE_PATH.exists():
                self.cache = []
                return []
            with open(self.CACHE_PATH, "r") as f:
                a = f.readlines()
                self.cache = a
            # self.cache_at = t # keep stale
            return self.cache

        self.cache_at = t

        p = subprocess.run(["ykman", "oath", "accounts", "list"], stdout=subprocess.PIPE)
        s = p.stdout.decode("utf-8")
        l = s.splitlines()

        if self.cache != l:
            self.CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
            with open(self.CACHE_PATH.expanduser(), "w") as f:
                f.write(s)
            self.cache = l
        return l


    @staticmethod
    def _copy_totp(name):
        rc = 0
        p = None
        try:
            p = subprocess.run(
                [ "ykman", "oath", "accounts", "code", name, ],
                stdout=subprocess.PIPE,
                timeout=1,
            )
            rc = p.returncode
        except subprocess.TimeoutExpired:
            rc = 1

        if not p or rc != 0:
            notify_send("error ykman", "Failed to get code")
            return

        o = p.stdout.decode("utf-8").splitlines()[0]
        code = o.rsplit(" ", 1)[1]
        clipboard.copy(code)
        notify_send(name, f"copied {code}")


    def handleGlobalQuery(self, query):
        items = []
        try:

            a = self._get_accounts()
            if len(query.string) >= 1:
                a = ((i, len(query.string) / len(i)) for i in a if query.string.lower() in i.lower())
            else:
                a = ((i, 1) for i in a)

            for (name, score) in a:
                actions = [
                    Action("mount", "Mount",
                           lambda c=name: self._copy_totp(c))
                ]

                items.append(RankItem(
                    StandardItem(
                        id=name,
                        text=name,
                        subtext=f"Yubikey TOTP",
                        iconUrls=self.icon,
                        actions=actions
                    ),
                    score=score,
                ))


        except Exception as e:
            warning(traceback.format_exc())
            warning(e)
            self.client = None

        return items
