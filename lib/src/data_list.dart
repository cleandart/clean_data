// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//TODO nested Data objects
//TODO consider functions as subList, getRange, etc. to return DataList
//TODO expand(Iterable) ?
//TODO if we do []= without author and then _notify(author), what happens?
//TODO both remove and removeAt() ?

part of clean_dart;

/**
 * List with change notifications. Change set contains indexes which were changed.
 */

class DataList extends Object
  with IterableMixin, ChangeNotificationsMixin, DataChangeListenersMixin<int>
    implements List {

  Iterator get iterator => _elements.map((value) => (value is DataReference) ? value.value : value).iterator;

  /**
   * Number of elements in this [DataList].
   */
  int get length => _elements.length;

  /**
   * Changes the length of this list.
   * If [newLength] is greater than the current length, entries are initialized to null.
   */
  void set length(int newLength){

  }

  final List _elements = new List();

  /**
   * Creates an empty [DataList] object.
   */
  DataList();

  /**
   * Creates a new [DataList] object from [Iterable]
   */
  factory DataList.from(Iterable other, {author: null}) {
    DataList result = new DataList();
    result.addAll(other, author: author);
    result._clearChanges();
    //TODO should be also _clearChangesSync?
    return result;
  }

  bool _checkRange(int start, int end){
    if(end < start || start < 0 || _elements.length < end){
      throw new ArgumentError("Incorrect range [$start, $end) for DataList of size ${_elements.length}");
    }
    return true;
  }

  /**
   * Return [DataReference] for key. If DataList[key] is not [DataReference]
   * expection is thrown.
   */
  DataReference ref(int index) {
    if(_elements[index] is!  DataReference) {
      throw new Exception("'$index' is not primitive data type.");
    }{
      return _elements[index];
    }
  }

  dynamic operator[](index) {
    if(_elements[index] is DataReference) {
      return _elements[index].value;
    }
    else {
      _elements[index];
    }
  }

  void operator []=(int index, dynamic value){
    if(index >= length) {
      throw new RangeError('Index $index out of range(DataList length=$length).');
    }

    if(value is! ChangeNotificationsMixin){
      value = new DataReference(value);
    }

    _smartUpdateOnDataChangeListener(index, value);

    if(_elements[index] is DataReference) {
      _elements[index].value = value; //fires change
    }
    else {
      _elements[index] = value;
      _markChanged(index, new Change(_elements[index], value));
    }
    _notify();
  }

  /**
   * Adds the [value] to the end of [DataList].
   */
  void add(dynamic value, {author: null}) {
    addAll([value], author: author);
  }

  /**
   * Adds all key-value pairs of [other] to end of [DataList].
   */
  void addAll(Iterable other, {author: null}) {
    other.forEach((element) {
      int key = _elements.length;

      if(element is! ChangeNotificationsMixin) {
        element = new DataReference(element);
      }

      _markChanged(key, new Change(null, element));
      _markAdded(key);

      _addOnDataChangeListener(key, element);

      _elements.add(element);
    });

    _notify(author: author);
  }

  /**
   * Inserts the object at position [index] in this list.
   */
  void insert(int index, dynamic element, {author: null}){
    insertAll(index, [element], author: author);
  }

  /**
   * Inserts all objects of [iterable] at position [index] in this list.
   */
  void insertAll(int index, Iterable iterable, {author: null}){
    List other = (iterable is List) ? iterable : new List.from(iterable, growable: false);

    // The list will be shifted right after the addition.
    // Changed keys for iterable [index, index + iterable.length)
    for(int key=index ; key<index+iterable.length ; key++){
      var added = other[key-index];
      if(added is! ChangeNotificationsMixin) {
        added = new DataReference(added);
      }
      _markChanged(key, new Change((key>=_elements.length) ? null:_elements[key], added));
      _smartUpdateOnDataChangeListener(key, added);
    };
    // Changed keys for _elements
    for(int key=index + iterable.length ; key<_elements.length + iterable.length ; key++){
      var moved = _elements[key - iterable.length];
      _markChanged(key, new Change((key>=_elements.length) ? null:_elements[key], moved));
      _smartUpdateOnDataChangeListener(key, moved);
    };
    // Added keys [_elements.length, _elements.length + iterable.length).
    for(int key=_elements.length ; key<_elements.length + iterable.length ; key++){
      _markAdded(key);
      //update change listener done before
    };

    _elements.insertAll(index, iterable);

    _notify(author: author);
  }

  void clear({author: null}) {
    removeRange(0, _elements.length, author:author);
  }

  /**
   * Removes the first occurence of value from this list.
   * Returns true if value was in the list, false otherwise.
  */
  bool remove(Object value, {author: null}){
    int pos = indexOf(value);
    if(pos >= 0) {
      removeAt(pos, author: author);
    }
    return (pos >= 0);
  }

  /**
   * Removes the object at position [index] from this list.
   */
  dynamic removeAt(int index, {author: null}){
    dynamic result = _elements[index];
    removeRange(index, index+1, author: author);
    return result;
  }

  /**
   * Pops and returns the last object in this list.
   */
  dynamic removeLast({author: null}){
    return removeAt(_elements.length-1);
  }

  /**
   * Removes the objects in the range [start] inclusive to [end] exclusive.
   */
  void removeRange(int start, int end, {author: null}){
    //nothing to do
    if(end == start){
      return;
    }

    _checkRange(start, end);

    int change_end_i = _elements.length - end + start;

    // The list will be shifted left after the removal.
    // Changed keys [start, change_end_i) will be changed for [end, end + change_end_i - start)
    for(int key=start ; key<change_end_i ; key++){
      var moved = _elements[end + key - start];
      _markChanged(key, new Change(_elements[key], moved));
      _smartUpdateOnDataChangeListener(key, moved);
    };
    // Removed keys [change_end_i, _elements.length).
    for(int key=change_end_i ; key<_elements.length ; key++){
      _markChanged(key, new Change(_elements[key], null));
      _smartUpdateOnDataChangeListener(key, null);
      _markRemoved(key);
    };

    _elements.removeRange(start, end);

    _notify(author: author);
  }

  /**
   * Removes all objects from this list that satisfy [test].
   */
  void removeWhere(bool test(dynamic element), {author: null}){
    List toRemove = [];
    for(int key=0; key<_elements.length ; key++){
        if(test((_elements[key] is DataReference) ? _elements[key].value : _elements[key])) toRemove.add(key);
    };
    removeAll(toRemove, author: author);
  }

  /**
   * Removes all objects from this list that fail to satisfy [test].
   */
  void retainWhere(bool test(dynamic element), {author: null}){
    List toRemove = [];
    for(int key=0; key<_elements.length ; key++){
        if(!test( (_elements[key] is DataReference) ? _elements[key].value : _elements[key] )) toRemove.add(key);
    };
    removeAll(toRemove, author: author);
  }

  /**
   * Removes all indexes from the greatest to lowest. O(k * n)
   * TODO Performance could be cut down to O(k logk + n) by a left-right sweep
   *   and remembering how many indexes were deleted.
   */
  void removeAll(Iterable indexes, {author: null}){
    List toRemove = new List.from(indexes, growable: false);
    toRemove.sort();

    for(int i=toRemove.length-1; i>=0; i--){
      int key = toRemove[i];
      removeAt(key);
    }
  }


  /**
   * Returns an [Iterable] of the objects in this list in reverse order.
   */
  Iterable get reversed{
    //TODO
  }

  /**
   * Returns an [Iterable] that iterates over the objects in the range
   * [start] inclusive to [end] exclusive.
   */
  Iterable getRange(int start, int end){
    //TODO
  }

  /**
   * Overwrites objects of `this` with the objects of [iterable], starting
   * at position [index] in this list.
   */
  void setAll(int index, Iterable iterable, {author: null}){
    //TODO
  }

  /**
   * Returns the last index of [element] in this list.
   */
  int lastIndexOf(dynamic element, [int start]){
    //TODO
  }

  /**
   * Returns a new list containing the objects from [start] inclusive to [end]
   * exclusive.
   */
  List sublist(int start, [int end]){
    //TODO
  }

  /**
   * Returns the first index of [element] in this list.
   */
  int indexOf(dynamic element, [int start = 0]){
    //TODO
  }

  /**
   * Sorts this list according to the order specified by the [compare] function.
   */
  //TODO author (problem with named and positional paramters)
  void sort([int compare(dynamic a, dynamic b), author=null]){
    //TODO
  }

  /**
   * Sets the objects in the range [start] inclusive to [end] exclusive
   * to the given [fillValue].
   */
  //TODO author
  void fillRange(int start, int end, [dynamic fillValue, author=null]){
    //TODO
  }

  /**
   * Shuffles the elements of this list randomly.
   */
  //TODO author
  void shuffle([Random random, author=null]){
    //TODO
  }
  /**
   * Returns an unmodifiable [Map] view of `this`.
   *
   * The map uses the indices of this list as keys and the corresponding objects
   * as values. The `Map.keys` [Iterable] iterates the indices of this list
   * in numerical order.
   */
  Map<int, dynamic> asMap(){
    //TODO
  }

  /**
   * Copies the objects of [iterable], skipping [skipCount] objects first,
   * into the range [start] inclusive to [end] exclusive of `this`.
   */
  //TODO author
  void setRange(int start, int end, Iterable iterable, [int skipCount = 0, author=null]){
    //TODO
  }

  /**
   * Removes the objects in the range [start] inclusive to [end] exclusive
   * and replaces them with the contents of the [iterable].
   */
  void replaceRange(int start, int end, Iterable iterable, {author: null}){
    //TODO
  }

  /**
   *
   */
  void _replaceRange(int start, int end, Iterable iterable){

  }
}
