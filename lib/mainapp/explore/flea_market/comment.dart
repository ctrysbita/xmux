part of 'item_detail_page.dart';

class _CommentDialog extends StatelessWidget {
  final String _itemKey;

  _CommentDialog(this._itemKey);

  final TextEditingController _controller = TextEditingController();

  void _handleComment(String text) async {
    FirebaseDatabase.instance
        .reference()
        .child('flea_market/$_itemKey/comments')
        .push()
        .set({
      'from': firebaseUser.uid,
      'comment': text,
      'timestamp': DateTime.now().toIso8601String()
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      children: <Widget>[
        TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: i18n('FleaMarket/Details/Comments/Caption', context),
            labelText: i18n('FleaMarket/Details/Comments', context),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              child: Text(i18n('FleaMarket/Details/Comments', context)),
              onPressed: () {
                if (_controller.text.isNotEmpty)
                  _handleComment(_controller.text);
                Navigator.pop(context);
              },
            )
          ],
        )
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  final Comment _comment;

  const _CommentCard(this._comment);

  factory _CommentCard.fromSnapshot(DataSnapshot snap) =>
      _CommentCard(Comment.fromSnapshot(snap));

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: CircleAvatar(
            child: FutureBuilder<XMUXApiResponse<User>>(
              future: xmuxApi.getUser(_comment.from),
              builder: (_, snap) => snap.hasData
                  ? Image.network(xmuxApi.convertAvatarUrl(
                      snap.data.data.photoUrl, store.state.authState.moodleKey))
                  : SpinKitPulse(color: Colors.white),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder<XMUXApiResponse<User>>(
                future: xmuxApi.getUser(_comment.from),
                builder: (_, snap) => snap.hasData
                    ? Text(
                        snap.data.data.name,
                        style: Theme.of(context).textTheme.subhead,
                      )
                    : Text('...'),
              ),
              Text(
                '${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(_comment.timestamp)} ${DateFormat.Hm(Localizations.localeOf(context).languageCode).format(_comment.timestamp)}',
                style: Theme.of(context).textTheme.caption,
              ),
              Padding(padding: const EdgeInsets.all(2.0)),
              Text(_comment.comment),
            ],
          ),
        ),
      ],
    );
  }
}