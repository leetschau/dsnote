import sys
import os
import glob
from pathlib import Path
from typing import List
from sh import grep
from functools import reduce

if len(sys.argv) <= 2:
    sys.exit("Add at least one word for search")

CMD = sys.argv[1]
PARAM_LIST = sys.argv[2:]

BASE_DIR = os.path.join(Path.home(), ".donno")
REPO = os.path.join(BASE_DIR, "repo")
MD_FILES = glob.glob(os.path.join(REPO, '*.md'))

def filter_word(file_list: List[str], word: str) -> List[str]:
    if len(file_list) == 0: return []
    return grep('-i', '-l', word, file_list).stdout.decode(
            'UTF-8').strip().split('\n')

def simple_search(word_list: List[str]) -> List[str]:
    return reduce(filter_word, word_list, MD_FILES)

def note_list(file_list: List[str]) -> str:
    return file_list

if CMD == 's':
    path_list = simple_search(PARAM_LIST)
    if len(path_list) == 0:
        sys.exit("No match found")
    else:
        print(note_list(path_list))
