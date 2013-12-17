// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library data_reference_test;

import 'package:unittest/unittest.dart';
import 'package:clean_data/clean_data.dart';
import 'package:unittest/mock.dart';
import 'dart:async';


void main() {

  group('(DataReference)', () {

    test('Getter (T01)', () {
      DataReference ref = new DataReference('value');
      expect(ref.value, 'value');
    });
    
    test('Setter (T02)', () {
      DataReference ref = new DataReference('value');
      ref.value = 'newValue';
      expect(ref.value, 'newValue');
    });
    
    
    test('Listen on change (T03)', () {
      DataReference ref = new DataReference('oldValue');
      
      ref.onChange.listen(expectAsync1((Change event) {
        expect(event.oldValue , equals('oldValue'));
        expect(event.newValue , equals('newValue'));
      }));
      
      ref.value = 'newValue';
    });
    
    test('Listen on changeSync(T04)', () {
      DataReference ref = new DataReference('oldValue');
      
      ref.onChangeSync.listen(expectAsync1((event) {
        expect(event['change'].oldValue , equals('oldValue'));
        expect(event['change'].newValue , equals('newValue'));
      }));
      
      ref.value = 'newValue';
    });
  });
}