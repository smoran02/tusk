#!/usr/bin/env python3

import sys

# Installed package size
# apt-cache show patch | perl -ne 'm/Installed-Size: (\d+)/ && print "$1\n"'

"""
for i in `cat only_left.txt`; do
    echo -n "$i "
    apt-cache show $i | perl -ne '/Installed-Size: (\d+)/ && die "$1\n"'
done


for i in `cat only_right.txt`; do
    echo -n "$i "
    apt-cache show $i | perl -ne '/Installed-Size: (\d+)/ && die "$1\n"'
done
"""

def extract_name(line):
    try:
        package = line[:line.index('/')]
    except ValueError as e:
        package = ''
    return package

def package_list(file_name):
    with open(file_name, 'r') as fh:
        l = [extract_name(line) for line in fh if extract_name(line)]
    return l

def write_simple_list(l, output_file):
    with open(output_file, 'w') as ofh:
        for i in l:
            print(i, file=ofh)

def main():
    if len(sys.argv) < 3:
        print('give two files')
        return 1
    l = package_list(sys.argv[1])
    m = package_list(sys.argv[2])

    only_l = []
    only_r = []
    for package in l:
        if package in m:
            pass
            # print(f'{package} in both lists')
        else:
            only_l.append(package)
            print(f'{package} in only left')
    for package in m:
        if package not in l:
            only_r.append(package)
            print(f'{package} in only right')
    
    write_simple_list(only_l, "only_left.txt")
    write_simple_list(only_r, "only_right.txt")


    return 0
if __name__ == '__main__':
    exit(main())
