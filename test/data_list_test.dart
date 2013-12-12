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
      DataList dataList = new DataList();

      // then
      expect(dataList.isEmpty, isTrue);
      expect(dataList.isNotEmpty, isFalse);
      expect(dataList.length, 0);
    });

    test('element added like a list. (T02)', () {
      // given
      DataList dataList = new DataList();

      // when
      dataList.add('element1');

      // then
      expect(dataList.isEmpty, isFalse);
      expect(dataList.isNotEmpty, isTrue);
      expect(dataList.length, 1);
    });

    test('is accessed like a list. (T03)', () {
      // given
      DataList dataList = new DataList();
      dataList.add('element1');

      // when & then
      expect(dataList[0], equals('element1'));
    });

    test('initialize with data. (T04)', () {
      // given
      var list = ['element1', 'element2', 'element3'];

      // when
      DataList dataList = new DataList.from(list);

      // then
      expect(dataList.isEmpty, isFalse);
      expect(dataList.isNotEmpty, isTrue);
      expect(dataList.length, equals(list.length));
      for(int i=0; i<dataList.length ; i++) {
        expect(dataList[i], equals(list[i]));
      }
    });

    test('add multiple items. (T05)', () {
      // given
      var list = ['element1', 'element2', 'element3'];
      DataList dataList = new DataList();

      // when
      dataList.addAll(list);

      // then
      expect(dataList.isEmpty, isFalse);
      expect(dataList.isNotEmpty, isTrue);
      expect(dataList.length, equals(list.length));
      for(int i=0; i<dataList.length ; i++) {
        expect(dataList[i], equals(list[i]));
      }
    });

    test('listen on element added. (T08)', () {
      // given
      DataList dataList = new DataList();

      // when
      dataList.add('element');

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.isEmpty, isTrue);
        expect(event.removedItems.isEmpty, isTrue);
        expect(event.addedItems, equals([0]));
      }));

    });

    test('listen synchronously on element added. (T09)', () {
      // given
      DataList dataList = new DataList();
      var mock = new Mock();
      dataList.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataList.add('element', author: 'John Doe');

      // then
      mock.getLogs().verify(happenedOnce);
      var event = mock.getLogs().first.args[0];
      expect(event['author'], equals('John Doe'));
      expect(event['change'].addedItems, equals([0]));
      expect(event['change'].changedItems.keys, equals([0]));
    });

    test('listen synchronously on multiple elements added. (T10)', () {
      // given
      DataList dataList = new DataList();
      var mock = new Mock();
      dataList.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataList.add('element1');
      dataList.add('element2');

      // then
      mock.getLogs().verify(happenedExactly(2));
      var event1 = mock.getLogs().logs[0].args.first;
      var event2 = mock.getLogs().logs[1].args.first;
      expect(event1['change'].addedItems, equals([0]));
      expect(event2['change'].addedItems, equals([1]));
    });

    test('listen on index removed. (T11)', () {
      // given
      DataList dataList = new DataList.from(['element1']);

      // when
      dataList.remove(0);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.isEmpty, isTrue);
        expect(event.addedItems.isEmpty, isTrue);
        expect(event.removedItems, unorderedEquals([0]));
      }));
    });

    test('listen synchronously on index removed. (T12)', () {
      // given
      DataList dataList = new DataList.from(['element1']);
      var mock = new Mock();
      dataList.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataList.remove(0, author: 'John Doe');

      // then
      mock.getLogs().verify(happenedOnce);
      var event = mock.getLogs().logs.first.args.first;
      expect(event['author'], equals('John Doe'));
      expect(event['change'].addedItems.isEmpty, isTrue);
      expect(event['change'].removedItems, unorderedEquals([0]));
      expect(event['change'].changedItems.length, equals(1));
    });

    test('listen on {index, element} changed. (T13)', () {
      // given
      DataList dataList = new DataList.from(['oldElement']);

      // when
      dataList[0] = 'newElement';

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.addedItems.isEmpty, isTrue);
        expect(event.removedItems.isEmpty, isTrue);
        expect(event.changedItems.length, equals(1));
        var change = event.changedItems[0];
        expect(change.oldValue, equals('oldElement'));
        expect(change.newValue, equals('newElement'));
      }));
    });

    test('propagate multiple changes in single [ChangeSet]. (T14)', () {
      // given
      DataList dataList = new DataList.from(['element1', 'element2']);

      // when
      dataList[0] = 'newElement1';
      dataList.remove(1);
      dataList.add('newElement2');

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([0]));
        //TODO consult
        expect(event.removedItems, unorderedEquals([1]));
        expect(event.addedItems, unorderedEquals([1]));
      }));
    });

    //TODO -listening on adding after particular index (insertAll)

    test('listen on multiple elements added. (T15)', () {
      // given
      List list = ['element1', 'element2', 'element3'];
      DataList dataList = new DataList();
      var mock = new Mock();
      dataList.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataList.addAll(list, author: 'John Doe');

      // then sync onChange propagates information about all changes and
      // adds

      mock.getLogs().verify(happenedOnce);
      var event = mock.getLogs().first.args.first;
      expect(event['author'], equals('John Doe'));

      var changeSet = event['change'];
      expect(changeSet.removedItems.isEmpty, isTrue);
      expect(changeSet.addedItems, unorderedEquals(list));
      expect(changeSet.changedItems.length, equals(3));

      // but async onChange drops information about changes in added items.
      dataList.onChange.listen(expectAsync1((changeSet) {
        expect(changeSet.addedItems, unorderedEquals(list.keys));
        expect(changeSet.removedItems.isEmpty, isTrue);
        expect(changeSet.changedItems.isEmpty, isTrue);
      }));

    });

    test('listen sync & async on multiple indexes removed. (T16)', () {
      // given
      DataList dataList = new DataList.from(['element1', 'element2', 'element3']);
      var mock = new Mock();
      dataList.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataList.removeAll([0,1], author: 'John Doe');

      //then
      mock.getLogs().verify(happenedOnce);
      var event = mock.getLogs().first.args[0];
      expect(event['author'], equals('John Doe'));
      var changeSet = event['change'];
      expect(changeSet.removedItems, unorderedEquals([0,1]));

      // but async onChange drops information about changes in removed items.
      dataList.onChange.listen(expectAsync1((changeSet) {
        expect(changeSet.removedItems, unorderedEquals([0,1]));
        expect(changeSet.addedItems.isEmpty, isTrue);
        expect(changeSet.changedItems.isEmpty, isTrue);
      }));
    });

    test('when element is added then changed, only addition is in the [ChangeSet]. (T17)', () {
      // given
      DataList dataList = new DataList();

      // when
      dataList.add('oldElement');
      dataList[0] = 'newElement';

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.addedItems, unorderedEquals([0]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });


    test('when existing {index, element} is removed then re-added, this is a change. (T16)', () {
      // given
      DataList dataList = new DataList.from(['oldElement']);

      // when
      dataList.remove(0);
      dataList[0] = 'newElement';

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([0]));

        Change change = event.changedItems[0];
        expect(change.oldValue, equals('oldElement'));
        expect(change.newValue, equals('newElement'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    //TODO what should happen if remove(2); remove(2); remove(2) ?
    //TODO add add, remove from middle (also add remove multiple)

    test('when {index, element} is changed then removed, only deletion is in the [ChangeSet]. (T17)', () {
      // given
      DataList dataList = new DataList.from(['oldElement']);

      // when
      dataList[0] = 'newElement';
      dataList.remove(0);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([0]));
      }));
    });

    test('when {index, element} is added then removed, no changes are broadcasted. (T18)', () {
      // given
      DataList dataList = new DataList();

      // when
      dataList.add('element');
      dataList.remove(0);

      // then
      dataList.onChange.listen(protectAsync1((e) => expect(true, isFalse)));
    });

    test('when {element} is added, changed then removed, no changes are broadcasted. (T19)', () {
      // given
      DataList dataList = new DataList();

      // when
      dataList.add('oldElement');
      dataList[0] = 'newElement';
      dataList.remove(0);

      // then
      dataList.onChange.listen(protectAsync1((e) => expect(true, isFalse)));
    });

    test('remove multiple indexes. (T04)', () {
      // given

      // when

      // then
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