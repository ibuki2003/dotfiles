"""
udisksctl source
"""

from pathlib import Path

from albert import *
import time
import json
import subprocess
import traceback

md_iid = "2.0"
md_version = "1.6"
md_name = "disks"
md_description = "udisksctl mounting"
md_license = "MIT"
md_url = "https://fuwa.dev"
md_authors = "fuwa"

def notify_send(title, text):
    subprocess.Popen(["notify-send", title, text])

class Plugin(PluginInstance, GlobalQueryHandler):

    def __init__(self):
        PluginInstance.__init__(self)
        GlobalQueryHandler.__init__(
            self,
            id=self.id,
            name=self.name,
            description=self.description,
            defaultTrigger='d ',
            synopsis='<disk name>',
            supportsFuzzyMatching=True,
        )
        self.icon_mount = [f"file:{Path(__file__).parent}/usb.svg"]
        self.icon_eject = [f"file:{Path(__file__).parent}/eject.svg"]
        self.client = None

        self.cache = []
        self.cache_at = 0

    def _get_disks(self, refresh=False):
        t = time.time()
        if not refresh and (t - self.cache_at < 10):
            return self.cache
        self.cache_at = t

        # lsblk -fJ
        p = subprocess.run([
            "lsblk",
            "-J",
            "-o", "FSTYPE,FSUSE%,FSUSED,FSVER,ID,LABEL,MOUNTPOINT,NAME,PATH,RM,SIZE",
        ], stdout=subprocess.PIPE)
        d = json.loads(p.stdout.decode("utf-8"))

        disks = []
        for b in d['blockdevices']:
            if 'children' not in b: continue
            for t in b['children']:
                if t['rm']:
                    disks.append(t | { 'device': b })

        self.cache = disks
        return disks


    @staticmethod
    def _mount_disk(disk):
        p = subprocess.run([
            "udisksctl",
            "mount",
            "-b", disk['path'],
        ], stdout=subprocess.PIPE)
        notify_send("mount", p.stdout.decode("utf-8"))


    @staticmethod
    def _unmount_disk(disk):
        p = subprocess.run([
            "udisksctl",
            "unmount",
            "-b", disk['path'],
        ], stdout=subprocess.PIPE)
        notify_send("unmount", p.stdout.decode("utf-8"))


    def handleGlobalQuery(self, query):
        rank_items = []
        try:

            q = query.string.lower()
            disks = self._get_disks(refresh=(q == ""))
            for d in disks:
                if not (
                    q in d['name'] or
                    (d['label'] and q in d['label']) or
                    q in d['id']
                ):
                    continue

                did = d['name']

                actions = []
                action_name = ""

                if d['mountpoint'] is None:
                    actions.append(Action("mount", "Mount",
                                          lambda c=d: self._mount_disk(c)))
                    action_name = "Mount"
                else:
                    actions.append(Action("unmount", "Unmount",
                                          lambda c=d: self._unmount_disk(c)))
                    action_name = "Unmount"

                sizetext = (f"{d['fsused']} / {d['size']} ({d['fsuse%']})" if d['size']
                    else f"{d['size']}")

                rank_items.append(RankItem(
                    StandardItem(
                        id=did,
                        text=f"{action_name} {d['label'] or ''} ({d['name']})",
                        subtext=f"{sizetext} {d['fstype'] or ''} {d['fsver'] or ''} {d['id']}",
                        iconUrls=self.icon_mount if action_name == "Mount" else self.icon_eject,
                        actions=actions
                    ),
                    score=len(query.string)/len(did)
                ))

        except Exception as e:
            warning(e)
            self.client = None

        return rank_items
