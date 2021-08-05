import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/delegations_bloc/delegations_bloc.dart';
import 'package:hiverrr/data/models/delegation_model.dart';
import 'package:hiverrr/data/models/subscription_model.dart';
import 'package:hiverrr/presentation/delegations/delegation.dart';
import 'package:hiverrr/presentation/subscriptions/subscription.dart';
import 'package:hiverrr/presentation/widgets/infinite_list_exceptions/empty_list_indicator.dart';
import 'package:hiverrr/presentation/widgets/infinite_list_exceptions/error_indicator.dart';
import 'package:hiverrr/presentation/widgets/infinite_list_exceptions/loading_more_indicator.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:hiverrr/presentation/widgets/screen_header/screen_header.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:timeago/timeago.dart' as timeago;

class DelegationsPage extends StatefulWidget {
  final String username;
  final num vestsToHive;
  DelegationsPage({Key? key, required this.username, required this.vestsToHive})
      : super(key: key);

  @override
  _DelegationsPageState createState() => _DelegationsPageState();
}

class _DelegationsPageState extends State<DelegationsPage> {
  final ScrollController _scrollController = ScrollController();
  final PagingController<int, DelegationModel> _pagingController =
      PagingController(firstPageKey: 0);
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      BlocProvider.of<DelegationsBloc>(context).add(FetchDelegations(
          pageKey: pageKey,
          username: widget.username,
          vestsToHive: widget.vestsToHive,
          isRefresh: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      ScreenHeader(title: 'Delegations', hasBackButton: true),
      Expanded(
          child: BlocListener<DelegationsBloc, DelegationsState>(
              listener: (context, state) {
                if (state is IsLoaded) {
                  _pagingController.value = PagingState(
                      nextPageKey: state.nextPageKey,
                      itemList: state.delegations);
                }
                if (state is IsError) {
                  _pagingController.error = state.e;
                }
              },
              child: RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: () async {
                  BlocProvider.of<DelegationsBloc>(context).add(
                      FetchDelegations(
                          username: widget.username,
                          pageKey: 0,
                          vestsToHive: widget.vestsToHive,
                          isRefresh: true));
                },
                child: PagedListView(
                    addAutomaticKeepAlives: false,
                    scrollController: _scrollController,
                    pagingController: _pagingController,
                    physics: AlwaysScrollableScrollPhysics(),
                    builderDelegate: PagedChildBuilderDelegate<DelegationModel>(
                        noItemsFoundIndicatorBuilder: (context) =>
                            EmptyListIndicator(
                              message: 'No active delegations',
                            ),
                        noMoreItemsIndicatorBuilder: (context) => Container(),
                        firstPageErrorIndicatorBuilder: (context) =>
                            ErrorIndicator(
                                error: _pagingController.error,
                                onTryAgain: () =>
                                    BlocProvider.of<DelegationsBloc>(context)
                                        .add(FetchDelegations(
                                            username: widget.username,
                                            pageKey: 0,
                                            vestsToHive: widget.vestsToHive,
                                            isRefresh: true))),
                        newPageErrorIndicatorBuilder: (context) =>
                            ErrorIndicator(
                                error: _pagingController.error,
                                onTryAgain: () =>
                                    BlocProvider.of<DelegationsBloc>(context)
                                        .add(FetchDelegations(
                                            username: widget.username,
                                            pageKey:
                                                _pagingController.nextPageKey!,
                                            vestsToHive: widget.vestsToHive,
                                            isRefresh: false))),
                        firstPageProgressIndicatorBuilder:
                            (context) => LoadingMoreIndicator(
                                  message: 'Loading delegations',
                                ),
                        newPageProgressIndicatorBuilder: (context) =>
                            LoadingMoreIndicator(
                              message: 'Loading delegations',
                            ),
                        itemBuilder: (_, item, index) {
                          return NeumorphismContainer(
                              margin: EdgeInsets.fromLTRB(25, 0, 25, 25),
                              color: Theme.of(context).backgroundColor,
                              onTap: () {
                                item.isExpiring
                                    ? print('Expiring')
                                    : Navigator.of(context, rootNavigator: true)
                                        .push(MaterialPageRoute(
                                            builder: (_) => Delegation(
                                                  delegation: item,
                                                  changingDelegation: true,
                                                  vestsToHive:
                                                      widget.vestsToHive,
                                                )));
                              },
                              expandable: false,
                              tapable: !item.isExpiring,
                              mainContent: Row(
                                children: [
                                  item.isExpiring
                                      ? Expanded(
                                          child: RichText(
                                            text: TextSpan(children: [
                                              TextSpan(
                                                text: 'Expiring: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!,
                                              ),
                                              TextSpan(
                                                text: item.amount
                                                        .toStringAsFixed(3) +
                                                    ' ' +
                                                    item.currency,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: ' ' +
                                                    '(' +
                                                    timeago.format(
                                                        item.expireDate!,
                                                        allowFromNow: true,
                                                        clock: DateTime.now()) +
                                                    ')',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!,
                                              )
                                            ]),
                                          ),
                                        )
                                      : Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .backgroundColor,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                item.profilepic!,
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
                                                  '@' + item.username!,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                                Container(
                                                  height: 10,
                                                ),
                                                Text(item.amount
                                                        .toStringAsFixed(3) +
                                                    ' ' +
                                                    item.currency)
                                              ],
                                            )
                                          ],
                                        )
                                ],
                              ),
                              expandableContent: Container());
                        })),
              ))),
      Row(children: [
        Expanded(
          child: NeumorphismContainer(
            color: Theme.of(context).accentColor,
            tapable: true,
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                  builder: (_) => Delegation(vestsToHive: widget.vestsToHive)));
            },
            mainContent: Center(
              child: Text(
                'New delegation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            expandableContent: Container(),
            expandable: false,
          ),
        ),
      ]),
      Container(
        height: 25,
      ),
    ])));
  }
}
