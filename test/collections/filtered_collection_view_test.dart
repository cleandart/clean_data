// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library FilteredViewCollectionTest;

import 'package:unittest/unittest.dart';
import 'package:clean_data/clean_data.dart';

void main() {

  group('(FilteredCollectionView)', () {

    var data;
    setUp(() {
      
      data = [];
      for (var i = 0; i <= 10; i++) {
        data.add(new Data.fromMap({'id': i}));
      }
      
      
      var map11 = {'id': 11, 'name': 'jozef'};
      var map12 = {'id': 12, 'name': 'jozef'};
      
      data.add(new Data.fromMap(map11));
      data.add(new Data.fromMap(map12));      
    });


    test('simple filtering. (T01)', () {
      // given
      var collection = new DataCollection.from(data);
      
      // when
      var filteredData = collection.where((d)=>d['id']==7);
      var filteredData2 = collection.where((d)=>d['id']==100);
      var filteredData3 = collection.where((d)=>d['ID']==1);
      
      //then
      expect(filteredData, unorderedEquals([data[7]]));
      expect(filteredData2, unorderedEquals([]));
      expect(filteredData3, unorderedEquals([]));
    });
    

    test('double/triple filtering. (T02)', () {
      // given 
      var collection = new DataCollection.from(data);
      
      // when
      var filteredData = collection.where((d)=>d['id'] == 7)
                                   .where((d)=>d['id'] == 7);
      var filteredData2 = collection.where((d)=>d['name']=='jozef');      
      var filteredData3 = filteredData2.where((d)=>d['id']==11);
      var filteredData4 = filteredData3.where((d)=>d['id']==17);
      
      // then
      expect(filteredData, unorderedEquals([data[7]]));
      expect(filteredData2, unorderedEquals([data[11], data[12]]));
      expect(filteredData3, unorderedEquals([data[11]]));
      expect(filteredData4.isEmpty, isTrue);
    });
    

    test('adding a new data object to the filtered collection. (T03)', () {
      // given
      var collection = new DataCollection.from(data);
      var filteredData = collection.where((d)=>d['name']=='jozef');  //data[11], data[12]
      
      var jozef = new Data.fromMap({'id': 47, 'name': 'jozef'});
      var anicka = new Data.fromMap({'id': 49, 'name': 'anicka'});
      
      // when      
      collection.add(jozef);
      collection.add(anicka);
      
      filteredData.onChange.listen(expectAsync1((ChangeSet event) {
        // then
        expect(event.removedItems.isEmpty, isTrue);
        expect(event.changedItems.isEmpty, isTrue);
        expect(event.addedItems, equals([jozef]));
        expect(filteredData, unorderedEquals([data[11], data[12], jozef]));
      }));
    });
        
    test('removing a data object from the filtered collection. (T04)', () {
      // given
      var collection = new DataCollection.from(data);
      var filteredData = collection.where((d)=>d['name']=='jozef'); //data[11], data[12]

      // when
      data[11]['name'] = "Anicka";
      
      filteredData.onChange.listen(expectAsync1((ChangeSet event) {
        // then
        expect(event.addedItems.isEmpty, isTrue);
        expect(event.changedItems.isEmpty, isTrue);
        expect(event.removedItems.length, equals(1));
        expect(event.removedItems.first['id'], equals(11));
      }));
    });
    

    test('changing a data object in the underlying collection - gets added to the filtered collection. (T05)', () {
      // given
      var collection = new DataCollection.from(data);
      var filteredData = collection.where((d)=>d['name']=='jozef'); //data[11], data[12]
    
      // when
      data[10]['name'] = "jozef";
      
      filteredData.onChange.listen(expectAsync1((ChangeSet event) {
        // then
        expect(event.addedItems, unorderedEquals([data[10]]));
        expect(event.changedItems.isEmpty, isTrue);
        expect(event.removedItems.isEmpty, isTrue);
        expect(filteredData, unorderedEquals([data[10], data[11], data[12]]));
      }));
    });
    
    test('changing a data object in the underlying collection - gets removed from the filtered collection. (T06)', () {
      // given
      var collection = new DataCollection.from(data);
      var filteredData = collection.where((d)=>d['name']=='jozef'); //data[11], data[12]

      // when
      data[11]['name'] = "Jozef";
      
      filteredData.onChange.listen(expectAsync1((ChangeSet event) {
        // then
        expect(event.changedItems.isEmpty, isTrue);
        expect(event.addedItems.isEmpty, isTrue);
        expect(event.removedItems, unorderedEquals([data[11]]));
        expect(filteredData, unorderedEquals([data[12]]));
      }));
    });

    test('changing a data object in the underlying collection - gets changed in the filtered collection. (T07)', () {
      // given
      var collection = new DataCollection.from(data);
      var filteredData = collection.where((d)=>d['name']=='jozef'); //data[11], data[12]
      
      // when
      data[11]['email'] = "jozef@mrkvicka.com";

      filteredData.onChange.listen(expectAsync1((ChangeSet event) {
        //then
        expect(event.addedItems.isEmpty, isTrue);
        expect(event.removedItems.isEmpty, isTrue);
        
        expect(event.changedItems.length, equals(1));
        expect(event.changedItems.keys, unorderedEquals([data[11]]));
        
        expect(filteredData, unorderedEquals([data[11],data[12]]));
      }));
      
    });

    test('clearing the underlying collection - gets changed in the filtered collection. (T08)', () {
      // when
      var collection = new DataCollection.from(data);
      var filteredData = collection.where((d)=>d['name']=='jozef'); //data[11], data[12]

      // when
      collection.clear();
      
      filteredData.onChange.listen(expectAsync1((ChangeSet event) {
        // then
        expect(event.changedItems.isEmpty, isTrue);
        expect(event.addedItems.isEmpty, isTrue);
        expect(event.removedItems.length, equals(2));
        
        expect(filteredData.isEmpty, isTrue);
      }));
    });
   
    test('complex filter function - objects with even IDs get filtered. (T09)', () {
      // given
      var collection = new DataCollection.from(data);
      
      // when
      var filteredData = collection.where((d)=>d['id']%2==0);
      
      // then      
      expect(filteredData, unorderedEquals([data[0], data[2], data[4],data[6],data[8],data[10], data[12]]));
    });
   
    test('when removed item gets changed so it does not comply to the filter.', (){
      // given
      var dataSample = new Data.fromMap({'id': 1});
      var collection = new DataCollection.from([dataSample]);
      var filtered = new FilteredCollectionView(collection, (dataObj) => dataObj['id'] < 10);
      
      // when
      collection.remove(dataSample);
      dataSample['id'] = 20;
      
      // then
      filtered.onChange.listen(expectAsync1((ChangeSet event) {
        //then
        expect(filtered, unorderedEquals([]));
      }));
    });
    
    test('when item in filtered collection is removed, changed and added, it is in changedItems. (T10)',(){
      // given
      var dataObj = new Data.fromMap({'id': 1});
      var collection = new DataCollection.from([dataObj]);
      var filtered = new FilteredCollectionView(collection, (d) => d['id'] < 10);
      
      // when
      collection.remove(dataObj);
      dataObj['id'] = 5;
      collection.add(dataObj);
      
      // then
      filtered.onChange.listen(expectAsync1((ChangeSet event) {
        expect(event.changedItems.keys, unorderedEquals([dataObj]));
      }));
    });
   
    test('after removing an object from the filtered collection, it does not react to changes on this object anymore. (T11)', () {
      // given
      var collection = new DataCollection.from(data);
      var filteredData = collection.where((d)=>d['id']==1);
      collection.remove(data[1]);
      
      // when
      data[1]['name'] = 'Bob';  
      
      filteredData.onChange.listen(expectAsync1((ChangeSet event) {
        // then
        expect(event.changedItems.isEmpty, isTrue);
        expect(event.addedItems.isEmpty, isTrue);
        expect(event.removedItems.length, equals(1));       
        expect(filteredData.isEmpty, isTrue);
      }));
    });
  });
}