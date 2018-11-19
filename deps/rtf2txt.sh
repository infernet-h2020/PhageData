#! /bin/sh

# the four sed expressions in the command line below are to:
# 1. delete leading control lines starting with a backslash
# 2. delete leading control lines starting with an open bracket
# 3. delete all empty lines
# 4. eliminate the trailing backslash on all lines

#sed -e '/^\\/d' -e '/^{/d' -e '/^$/d' -e 's/\\$//' $1

# I added:
# 2a. delete control lines starting with a closing bracket

sed -e '/^\\/d' -e '/^{/d' -e '/^}/d' -e '/^$/d' -e 's/\\$//' $1


# I use this to convert the Boyer et al 2016 PNAS files to .txt.

# source: https://mail.google.com/mail/u/0/#inbox/KtbxLxGcDxlLxCgXrpflMHMgBsfpNVRvFL
# author: David F. Davey (thanks!)
