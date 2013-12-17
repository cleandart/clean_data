// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of clean_data;

/**
 * Observable object, which represents single primitive in Data.
 * 
 */
class DataReference extends Object with ChangeNotificationsMixin {
  
  /**
   * Primitive type
   */
  dynamic _value;
  
  /**
   * Return value of a primitive type.
   */
  get value => _value;
  
  /**
   * Change value of primitive type and notify listeners.
   */
  set value(newValue) {
    _markChanged('value', new Change(_value, newValue));
    _value = newValue;
    _notify(single: 'value');
  }
  
  /**
   * Creates new DataReference with [_value]
   */
  DataReference(this._value);
}