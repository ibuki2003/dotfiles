import importlib.util
import sys
import tempfile
import types
import unittest
from pathlib import Path
from unittest.mock import patch


class PluginImportTests(unittest.TestCase):
    def test_albert_loader_without_a_python_package_or_warning_function(self):
        with tempfile.TemporaryDirectory() as cache:
            class PluginInstance:
                def readConfig(self, key, kind):
                    return None

                def cacheLocation(self):
                    return Path(cache)

            class GeneratorQueryHandler:
                pass

            class StandardItem:
                def __init__(self, **kwargs):
                    self.__dict__.update(kwargs)

            class Action:
                def __init__(self, id, text, callback):
                    self.callback = callback

            albert = types.ModuleType("albert")
            albert.PluginInstance = PluginInstance
            albert.GeneratorQueryHandler = GeneratorQueryHandler
            albert.StandardItem = StandardItem
            albert.Action = Action
            albert.setClipboardText = lambda text: None

            with patch.dict(sys.modules, {"albert": albert}):
                spec = importlib.util.spec_from_file_location(
                    "albert.python.eijiro", Path(__file__).with_name("__init__.py")
                )
                module = importlib.util.module_from_spec(spec)
                module.__package__ = "albert.python"
                spec.loader.exec_module(module)
                plugin = module.Plugin()
                self.assertEqual(plugin.defaultTrigger(), "ej ")
                context = types.SimpleNamespace(query="apple", isValid=True)
                error = OSError("test error")
                with (
                    patch.object(plugin._dictionary, "lookup", side_effect=error),
                    patch.object(module.logging, "warning") as warning,
                ):
                    batches = list(plugin.items(context))
                warning.assert_called_once_with("EIJIRO: %s", error)
                self.assertEqual(batches[0][0].id, "eijiro-error")
                definition = "{名-1} : リンゴ\n{名-2} : 会社"
                with patch.object(
                    plugin._dictionary, "lookup", return_value=[("apple", definition)]
                ):
                    for trigger in ("ej ", "custom "):
                        context.trigger = trigger
                        batches = list(plugin.items(context))
                        item = batches[0][0]
                        self.assertEqual(item.subtext, definition)
                        self.assertEqual(item.input_action_text, "apple")
                        self.assertEqual(
                            trigger + item.input_action_text, trigger + "apple"
                        )
                        with patch.object(module, "setClipboardText") as copy:
                            item.actions[0].callback()
                            copy.assert_called_once_with(f"apple\n{definition}")


if __name__ == "__main__":
    unittest.main()
