Versus
======

A `git difftool`/`git mergetool` wrapper


Features
--------

- Uses `git difftool` or
- Uses `git mergetool` when merge conflicts were detected
- Automatically uses `--staged` option when only cached files specified/available
- Automatically uses `--dir-diff` option depending on number of files changed

- Support for unversioned files


Installation
------------

1. Download or clone this repository
2. Copy/move the script files to *~/bin* or any other directory that is added to *PATH*.
3. Make sure both are executable: `chmod +x vs git-difftool-cmd`
4. Make sure you have a difftool and mergetool set in your git config.  
   Recommended setup (example with BeyondCompare 3 &rarr; `bc3` keyword):

   ```ini
   [diff]
   	tool = bc3
   [merge]
   	tool = bc3
   [difftool]
   	prompt = false
   [mergetool]
   	prompt = false
   ```


Usage
-----

```
vs [OPTIONS]... [FILES]
```

OPTIONS: Same as for `git difftool`
