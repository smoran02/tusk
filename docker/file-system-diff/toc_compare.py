#!/usr/bin/env python3

import sys
from collections import namedtuple

_Entry = namedtuple("_Entry", ["size", "file_name"])

class Entry(_Entry):
    def __str__(self):
        return f'{self.size} {self.file_name}'
    def __repr__(self):
        return f'Entry(size={self.size}, file_name={self.file_name})'
    def __add__(self, rhs):
        return int(self.size) + int(rhs.size)
    def __sub__(self, rhs):
        return int(self.size) - int(rhs.size)
    def __int__(self):
        return int(self.size)
    def __float__(self):
        return float(self.size)


def line_list(line):
    return line.split()

def toc_entry_list(file_name):
    with open(file_name, 'r') as fh:
        l = [Entry(line_list(line)[0], line_list(line)[1]) for line in fh]
    return l

def write_simple_list(l, output_file):
    with open(output_file, 'w') as ofh:
        for i in l:
            print(i, file=ofh)

def entry_list_sum(l):
    return sum([int(entry) for entry in l])

def main():
    if len(sys.argv) < 3:
        print('give two toc files')
        return 1
    l = toc_entry_list(sys.argv[1])
    r = toc_entry_list(sys.argv[2])

    # only_l = []
    # only_r = []
    only_l = [entry for entry in l if entry not in r]
    only_r = [entry for entry in r if entry not in l]
    # for entry in l:
    #     if entry in r:
    #         pass
    #         # print(f'{package} in both lists')
    #     else:
    #         only_l.append(entry)
    #         # print(f'{package} in only left')
    # for entry in r:
    #     if entry not in l:
    #         only_r.append(entry)
    
    print('Files that were modified in r that appear in l.')
    # print('\n'.join(map(str, only_l)))
    for entry in only_l:
        # Find matching entry in only_r
        # (should be there because size is different)
        updated_entry = next((i for i in only_r if i.file_name == entry.file_name), None)
        if not updated_entry:
            print(f'something fishy {entry}')
            exit(1)
        size_difference = int(updated_entry) - int(entry)
        if int(entry) == 0:
            denom = 1.0
        else:
            denom = float(entry)
        percent_change = int((size_difference / denom) * 100.0)
        print(f'{percent_change}% {str(entry)} {updated_entry - entry}')

    print()
    print('Files that only are in r and are not 0 size')
    non_zero = [entry for entry in only_r if int(entry) > 0]
    header_files = [entry for entry in non_zero if entry.file_name.endswith('.h') or entry.file_name.endswith('.hpp') or entry.file_name.startswith('usr/include')]

    candidates = [entry for entry in non_zero if not entry.file_name.endswith('.h') and not entry.file_name.endswith('.hpp') and not '.so.' in entry.file_name and not entry.file_name.endswith('.so') and not entry.file_name.startswith('usr/include')]

    static_libs = [entry for entry in non_zero if entry.file_name.endswith('.a')]

    non_zero.sort(key=lambda x: int(x), reverse=True)
    print(f'{entry_list_sum(non_zero) / 1000000:.2f} MB in non_zero list.')
    write_simple_list(map(str, non_zero), 'non_zero.txt')
    
    print(f'{entry_list_sum(header_files) / 1000000:.2f} MB in header list.')

    candidates.sort(key=lambda x: int(x), reverse=True)
    print(f'{entry_list_sum(candidates) / 1000000:.2f} MB in candidates list.')
    write_simple_list(map(str, candidates), 'candidates.txt')

    static_libs.sort(key=lambda x: int(x), reverse=True)
    print(f'{entry_list_sum(static_libs) / 1000000:.2f} MB in static_libs list.')
    write_simple_list(map(str, static_libs), 'static_libs.txt')

    return 0
if __name__ == '__main__':
    exit(main())
