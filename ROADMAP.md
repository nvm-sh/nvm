# nvm Road Map

This is a list of the primary features planned for `nvm`:

- [x] Rewriting installation code paths to support installing `io.js` and `node` `v4+` [from source](https://github.com/creationix/nvm/issues/1188).
  - This will include [reusing previously downloaded tarballs](https://github.com/creationix/nvm/issues/1193) that match checksums, which is a nice performance and bandwidth bonus.
- [ ] Adding opt-in environment variable support to list, download, and install `node` [release candidates](https://github.com/creationix/nvm/issues/779), and [nightly builds](https://github.com/creationix/nvm/issues/1053).
- [ ] [`nvm update`](https://github.com/creationix/nvm/issues/400): the ability to autoupdate `nvm` itself
- [ ] [v1.0.0](https://github.com/creationix/nvm/milestone/1), including updating the [nvm on npm](https://github.com/creationix/nvm/issues/304) to auto-install nvm properly
