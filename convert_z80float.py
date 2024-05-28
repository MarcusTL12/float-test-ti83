import os
import re
import shutil


def replace_root_dir(dir):
    parts = os.path.normpath(dir).split(os.sep)
    if parts[0] == "z80float":
        parts[0] = "z80float_relative"
    return "/".join(parts)


dirs_to_convert = [
    "z80float/common/",
    "z80float/conversion/",
    "z80float/f32/",
]

file_dict = {}

for dir in dirs_to_convert:
    for root, _, files in os.walk(dir):
        relroot = replace_root_dir(root)
        for file in files:
            file_dict[file] = f"{relroot}/{file}"


include_reg = re.compile(r"#include\s+\"(.+)\"\s*")
use_label_reg = re.compile(r"(\+|-)_")
def_label_reg = re.compile(r"_:")

sub_reg = re.compile(r"sub\s+a,\s*(a|h|l|b|c|d|e)")

def convert_file(filepath):
    relfile = replace_root_dir(filepath)

    newdir = os.path.split(relfile)[0]

    os.makedirs(newdir, exist_ok=True)

    with open(filepath) as infile:
        lines = infile.readlines()

    have_labels_pointing_forward = False

    for i in range(len(lines)):
        line = lines[i]
        m = include_reg.match(line)

        if m is not None:
            if m.group(1) in file_dict:
                lines[i] = f"#include \"{file_dict[m.group(1)]}\"\n"
            continue

        if line.startswith("_:"):
            if have_labels_pointing_forward:
                have_labels_pointing_forward = False
                lines[i] = def_label_reg.sub("+:", line)
            else:
                lines[i] = def_label_reg.sub("-:", line)
            continue

        m = use_label_reg.search(line)

        if m is not None:
            if m.group(1) == "+":
                have_labels_pointing_forward = True

            lines[i] = use_label_reg.sub(r"{\1}", line)

        lines[i] = sub_reg.sub(r"sub \2", lines[i])

    with open(relfile, "w") as outfile:
        outfile.writelines(lines)


shutil.rmtree("z80float_relative")


for dir in dirs_to_convert:
    for root, _, files in os.walk(dir):
        for file in files:
            if file.endswith(".z80"):
                convert_file(f"{root}/{file}")
