// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//TODO refactor for DataList

library data_list_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:clean_data/clean_data.dart';

int GROUP_CHANGED = 0;
int GROUP_ADDED = 1;
int GROUP_REMOVED = 2;
List groupChanges(Mock mock, int size){
  List result = [[],[],[]];
  var event1 = mock.getLogs().logs.forEach((log){
    var change = log.args.first['change'];
    result[GROUP_CHANGED].addAll(change.changedItems.keys);
    result[GROUP_ADDED].addAll(change.addedItems);
    result[GROUP_REMOVED].addAll(change.removedItems);
  });
  return result;
}

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

    test('element added like in list. (T02)', () {
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

    test('remove multiple indexes. (T06)', () {
      // given
      var list = ['element1', 'element2', 'element3'];
      DataList dataList = new DataList();

      // when
      dataList.removeAt(2);
      dataList.removeAt(1);
      dataList.removeAt(0);

      // then
      expect(dataList.isEmpty, isTrue);
      expect(dataList.isNotEmpty, isFalse);
      expect(dataList.length, 0);
    });

    /*
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
      dataList.removeAt(0);

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
      dataList.removeAt(0, author: 'John Doe');

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
      dataList.add('newElement3');

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([0]));
        expect(event.removedItems, unorderedEquals([]));
        expect(event.addedItems, unorderedEquals([1]));
      }));
    });

    test('propagate multiple changes in single [ChangeSet]. (T14.5)', () {
      // given
      DataList dataList = new DataList.from(['element1', 'element2']);

      // when
      dataList[0] = 'newElement1';
      dataList.removeAt(1);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([0]));
        expect(event.removedItems, unorderedEquals([1]));
        expect(event.addedItems, unorderedEquals([]));
      }));
    });

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


    test('when existing {index, element} is removed then re-added, this is a change. (T18', () {
      // given
      DataList dataList = new DataList.from(['oldElement']);

      // when
      dataList.removeAt(0);
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

    test('when {index, element} is changed then removed, only deletion is in the [ChangeSet]. (T19)', () {
      // given
      DataList dataList = new DataList.from(['oldElement']);

      // when
      dataList[0] = 'newElement';
      dataList.removeAt(0);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([0]));
      }));
    });

    test('when {index, element} is added then removed, no changes are broadcasted. (T20)', () {
      // given
      DataList dataList = new DataList();

      // when
      dataList.add('element');
      dataList.removeAt(0);

      // then
      dataList.onChange.listen(protectAsync1((e) => expect(true, isFalse)));
    });

    test('when {element} is added, changed then removed, no changes are broadcasted. (T21)', () {
      // given
      DataList dataList = new DataList();

      // when
      dataList.add('oldElement');
      dataList[0] = 'newElement';
      dataList.removeAt(0);

      // then
      dataList.onChange.listen(protectAsync1((e) => expect(true, isFalse)));
    });

    test('listen elements inserted to middle. (T22)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3']);
      var mock = new Mock();
      dataList.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataList.insert(1, 'element1.5');

      // then
      mock.getLogs().verify(happenedExactly(3));
      var changes = groupChanges(mock, 3);
      expect(changes[GROUP_CHANGED], unorderedEquals([1,2]));
      expect(changes[GROUP_ADDED], unorderedEquals([3]));
      expect(changes[GROUP_REMOVED], unorderedEquals([]));
    });

    test('listen multiple elements inserted to middle. (T23)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3']);

      // when
      dataList.insert(1, 'element1.5');
      dataList.insert(1, 'element1.25');

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1,2]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('element1.25'));

        Change change2 = event.changedItems[1];
        expect(change2.oldValue, equals('element3'));
        expect(change2.newValue, equals('element1.5'));

        expect(event.addedItems, unorderedEquals([3,4]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    test('listen elements removed from middle. (T24)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);
      var mock = new Mock();
      dataList.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataList.removeAt(1);

      // then
      mock.getLogs().verify(happenedExactly(3));
      var changes = groupChanges(mock, 3);
      expect(changes[GROUP_CHANGED], unorderedEquals([1,2]));
      expect(changes[GROUP_ADDED], unorderedEquals([]));
      expect(changes[GROUP_REMOVED], unorderedEquals([3]));
    });

    test('listen remove multiple elements from middle. (T25)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4', 'element5']);

      // when
      dataList.removeAt(1);
      dataList.removeAt(1);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1,2]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('element4'));

        Change change2 = event.changedItems[1];
        expect(change2.oldValue, equals('element3'));
        expect(change2.newValue, equals('element5'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([3,4]));
      }));
    });

    test('removing multiple from middle and then reading same makes no change. (T26)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4', 'element5']);

      // when
      dataList.removeAt(1);
      dataList.removeAt(1);
      dataList.insert(1, 'element3');
      dataList.insert(1, 'element2');

      // then
      dataList.onChange.listen(protectAsync1((ChangeSet event) {
        expect(true, isFalse);
      }));
    });

    test(' implements List.clear(). (T27)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3']);

      // when
      dataList.clear();

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([0,1,2]));
      }));
    });

    /**
     * Returns an [Iterable] of the objects in this list in reverse order.
     */
    test(' implements List.reversed(). (T28)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3']);
      var mock = new Mock();

      // when
      List reversed = dataList.reversed;

      // then
      expect(reversed, equals(['element3','element2', 'element1']));
    });

    /**
     * Removes the objects in the range [start] inclusive to [end] exclusive
     * and replaces them with the contents of the [iterable].
     */
    test(' implements List.replaceRange(). (T29)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.replaceRange(1, 3, ['new2', 'new3']);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1,2]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('new2'));

        Change change2 = event.changedItems[1];
        expect(change2.oldValue, equals('element3'));
        expect(change2.newValue, equals('new3'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    /**
     * Returns an [Iterable] that iterates over the objects in the range
     * [start] inclusive to [end] exclusive.
     */
    test(' implements List.getRange(). (T30)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      var range = dataList.getRange(1, 3);

      // then
      expect(range, equals(['element1', 'element2']));
    });

    /**
     * Overwrites objects of `this` with the objects of [iterable], starting
     * at position [index] in this list.
     */
    test(' implements List.setAll(). (T31)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.setAll(1, ['new2', 'new3']);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1,2]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('new2'));

        Change change2 = event.changedItems[1];
        expect(change2.oldValue, equals('element3'));
        expect(change2.newValue, equals('new3'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    /**
     * Returns the last index of [element] in this list.
     */
    test(' implements List.lastIndexOf(). (T32)', () {
      // given
      DataList dataList = new DataList.from(['element','element', 'kitty']);

      // when
      var index = dataList.lastIndexOf('element');

      // then
      expect(index, equals(1));
    });

    /**
     * Returns a new list containing the objects from [start] inclusive to [end]
     * exclusive.
     */
    test(' implements List.sublist(). (T33)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      var range = dataList.sublist(1, 3);

      // then
      expect(range, equals(['element1', 'element2']));
    });

    /**
     * Returns the first index of [element] in this list.
     */
    test(' implements List.indexOf(). (T35)', () {
      // given
      DataList dataList = new DataList.from(['kitty','element', 'element']);

      // when
      var index = dataList.indexOf('element');

      // then
      expect(index, equals(1));
    });

    /**
     * Removes all objects from this list that satisfy [test].
     */
    test(' implements List.removeWhere(). (T36)', () {
      // given
      DataList dataList = new DataList.from(['element1','doge', 'doge', 'element4']);

      // when
      dataList.removeWhere((el) => el == 'doge');

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('doge'));
        expect(change1.newValue, equals('element4'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([2,3]));
      }));
    });

    /**
     * Removes all objects from this list that fail to satisfy [test].
     */
    test(' implements List.retainWhere(). (T37)', () {
      // given
      DataList dataList = new DataList.from(['kitty','element2', 'element3', 'kitty']);

      // when
      dataList.retainWhere((el) => el == 'kitty');

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('kitty'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([2,3]));
      }));
    });

    /**
     * Sorts this list according to the order specified by the [compare] function.
     */
    test(' implements List.sort(). (T38)', () {
      // given
      DataList dataList = new DataList.from(['element2','element4', 'element3', 'element1']);

      // when
      dataList.sort();

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([0,1,3]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('element1'));

        Change change2 = event.changedItems[1];
        expect(change2.oldValue, equals('element4'));
        expect(change2.newValue, equals('element2'));

        Change change3 = event.changedItems[2];
        expect(change3.oldValue, equals('element1'));
        expect(change3.newValue, equals('element4'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    /**
     * Sets the objects in the range [start] inclusive to [end] exclusive
     * to the given [fillValue].
     */
    test(' implements List.fillRange(). (T39)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.fillRange(1, 3, 'kitty');

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1,2]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('kitty'));

        Change change2 = event.changedItems[1];
        expect(change2.oldValue, equals('element3'));
        expect(change2.newValue, equals('kitty'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    /**
     * Shuffles the elements of this list randomly.
     */
    test(' implements List.shuffle(). (T40)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.shuffle();

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        //TODO changed items

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    /**
     * Inserts all objects of [iterable] at position [index] in this list.
     */
    test(' implements List.insertAll(). (T41)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.insertAll(1, ['kitty', 'doge']);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1,2,3]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('kitty'));

        Change change2 = event.changedItems[1];
        expect(change2.oldValue, equals('element3'));
        expect(change2.newValue, equals('doge'));

        Change change3 = event.changedItems[3];
        expect(change3.oldValue, equals('element4'));
        expect(change3.newValue, equals('element2'));


        expect(event.addedItems, unorderedEquals([4,5]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    /**
     * Returns an unmodifiable [Map] view of `this`.
    *
     * The map uses the indices of this list as keys and the corresponding objects
     * as values. The `Map.keys` [Iterable] iterates the indices of this list
     * in numerical order.
     */
    test(' implements List.asMap(). (T42)', () {
      //TODO should be as clean_data.Data ?
    });

    /**
     * Pops and returns the last object in this list.
     */
    test(' implements List.removeLast(). (T43)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.removeLast();

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([3]));
      }));
    });

    /**
     * Removes the objects in the range [start] inclusive to [end] exclusive.
     */
    test(' implements List.removeRange(). (T44)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.removeRange(1,3);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('element4'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([2,3]));
      }));
    });

    /**
     * Copies the objects of [iterable], skipping [skipCount] objects first,
     * into the range [start] inclusive to [end] exclusive of `this`.
     */
    test(' implements List.setRange(). (T45)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.setRange(1,3, ['kid', 'kitty', 'doge'], 1);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1,2]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('kitty'));

        Change change2 = event.changedItems[1];
        expect(change2.oldValue, equals('element3'));
        expect(change2.newValue, equals('doge'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });
    */
 });
}