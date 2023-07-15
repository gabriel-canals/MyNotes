// Creates an extension Filter of an Stream of a list of any type
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) => 
    // If the List passes the test of the filter, the item will be added to the map
    map((items) => items.where(where).toList()); 
}
