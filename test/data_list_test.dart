// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//TODO DataReferences persistence test

library data_list_test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:clean_data/clean_data.dart';

int isSameList(List a, List b){
  for(int i=0; i<a.length; i++){
    if(a[i] != b[i]){
      return 0;
    }
  }
  return 1;
}

void main() {
  group('(DataList)', () {

    group('(Implements)', () {
      test('DataList(). (T00)', () {
        // when
        DataList dataList = new DataList();

        // then
        expect(dataList.isEmpty, isTrue);
        expect(dataList.isNotEmpty, isFalse);
        expect(dataList.length, 0);
      });

      test('DataList.from(). (T01)', () {
        // when
        DataList dataList = new DataList.from(['element1', 'element2']);

        // then
        expect(dataList.length, 2);
      });

      test('List.operator[]. (TO2)', () {
        // given
        DataList dataList = new DataList.from(['element1', 'element2']);

        // when & then
        expect(dataList[0], equals('element1'));
        expect(dataList[1], equals('element2'));
      });

      test('List.operator[]=. (TO3)', () {
        // given
        DataList dataList = new DataList.from(['oldElement']);

        // when
        dataList[0] = 'newElement';

        // then
        expect(dataList[0], equals('newElement'));
      });

      test('List.add(). (T04)', () {
        // given
        DataList dataList = new DataList();

        // when
        dataList.add('element1');

        // then
        expect(dataList.isEmpty, isFalse);
        expect(dataList.isNotEmpty, isTrue);
        expect(dataList.length, 1);
        expect(dataList[0], equals('element1'));
      });

      test('List.addAll(). (T05)', () {
        // given
        DataList dataList = new DataList();

        // when
        dataList.addAll(['element1', 'element2', 'element3']);

        // then
        expect(dataList.length, equals(3));
        expect(dataList[0], equals('element1'));
        expect(dataList[1], equals('element2'));
        expect(dataList[2], equals('element3'));
      });

      test('List.removeLast(). (T06)', () {
        // given
        DataList dataList = new DataList.from(['element1', 'element2', 'element3']);

        // when
        dataList.removeLast();

        // then
        expect(dataList[0], equals('element1'));
        expect(dataList[1], equals('element2'));
      });

      test('List.removeAt() - middle. (T07a)', () {
        // given
        DataList dataList = new DataList.from(['element1', 'element2', 'element3']);

        // when
        dataList.removeAt(1);

        // then
        expect(dataList[0], equals('element1'));
        expect(dataList[1], equals('element3'));
      });

      test('List.removeAt() - front. (T07b)', () {
        // given
        DataList dataList = new DataList.from(['element1', 'element2', 'element3']);

        // when
        dataList.removeAt(0);

        // then
        expect(dataList[0], equals('element2'));
        expect(dataList[1], equals('element3'));
      });

      test('List.asMap(). (T08)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2', 'element3']);

        // when
        Map<int, dynamic> map = dataList.asMap();

        // then
        expect(map[0], equals('element1'));
        expect(map[1], equals('element2'));
        expect(map[2], equals('element3'));
      });

      test('List.clear(). (T09)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2', 'element3']);

        // when
        dataList.clear();

        // then
        expect(new List.from(dataList), orderedEquals(
            []));
      });

      test('List.fillRange(). (T10)', () {
        // given
        DataList dataList = new DataList.from(
            ['element1','element2', 'element3', 'element4']);

        // when
        dataList.fillRange(1,4,'kitty');

        // then
        expect(new List.from(dataList), orderedEquals(
            ['element1','kitty', 'kitty', 'kitty']));
      });

      test('List.getRange(). (T11)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

        // when & then
        expect(new List.from(dataList.getRange(1, 3)), orderedEquals(
            ['element2','element3']));
      });

      test('List.indexOf(). (T12)', () {
        // given
        DataList dataList = new DataList.from(['doge','kitty', 'kitty', 'pikachu']);

        // when & then
        expect(dataList.indexOf('kitty'), equals(1));
      });

      test('List.insert(). (T13)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2', 'element3']);

        // when
        dataList.insert(1, 'element1.5');

        // then
        expect(new List.from(dataList), orderedEquals(
            ['element1', 'element1.5', 'element2', 'element3']));
      });

      test('List.insertAll(). (T14)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2']);

        // when
        dataList.insertAll(1, ['kitty', 'doge']);

        // then
        expect(new List.from(dataList), orderedEquals(
            ['element1', 'kitty', 'doge', 'element2']));
      });

      test('List.lastIndexOf(). (T15)', () {
        // given
        DataList dataList = new DataList.from(['kitty','kitty', 'kitty', 'doge']);

        // when & then
        expect(dataList.lastIndexOf('kitty'), equals(2));
      });

      test('List.remove(). (T16)', () {
        // given
        DataList dataList = new DataList.from(['kitty', 'doge', 'doge', 'pikachu']);

        // when
        dataList.remove('doge');

        // then
        expect(new List.from(dataList), orderedEquals(
            ['kitty', 'doge', 'pikachu']));
      });

      test('List.removeRange() - rangeTest. (T17)', () {
        // given
        DataList dataList = new DataList.from(['element1', 'element2', 'element3']);

        // when
        expect(() => dataList.removeRange(-1, 1), throwsArgumentError);
        expect(() => dataList.removeRange(1, 0), throwsArgumentError);
        expect(() => dataList.removeRange(1, 4), throwsArgumentError);
      });

      test('List.removeRange() - from middle. (T18)', () {
        // given
        DataList dataList = new DataList.from(
            ['element1','element2', 'element3', 'element4']);

        // when
        dataList.removeRange(1,3);

        // then
        expect(new List.from(dataList), orderedEquals(
            ['element1', 'element4']));
      });

      test('List.removeWhere(). (T19)', () {
        // given
        DataList dataList = new DataList.from(
            ['element1','doge', 'doge', 'element4']);

        // when
        dataList.removeWhere((el) => el == 'doge');

        // then
        expect(new List.from(dataList), orderedEquals(
            ['element1', 'element4']));
      });

      // replaceRange is more extensively tested in (DataReference) (replaceRange)
      test('List.replaceRange(). (T20)', () {
        // given
        DataList dataList = new DataList.from(
            ['element1','element2', 'element3', 'element4']);

        // when
        dataList.replaceRange(1,3,['kitty']);

        // then
        expect(new List.from(dataList), orderedEquals(
            ['element1', 'kitty', 'element4']));
      });

      test('List.retainWhere(). (T21)', () {
        // given
        DataList dataList = new DataList.from(
            ['element0','kitty','element2', 'element3', 'kitty']);

        // when
        dataList.retainWhere((el) => el == 'kitty');

        // then
        expect(new List.from(dataList), orderedEquals(
            ['kitty', 'kitty']));
      });

      test('List.reversed(). (T22)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2', 'element3']);

        // when & then
        expect(new List.from(dataList.reversed), orderedEquals(
            ['element3','element2', 'element1']));
      });

      test('List.setAll(). (T23)', () {
        // given
        DataList dataList = new DataList.from(
            ['element1', 'element2', 'element3']);

        // when
        dataList.setAll(1, ['kitty', 'doge']);

        // then
        expect(new List.from(dataList), orderedEquals(
            ['element1', 'kitty', 'doge']));
      });

      test('List.setRange(). (T24)', () {
        // given
        DataList dataList = new DataList.from(
            ['element1', 'element2', 'element3', 'element4']);

        // when
        dataList.setRange(1,3, ['doge', 'kitty', 'pikachu'], 1);

        // then
        expect(new List.from(dataList), orderedEquals(
            ['element1', 'kitty', 'pikachu', 'element4']));
      });

      test('List.shuffle(). (T25)', () {
        // given
        DataList dataList = new DataList.from(
            ['element1', 'element2', 'element3', 'element4']);
        List target = ['element4', 'element1', 'element3', 'element2'];
        int target_met = 0;

        // when - try 10 times more permutations then permutation count
        for(int i=0; i<10*24; i++){
          dataList.shuffle();
          target_met += isSameList(target, new List.from(dataList));
        }

        // then
        expect(target_met, lessThan(15));
        expect(target_met, greaterThan(5));
      });

      test('List.sort(). (T26)', () {
        // given
        DataList dataList = new DataList.from(
            ['element4', 'element1', 'element3', 'element5', 'element2']);

        // when
        dataList.sort();

        // then
        expect(new List.from(dataList), orderedEquals(
            ['element1','element2', 'element3', 'element4', 'element5']));
      });

      test('List.sublist(). (T27)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);

        // when & then
        expect(new List.from(dataList.sublist(1)), orderedEquals(
            ['element2','element3', 'element4']));
      });
    });


    group('(Listen)', () {
      test('asynchronously on element added. (L01)', () {
        // given
        DataList dataList = new DataList();

        // when
        dataList.add('element');

        // then
        dataList.onChange.listen(expectAsync1((ChangeSet event) {
          expect(event.changedItems.isEmpty, isTrue);
          expect(event.removedItems.isEmpty, isTrue);
          expect(event.addedItems, unorderedEquals([0]));
        }));
      });

      test('synchronously on element added. (L02)', () {
        // given
        DataList dataList = new DataList();
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onChange(event));

        // when
        dataList.add('element', author: 'John Doe');

        // then
        onChange.getLogs().verify(happenedOnce);
        var event = onChange.getLogs().first.args[0];
        expect(event['author'], equals('John Doe'));
        expect(event['change'].addedItems, unorderedEquals([0]));
        expect(event['change'].changedItems.keys, unorderedEquals([0]));
      });

      test('multiple elements added. (L03)', () {
        // given
        List list = ['element1', 'element2', 'element3'];
        DataList dataList = new DataList();
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onChange(event));

        // when
        dataList.addAll(list, author: 'John Doe');

        //then
        onChange.getLogs().verify(happenedOnce);
        var event = onChange.getLogs().first.args.first;
        expect(event['author'], equals('John Doe'));
        expect(event['change'].removedItems.isEmpty, isTrue);
        expect(event['change'].addedItems, unorderedEquals([0,1,2]));
        expect(event['change'].changedItems.keys, unorderedEquals([0,1,2]));

        // but async onChange drops information about changes in added items.
        dataList.onChange.listen(expectAsync1((changeSet) {
          expect(changeSet.addedItems, unorderedEquals([0,1,2]));
          expect(changeSet.removedItems.isEmpty, isTrue);
          expect(changeSet.changedItems.isEmpty, isTrue);
        }));

      });

      test('asynchronously index removed. (L04)', () {
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

      test('synchronously on index removed. (L05)', () {
        // given
        DataList dataList = new DataList.from(['element1']);
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onChange(event));

        // when
        dataList.removeAt(0, author: 'John Doe');

        // then
        onChange.getLogs().verify(happenedOnce);
        var event = onChange.getLogs().logs.first.args.first;
        expect(event['author'], equals('John Doe'));
        expect(event['change'].addedItems.isEmpty, isTrue);
        expect(event['change'].removedItems, unorderedEquals([0]));
        expect(event['change'].changedItems.keys, unorderedEquals([0]));
      });

      test('multiple indexes removed. (L06)', () {
        // given
        DataList dataList = new DataList.from(['element1', 'element2', 'element3']);
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onChange(event));

        // when
        dataList.removeRange(1,3, author: 'John Doe');

        //then
        onChange.getLogs().verify(happenedOnce);
        var event = onChange.getLogs().first.args[0];
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

      test('{index, element} changed. (L07)', () {
        // given
        DataList dataList = new DataList.from(['oldElement']);
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onChange(event));

        // when
        dataList[0] = 'newElement';

        // then
        onChange.getLogs().verify(happenedOnce);
        var event = onChange.getLogs().first.args[0];
        expect(event['change'].addedItems.isEmpty, isTrue);
        expect(event['change'].removedItems.isEmpty, isTrue);
        expect(event['change'].changedItems.keys, unorderedEquals([0]));
        expect(event['change'].changedItems[0].oldValue, equals('oldElement'));
        expect(event['change'].changedItems[0].newValue, equals('newElement'));

        dataList.onChange.listen(expectAsync1((ChangeSet event) {
          expect(event.addedItems.isEmpty, isTrue);
          expect(event.removedItems.isEmpty, isTrue);
          expect(event.changedItems.length, equals(1));
          var change = event.changedItems[0];
          expect(change.oldValue, equals('oldElement'));
          expect(change.newValue, equals('newElement'));
        }));
      });

      test('propagate multiple changes in single [ChangeSet]. (L08a)', () {
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

      test('propagate multiple changes in single [ChangeSet]. (L08b)', () {
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

      test('when element is added then changed, only addition is in the [ChangeSet]. (L09)', () {
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


      test('when existing {index, element} is removed then re-added, this is a change. (L10', () {
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

      test('when {index, element} is changed then removed, only deletion is in the [ChangeSet]. (L11)', () {
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

      test('when {index, element} is added then removed, no changes are broadcasted. (L12)', () {
        // given
        DataList dataList = new DataList();

        // when
        dataList.add('element');
        dataList.removeAt(0);

        // then
        dataList.onChange.listen(protectAsync1((e) => expect(true, isFalse)));
      });

      test('when {element} is added, changed then removed, no changes are broadcasted. (L13)', () {
        // given
        DataList dataList = new DataList();

        // when
        dataList.add('oldElement');
        dataList[0] = 'newElement';
        dataList.removeAt(0);

        // then
        dataList.onChange.listen(protectAsync1((e) => expect(true, isFalse)));
      });

      test('insert element into middle of list. (L14)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2', 'element3']);
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onChange(event));

        // when
        dataList.insert(1, 'element1.5');

        // then
        onChange.getLogs().verify(happenedExactly(1));
        var change = onChange.getLogs().logs.first.args.first['change'];
        expect(change.changedItems.keys, unorderedEquals([1,2,3]));
        expect(change.addedItems, unorderedEquals([3]));
        expect(change.removedItems, unorderedEquals([]));
      });

      test('insert multiple elements into middle of list. (L15)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2']);
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onChange(event));

        // when
        dataList.insertAll(1, ['element1.1', 'element1.25', 'element1.5']);

        // then
        onChange.getLogs().verify(happenedExactly(1));
        var change = onChange.getLogs().logs.first.args.first['change'];
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

      test('insert multiple elements into front. (L16)', () {
        // given
        DataList dataList = new DataList.from(['element1', 'element2']);

        // when
        dataList.insertAll(0, ['element0.25', 'element0.5']);

        // then
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

      test('element removed from middle. (L17)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4']);
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onChange(event));

        // when
        dataList.removeAt(1);

        // then
        onChange.getLogs().verify(happenedExactly(1));
        var change = onChange.getLogs().logs.first.args.first['change'];
        expect(change.changedItems.keys, unorderedEquals([1,2,3]));
        expect(change.addedItems, unorderedEquals([]));
        expect(change.removedItems, unorderedEquals([3]));
      });

      test('remove multiple elements from middle. (L18)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4', 'element5']);

        // when
        dataList.removeAt(1);
        dataList.removeAt(1);

        // then
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

      test('remove multiple elements from from. (L19)', () {
        // given
        DataList dataList = new DataList.from(['element1','element2', 'element3', 'element4', 'element5']);

        // when
        dataList.removeRange(0,3);

        // then
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

      test('removing multiple from middle and then readding same makes no change. (L20)', () {
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

      //TODO
      /*
      test('when child Data is removed, changed and then added, only change is propagated.', () {
      // given
      var child = new Data();
      var dataObj = new Data.from({'child': child});
      var onChange = new Mock();

      // when
      dataObj.remove('child');
      child['name'] = 'John Doe';
      dataObj.add('child', child);

      // then
      dataObj.onChange.listen(expectAsync1((ChangeSet event) {
      expect(event.changedItems['child'].addedItems, equals(['name']));
      }));
      });
      */
    });

    /*
    group('(DataReference)', () {
      test('change value with list interface.', () {
        // given
        DataList dataList = new DataList.from(['oldName']);
        var ref = dataList.ref(0);
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onChange(event));

        // when
        dataList[0] = 'newName';

        // then
        expect(dataList[0], equals('newName'));

        onChange.getLogs().verify(happenedExactly(1));
        var change = onChange.getLogs().logs.first.args.first['change'];
        expect(change.changedItems.keys, orderedEquals([0]));
        expect(change.changedItems[0].oldValue, equals('oldName'));
        expect(change.changedItems[0].newValue, equals('newName'));

        dataList.onChange.listen(expectAsync1((ChangeSet event) {
          expect(event.changedItems[0].oldValue, equals('oldName'));
          expect(event.changedItems[0].newValue, equals('newName'));
        }));
      });

      test('reference removed when ChangeNotificationsMixin is assigned.', () {
        //given
        DataList dataList = new DataList.from(['John Doe String']);
        var name = new Data.from({'first': 'John', 'second': 'Doe'});

        //when
        var ref1 = dataList.ref(0);
        dataList[0] = name;

        //then
        expect(() => dataList.ref(0), throws);
      });

     test('reference does not change when another primitive is assigned.', () {
        //given
        DataList dataList = new DataList.from(['oldValue']);
        var ref1 = data.ref(0);

        //when
        dataList[0] = 'newValue';
        var ref2 = data.ref(0);
        ref1.value = 500;

        //then
        expect(ref1, equals(ref2));
      });

      test('passing data reference.', () {
        //given
        var dataRef = new DataReference('John Doe');
        var dataList = new DataList.from([dataRef]);
        var listener = new Mock();

        //when
        var future = new Future.delayed(new Duration(milliseconds: 20), () {
          dataList.onChangeSync.listen((e) => listener(e));
          dataRef.value = 'Somerset';
        });

        // then
        return future.then((_) {
          listener.getLogs().verify(happenedOnce);
          var changes = listener.getLogs().logs.first.args.first['change'];

          //because of single
          expect(changes.changedItems[0], new isInstanceOf<Change>());

          Change change1 = changes.changedItems[0];
          expect(change1.oldValue, equals('John Doe'));
          expect(change1.newValue, equals('Somerset'));
        });
      });

      //TODO check on replaceRange if references are perserved correctly
      group('(Perserved)', () {

      });
    });

    group('(Nested DataMap)', () {
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

      test('do not listen to removedAt children changes.', () {
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

      test('do not listen after removeAll multiple children with removeRange.', () {
        // given
        var child1 = new Data();
        var child3 = new Data();
        DataList dataList = new DataList.from([new Data(), child1, new Data(), child3, new Data()]);
        var onRemove = new Mock();
        var onChange = new Mock();
        dataList.onChangeSync.listen((event) => onRemove.handler(event));

        // when
        dataList.removeAll([1,3], author: 'John Doe');

        // then
        var future = new Future.delayed(new Duration(milliseconds: 20), () {
          dataList.onChangeSync.listen((e) => onChange(e));
          child1['name'] = 'John Doe';
          child3['name'] = 'Mills';
        });

        future.then((_) {
          onChange.getLogs().verify(neverHappened);
        });

        // but async onChange drops information about changes in removed items.
        dataList.onChange.listen(expectAsync1((changeSet) {
          expect(changeSet.removedItems, orderedEquals([1,3]));
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
          expect(event.changedItems.keys, orderedEquals([0]));

          Change change = event.changedItems[0];
          expect(change.oldValue, equals(childOld));
          expect(change.newValue, equals(childNew));

          expect(event.addedItems, orderedEquals([]));
          expect(event.removedItems, orderedEquals([]));
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
    }); */
 });
}