//Implementacion de una tabla hash en Dart para un analizador lexico

// /*

// -* Hash Table *-

// The Hash table data structure stores elements in key-value pairs where

// Key- unique integer that is used for indexing the values
// Value - data that are associated with keys.

// Hashing (Hash Function)
// In a hash table, a new index is processed using the keys. And, the element corresponding to that key is stored in the index. This process is called hashing.

// Let k be a key and h(x) be a hash function.

// Here, h(k) will give us a new index to store the element linked with k.

// Hash Collision
// When the hash function generates the same index for multiple keys, there will be a conflict (what value to be stored in that index). This is called a hash collision.

// We can resolve the hash collision using one of the following techniques.

// Collision resolution by chaining
// Open Addressing: Linear/Quadratic Probing and Double Hashing

// 1. Collision resolution by chaining
// In chaining, if a hash function produces the same index for multiple elements, these elements are stored in the same index by using a doubly-linked list.

// If j is the slot for multiple elements, it contains a pointer to the head of the list of elements. If no element is present, j contains NIL.

// 2. Open Addressing
// Unlike chaining, open addressing doesn't store multiple elements into the same slot. Here, each slot is either filled with a single key or left NIL.

// Different techniques used in open addressing are:

// i. Linear Probing
// In linear probing, collision is resolved by checking the next slot.

// h(k, i) = (h′(k) + i) mod m

// where

// i = {0, 1, ….}
// h'(k) is a new hash function
// If a collision occurs at h(k, 0), then h(k, 1) is checked. In this way, the value of i is incremented linearly.

// The problem with linear probing is that a cluster of adjacent slots is filled. When inserting a new element, the entire cluster must be traversed. This adds to the time required to perform operations on the hash table.

// ii. Quadratic Probing
// It works similar to linear probing but the spacing between the slots is increased (greater than one) by using the following relation.

// h(k, i) = (h′(k) + c1i + c2i2) mod m

// where,

// c1 and c2 are positive auxiliary constants,
// i = {0, 1, ….}
// iii. Double hashing
// If a collision occurs after applying a hash function h(k), then another hash function is calculated for finding the next slot.

// h(k, i) = (h1(k) + ih2(k)) mod m

// Good Hash Functions
// A good hash function may not prevent the collisions completely however it can reduce the number of collisions.

// Here, we will look into different methods to find a good hash function

// 1. Division Method
// If k is a key and m is the size of the hash table, the hash function h() is calculated as:

// h(k) = k mod m

// For example, If the size of a hash table is 10 and k = 112 then h(k) = 112 mod 10 = 2. The value of m must not be the powers of 2. This is because the powers of 2 in binary format are 10, 100, 1000, …. When we find k mod m, we will always get the lower order p-bits.

// if m = 22, k = 17, then h(k) = 17 mod 22 = 10001 mod 100 = 01
// if m = 23, k = 17, then h(k) = 17 mod 22 = 10001 mod 100 = 001
// if m = 24, k = 17, then h(k) = 17 mod 22 = 10001 mod 100 = 0001
// if m = 2p, then h(k) = p lower bits of m
// 2. Multiplication Method
// h(k) = ⌊m(kA mod 1)⌋

// where,

// kA mod 1 gives the fractional part kA,
// ⌊ ⌋ gives the floor value
// A is any constant. The value of A lies between 0 and 1. But, an optimal choice will be ≈ (√5-1)/2 suggested by Knuth.
// 3. Universal Hashing
// In Universal hashing, the hash function is chosen at random independent of keys.

// */

class HashNode<K, V> {
  K key;
  V value;
  @override
  int hashCode;

  HashNode<K, V>? next;
  HashNode(this.key, this.value, this.hashCode);

  @override
  bool operator ==(Object other) {
    if (this == other) return true;
    if (other is! HashNode) return false;
    HashNode<K, V> node = other as HashNode<K, V>;
    return key == node.key && value == node.value;
  }
}

class HashTable<K, V> {
  late List<HashNode<K, V>?> bucketArray;
  late int numBuckets;
  late int size;

  HashTable() {
    bucketArray = [];
    numBuckets = 100;
    size = 0;
    for (int i = 0; i < numBuckets; i++) {
      bucketArray.add(null);
    }
  }
  int sizes() {
    return size;
  }

  bool isEmpty() {
    return sizes() == 0;
  }

  int hashCodes(K key) {
    return Object.hashAll([key]);
  }

  int getBucketIndex(K key) {
    // int hashCode = hashCode(key);
    int hashCode = hashCodes(key);
    int index = hashCode % numBuckets;
    // key.hashCode() could be negative.
    index = index < 0 ? index * -1 : index;
    return index;
  }

  V? remove(K key) {
    // Apply hash function to find index for given key
    int bucketIndex = getBucketIndex(key);
    int hashCode = hashCodes(key);
    // Get head of chain
    HashNode<K, V>? head = bucketArray.elementAt(bucketIndex);

    // Search for key in its chain
    HashNode<K, V>? prev;
    while (head != null) {
      // If Key found
      if (head.key == key && hashCode == head.hashCode) break;

      // Else keep moving in chain
      prev = head;
      head = head.next;
    }

    // If key was not there
    if (head == null) return null;

    // Reduce size
    size--;

    // Remove key
    if (prev != null) {
      prev.next = head.next;
    } else {
      bucketArray.insert(bucketIndex, head.next);
    }

    return head.value;
  }

  V? getKey(K key) {
    // Find head of chain for given key
    int bucketIndex = getBucketIndex(key);
    int hashCode = hashCodes(key);

    HashNode<K, V>? head = bucketArray.elementAt(bucketIndex);

    // Search key in chain
    while (head != null) {
      if (head.key == key && head.hashCode == hashCode) return head.value;
      head = head.next;
    }

    // If key not found
    //print("KeyAt ${key}");
    return null;
  }

  void add(K key, V value) {
    // Find head of chain for given key
    int bucketIndex = getBucketIndex(key);
    int hashCode = hashCodes(key);
    HashNode<K, V>? head = bucketArray.elementAt(bucketIndex);

    // Check if key is already present
    while (head != null) {
      if (head.key == key && head.hashCode == hashCode) {
        head.value = value;
        return;
      }
      head = head.next;
    }

    // Insert key in chain
    size++;
    head = bucketArray.elementAt(bucketIndex);
    HashNode<K, V> newNode = HashNode<K, V>(key, value, hashCode);
    newNode.next = head;
    bucketArray.insert(bucketIndex, newNode);

    // If load factor goes beyond threshold, then
    // double hash table size
    if ((1.0 * size) / numBuckets >= 0.7) {
      List<HashNode<K, V>?> temp = bucketArray;
      bucketArray = [];
      numBuckets = 2 * numBuckets;
      size = 0;
      for (int i = 0; i < numBuckets; i++) {
        bucketArray.add(null);
      }

      for (HashNode<K, V>? headNode in temp) {
        while (headNode != null) {
          add(headNode.key, headNode.value);
          headNode = headNode.next;
        }
      }
    }
    //print("Key: ${key}" + " " + "Value: ${value}");
  }
}
