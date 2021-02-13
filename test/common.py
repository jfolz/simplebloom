from simplebloom import BloomFilter

from reference_filters import get_elements
from reference_filters import get_filter_data


ELEMS = get_elements()


def add(n):
    elements = ELEMS[:n]
    bf = BloomFilter(n)
    for e in elements:
        bf += e
    buf = bf.dumps()
    reference = get_filter_data(n)
    assert buf == reference


def check(n):
    elements = ELEMS[:n]
    reference = get_filter_data(n)
    bf = BloomFilter.loads(reference)
    for e in elements:
        assert e in bf
