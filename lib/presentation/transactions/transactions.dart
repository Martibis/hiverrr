import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiverrr/blocs/transaction_history_bloc/transaction_history_bloc.dart';
import 'package:hiverrr/data/models/transaction_model.dart';
import 'package:hiverrr/presentation/widgets/infinite_list_exceptions/empty_list_indicator.dart';
import 'package:hiverrr/presentation/widgets/infinite_list_exceptions/error_indicator.dart';
import 'package:hiverrr/presentation/widgets/infinite_list_exceptions/loading_more_indicator.dart';
import 'package:hiverrr/presentation/widgets/neumorphism/neumorphism_container.dart';
import 'package:hiverrr/presentation/widgets/screen_header/screen_header.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:timeago/timeago.dart' as timeago;

class TransactionsPage extends StatefulWidget {
  final String username;
  TransactionsPage({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final ScrollController _scrollController = ScrollController();
  final PagingController<int, TransactionModel> _pagingController =
      PagingController(firstPageKey: -1);
  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      BlocProvider.of<TransactionHistoryBloc>(context)
          .add(FetchTransactions(pageKey: pageKey, username: widget.username));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      ScreenHeader(title: 'Transactions', hasBackButton: true),
      Expanded(
          child: BlocListener<TransactionHistoryBloc, TransactionHistoryState>(
              listener: (context, state) {
                if (state is IsLoaded) {
                  _pagingController.value = PagingState(
                      nextPageKey: state.nextPageKey,
                      itemList: state.transactions);
                }
                if (state is IsError) {
                  _pagingController.error = state.e;
                }
              },
              child: RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: () async {
                  BlocProvider.of<TransactionHistoryBloc>(context)
                      .add(FetchTransactions(
                    username: widget.username,
                    pageKey: -1,
                  ));
                },
                child: PagedListView(
                    addAutomaticKeepAlives: false,
                    scrollController: _scrollController,
                    pagingController: _pagingController,
                    physics: AlwaysScrollableScrollPhysics(),
                    builderDelegate: PagedChildBuilderDelegate<
                            TransactionModel>(
                        noItemsFoundIndicatorBuilder: (context) =>
                            EmptyListIndicator(
                              message: 'No transactions found',
                            ),
                        noMoreItemsIndicatorBuilder: (context) => Container(),
                        firstPageErrorIndicatorBuilder: (context) =>
                            ErrorIndicator(
                                error: _pagingController.error,
                                onTryAgain: () =>
                                    BlocProvider.of<TransactionHistoryBloc>(
                                            context)
                                        .add(FetchTransactions(
                                      username: widget.username,
                                      pageKey: -1,
                                    ))),
                        newPageErrorIndicatorBuilder: (context) =>
                            ErrorIndicator(
                                error: _pagingController.error,
                                onTryAgain: () =>
                                    BlocProvider.of<TransactionHistoryBloc>(
                                            context)
                                        .add(FetchTransactions(
                                      username: widget.username,
                                      pageKey: _pagingController.nextPageKey!,
                                    ))),
                        firstPageProgressIndicatorBuilder: (context) =>
                            LoadingMoreIndicator(
                              message: 'Loading transactions',
                            ),
                        newPageProgressIndicatorBuilder: (context) =>
                            LoadingMoreIndicator(
                              message: 'Loading transactions',
                            ),
                        itemBuilder: (_, item, index) {
                          return item.showTransaction
                              ? NeumorphismContainer(
                                  margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
                                  color: Theme.of(context).backgroundColor,
                                  onTap: () {},
                                  expandable: false,
                                  tapable: false,
                                  mainContent: Row(
                                    //crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      item.isProfilepic
                                          ? Container(
                                              padding: EdgeInsets.only(top: 5),
                                              child: CircleAvatar(
                                                radius: 25,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .backgroundColor,
                                                child: CircleAvatar(
                                                  radius: 24,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .backgroundColor,
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                    item.asset,
                                                  ),
                                                ),
                                              ))
                                          : Container(
                                              padding: EdgeInsets.only(top: 5),
                                              child: CircleAvatar(
                                                radius: 25,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .backgroundColor,
                                                child: CircleAvatar(
                                                  radius: 24,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .backgroundColor,
                                                  child: Center(
                                                    child: Text(
                                                      item.emoji,
                                                      style: TextStyle(
                                                          fontSize: 25),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      Container(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.infoText,
                                            ),
                                            Container(
                                              height: 10,
                                            ),
                                            item.amountText != ''
                                                ? Text(
                                                    item.amountText,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  )
                                                : Container(),
                                            item.amountText != ''
                                                ? Container(
                                                    height: 10,
                                                  )
                                                : Container(),
                                            item.hasSecondInfoText
                                                ? Text(item.secondInfoText!)
                                                : Container(),
                                            item.hasSecondInfoText
                                                ? Container(
                                                    height: 10,
                                                  )
                                                : Container(),
                                            Text(
                                              timeago.format(item.timestamp,
                                                  clock: DateTime.now()),
                                              style: TextStyle(fontSize: 13),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  expandableContent: Container())
                              : Container();
                        })),
              ))),
    ])));
  }
}
