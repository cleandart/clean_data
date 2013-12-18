// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library data_list_test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:clean_data/clean_data.dart';

void main() {
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

    test('range test. (T06a)', () {
      // given
      DataList dataList = new DataList.from(['element1', 'element2', 'element3']);

      // when
      expect(() => dataList.removeRange(-1, 1), throwsArgumentError);
      expect(() => dataList.removeRange(1, 0), throwsArgumentError);
      expect(() => dataList.removeRange(1, 4), throwsArgumentError);
    });

    test('remove multiple indexes. (T06b)', () {
      // given
      DataList dataList = new DataList.from(['element1', 'element2', 'element3']);

      // when
      dataList.removeAt(2);
      dataList.removeAt(1);
      dataList.removeAt(0);

      // then
      expect(dataList.isEmpty, isTrue);
      expect(dataList.isNotEmpty, isFalse);
      expect(dataList.length, 0);
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
      dataList.removeAt(0);

      // then
      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.addedItems, unorderedEquals([]));
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
        expect(event.addedItems, unorderedEquals([2]));
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
      expect(changeSet.addedItems, unorderedEquals([0,1,2]));
      expect(changeSet.changedItems.length, equals(3));

      // but async onChange drops information about changes in added items.
      dataList.onChange.listen(expectAsync1((changeSet) {
        expect(changeSet.addedItems, unorderedEquals([0,1,2]));
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
      dataList.removeRange(1,3, author: 'John Doe');

      //then
      mock.getLogs().verify(happenedOnce);
      var event = mock.getLogs().first.args[0];
      expect(event['author'], equals('John Doe'));
      var changeSet = event['change'];
      expect(changeSet.removedItems, unorderedEquals([1,2]));

      // but async onChange drops information about changes in removed items.
      dataList.onChange.listen(expectAsync1((changeSet) {
        expect(changeSet.removedItems, unorderedEquals([1,2]));
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
      dataList.add('newElement');

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
      expect(new List.from(dataList), unorderedEquals(
          ['element1','element1.5', 'element2', 'element3']));

      mock.getLogs().verify(happenedExactly(1));
      var change = mock.getLogs().logs.first.args.first['change'];
      expect(change.changedItems.keys, unorderedEquals([1,2,3]));
      expect(change.addedItems, unorderedEquals([3]));
      expect(change.removedItems, unorderedEquals([]));
    });

    test('listen multiple elements inserted to middle. (T23)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2']);
      var mock = new Mock();
      dataList.onChangeSync.listen((event) => mock.handler(event));

      // when
      dataList.insertAll(1, ['element1.1', 'element1.25', 'element1.5']);

      // then
      expect(new List.from(dataList), unorderedEquals(
          ['element1', 'element1.1', 'element1.25', 'element1.5', 'element2']));

      mock.getLogs().verify(happenedExactly(1));
      var change = mock.getLogs().logs.first.args.first['change'];
      expect(change.changedItems.keys, unorderedEquals([1,2,3,4]));

      Change change1 = change.changedItems[1];
      expect(change1.oldValue, equals('element2'));
      expect(change1.newValue, equals('element1.1'));

      Change change2 = change.changedItems[2];
      expect(change2.oldValue, equals(null));
      expect(change2.newValue, equals('element1.25'));

      Change change3 = change.changedItems[3];
      expect(change3.oldValue, equals(null));
      expect(change3.newValue, equals('element1.5'));

      Change change4 = change.changedItems[4];
      expect(change4.oldValue, equals(null));
      expect(change4.newValue, equals('element2'));

      expect(change.addedItems, unorderedEquals([2,3,4]));
      expect(change.removedItems, unorderedEquals([]));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1]));

        Change change1 = event.changedItems[1];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('element1.1'));

        expect(event.addedItems, unorderedEquals([2,3,4]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    test('listen multiple elements inserted to beginning. (T23.5)', () {
      // given
      DataList dataList = new DataList.from(['element1', 'element2']);

      // when
      dataList.insertAll(0, ['element0.25', 'element0.5']);

      // then
      expect(new List.from(dataList), unorderedEquals(
          ['element0.25', 'element0.5', 'element1', 'element2']));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([0,1]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element1'));
        expect(change1.newValue, equals('element0.25'));

        Change change2 = event.changedItems[1];
        expect(change2.oldValue, equals('element2'));
        expect(change2.newValue, equals('element0.5'));

        expect(event.addedItems, unorderedEquals([2, 3]));
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
      expect(new List.from(dataList), unorderedEquals(
          ['element1', 'element3', 'element4']));

      mock.getLogs().verify(happenedExactly(1));
      var change = mock.getLogs().logs.first.args.first['change'];
      expect(change.changedItems.keys, unorderedEquals([1,2,3]));
      expect(change.addedItems, unorderedEquals([]));
      expect(change.removedItems, unorderedEquals([3]));
    });

    test('listen remove multiple elements from middle. (T25)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4', 'element5']);

      // when
      dataList.removeAt(1);
      dataList.removeAt(1);

      // then
      expect(new List.from(dataList), unorderedEquals(
          ['element1', 'element4', 'element5']));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1,2]));

        Change change1 = event.changedItems[1];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('element4'));

        Change change2 = event.changedItems[2];
        expect(change2.oldValue, equals('element3'));
        expect(change2.newValue, equals('element5'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([3,4]));
      }));
    });

    test('listen remove multiple elements from beginning. (T25.5)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4', 'element5']);

      // when
      dataList.removeRange(0,3);

      // then
      expect(new List.from(dataList), unorderedEquals(
          ['element4', 'element5']));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([0,1]));

        Change change1 = event.changedItems[0];
        expect(change1.oldValue, equals('element1'));
        expect(change1.newValue, equals('element4'));

        Change change2 = event.changedItems[1];
        expect(change2.oldValue, equals('element2'));
        expect(change2.newValue, equals('element5'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([2,3,4]));
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
      expect(new List.from(dataList), unorderedEquals(
          ['element1','element2', 'element3', 'element4', 'element5']));

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
      expect(new List.from(dataList), unorderedEquals(
          []));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([0,1,2]));
      }));
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
      expect(new List.from(dataList), unorderedEquals(
          ['element1', 'element4']));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1]));

        Change change1 = event.changedItems[1];
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
      expect(new List.from(dataList), unorderedEquals(
          ['kitty', 'kitty']));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1]));

        Change change1 = event.changedItems[1];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('kitty'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([2,3]));
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
      expect(new List.from(dataList), unorderedEquals(
          ['element1', 'kitty', 'doge', 'element2', 'element3', 'element4']));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1,2,3]));

        Change change1 = event.changedItems[1];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('kitty'));

        Change change2 = event.changedItems[2];
        expect(change2.oldValue, equals('element3'));
        expect(change2.newValue, equals('doge'));

        Change change3 = event.changedItems[3];
        expect(change3.oldValue, equals('element4'));
        expect(change3.newValue, equals('element2'));


        expect(event.addedItems, unorderedEquals([4,5]));
        expect(event.removedItems, unorderedEquals([]));
      }));
    });

    test(' implements List.removeLast(). (T43)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.removeLast();

      // then
      expect(new List.from(dataList), unorderedEquals(
          ['element1','element2', 'element3']));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([3]));
      }));
    });

    test(' implements List.removeRange(). (T44)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.removeRange(1,3);

      // then
      expect(new List.from(dataList), unorderedEquals(
          ['element1', 'element4']));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1]));

        Change change1 = event.changedItems[1];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('element4'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([2,3]));
      }));
    });

    test(' implements List.removeRange() from end. (T44.5)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

      // when
      dataList.removeRange(1,4);

      // then
      expect(new List.from(dataList), unorderedEquals(
          ['element1']));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([]));
        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([1,2,3]));
      }));
    });

    test(' removeAll (T46)', () {
      // given
      DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4', 'element5']);

      // when
      dataList.removeAll([1,3]);

      // then
      expect(new List.from(dataList), unorderedEquals(
          ['element1', 'element3', 'element5']));

      dataList.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([1,2]));

        Change change1 = event.changedItems[1];
        expect(change1.oldValue, equals('element2'));
        expect(change1.newValue, equals('element3'));

        Change change2 = event.changedItems[2];
        expect(change2.oldValue, equals('element3'));
        expect(change2.newValue, equals('element5'));

        expect(event.addedItems, unorderedEquals([]));
        expect(event.removedItems, unorderedEquals([3,4]));
      }));
    });

    group('(Nested Data)', () {
      test('listens to changes of its children.', () {
        // given
        DataList dataList = new DataList.from([new Data(), new Data()]);

        // when
        dataList[0]['name'] = 'John Doe';
        dataList[1]['name'] = 'Mills';

        // then
        dataList.onChange.listen(expectAsync1((ChangeSet event) {
          expect(event.changedItems[0].addedItems, equals(['name']));
          expect(event.changedItems[1].addedItems, equals(['name']));
        }));
      });
      /*
      test('listens to changes of its children with insertAll', () {
        // given
        List childs = [new Data(),new Data(),new Data(),new Data()];
        DataList dataList = new DataList.from([childs[0], childs[3]]);

        // when
        dataList.insertAll(1, [childs[1], childs[2]]);
        dataList[0]['name'] = 'John Doe';
        dataList[1]['name'] = 'Mills';
        dataList[2]['name'] = 'Somerset';
        dataList[3]['name'] = 'Tracy';

        // then
        dataList.onChange.listen(expectAsync1((ChangeSet event) {
          expect(event.changedItems[0].addedItems, equals(['name']));
          expect(event.changedItems[1].addedItems, equals(['name']));
          expect(event.changedItems[2].addedItems, equals(['name']));
          expect(event.changedItems[3].addedItems, equals(['name']));
        }));
      });*/

      test('do not listen to removed children changes.', () {
        // given
        var child = new Data();
        DataList dataList = new DataList.from([child]);
        var onChange = new Mock();

        // when
        dataList.removeAt(0);
        var future = new Future.delayed(new Duration(milliseconds: 20), () {
          dataList.onChangeSync.listen((e) => onChange(e));
          child['name'] = 'John Doe';
        });

        // then
        return future.then((_) {
          onChange.getLogs().verify(neverHappened);
        });
      });

      test('do not listen to changed children changes.', () {
        // given
        var childOld = new Data();
        var childNew = new Data();
        DataList dataList = new DataList.from([childOld]);
        var onChange = new Mock();

        // when
        dataList[0] = childNew;
        var future = new Future.delayed(new Duration(milliseconds: 20), () {
          dataList.onChangeSync.listen((e) => onChange(e));
          childOld['name'] = 'John Doe';
        });

        // then
        return future.then((_) {
          onChange.getLogs().verify(neverHappened);
        });
      });

      test('do not listen after remove multiple children with removeRange.', () {
        // given
        var child1 = new Data();
        var child2 = new Data();
        DataList dataList = new DataList.from([new Data(), child1, child2]);
        var onRemove = new Mock();
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onRemove.handler(event));

        // when
        dataList.removeRange(1,3, author: 'John Doe');

        // then
        var future = new Future.delayed(new Duration(milliseconds: 20), () {
          dataList.onChangeSync.listen((e) => onChange(e));
          child1['name'] = 'John Doe';
          child2['name'] = 'Mills';
        });

        future.then((_) {
          onChange.getLogs().verify(neverHappened);
        });

        // but async onChange drops information about changes in removed items.
        dataList.onChange.listen(expectAsync1((changeSet) {
          expect(changeSet.removedItems, unorderedEquals([1,2]));
          expect(changeSet.addedItems.isEmpty, isTrue);
          expect(changeSet.changedItems.isEmpty, isTrue);
        }));
      });

      test('when child Data is added then removed, no changes are broadcasted. (T18)', () {
        // given
        DataList dataList = new DataList();
        var child = new Data();

        // when
        dataList.add(child);
        dataList.removeAt(0);

        // then
        dataList.onChange.listen(protectAsync1((e) => expect(true, isFalse)));
      });

      test('when child Data is removed then added, this is a change.', () {
        // given
        var childOld = new Data();
        var childNew = new Data();
        DataList dataList = new DataList.from([new Data()]);
        var onChange = new Mock();

        // when
        dataList.removeAt(0);
        dataList.insert(0, childNew);

        // then
        dataList.onChange.listen(expectAsync1((ChangeSet event) {
          expect(event.changedItems.keys, unorderedEquals([0]));

          Change change = event.changedItems[0];
          expect(change.oldValue, equals(childOld));
          expect(change.newValue, equals(childNew));

          expect(event.addedItems, unorderedEquals([]));
          expect(event.removedItems, unorderedEquals([]));
        }));
      });

      test('when child Data is removed then added, only one subscription remains.', () {
        // given
        var child = new Data();
        DataList dataList = new DataList.from([new Data()]);
        var onChange = new Mock();

        // when
        dataList.removeAt(0);
        dataList.add(child);

        var future = new Future.delayed(new Duration(milliseconds: 20), () {
          dataList.onChangeSync.listen((e) => onChange(e));
          child['key'] = 'value';
        });

        // then
        return future.then((_) {
          onChange.getLogs().verify(happenedOnce);
        });
      }); 
    });

    //Testing only part of functionality
    group('(Nested DataList)', () {
        test('listens to changes of its children.', () {
          // given
          DataList dataList = new DataList.from([new DataList()]);

          // when
          dataList[0].add('John Doe');

          // then
          dataList.onChange.listen(expectAsync1((ChangeSet event) {
            expect(event.changedItems[0].addedItems, equals([0]));
          }));
        });

        test('do not listen to removed children changes.', () {
          // given
          var child = new DataList();
          DataList dataList = new DataList.from([child]);
          var onChange = new Mock();

          // when
          dataList.remove(0);
          var future = new Future.delayed(new Duration(milliseconds: 20), () {
            dataList.onChangeSync.listen((e) => onChange(e));
            child.add('John Doe');
          });

          // then
          return future.then((_) {
            onChange.getLogs().verify(neverHappened);
          });
        });

        test('do not listen to changed children changes.', () {
          // given
          var childOld = new DataList();
          var childNew = new DataList();
          DataList dataList = new DataList.from([childOld]);
          var onChange = new Mock();

          // when
          dataList[0] = childNew;
          var future = new Future.delayed(new Duration(milliseconds: 20), () {
            dataList.onChangeSync.listen((e) => onChange(e));
            childOld.add('John Doe');
          });

          // then
          return future.then((_) {
            onChange.getLogs().verify(neverHappened);
          });
        });
    });
 });
}