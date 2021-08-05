#!/usr/bin/env python3
""" ibus2rime - Convert & Collapse iBus table into Rime dictionary yaml

    Author: Halley Tsai <hftsai256@gmail.com>
    Date: August, 2021
"""
import sys
import argparse
from pathlib import Path
from dataclasses import dataclass, field
from easysql3 import DataBaseSQL3
from datetime import date
from collections.abc import Callable
from typing import List, Dict, Iterable, Set

class RimeDict:
    """ RimeDict
    """
    _keyorder: str = r"abcdefghijklmnopqrstuvwxyz[];',."
    _sel_suffix: List[str] = ['', 'v', 'r', 's', 'f', 'w', 'l', 'c', 'b']
    _flat_table: Iterable
    _db: DataBaseSQL3

    @dataclass(frozen=True)
    class Entry():
        id: int = field(compare=False, hash=False)
        tabkeys: str
        phrase: str
        freq: int = field(compare=False, hash=False)
        user_freq: int = field(compare=False, hash=False)


    def __init__(self, dbfp):
        self._db = DataBaseSQL3(dbfp)
        self._flat_table = [self.Entry(*e) for e in self._db.phrases.full()]

    def join(self, rime_dicts: Iterable) -> None:
        base = self._pivot('phrase', cleaner=self.__clean_dupe_phrases)
        for offset, ext in enumerate(rime_dicts):
            for k, val in ext._pivot('phrase', cleaner=self.__clean_dupe_phrases).items():
                try:
                    pool = base[k]
                except KeyError:
                    pool = set()
                finally:
                    pool.update(self.Entry(v.id, v.tabkeys, v.phrase, v.freq-20*(offset+1), v.user_freq)
                                for v in val)
                    base[k] = pool
        self._falt_table = self._flatten(base)

    def rehash(self):
        base = self._pivot('tabkeys')
        append = dict()
        for k in base.keys():
            if k == 'akl':
                import pdb; pdb.set_trace()
            for i, e in enumerate(sorted(base[k], key=lambda x:-x.freq)):
                if i > 0:
                    sh = self.__shorthand(e.tabkeys, i)
                    ent = self.Entry(e.id, sh, e.phrase, e.freq, e.user_freq-i)
                    try:
                        append[sh].add(ent)
                    except KeyError:
                        append[sh] = set([ent])
        base = self.__merge_pivoted_table(base, append)

        ret = dict()
        for key, group in base.items():
            ordered = sorted(group, key=lambda x:(-x.freq, -x.user_freq))
            ret[key] = [self.Entry(e.id, e.tabkeys, e.phrase, 100-i, 0) for i, e in enumerate(ordered)]
        self._flat_table = self._flatten(ret)

    def export(self):
        return self._flat_table

    def _flatten(self, pivoted_table: Dict) -> List:
        pool = set(e for grp in pivoted_table.values() for e in grp)
        return sorted(pool, key=lambda x:(*(self._keyorder.index(c) for c in x.tabkeys), -x.freq))

    def _pivot(self, key: str, cleaner: Callable = None) -> Dict:
        ret = dict()
        pool = [entry for entry in self._flat_table]
        for e in pool:
            try:
                ret[getattr(e, key)].add(e)
            except KeyError:
                ret[getattr(e, key)] = set([e])
        if cleaner:
            for k in ret.keys():
                ret[k] = cleaner(ret[k])
        return ret

    def __shorthand(self, original_key, index):
        try:
            return original_key + self._sel_suffix[index]
        except IndexError:
            return original_key

    @staticmethod
    def __merge_pivoted_table(base: Dict, append: Dict):
        ret = base.copy()
        for key, value in append.items():
            try:
                ret[key].update(value)
            except KeyError:
                ret[key] = value
        return ret

    @staticmethod
    def __clean_dupe_phrases(entry: Iterable[Entry]) -> Set:
        filtered = []
        dupes = [e for e in entry if e.freq < 100]

        for ent in entry:
            for dupe in dupes:
                if dupe.tabkeys in ent.tabkeys and dupe.freq < ent.freq:
                    break
            else:
                filtered.append(ent)
        return set(filtered)


class RimeWriter:
    yaml_data = {'name': 'Boshiamy_TCJP',
                 'version': f'{date.today().strftime("%m%d%Y")}-nightly',
                 'sort': 'original'}
    descripter = ('# Boshiamy Input Table for RIME\n'
                  '# encoding: utf-8\n'
                  '#\n')
    yaml_header = '---\n'
    yaml_sentinal = '...\n'

    def __init__(self, filepath: str):
        self._name = filepath
        self._fp = filepath
        self._handle = None
        self.yaml_data['name'] = filepath.removesuffix('.dict.yaml')

    def __enter__(self):
        if Path(self._fp).exists():
            if not input(f'Output file {self._fp} exists, overwrite? [y/N] ').lower() == 'y':
                raise FileExistsError

        self._handle = open(self._fp, 'w+')
        self._write_header()
        return self

    def __exit__(self, tp, value, traceback):
        self._handle.close()

    def _write_header(self):
        self._handle.write(self.descripter)
        self._handle.write(self.yaml_header)
        for key, value in self.yaml_data.items():
            self._handle.write(f'{key}: {value}\n')
        self._handle.write(self.yaml_sentinal)

    def write_table(self, entry):
        self._handle.write(f'{entry.phrase}\t{entry.tabkeys}\t{entry.freq}\n')


def parse(args):
    parser = argparse.ArgumentParser(
        description="""Convert iBus input table (v1.8.x+) into yaml format for Rime""")
    parser.add_argument('databases', nargs='+', help='iBus input databases in priority order')
    parser.add_argument('-o', '--output',
        help='output table file, will append .dict.yaml extension if missing')
    return parser.parse_args(args)

def main():
    args = parse(sys.argv[1:])
    output = args.output.removesuffix('.yaml').removesuffix('.dict') + '.dict.yaml'

    with RimeWriter(output) as wt:
        base, *exts = [RimeDict(db) for db in args.databases]
        base.join(exts)
        base.rehash()
        for entry in base.export():
            wt.write_table(entry)

if __name__ == '__main__':
    main()
