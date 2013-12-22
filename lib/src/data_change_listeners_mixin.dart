part of clean_data;

abstract class DataChangeListenersMixin<T> {

  void _markChanged(T key, changeSet);
  void _notify({author});
  /**
   * Internal Set of data objects removed from Collection that still have DataListener listening.
   */
  Set<T> _removedObjects = new Set();
  /**
   * Internal set of listeners for change events on individual data objects.
   */
  final Map<dynamic, StreamSubscription> _dataListeners =
      new Map<dynamic, StreamSubscription>();

  /**
   * Removes listeners to all objects which have been removed and stacked in [_removedObjects]
   */
  void _onBeforeNotify() {
    // if this object was removed and then re-added in this event loop, don't
    // destroy onChange listener to it.
    for(T key in _removedObjects) {
      _removeOnDataChangeListener(key);
    }
    _removedObjects.clear();
  }

  /**
   * Starts listening to changes on [dataObj].
   */
  void _addOnDataChangeListener(T key, ChangeNotificationsMixin dataObj) {
    if (_dataListeners.containsKey(dataObj)) return;

    _dataListeners[key] = dataObj.onChangeSync.listen((changeEvent) {
      _markChanged(key, changeEvent['change']);
      _notify(author: changeEvent['author']);
    });
  }

  /**
   * Stops listening to changes on [dataObj]
   * Second possibility is to add to [_removedObjects] and call [_onBeforeNotify]
   */
  void _removeAllOnDataChangeListeners() {
    for(T key in _removedObjects) {
      _removeOnDataChangeListener(key);
    }
  }

  void _removeOnDataChangeListener(T key) {
    if (_dataListeners.containsKey(key)) {
      _dataListeners[key].cancel();
      _dataListeners.remove(key);
    }
  }

  /**
   *  Makes to be good. In positive case old data listener is removed and new subscribed
   *  only if [dataObj] is [ChangeNotificationsMixin].
   *  If [dataObj] is null, only removal. If key is not contained,
   *  then only addition. If both null, nothing is done.
   */
  void _smartUpdateOnDataChangeListener(T key, dynamic dataObj){
    //it will be a bug if key is! ChangeNotificationsMixin and _dataListeners.containsKey(key) :P
    //  -- and this code actually fixes this bad state ;)
    _removeOnDataChangeListener(key);

    if(dataObj != null && dataObj is ChangeNotificationsMixin){
      _addOnDataChangeListener(key, dataObj);
    }
  }
}
