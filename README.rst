simplebloom
===========

simplebloom is a (probably) dumb but fast bloom filter.
To quote `Wikipedia <https://en.wikipedia.org/wiki/Bloom_filter>`_:

    A Bloom filter is a space-efficient probabilistic data structure,
    conceived by Burton Howard Bloom in 1970, that is used to test
    whether an element is a member of a set.
    False positive matches are possible, but false negatives are not
    – in other words, a query returns either "possibly in set" or
    "definitely not in set".
    Elements can be added to the set, but not removed [...];
    the more items added, the larger the probability of false positives.

The included ``BloomFilter`` class is quite dumb as it's fixed size,
only supports strings, and always uses the blake2s hash function included
with Python 3.6+.
But at least it's fast, hey?


Speed
-----

~1.4 million elements/s on an i7-6700HQ, both adding and checking.


Usage
-----

Note that around 98% of the execution time is spent creating UUIDs.

::

    import uuid
    from simplebloom import BloomFilter

    keys = [uuid.uuid4().hex for _ in range(100000)]
    bf = BloomFilter(len(keys))

    for k in keys:
        bf += k

    with open('test.filter', 'wb') as fp:
        bf.dump(fp)

    with open('test.filter', 'rb') as fp:
        bf = BloomFilter.load(fp)

    for k in keys:
        assert k in bf

    other_keys = [uuid.uuid4().hex for _ in range(1000000)]
    fp = 0
    for k in other_keys:
        fp += k in bf
    print(bf.false_positive_prob, fp / len(other_keys))


The BloomFilter class
---------------------

A simple but fast bloom filter.
Elements must be strings.

Add an element and check whether it is contained::

    bf = BloomFilter(1000)
    bf += 'hellobloom'
    assert 'hellobloom' in bf

``false_positive_prob`` defaults to ``1 / num_elements``.

The number of bits in the filter is
``num_bits = num_elements * log(false_positive_prob) / log(1 / 2**log(2))``,
rounded to the next highest multiple of 8.

The number of hash functions used is
``num_hashes = round(num_bits / num_elements * log(2))`` .

Parameters:
    num_elements: expected max number of elements in the filter
    false_positive_prob: desired approximate false positive probability


``BloomFilter.__iadd__`` / add element
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the "inplace add" syntax to add elements ``bf += k``,
where bf is the ``BloomFilter`` and ``k`` a string.


``BloomFilter.__contains__`` / contains element
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the "contains" syntax to check if an element is (probably)
in the filter ``k in bf``,
where bf is the ``BloomFilter`` and ``k`` a string.


``BloomFilter.load``
~~~~~~~~~~~~~~~~~~~~

Load a filter from a path or file-like::

    bf = BloomFilter.load('bloom.filter')

    with open('bloom.filter', 'rb') as fp:
        bf = BloomFilter.load(fp)

Parameters:
    - fp: path or file-like


``BloomFilter.loads``
~~~~~~~~~~~~~~~~~~~~~

Load a filter from a buffer::

    data = bf.dumps()
    bf = BloomFilter.loads(data)

Parameters:
    data: filter data


``BloomFilter.dump``
~~~~~~~~~~~~~~~~~~~~

Dump filter to a path or file-like::

    bf.dump('bloom.filter')

    with open('bloom.filter', 'wb') as fp:
        bf.dump(fp)

Parameters:
    - fp: path or file-like


``BloomFilter.dumps``
~~~~~~~~~~~~~~~~~~~~~

Returns filter data as buffer::

    data = bf.dumps()
    bf = BloomFilter.loads(data)


Developing
----------

Extension code is generated by Cython.
Install Cython to make and build changes to the extension.
