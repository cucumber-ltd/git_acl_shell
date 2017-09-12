# Git Acl Shell

Git shell that adds access control to Git repositories accessed over SSH.
Similar to [Gitolite](http://gitolite.com/gitolite/index.html) and [gitlab-shell](https://github.com/gitlabhq/gitlab-shell).

The main difference is that the shell queries an external service over HTTP
to check if a user has access.
