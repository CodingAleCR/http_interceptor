import 'package:pool/pool.dart';

/// Manage the pool of requests.
/// Throttle when there are too many requests at once.
/// During the update of tokens, new requests will wait until the token
/// pool is released.
class PoolManager {
  final int maxActiveConnections;

  PoolManager({
    this.maxActiveConnections = 32,
  });

  /// The pool for general requests.
  late Pool _mainPool = Pool(
    maxActiveConnections,
  );

  /// The pool when a token is being refreshed.
  late Pool _tokenPool = Pool(1);
  PoolResource? _tokenResource;

  /// A new request for the main pool.
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
    return await _mainPool.request();
  }

  /// A new request for the token pool.
  /// This will make other requests wait until the token pool is released
  /// by using [releaseUpdateToken].
  Future requestUpdateToken() async {
    if (_tokenResource != null) {
      return;
    }
    _tokenResource = await _tokenPool.request();
  }

  /// Release the request of the token pool.
  void releaseUpdateToken() {
    _tokenResource?.release();
    _tokenResource = null;
  }
  
  /// Release all pending requests and create new pools.
  /// This will allow all pending requests to continue.
  Future reset() async {
    await _mainPool.close();
    await _tokenPool.close();

    _mainPool = Pool(
      maxActiveConnections,
    );
    _tokenPool = Pool(1);
  }
}
