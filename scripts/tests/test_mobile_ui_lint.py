"""Tests for mobile_ui_lint. Run from the pack root: python3 -m unittest discover -s scripts/tests"""

import os
import re
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "skills", "mobile-ui", "scripts"))

import mobile_ui_lint as lint  # noqa: E402


def run(path):
    linter = lint.Linter()
    for f in lint.walk([path]):
        linter.lint_file(f)
    return linter.findings


def rules(findings, file_suffix):
    return {f.rule for f in findings if f.file.endswith(file_suffix)}


class ShippedAssetsAreClean(unittest.TestCase):
    """The pack's own tokens, components and templates must model the rules."""

    def test_no_errors_or_warnings_in_skills(self):
        findings = [f for f in run(os.path.join(ROOT, "skills")) if f.severity in ("error", "warning")]
        self.assertEqual(findings, [], "\n".join(f"{f.file}:{f.line} {f.rule} {f.message}" for f in findings))


class GenericFixturesAreCaught(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.findings = run(os.path.join(HERE, "fixtures", "generic"))

    def test_swiftui_tells(self):
        r = rules(self.findings, "GenericDashboard.swift")
        for expected in ["MU001", "MU002", "MU003", "MU004", "MU005", "MU100", "MU101", "MU102", "MU103",
                         "MU104", "MU105", "MU107", "MU109", "MU113"]:
            self.assertIn(expected, r, f"SwiftUI fixture should trigger {expected}")

    def test_react_native_tells(self):
        r = rules(self.findings, "GenericProfile.tsx")
        for expected in ["MU001", "MU002", "MU004", "MU005", "MU100", "MU101", "MU102", "MU104", "MU105",
                         "MU106", "MU107", "MU109", "MU112", "MU113", "MU114"]:
            self.assertIn(expected, r, f"RN fixture should trigger {expected}")

    def test_flutter_tells(self):
        r = rules(self.findings, "generic_settings.dart")
        for expected in ["MU001", "MU002", "MU004", "MU101", "MU104", "MU105", "MU106", "MU107", "MU109"]:
            self.assertIn(expected, r, f"Flutter fixture should trigger {expected}")

    def test_exit_code_fails_on_errors(self):
        self.assertEqual(lint.main([os.path.join(HERE, "fixtures", "generic"), "--json"]), 1)


class Unit(unittest.TestCase):
    def test_comments_are_ignored(self):
        lines = ["// Color.blue in a comment", "let x = 1 /* Colors.blue */", 'let url = "https://x.y"']
        out = lint.strip_comments(lines)
        self.assertNotIn("blue", out[0] + out[1])
        self.assertIn("https://x.y", out[2])

    def test_real_labels_are_not_placeholders(self):
        import tempfile
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, "Form.swift")
            open(p, "w").write('TextField("Name", text: $name)\nText("Title")\nText("Item 1")\n')
            linter = lint.Linter(); linter.lint_file(p)
            flagged = [f.line for f in linter.findings if f.rule == "MU004"]
            self.assertEqual(flagged, [3])

    def test_overlaid_bottom_bar(self):
        import tempfile
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, "Pay.swift")
            open(p, "w").write('ScrollView { Text("Hi") }\n.overlay(alignment: .bottom) {\n  Button("Subscribe") {}\n}\n')
            linter = lint.Linter(); linter.lint_file(p)
            self.assertIn("MU115", {f.rule for f in linter.findings})

    def test_mixed_money_formats(self):
        import tempfile
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, "Home.swift")
            open(p, "w").write('QHeroMetric(label: "Left", value: "1,862", prefix: "$")\nText(spent.formatted(.currency(code: "USD")))\n')
            linter = lint.Linter(); linter.lint_file(p)
            self.assertIn("MU117", {f.rule for f in linter.findings})

    def test_hermes_missing_intl(self):
        import tempfile
        cases = {
            "const usd = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });\nconst p = usd.formatToParts(12);\n": "error",
            "const p = new Intl.NumberFormat('en-US').formatToParts(12);\n": "error",
            "const r = new Intl.RelativeTimeFormat('en');\n": "error",
            "const s = fmt.formatRange(1, 2);\n": "error",
            "const km = new Intl.NumberFormat('en-US', { style: 'unit', unit: 'kilometer' });\n": "error",
            "const c = new Intl.NumberFormat('en-US', { notation: 'compact' });\n": "warning",
            "const p = parts.formatToParts(d);\n": "warning",
        }
        with tempfile.TemporaryDirectory() as d:
            for src, sev in cases.items():
                p = os.path.join(d, "Screen.tsx")
                open(p, "w").write(src)
                linter = lint.Linter(); linter.lint_file(p)
                got = {f.severity for f in linter.findings if f.rule == "MU118"}
                self.assertEqual(got, {sev}, src)

    def test_hermes_safe_intl_is_clean(self):
        import tempfile
        src = (
            "const usd = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });\n"
            "const day = new Intl.DateTimeFormat('en-US', { weekday: 'short' });\n"
            "const a = usd.format(12); const b = day.formatToParts(new Date());\n"
            "const c = new Intl.DateTimeFormat('en-US').formatToParts(new Date());\n"
        )
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, "Screen.tsx")
            open(p, "w").write(src)
            linter = lint.Linter(); linter.lint_file(p)
            self.assertNotIn("MU118", {f.rule for f in linter.findings})

    def test_hermes_rule_is_rn_only(self):
        import tempfile
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, "Screen.swift")
            open(p, "w").write('let r = "Intl.RelativeTimeFormat"\n')
            linter = lint.Linter(); linter.lint_file(p)
            self.assertNotIn("MU118", {f.rule for f in linter.findings})

    def test_content_color_marker(self):
        import tempfile
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, "Detail.swift")
            open(p, "w").write('let ink = Color(red: 0.1, green: 0.1, blue: 0.1)\nlet shoe = Color(red: 0.8, green: 0.1, blue: 0.1) // mobile-ui: content-color\n')
            linter = lint.Linter(); linter.lint_file(p)
            self.assertEqual([f.line for f in linter.findings if f.rule == "MU001"], [1])

    def test_token_files_may_hold_hex(self):
        self.assertTrue(lint.TOKEN_FILE.search("app/theme.ts"))
        self.assertTrue(lint.TOKEN_FILE.search("Sources/DesignSystem.swift"))
        self.assertFalse(lint.TOKEN_FILE.search("app/screens/HomeScreen.tsx"))


