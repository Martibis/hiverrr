import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/authbloc/auth_bloc.dart';
import 'package:hiverrr/blocs/subscriptions_bloc/subscriptions_bloc.dart';
import 'package:hiverrr/data/models/subscription_model.dart';
import 'package:hiverrr/presentation/widgets/infinite_list_exceptions/empty_list_indicator.dart';
import 'package:hiverrr/presentation/widgets/infinite_list_exceptions/error_indicator.dart';
import 'package:hiverrr/presentation/widgets/infinite_list_exceptions/loading_more_indicator.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:hiverrr/presentation/widgets/screen_header/screen_header.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SubscriptionsPage extends StatefulWidget {
  final String username;
  SubscriptionsPage({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final ScrollController _scrollController = ScrollController();
  final PagingController<int, Subscription> _pagingController =
      PagingController(firstPageKey: 0);
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      BlocProvider.of<SubscriptionsBloc>(context)
          .add(FetchSubscriptions(pageKey: pageKey, username: widget.username));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      ScreenHeader(title: 'Subscriptions', hasBackButton: true),
      Expanded(
          child: BlocListener<SubscriptionsBloc, SubscriptionsState>(
              listener: (context, state) {
                if (state is IsLoaded) {
                  _pagingController.value = PagingState(
                      nextPageKey: state.nextPageKey,
                      itemList: state.subscriptions);
                }
                if (state is IsError) {
                  _pagingController.error = state.e;
                }
              },
              child: RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: () async {
                  BlocProvider.of<SubscriptionsBloc>(context)
                      .add(FetchSubscriptions(
                    username: widget.username,
                    pageKey: 0,
                  ));
                },
                child: PagedListView(
                    addAutomaticKeepAlives: false,
                    scrollController: _scrollController,
                    pagingController: _pagingController,
                    physics: AlwaysScrollableScrollPhysics(),
                    builderDelegate: PagedChildBuilderDelegate<Subscription>(
                        noItemsFoundIndicatorBuilder: (context) =>
                            EmptyListIndicator(
                              message: 'No active subscriptions',
                            ),
                        noMoreItemsIndicatorBuilder: (context) => Container(),
                        firstPageErrorIndicatorBuilder: (context) =>
                            ErrorIndicator(
                                error: _pagingController.error,
                                onTryAgain: () =>
                                    BlocProvider.of<SubscriptionsBloc>(context)
                                        .add(FetchSubscriptions(
                                      username: widget.username,
                                      pageKey: 0,
                                    ))),
                        newPageErrorIndicatorBuilder: (context) =>
                            ErrorIndicator(
                                error: _pagingController.error,
                                onTryAgain: () =>
                                    BlocProvider.of<SubscriptionsBloc>(context)
                                        .add(FetchSubscriptions(
                                      username: widget.username,
                                      pageKey: _pagingController.nextPageKey!,
                                    ))),
                        firstPageProgressIndicatorBuilder: (context) =>
                            LoadingMoreIndicator(
                              message: 'Loading subscriptions',
                            ),
                        newPageProgressIndicatorBuilder: (context) =>
                            LoadingMoreIndicator(
                              message: 'Loading subscriptions',
                            ),
                        itemBuilder: (_, item, index) {
                          return NeumorphismContainer(
                              color: Theme.of(context).backgroundColor,
                              onTap: () {},
                              expandable: false,
                              tapable: true,
                              mainContent: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).backgroundColor,
                                    backgroundImage: CachedNetworkImageProvider(
                                      item.profilepic,
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '@' + item.username,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        height: 10,
                                      ),
                                      Text(item.amount.toStringAsFixed(3) +
                                          ' ' +
                                          item.currency +
                                          ' - ' +
                                          item.reccurenceString.toLowerCase())
                                    ],
                                  )
                                ],
                              ),
                              expandableContent: Container());
                        })),
              )))
    ])));
  }
}
