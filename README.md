# Bootyhunter -- geocaching for SailfishOS

Openrepos: https://openrepos.net/content/tadzik/bootyhunter
TMO thread: https://talk.maemo.org/showthread.php?p=1522184#post1522184

# Building

The `oauthkeys.h` file included in the source code release needs some
modifications. It should contain OKAPI OAuth keys that you have to
obtain yourself (it's fully automated, no human is harmed when
distributing those and it takes literally less than a minute though).

Only the keys defined in the file will be included in the build. For
an empty `oauthkeys.h` the app will be somewhat useless :)
