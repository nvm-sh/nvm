#!/bin/sh

NEWEST_NODE_VERSION=$(nvm_remote_version | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
NEWEST_NODE_VERSION_5='5.12.0'

# The only operators prefixing versions that would be acceptable inputs to the semver interpretation logic.
VALID_NORMALIZED_SEMVER_OPERATORS='<
>
<=
>='

# Valid semver operators that would be acceptable to find prefixing a semver in a package.json file, but would need to be validated/normalized before interpretting.
VALID_NON_NORMALIZED_SEMVER_OPERATORS='v
=
~
^'

# Versions (stripped of any operators) that are considered valid inputs to the semver interpretation logic.
VALID_NORMALIZED_VERSIONS='4.1.0
0.12.18
0.11.16
6.11.4
10.0.0'

# Semvers that won't be pulled from package.json files because they contain characters that are not included in valid semvers
INVALID_SEMVERS_FOR_PKG_JSON='&1
#
$
@
!
%
&
)
(
+
@1
#1
$1
%s
1)
1(
1_
1+
1]
1[
1"
1:
1?
1`
1!'

# Semvers that won't resolve to a node version
INVALID_SEMVERS="$INVALID_SEMVERS_FOR_PKG_JSON
~1
^1
-
=
^
1
a
asdf
1111
1  1
1.
1.1
1.*
1.2
11.222
1.2.a
1.*.*
1.x.x
11.22.a
=1.2.3
~1.2.3
^1.2.3
1.1.1 2.2.2
>1.1.1 <1.1.0
1.2 - 1.3
10.221.32 - 10.21.33
10.212 - 10.22
1.2.3 - 1.2.4
1.2.3-1.2.4
1.2 1.3
1 2
1.2.3||1.2.4
1.2||1.3
1||2
>1000
<0"

# Valid semvers that should resolve to a node version and are slightly more complex than the [operator][version] structure
VALID_NORMALIZED_COMPLEX_SEMVERS='10.3.0 || 8.1.1 || 4.1.0
7.7.2 || >=9.0.0 <=8.9.0 || <8.2.1
8.2.0 8.2.0
>4.0.0 <=5.0.0
8.0.0 || <6.12.0'

# Valid semvers that should resolve to a node version but need to be validated/normalized before interpretting.
VALID_NON_NORMALIZED_SEMVERS='x
X
*
x.x
X.X
*.*
x.x.x
X.X.X
x.X.*
*.x.X
x.1.2
>1.1.1  <6.2.2
> 1.1.1 <6.2.2
10 - 11
10-11
4.2.2||8.1.1
4.2 || 1.3
4 || 2'

# Strings that should be extracted from a package.json engines.node value but don't need to resolve to a node version.
VALID_COMPLEX_SEMVERS_FOR_PKG_JSON="$VALID_NORMALIZED_COMPLEX_SEMVERS
<1.2.3>
<1.2>
<1>
>>1
<<1
==1
**
xx
^^1
~~1
10.211.32-10.211.33
10.211-10.222
 1		1
	2	2	"

die () { printf "$@" ; exit 1; }

generate_semvers() {
  versions="${1-}"
  operators="${2-}"
  should_add_spacing_permutations=${3-1}
  if [ -z "$versions" ] || [ -z "$operators" ]; then
    die "Problem generating semvers: Given invalid parameters. versions: '$versions' operators: '$operators'"
  fi
  while [ -n "$versions" ]; do
    version=$(echo "$versions" | head -n1)
    versions=$(echo "$versions" | tail -n +2)

    operators_copy="$operators"
    while [ -n "$operators_copy" ]; do
      operator=$(echo "$operators_copy" | head -n1)
      operators_copy=$(echo "$operators_copy" | tail -n +2)
      if [ -z "$semvers" ]; then
        # NOTE: the third spacing permutation of the operator has a tab between the operator and version.
        if [ $should_add_spacing_permutations -eq 0 ]; then
          semvers=$(printf "%s\n%s\n%s" "${operator}${version}" "${operator} ${version}" "${operator}		${version}")
        else
          semvers="${operator}${version}"
        fi
      else
        # NOTE: the third spacing permutation of the operator has a tab between the operator and version.
        if [ $should_add_spacing_permutations -eq 0 ]; then
          semvers=$(printf "%s\n%s\n%s\n%s" "$semvers" "${operator}${version}" "${operator} ${version}" "${operator}	${version}")
        else
          semvers=$(printf "%s\n%s" "$semvers" "${operator}${version}")
        fi
      fi
    done
  done
  echo "$semvers"
}

VALID_NORMALIZED_SEMVERS=$(printf "%s\n%s\n%s" \
  "$VALID_NORMALIZED_COMPLEX_SEMVERS" \
  "$VALID_NORMALIZED_VERSIONS" \
  "$(generate_semvers "$VALID_NORMALIZED_VERSIONS" "$VALID_NORMALIZED_SEMVER_OPERATORS")" \
)

VALID_SEMVERS=$(printf "%s\n%s\n%s" \
  "$VALID_NORMALIZED_SEMVERS" \
  "$VALID_NON_NORMALIZED_SEMVERS" \
  "$(generate_semvers "$VALID_NORMALIZED_VERSIONS" "$VALID_NON_NORMALIZED_SEMVER_OPERATORS" 0)" \
)

VALID_SEMVERS_FOR_PKG_JSON=$(printf "%s\n%s" \
  "$VALID_SEMVERS" \
  "$VALID_COMPLEX_SEMVERS_FOR_PKG_JSON" \
)
