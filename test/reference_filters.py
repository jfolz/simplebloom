from math import log10
from pathlib import Path
import gzip
from hashlib import sha256

import os
os.environ['SIMPLEBLOOM_USEPY'] = '1'

from simplebloom import BloomFilter
from simplebloom.bloom import PURE_PYTHON


ELEMENT_SEED = '1234567890'
NUM_ELEMENTS = 100000
PWD = Path(__file__).parent.absolute()


def generate_elements(outfile):
    seed = ELEMENT_SEED
    with gzip.open(outfile, 'wt') as f:
        for _ in range(NUM_ELEMENTS):
            seed = sha256(seed.encode('utf-8')).hexdigest()
            f.write(seed+'\n')


def get_elements():
    with gzip.open(Path(PWD, 'elements.gz'), 'rt') as f:
        return [l.strip() for l in f]


def get_filter_data(num_elements):
    path = Path(PWD, f'bloom_{num_elements}.filter')
    with path.open('rb') as fp:
        return fp.read()


def main():
    path = Path(PWD, 'elements.gz')
    if not path.exists():
        generate_elements(path)
    elements = get_elements()
    magnitudes = int(log10(NUM_ELEMENTS))
    for m in range(1, magnitudes+1):
        num_elements = 10 ** m
        path = Path(PWD, f'bloom_{num_elements}.filter')
        if path.exists():
            continue
        bf = BloomFilter(num_elements)
        for _, elem in zip(range(num_elements), elements):
            bf += elem
        bf.dump(path)


if __name__ == '__main__':
    main()
