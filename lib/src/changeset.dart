// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of clean_data;

/*
 * Class to remember what one change since last synchronization
 */
class Change {
  dynamic oldValue;
  dynamic newValue;
  
  /**
   * Merges to changes into one
   */
  apply(Change change) {
    newValue = change.newValue;
  }

  Change(this.oldValue, this.newValue);
  toString(){
    return oldValue.toString() + ' '+  newValue.toString();
  }
}

/**
 * Class to remember collection of changes since last synchronization
 */
class ChangeSet {
  Set addedChildren = new Set();
  Set removedChildren = new Set();
  /** <children,Change> or <children, ChangeSet> */
  Map changedChildren = new Map();
  
  ChangeSet();
  /**
   * Factory to clone ChangeSet
   */
  factory ChangeSet.from(ChangeSet other) {
    var changeSet = new ChangeSet();
    changeSet.apply(other);
    return changeSet;
  }
  
  /**
   * Marks child as added
   */
  void addChild(dynamic child) {
    if(this.removedChildren.contains(child)) {
      this.removedChildren.remove(child);
    } else {
      this.addedChildren.add(child);
    }
  }
  
  /**
   * Marks [child] as deleted
   */
  void removeChild(dynamic child) {
    if(addedChildren.contains(child)) {
      this.addedChildren.remove(child);
    } else {
      this.removedChildren.add(child);
    }
  }
  
  /**
   * changeSet can be [ChangeSet[ or [Change]
   * Marks what was changed inside child
   */
  void changeChild(dynamic child, changeSet) {
    if(this.addedChildren.contains(child)) return;
    
    if(this.changedChildren.containsKey(child)) {
      this.changedChildren[child].apply(changeSet);
    } else {
      this.changedChildren[child] = changeSet;
    }
  }
  
  /**
   * Merges two [ChangeSet]s together. 
   */
  void apply(ChangeSet changeSet) {
    for(var child in changeSet.addedChildren ){
      this.addChild(child);
    }
    for(var child in changeSet.removedChildren) {
      this.removeChild(child);
    }
    changeSet.changedChildren.forEach((child,changeSet) {
      this.changeChild(child,changeSet);
    });
  }
  
  /**
   * Removes all changes
   */
  void clear() {
    this.addedChildren.clear();
    this.removedChildren.clear();
    this.changedChildren.clear();
  }
  
  /**
   * Return if there are any changes
   */
  bool get isEmpty =>
      this.addedChildren.isEmpty && this.removedChildren.isEmpty &&
        this.changedChildren.isEmpty;
  String toString(){
    var sb = new StringBuffer();
    sb.writeln('AddedChildren: ' + this.addedChildren.toString());
    sb.writeln('RemovedChildren: ' + this.removedChildren.toString());
    sb.writeln('ChangedChildren: ' + this.changedChildren.toString());
    return sb.toString();
  }
}