class PublicApiIsPrefixed(unittest.TestCase):
    """Users copy the assets into their app, where every public name shares their namespace (Swift
    module, Dart library imports next to Material, RN imports next to React Navigation). Generic
    names break builds on upgrade (0.3's `Swatch`), so every shipped symbol carries the Q prefix."""

    ASSETS = os.path.join(ROOT, "skills")

    def read(self, rel):
        return open(os.path.join(self.ASSETS, rel)).read()

    def test_swift(self):
        src = self.read("mobile-ui-swiftui/assets/DesignSystem.swift") + self.read("mobile-ui-swiftui/assets/Components.swift")
        types = re.findall(r"^(?:public )?(?:struct|enum|final class|class|protocol) (\w+)", src, re.M)
        funcs = re.findall(r"^extension (?:View|Color|ButtonStyle)\b[^{]*\{(.*?)^\}", src, re.M | re.S)
        members = [m for body in funcs for m in re.findall(r"^    (?:static )?(?:func|var|let) (\w+)", body, re.M)]
        bad = [t for t in types if not t.startswith("Q")] + [m for m in members if not m.startswith("q")]
        self.assertEqual(bad, [], "unprefixed public Swift symbols")

    def test_dart(self):
        src = self.read("mobile-ui-flutter/assets/theme.dart") + self.read("mobile-ui-flutter/assets/components.dart")
        names = re.findall(r"^(?:abstract |final |sealed |base )*(?:class|enum|extension|mixin|typedef) (\w+)", src, re.M)
        names += re.findall(r"^(?:[A-Z]\w*(?:<[^>]*>)?|void|bool) ([a-z]\w*)\(", src, re.M)
        allowed = {"Quiet", "QuietContext", "quietTheme"}  # the skin's own, already distinctive names
        bad = [n for n in names if not n.startswith(("Q", "q", "_")) and n not in allowed and not n.startswith("showQ")]
        self.assertEqual(bad, [], "unprefixed public Dart symbols")

    def test_react_native(self):
        src = self.read("mobile-ui-react-native/assets/components.tsx") + self.read("mobile-ui-react-native/assets/theme.ts")
        names = re.findall(r"^export (?:function|const|type|interface|class) (\w+)", src, re.M)
        # lowercase token objects (space, radius, motion…) are imported by name and can't shadow anything
        bad = [n for n in names if n[0].isupper() and not n.startswith("Q") and n != "DISPLAY_FAMILY"]
        bad += [n for n in names if n.startswith("use") and not n.startswith("useQ")]
        self.assertEqual(bad, [], "unprefixed public React Native symbols")


if __name__ == "__main__":
    unittest.main()
