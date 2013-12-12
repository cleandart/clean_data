// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//TODO refactor for DataList

library data_list_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:clean_data/clean_data.dart';

void main() {
  //TODO
  group('(DataList)', () {

    test('initialize. (T01)', () {
      // when
      var data = new Data();

      // then
      expect(data.isEmpty, isTrue);
      expect(data.isNotEmpty, isFalse);
      expect(data.length, 0);
    });

    test('initialize with data. (T02)', () {
      // given
      var data = {
        'key1': 'value1',
        'key2': 'value2',
        'key3': 'value3',
      };

      // when
      var dataObj = new Data.from(data);

      // then
      expect(dataObj.isEmpty, isFalse);
      expect(dataObj.isNotEmpty, isTrue);
      expect(dataObj.length, equals(data.length));
      expect(dataObj.keys, equals(data.keys));
      expect(dataObj.values, equals(data.values));
      for (var key in data.keys) {
        expect(dataObj[key], equals(data[key]));
      }
    });

    test('is accessed like a list. (T03)', () {
      // given

      // when

      // then
    });

    test('remove multiple indexes. (T04)', () {
      // given

      // when

      // then
    });

    test('add multiple items. (T05)', () {
      // given

      // when

      // then
    });

    test('listen on multiple indexes removed. (T06)', () {
      // given
      var data = {'key1': 'value1', 'key2': 'value2', 'key3': 'value3'};
      var keysToRemove = ['key1', 'key2'];
      var dataObj = new Data.from(data);
      var mock = new Mock();
      dataObj.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataObj.removeAll(keysToRemove, author: 'John Doe');

      // then sync onChange propagates information about all changes and
      // removals

      //then
      mock.getLogs().verify(happenedOnce);
      var event = mock.getLogs().first.args[0];
      expect(event['author'], equals('John Doe'));
      var changeSet = event['change'];
      expect(changeSet.removedItems, unorderedEquals(keysToRemove));

      // but async onChange drops information about changes in removed items.
      dataObj.onChange.listen(expectAsync1((changeSet) {
        expect(changeSet.removedItems, unorderedEquals(keysToRemove));
        expect(changeSet.addedItems.isEmpty, isTrue);
        expect(changeSet.changedItems.isEmpty, isTrue);
      }));

    });

    //TODO -adding after particular index (insertAll)
    test('listen on multiple elements added. (T07)', () {
      // given
      var data = {'key1': 'value1', 'key2': 'value2', 'key3': 'value3'};
      var dataObj = new Data();
      var mock = new Mock();
      dataObj.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataObj.addAll(data, author: 'John Doe');

      // then sync onChange propagates information about all changes and
      // adds

      mock.getLogs().verify(happenedOnce);
      var event = mock.getLogs().first.args.first;
      expect(event['author'], equals('John Doe'));

      var changeSet = event['change'];
      expect(changeSet.removedItems.isEmpty, isTrue);
      expect(changeSet.addedItems, unorderedEquals(data.keys));
      expect(changeSet.changedItems.length, equals(3));

      // but async onChange drops information about changes in added items.
      dataObj.onChange.listen(expectAsync1((changeSet) {
        expect(changeSet.addedItems, unorderedEquals(data.keys));
        expect(changeSet.removedItems.isEmpty, isTrue);
        expect(changeSet.changedItems.isEmpty, isTrue);
      }));

    });

    test('listen on element added. (T08)', () {
      // given
      var dataObj = new Data();

      // when
      dataObj['key'] = 'value';

      // then
      dataObj.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.isEmpty, isTrue);
        expect(event.removedItems.isEmpty, isTrue);
        expect(event.addedItems, equals(['key']));
      }));

    });

    test('listen synchronously on element added. (T09)', () {
      // given
      var dataObj = new Data();
      var mock = new Mock();
      dataObj.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataObj.add('key', 'value', author: 'John Doe');

      // then
      mock.getLogs().verify(happenedOnce);
      var event = mock.getLogs().first.args[0];
      expect(event['author'], equals('John Doe'));
      expect(event['change'].addedItems, equals(['key']));
      expect(event['change'].changedItems.keys, equals(['key']));
    });

    test('listen synchronously on multiple elements added. (T10)', () {
      // given
      var dataObj = new Data();
      var mock = new Mock();
      dataObj.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataObj['key1'] = 'value1';
      dataObj['key2'] = 'value2';

      // then
      mock.getLogs().verify(happenedExactly(2));
      var event1 = mock.getLogs().logs[0].args.first;
      var event2 = mock.getLogs().logs[1].args.first;
      expect(event1['change'].addedItems, equals(['key1']));
      expect(event2['change'].addedItems, equals(['key2']));
    });

    test('listen on index removed. (T11)', () {
      // given
      var data = {'key': 'value'};
      var dataObj = new Data.from(data);

      // when
      dataObj.remove('key');

      // then
      dataObj.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.isEmpty, isTrue);
        expect(event.addedItems.isEmpty, isTrue);
        expect(event.removedItems, unorderedEquals(['key']));
      }));

    });

    test('listen synchronously on index removed. (T12)', () {
      // given
      var dataObj = new Data.from({'key': 'value'});
      var mock = new Mock();
      dataObj.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataObj.remove('key', author: 'John Doe');

      // then
      mock.getLogs().verify(happenedOnce);
      var event = mock.getLogs().logs.first.args.first;
      expect(event['author'], equals('John Doe'));
      expect(event['change'].addedItems.isEmpty, isTrue);
      expect(event['change'].removedItems, unorderedEquals(['key']));
      expect(event['change'].changedItems.length, equals(1));

    });

    test('listen on {index, element} changed. (T13)', () {
      // given
      var data = {'key': 'oldValue'};
      var dataObj = new Data.from(data);

      // when
      dataObj['key'] = 'newValue';

      // then
      dataObj.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.addedItems.isEmpty, isTrue);
        expect(event.removedItems.isEmpty, isTrue);
        expect(event.changedItems.length, equals(1));
        var change = event.changedItems['key'];
        expect(change.oldValue, equals('oldValue'));
        expect(change.newValue, equals('newValue'));
      }));
    });

    test('propagate multiple changes in single [ChangeSet]. (T14)', () {
      // given
      var data = {'key1': 'value1', 'key2': 'value2'};
      var dataObj = new Data.from(data);

      // when
      dataObj['key1'] = 'newValue1';
      dataObj.remove('key2');
      dataObj['key3'] = 'value3';

      // then
      dataObj.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals(['key1']));
        expect(event.removedItems, unorderedEquals(['key2']));
        expect(event.addedItems, unorderedEquals(['key3']));
      }));
    });


    test('when element is added then changed, only addition is in the [ChangeSet]. (T15)', () {
      // given
      var data = {'key1': 'value1', 'key2': 'value2'};
      var dataObj = new Data.from(data);

      // when
      dataObj['key3'] = 'John Doe';
      dataObj['key3'] = 'John Doe II.';

      // then
      dataObj.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.addedItems, unorderedEquals(['key3']));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });


    test('when existing {index, element} is removed then re-added, this is a change. (T16)', () {
      // given
      var data = {'key1': 'value1', 'key2': 'value2'};
      var dataObj = new Data.from(data);

      // when
      dataObj.remove('key1');
      dataObj['key1'] = 'John Doe II.';

      // then
      dataObj.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals(['key1']));

        Change change = event.changedItems['key1'];
        expect(change.oldValue, equals('value1'));
        expect(change.newValue, equals('John Doe II.'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    test('when {index, element} is changed then removed, only deletion is in the [ChangeSet]. (T17)', () {
      // given
      var data = {'key1': 'value1', 'key2': 'value2'};
      var dataObj = new Data.from(data);

      dataObj['key1'] = 'John Doe';

      // when
      dataObj.remove('key1');

      // then
      dataObj.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals(['key1']));
      }));
    });

    test('when {index, element} is added then removed, no changes are broadcasted. (T18)', () {
      // given
      var data = {'key1': 'value1', 'key2': 'value2'};
      var dataObj = new Data.from(data);

      // when
      dataObj['key3'] = 'John Doe';
      dataObj.remove('key3');

      // then
      dataObj.onChange.listen(protectAsync1((e) => expect(true, isFalse)));
    });

    test('when {element} is added, changed then removed, no changes are broadcasted. (T19)', () {
      // given
      var data = {'key1': 'value1', 'key2': 'value2'};
      var dataObj = new Data.from(data);

      // when
      dataObj['key3'] = 'John Doe';
      dataObj['key3'] = 'John Doe II';
      dataObj.remove('key3');

      // then
      dataObj.onChange.listen(protectAsync1((e) => expect(true, isFalse)));
    });

    test(' implements List.clear(). (T20)', () {
      //TODO
    });

    /**
     * Returns an [Iterable] of the objects in this list in reverse order.
     */
    test(' implements List.reversed(). (T20)', () {
      //TODO
    });

    /**
     * Removes the objects in the range [start] inclusive to [end] exclusive
     * and replaces them with the contents of the [iterable].
     */
    test(' implements List.replaceRange(). (T20)', () {
      //TODO
    });

    /**
     * Returns an [Iterable] that iterates over the objects in the range
     * [start] inclusive to [end] exclusive.
     */
    test(' implements List.getRange(). (T20)', () {
      //TODO
    });

    /**
     * Overwrites objects of `this` with the objects of [iterable], starting
     * at position [index] in this list.
     */
    test(' implements List.setAll(). (T20)', () {
      //TODO
    });

    /**
     * Returns the last index of [element] in this list.
     */
    test(' implements List.lastIndexOf(). (T20)', () {
      //TODO
    });

    /**
     * Returns a new list containing the objects from [start] inclusive to [end]
     * exclusive.
     */
    test(' implements List.sublist(). (T20)', () {
      //TODO
    });

    /**
     * Removes the object at position [index] from this list.
     */
    test(' implements List.removeAt(). (T20)', () {
      //TODO
    });

    /**
     * Returns the first index of [element] in this list.
     */
    test(' implements List.indexOf(). (T20)', () {
      //TODO
    });

    /**
     * Removes all objects from this list that satisfy [test].
     */
    //TODO iterable mixin?
    test(' implements List.removeWhere(). (T20)', () {
      //TODO
    });

    /**
     * Removes all objects from this list that fail to satisfy [test].
     */
    test(' implements List.retainWhere(). (T20)', () {
      //TODO
    });

    /**
     * Sorts this list according to the order specified by the [compare] function.
     */
    test(' implements List.sort(). (T20)', () {
      //TODO
    });

    /**
     * Sets the objects in the range [start] inclusive to [end] exclusive
     * to the given [fillValue].
     */
    test(' implements List.fillRange(). (T20)', () {
      //TODO
    });

    /**
     * Shuffles the elements of this list randomly.
     */
    test(' implements List.shuffle(). (T20)', () {
      //TODO
    });

    /**
     * Inserts all objects of [iterable] at position [index] in this list.
     */
    test(' implements List.insertAll(). (T20)', () {
      //TODO
    });

    /**
     * Inserts the object at position [index] in this list.
     */
    test(' implements List.insert(). (T20)', () {
      //TODO
    });

    /**
     * Returns an unmodifiable [Map] view of `this`.
    *
     * The map uses the indices of this list as keys and the corresponding objects
     * as values. The `Map.keys` [Iterable] iterates the indices of this list
     * in numerical order.
     */
    test(' implements List.asMap(). (T20)', () {
      //TODO
    });

    /**
     * Pops and returns the last object in this list.
     */
    test(' implements List.removeLast(). (T20)', () {
      //TODO
    });

    /**
     * Removes the objects in the range [start] inclusive to [end] exclusive.
     */
    test(' implements List.removeRange(). (T20)', () {
      //TODO
    });

    /**
     * Copies the objects of [iterable], skipping [skipCount] objects first,
     * into the range [start] inclusive to [end] exclusive of `this`.
     */
    test(' implements List.setRange(). (T20)', () {
      //TODO
    });
 });
}