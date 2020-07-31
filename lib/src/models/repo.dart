import 'package:github/github.dart';

/// Represents a GitHub repository.
///
/// The [owner] indicates the GitHub username of the repository owner.
/// The [name] indicates the repository name.
///
/// The [owner] and [name] must not be null.
class Repo {
  final String owner;
  final String name;
  Repo(this.owner, this.name)
      : assert(owner != null),
        assert(name != null);

  RepositorySlug toSlug() => RepositorySlug(owner, name);
}
