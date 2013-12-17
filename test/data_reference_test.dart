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
      
      var check = expectAsync1((ChangeSet event) {
        expect(event.changedItems.length, equals(1));
        expect(event.changedItems.containsKey('value'), isTrue);
        expect(event.changedItems['value'].oldValue , equals('oldValue'));
        expect(event.changedItems['value'].newValue , equals('newValue'));

        expect(event.addedItems.length, equals(0));
        expect(event.removedItems.length, equals(0));
      });
      
      ref.onChange.listen(check);
      ref.value = 'newValue';
    });
    
    test('Listen on changeSync(T04)', () {
      DataReference ref = new DataReference('oldValue');
      
      var check = expectAsync1((ChangeSet event) {
        expect(event.changedItems.length, equals(1));
        expect(event.changedItems.containsKey('value'), isTrue);
        expect(event.changedItems['value'].oldValue , equals('oldValue'));
        expect(event.changedItems['value'].newValue , equals('newValue'));
        
        expect(event.addedItems.length, equals(0));
        expect(event.removedItems.length, equals(0));
      });
      
      ref.onChange.listen(check);
      ref.value = 'newValue';
    });
  });
}