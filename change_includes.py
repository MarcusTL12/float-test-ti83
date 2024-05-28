import os
import re


def replace_root_dir(dir):
    parts = os.path.normpath(dir).split(os.sep)
    if parts[0] == "z80float":
        parts[0] = "z80float_relative"
    return "/".join(parts)


dirs_to_convert = [
    "z80float/common/",
    "z80float/conversion/",
    "z80float/f32",
]

file_dict = {}

for dir in dirs_to_convert:
    for root, _, files in os.walk(dir):
        relroot = replace_root_dir(root)
        for file in files:
            file_dict[file] = f"{relroot}/{file}"


include_reg = re.compile(r"#include\s+\"(.+)\"\s*")


def convert_file(filepath):
    relfile = replace_root_dir(filepath)

    newdir = os.path.split(relfile)[0]

    os.makedirs(newdir, exist_ok=True)

    with open(filepath) as infile:
        lines = infile.readlines()

    last_label = 0

    for i in range(len(lines)):
        line = lines[i]
        m = include_reg.match(line)

        if m is not None:
            if m.group(1) in file_dict:
                lines[i] = f"#include \"{file_dict[m.group(1)]}\"\n"

        if line.startswith("_:"):
            pass

    with open(relfile, "w") as outfile:
        outfile.writelines(lines)


for dir in dirs_to_convert:
    for root, _, files in os.walk(dir):
        for file in files:
            convert_file(f"{root}/{file}")
