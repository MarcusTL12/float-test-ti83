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


r = re.compile(r"#include\s+\"(.+)\"\s*")


def convert_line(line: str):
    m = r.match(line)

    if m is not None:
        if m.group(1) in file_dict:
            return f"#include \"{file_dict[m.group(1)]}\"\n"

    return line


def convert_file(filepath):
    relfile = replace_root_dir(filepath)

    newdir = os.path.split(relfile)[0]

    os.makedirs(newdir, exist_ok=True)

    with open(filepath) as infile:
        with open(relfile, "w") as outfile:
            for line in infile:
                outfile.write(convert_line(line))


for dir in dirs_to_convert:
    for root, _, files in os.walk(dir):
        for file in files:
            convert_file(f"{root}/{file}")
