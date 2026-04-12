import 'package:flutter/material.dart';

import '../routes/app_route_observer.dart';

mixin RefreshOnReturnMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  Future<void> onRefreshRequested();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    onRefreshRequested();
  }

  @override
  void didPush() {}

  @override
  void didPushNext() {}

  @override
  void didPop() {}
}
