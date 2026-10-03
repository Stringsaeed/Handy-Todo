"""Extract the original icon sheet and the standalone hand-drawn icons."""
from pathlib import Path
import copy
import json
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Design/InterfaceIcons.svg"
NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", NS)
parts = list(ET.parse(SOURCE).getroot())[0]
icons = {
    "Completed": (range(0, 2), "6 97 56 56"),
    "Sound": (range(2, 6), "66 97 58 58"),
    "Muted": (range(6, 9), "132 97 56 56"),
    "Feedback": (range(9, 14), "194 95 58 58"),
    "Settings": (range(14, 16), "6 24 56 56"),
    "Delete": (range(16, 22), "69 24 56 56"),
    "Add": (range(22, 23), "134 28 52 52"),
    "Circle": (range(23, 24), "194 26 58 58"),
    "Remove": (range(24, 27), "31 174 56 56"),
    "Calendar": (range(27, 43), "97 174 58 58"),
    "Shuffle": (range(43, 47), "173 176 54 54"),
    "Close": (range(25, 27), "54 175 26 26"),
}
assert sorted({index for indices, _ in icons.values() for index in indices}) == list(range(len(parts)))
standalone = {
    "Shuffle": ROOT / "Design/Shuffle-B.svg",
    "GitHub": ROOT / "Design/GitHub.svg",
}
for name in dict.fromkeys([*icons, *standalone]):
    folder = ROOT / f"HandyTodo/Assets.xcassets/Handy{name}.imageset"
    folder.mkdir(exist_ok=True)
    size = "18" if name == "Delete" else "64"
    if name in standalone:
        svg = ET.parse(standalone[name]).getroot()
        svg.set("width", size)
        svg.set("height", size)
        for element in svg.iter():
            for attribute in ("stroke", "fill"):
                if element.get(attribute) == "currentColor":
                    element.set(attribute, "#080808")
    else:
        indices, bounds = icons[name]
        svg = ET.Element(f"{{{NS}}}svg", {"width": size, "height": size, "viewBox": bounds, "fill": "none"})
        svg.append(ET.Comment(" SVG created with Arrow, by QuiverAI (https://quiver.ai); extracted from supplied artwork. "))
        for index in indices:
            svg.append(copy.deepcopy(parts[index]))
    ET.ElementTree(svg).write(folder / f"{name}.svg", encoding="utf-8", xml_declaration=True)
    contents = {"images": [{"filename": f"{name}.svg", "idiom": "universal"}],
                "info": {"author": "xcode", "version": 1},
                "properties": {"preserves-vector-representation": True, "template-rendering-intent": "template"}}
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")
print(f"Extracted {len(set(icons) | set(standalone))} vector icons.")
