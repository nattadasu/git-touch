import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:git_touch/models/auth.dart';
import 'package:git_touch/models/gitlab.dart';
import 'package:git_touch/scaffolds/refresh_stateful.dart';
import 'package:git_touch/widgets/repository_item.dart';
import 'package:git_touch/widgets/user_header.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:git_touch/utils/utils.dart';
import 'package:timeago/timeago.dart' as timeago;

final gitlabGroupRouter = RouterScreen(
    '/gitlab/group/:id',
    (context, parameters) =>
        GitlabGroupScreen(int.parse(parameters['id'].first)));

class GitlabGroupScreen extends StatelessWidget {
  final int id;
  GitlabGroupScreen(this.id);

  @override
  Widget build(BuildContext context) {
    return RefreshStatefulScaffold<Tuple2<GitlabGroup, Null>>(
      title: Text('Group'),
      fetchData: () async {
        final auth = Provider.of<AuthModel>(context);
        final res = await Future.wait([auth.fetchGitlab('/groups/$id')]);
        return Tuple2(GitlabGroup.fromJson(res[0]), null);
      },
      bodyBuilder: (data, _) {
        final p = data.item1;
        return Column(
          children: <Widget>[
            UserHeader(
              login: p.path,
              avatarUrl: p.avatarUrl,
              name: p.name,
              createdAt: null,
              bio: p.description,
            ),
            CommonStyle.border,
            Column(
              children: <Widget>[
                for (var v in p.projects)
                  RepositoryItem.gl(
                    payload: v,
                    note: 'Updated ${timeago.format(v.lastActivityAt)}',
                  )
              ],
            )
          ],
        );
      },
    );
  }
}