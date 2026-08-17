# KnowMe stable-hash specifications

## Mirror stable hash v1

`ThaiMirrorStableHash.string` processes Dart UTF-16 code units with Jenkins one-at-a-time mixing. Every add, shift and XOR stage is masked to unsigned 32 bits. Final output is masked to the low 30 bits and zero is mapped to one. `strings` combines each independently hashed string in caller-provided order, finalizes once, and applies the same low-30/zero rule.

This is an application contract; it does not depend on Dart runtime hash guarantees. UTF-16 is intentional, so BMP characters, combining marks and surrogate pairs have frozen integer vectors.

## Thai Beta narrative stable hash

`ThaiBetaNarrativeStableHash.fnv1a32` is FNV-1a over UTF-16 code units with exact low-32-bit XOR and multiplication after every unit. `seedOffset` combines stable string IDs in order. It never consumes `String.hashCode`.

## Arithmetic contract

- `unsigned32`: mask with `0xFFFFFFFF`.
- `signed32`: interpret bit 31 using the explicit `2^32` range.
- `multiply32`: multiply 16-bit halves and retain the exact low 32 bits.
- `xor32`: XOR unsigned 32-bit operands.
- `exactXor`/`exactXorAll`: use `BigInt` and reject results beyond the exact 53-bit selection range.
- `exactXorProductModulo`: evaluate the product, XOR, absolute value and modulo using `BigInt` before conversion to `int`.

## Fixed vectors

The one shared expected-value table covers empty, ASCII, Thai, Thai combining marks, BMP Unicode, emoji/surrogate pairs, long text, real theme IDs, real Lagna keys, multiple strings, repeated strings, ordering changes, and arithmetic edges `0`, `1`, `0x7FFFFFFF`, `0x80000000`, `0xFFFFFFFF`, overflow-producing values and `-2147483648`.

The VM and compiled-JavaScript/Chrome outputs in `stable-hash-vectors-vm.json` and `stable-hash-vectors-chrome.json` are byte-for-byte equivalent after runtime/run-label metadata is excluded. Expected integers are shared; there are no runtime-specific expected values.
