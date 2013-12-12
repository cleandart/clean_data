// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//TODO why not observable?
//TODO nested Data objects
//TODO refactor with Data.dart

part of clean_dart;

/**
 * List with change notifications. Change set contains indexes which were changed.
 */

class DataList extends Object with IterableMixin, ChangeNotificationsMixin implements List {

  Iterator get iterator => _elements.iterator;

  /**
   * Number of elements in this [DataList].
   */
  int get length => _elements.length;

  /**
   * Returns an [Iterable] of the objects in this list in reverse order.
   */
  Iterable get reversed{
    //TODO
  }

  /**
   * Removes the objects in the range [start] inclusive to [end] exclusive
   * and replaces them with the contents of the [iterable].
   */
  void replaceRange(int start, int end, Iterable iterable){
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
  void setAll(int index, Iterable iterable){
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
   * Removes the object at position [index] from this list.
   */
  dynamic removeAt(int index){
    //TODO
  }

  /**
   * Returns the first index of [element] in this list.
   */
  int indexOf(dynamic element, [int start = 0]){
    //TODO
  }

  /**
   * Removes all objects from this list that satisfy [test].
   */
  //TODO iterable mixin?
  void removeWhere(bool test(dynamic element)){
    //TODO
  }

  /**
   * Removes all objects from this list that fail to satisfy [test].
   */
  void retainWhere(bool test(dynamic element)){
    //TODO
  }

  /**
   * Sorts this list according to the order specified by the [compare] function.
   */
  void sort([int compare(dynamic a, dynamic b)]){
    //TODO
  }

  /**
   * Sets the objects in the range [start] inclusive to [end] exclusive
   * to the given [fillValue].
   */
  void fillRange(int start, int end, [dynamic fillValue]){
    //TODO
  }

  /**
   * Shuffles the elements of this list randomly.
   */
  void shuffle([Random random]){
    //TODO
  }

  /**
   * Inserts all objects of [iterable] at position [index] in this list.
   */
  void insertAll(int index, Iterable iterable){
    //TODO
  }

  /**
   * Inserts the object at position [index] in this list.
   */
  void insert(int index, dynamic element){
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
   * Pops and returns the last object in this list.
   */
  dynamic removeLast(){
    //TODO
  }

  /**
   * Removes the objects in the range [start] inclusive to [end] exclusive.
   */
  void removeRange(int start, int end){
    //TODO
  }

  /**
   * Copies the objects of [iterable], skipping [skipCount] objects first,
   * into the range [start] inclusive to [end] exclusive of `this`.
   */
  void setRange(int start, int end, Iterable iterable, [int skipCount = 0]){
    //TODO
  }


  final List _elements = new List();

  /**
   * Creates an empty [DataList] object.
   */
  DataList();

  /**
   * Creates a new [DataList] object from [Iterable]
   */
  factory DataList.from(Iterable) {

  }

  dynamic operator[](index) => _elements[index];

  /**
   * Returns true if there is no {key, value} pair in the data object.
   */
  bool get isEmpty {
    return _elements.isEmpty;
  }

  /**
   * Returns true if there is at least one {key, value} pair in the data object.
   */
  bool get isNotEmpty {
    return _elements.isNotEmpty;
  }

  /**
   * Adds the [value] to the end of [DataList].
   */
  void add(dynamic value, {author: null}) {
    addAll([value], author: author);
  }

  /**
   * Adds all key-value pairs of [other] to this data.
   */
  void addAll(List other, {author: null}) {
    //TODO
    /*
    other.forEach((key, value) {
      if (_fields.containsKey(key)) {
        _markChanged(key, new Change(_fields[key], value));
      } else {
        _markChanged(key, new Change(null, value));
        _markAdded(key);
      }
      _fields[key] = value;
    });
    _notify(author: author); */
  }

  /**
   * Assigns the [value] to the [key] field.
   */
  void operator[]=(int index, value) {
    //TODO
    _notify();
  }

  /**
   * Removes element with [index] from the data object.
   */
  bool remove(int index, {author: null}) {
    removeAll([index], author: author);
  }

  /**
   * Remove all [keys] from the data object.
   */
  void removeAll(List<int> indexes, {author: null}) {
    //TODO
    /*
    for (var key in keys) {
      _markChanged(key, new Change(_fields[key], null));
      _markRemoved(key);
      _fields.remove(key);
    }
    _notify(author: author); */
  }

  void clear({author: null}) {
    //TODO
  }
}
