import 'package:pool/pool.dart';

/// An event type to signal the pool is empty.
typedef PoolEmptied = Future<void> Function();

/// An event type to signal a request is being added to the pool.
typedef AddingToPool = Future<void> Function();

/// An event type to signal a request was removed from the pool.
typedef RemovedFromPool = Future<void> Function();

/// Manage the pool of requests.
/// Throttle when there are too many requests at once.
/// During the update of tokens, new requests will wait until the token
/// pool is released.
class PoolManager {
  /// The amount of concurrent requests.
  final int maxActiveConnections;

  /// An event when the request pool is emptied.
  final PoolEmptied? poolEmptied;

  /// An event when a request is added to the request pool.
  final AddingToPool? addingToPool;

  /// An event when a request is removed from the request pool.
  final RemovedFromPool? removedFromPool;

  PoolManager({
    this.maxActiveConnections = 32,
    this.poolEmptied,
    this.addingToPool,
    this.removedFromPool,
  });

  /// The pool for general requests.
  late Pool _mainPool = Pool(
    maxActiveConnections,
  );

  /// If the main request pool is empty.
  bool get emptyPool => mainPoolAllocatedResources == 0;
  int mainPoolAllocatedResources = 0;

  /// The pool when a token is being refreshed.
  late Pool _tokenPool = Pool(1);
  PoolResource? _tokenResource;
  bool _tokenUpdateRequested = false;

  /// The pool when a pause was requested.
  late Pool _pausePool = Pool(1);
  PoolResource? _pauseResource;
  bool _pauseRequested = false;

  /// If a token update has been requested, and has not been released yet.
  bool get tokenUpdateRequested => _tokenUpdateRequested;

  /// If a pause has been requested, and has not been released yet.
  bool get pauseRequested => _pauseRequested;

  /// A new request for the main pool.
  /// It is important to always release a request with the [release] method of
  /// the [PoolManager], not the [PoolResource] itself!
  Future<PoolResource> request() async {
    if (_tokenResource != null) {
      // There is a pending token update.
      // Add another request to the pool.
      // This will pause adding the main pool.
      // When the token is released, all other requests will be released
      // one by one.
      PoolResource tempTokenResource = await _tokenPool.request();
      tempTokenResource.release();
    }

    if (_pauseResource != null) {
      // There is a pending pause.
      // Add another request to the pool.
      // This will pause adding the main pool.
      // When the pause is released, all other requests will be released
      // one by one.
      PoolResource tempTokenResource = await _pausePool.request();
      tempTokenResource.release();
    }

    mainPoolAllocatedResources++;
    await addingToPool?.call();
    return await _mainPool.request();
  }

  /// Release a [PoolResource].
  Future<void> release(PoolResource resource) async {
    resource.release();
    mainPoolAllocatedResources--;
    await removedFromPool?.call();

    if (mainPoolAllocatedResources <= 0) {
      mainPoolAllocatedResources = 0;
      await poolEmptied?.call();
    }
  }

  /// A new request for the token pool.
  /// This will make other requests wait until the token pool is released
  /// by using [releaseUpdateToken].
  Future<void> requestUpdateToken() async {
    _tokenUpdateRequested = true;
    if (_tokenResource != null) {
      return;
    }
    _tokenResource = await _tokenPool.request();
  }

  /// Release the request of the token pool.
  void releaseUpdateToken() {
    _tokenUpdateRequested = false;
    _tokenResource?.release();
    _tokenResource = null;
  }

  /// Request a pause of all future requests.
  /// This will make other requests wait until the pause pool is released
  /// by using [releasePause].
  Future<void> requestPause() async {
    _pauseRequested = true;
    if (_pauseResource != null) {
      return;
    }
    _pauseResource = await _pausePool.request();
  }

  /// Release the request of the pause pool.
  void releasePause() {
    _pauseRequested = false;
    _pauseResource?.release();
    _pauseResource = null;
  }

  /// Release all pending requests and create new pools.
  /// This will allow all pending requests to continue.
  Future<void> reset() async {
    mainPoolAllocatedResources = 0;

    await _mainPool.close();
    await _tokenPool.close();
    await _pausePool.close();

    _mainPool = Pool(
      maxActiveConnections,
    );
    _tokenPool = Pool(1);
    _pausePool = Pool(1);
  }
}
