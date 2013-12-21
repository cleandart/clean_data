// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//TODO check if this[index] is called properly.

part of clean_dart;

/**
 * List with change notifications. Change set contains indexes which were changed.
 * Most of the methods are reduced to _replaceRange.
 * [DataList] retains [DataReferences] even after moving around in the array.
 * But changes are treated as it was Map<index, dynamix>(). So when removing
 * from the middle of [DataList] changes will be generated for each successive elements.
 * See tests for more information.
 */
class DataList extends Object
  with IterableMixin, ChangeNotificationsMixin, DataChangeListenersMixin<int>
    implements List {

  /**
   * Developers, mind the difference between [List.from](this) and [List.from](_elements).
   */
  Iterator get iterator => _elements.map((value) => (value is DataReference) ? value.value : value).iterator;

  /**
   * Number of elements in this [DataList].
   */
  int get length => _elements.length;

  /**
   * Changes the length of this list.
   * If [newLength] is greater than the current length, entries are initialized to null.
   */
  //TODO should be DataRef<null> ?
  void set length(int newLength){
    if(newLength > length){
      _elements.length = newLength; //TODO works good?
    }
    else{
      _replaceRange(newLength, length, []);
    }
  }

  final List<ChangeNotificationsMixin> _elements = new List();

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

  /**
   * Returns object at position [index] except when it is [DataReference].
   * In that case [DataReference.value] is used. Developers should mind the diffence
   * between [_elements[index]] and [this[index]].
   */
  dynamic operator[](index) {
    if(_elements[index] is DataReference) {
      return _elements[index].value;
    }
    else {
      _elements[index];
    }
  }

  void operator []=(int index, dynamic value){
    replaceRange(index, index+1, [value]);
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
    replaceRange(length, length, other, author: author);
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
    replaceRange(index, index, iterable, author: author);
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
   * Pops and returns the last object in this list.
   */
  dynamic removeLast({author: null}){
    return removeAt(_elements.length-1);
  }

  /**
   * Removes the object at position [index] from this list.
   */
  dynamic removeAt(int index, {author: null}){
    dynamic result = this[index];
    removeRange(index, index+1, author: author);
    return result;
  }

  /**
   * Removes the objects in the range [start] inclusive to [end] exclusive.
   */
  void removeRange(int start, int end, {author: null}){
    replaceRange(start, end, [], author: author);
  }

  /**
   * Removes all objects from this list; the length of the list becomes zero.
   */
  void clear({author: null}) {
    removeRange(0, _elements.length, author:author);
  }

  /**
   * Removes all objects from this list that satisfy [test].
   */
  void removeWhere(bool test(dynamic element), {author: null}){
    List<ChangeNotificationsMixin> target = [];
    for(int key=0; key<_elements.length ; key++){
        if(test(this[key])) target.add(_elements[key]);
    };
    _replaceRange(0, length, target, author: author);
  }

  /**
   * Removes all objects from this list that fail to satisfy [test].
   */
  void retainWhere(bool test(dynamic element), {author: null}){
    removeWhere((dynamic element) => !test(element), author: author);
  }

  /**
   * Returns an [Iterable] of the objects in this list in reverse order.
   */
  Iterable get reversed{
    List result = [];
    for(int i=length-1 ; i>=0 ; i--){
      result.add(this[i]);
    }
    return result;
  }

  /**
   * Returns an [Iterable] that iterates over the objects in the range
   * [start] inclusive to [end] exclusive.
   */
  Iterable getRange(int start, int end){
    return sublist(start, end);
  }

  /**
   * Overwrites objects of `this` with the objects of [iterable], starting
   * at position [index] in this list.
   *
   * This operation does not increase the length of this.
   *
   * An error occurs if the index is less than 0 or greater than length.
   * An error occurs if the iterable is longer than length - index.
   */
  void setAll(int index, Iterable iterable, {author: null}){
    replaceRange(index, index + iterable.length, iterable, author: author);
  }

  /**
   * Returns the last index of [element] in this list.
   * Returns -1 if element is not found.
   */
  int lastIndexOf(dynamic element, [int start = null]){
    for(int i = (start == null) ? length : start; i >= 0 ; i--){
      if(this[i] == element){
        return i;
      }
    }
    return -1;
  }

  /**
   * Returns a new list containing the objects from [start] inclusive to [end]
   * exclusive.
   * An error occurs if start is outside the range 0 .. length or if end is outside the range start .. length.
   */
  List sublist(int start, [int end = null]){
    end = (end == null) ? length : end;
    _checkRange(start, end);

    List result = [];
    for(int i=start ; i<end ; i++){
      result.add(this[i]);
    }
    return result;
  }

  /**
   * Returns the first index of [element] in this list.
   * Returns -1 if element is not found.
   */
  int indexOf(dynamic element, [int start = 0]){
    for(int i=start ; i < length ; i++){
      if(this[i] == element){
        return i;
      }
    }
    return -1;
  }

  /**
   * Sorts this list according to the order specified by the [compare] function.
   * For [DataReference]s their corresponding values will be used for comparison.
   */
  //TODO author (problem with named and positional parameters)
  void sort([int compare(dynamic a, dynamic b), author=null]){
    List<List> order = new List<List>();
    for(int i=0; i<length ; i++){
      order.add([this[i], i]);
    }
    order.sort((a,b){
      (a[0] == b[0]) ? ((a[1] > b[1]) ? 1:-1)
          : ((a[0] > b[0]) ? 1:-1);
    });

    List<ChangeNotificationsMixin> target = new List<ChangeNotificationsMixin>();
    order.forEach(([el, order_i]) => target.add(_elements[order_i]));
    _replaceRange(0, length, target, author: author, forceResuscribe: false);
  }

  /**
   * Sets the objects in the range [start] inclusive to [end] exclusive
   * to the given [fillValue].
   */
  //TODO author (problem with named and positional parameters)
  void fillRange(int start, int end, [dynamic fillValue, author=null]){
    List fill = [];
    for(int i=0; i<end-start; i++){
      fill.add(fillValue);
    }
    replaceRange(start, end, fill, author: author);
  }

  /**
   * Shuffles the elements of this list randomly.
   */
  //TODO author (problem with named and positional parameters)
  void shuffle([Random random, author=null]){
    List target = new List.from(_elements);
    target.shuffle(random);
    _replaceRange(0, length, target, author: author);
  }

  /**
   * Returns an unmodifiable [Map] view of `this`.
   *
   * The map uses the indices of this list as keys and the corresponding objects
   * as values. The `Map.keys` [Iterable] iterates the indices of this list
   * in numerical order.
   */
  Map<int, dynamic> asMap(){
    //TODO Map<int, dynamic> result = new ConstantMap<int, dynamic>();
    Map<int, dynamic> result = new Map<int, dynamic>();
    for(int i=0; i<length; i++){
      result[i] = this[i];
    }
    return result;
  }

  /**
   * Copies the objects of [iterable], skipping [skipCount] objects first,
   * into the range [start] inclusive to [end] exclusive of `this`.
   *
   * If [start] equals [end] and [start].. [end] represents a legal range, this method has no effect.
   *
   * An error occurs if [start].. [end] is not a valid range for this.
   * An error occurs if the iterable does not have enough objects after skipping skipCount objects.
   */
  //TODO author
  void setRange(int start, int end, Iterable iterable, [int skipCount = 0, author=null]){
    if(end-start-skipCount > iterable.length){
      throw new ArgumentError("Iterable(${iterable.length}) does not have enough objects after skipping $skipCount objects. Called [$start, $end]");
    }
    replaceRange(start, end, iterable, skipCount: skipCount, author: author);
  }

  /**
   * Removes the objects in the range [start] inclusive to [end] exclusive
   * and replaces them with the contents of the [iterable].
   */
  void replaceRange(int start, int end, Iterable iterable, {author: null, skipCount: 0}){
    List<ChangeNotificationsMixin> target = new List<ChangeNotificationsMixin>();
    iterable.forEach((element){
      target.add((element is ChangeNotificationsMixin) ? element : new DataReference(element));
    });
    _replaceRange(start, end, target, author: author, skipCount: skipCount);
  }

  /**
   * Usage of [skipCount] is highly discouraged.
   * If [forceResuscribe] is true then all [DataListners] from [start].. [end] will be removed
   * and then readed in [iterable]. Otherwise only necessary will be resuscribe (set difference).
   */
  void _replaceRange(int start, int end, Iterable<ChangeNotificationsMixin> iterable, {
    author: null, forceResuscribe: false, skipCount: 0}){

    _checkRange(start, end);

    //[0, start) - nothing happens
    //[start, end) - implicitly deleted but we must check if the same objects are inserted (sort, shuffle)
    //[end, length) - moved
    //to [start, start + iterable.length - skipCount) - inserted, as at deletion, we should check if same

    Set<ChangeNotificationsMixin> removed = new Set<ChangeNotificationsMixin>();
    Set<ChangeNotificationsMixin> added = new Set<ChangeNotificationsMixin>();

    int rEnd = start + iterable.length - skipCount;
    int oLength = _elements.length;
    int nLength = rEnd + _elements.length - end;

    //remove
    for(int key=start; key < end; key++){
      removed.add(_elements[key]);
    }

    //TODO change notifications
    //move range [end, oLength), we distinguish list shrink / grow because treating
    //    both cases in same way would lead to overriding values before copied (swap problem)
      //move right
    if(nLength > oLength){
      _elements.length = nLength;
      for(int key=nLength-1; key >= rEnd ; key--){
        _elements[key] = _elements[key - nLength + oLength];
      }
    }
      //move left
    if(nLength < oLength){
      for(int key=rEnd; key < nLength ; key++){
        _elements[key] = _elements[key - nLength + oLength];
      }
      _elements.length = nLength;
    }
    //nothing to do if nLength = oLength

    //insert
      //skip count
    var iter = iterable.iterator;
    for(int i=0; i<skipCount + 1; i++){
      iter.moveNext();
    }
      //(key < rEnd) <=> (iter.moveNext())
    for(int key=start; key < rEnd ; key++, iter.moveNext()){
      added.add(iter.current);
      _elements[key] = iter.current;
    }

    /*
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
    */

    /*
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
     */
  }
}
