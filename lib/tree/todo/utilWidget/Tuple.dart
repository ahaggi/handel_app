/// Find the original package implementation on  https://pub.dev/packages/tuple

// Copyright (c) 2014, the tuple project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

/// Represents a 2-tuple, or pair.
class Tuple<T1, T2> {
  /// Returns the first item of the tuple
  final T1 id;

  /// Returns the second item of the tuple
  final T2 txt;

  /// Creates a new tuple value with the specified items.
  const Tuple(this.id, this.txt);


  List toList({bool growable: false}) =>
      new List.from([id, txt], growable: growable);
 

  bool operator ==(o) {
    return o is Tuple && o.id == id && o.txt == txt;
  }
 
}
