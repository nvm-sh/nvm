#!/bin/sh

# Generates release notes for an nvm release, in the format used in the
# annotated release tags and version bump commits.
#
# Usage: ./release-notes.sh <new-version> [<prev-ref>] [<end-ref>]
#   <new-version>  the version being released, e.g. `v0.40.7` (the leading `v` is optional)
#   <prev-ref>     list commits since this ref; defaults to the most recent `vX.Y.Z` tag
#   <end-ref>      list commits up to this ref; defaults to HEAD
#
# Commits from <prev-ref> to <end-ref> are grouped into sections by the leading
# `[bracket]` tag of their subject line, in `git log` order (newest first).
# Category tags ([New], [Fix], ...) are stripped from the bullet text;
# context tags ([readme], [actions], [meta], ...) are kept.
# Commits without a recognized tag land under "Misc", with a warning on stderr.
#
# Each bullet gets a ` (#123)` reference to the pull request that introduced
# the commit, looked up via `gh` from GitHub's commit->PR association, unless
# the subject already ends with one. Set NVM_RELEASE_NOTES_SKIP_PRS to a
# nonempty value to skip the lookup (references will be omitted).

NEW_VERSION="${1-}"
PREV_REF="${2-}"
END_REF="${3:-HEAD}"

if [ -z "${NEW_VERSION}" ]; then
  printf >&2 'Usage: %s <new-version> [<prev-ref>] [<end-ref>]\n' "$0"
  exit 2
fi
case "${NEW_VERSION}" in
  v*) ;;
  *) NEW_VERSION="v${NEW_VERSION}" ;;
esac

if [ -z "${PREV_REF}" ]; then
  PREV_REF="$(git describe --abbrev=0 --tags --match 'v[0-9]*.[0-9]*.[0-9]*')" || {
    printf >&2 'release-notes: failed to determine the previous version tag.\n'
    exit 1
  }
fi
for REF in "${PREV_REF}" "${END_REF}"; do
  git rev-parse --quiet --verify "${REF}^{commit}" >/dev/null || {
    # shellcheck disable=SC2016
    printf >&2 'release-notes: `%s` is not a valid ref.\n' "${REF}"
    exit 1
  }
done

LOOKUP_PRS=1
if [ -n "${NVM_RELEASE_NOTES_SKIP_PRS-}" ]; then
  LOOKUP_PRS=0
elif ! command -v gh >/dev/null 2>&1; then
  # shellcheck disable=SC2016
  printf >&2 'release-notes: `gh` is not available; PR references will be omitted.\n'
  LOOKUP_PRS=0
fi

# the repo to look up commit->PR associations in, e.g. `nvm-sh/nvm`
REPO_SLUG="${GH_REPO-}"
if [ -z "${REPO_SLUG}" ]; then
  ORIGIN_URL="$(git remote get-url origin 2>/dev/null)" || ORIGIN_URL=''
  case "${ORIGIN_URL}" in
    *github.com[:/]*) REPO_SLUG="$(printf '%s' "${ORIGIN_URL}" | sed 's#^.*github\.com[:/]##;s#\.git$##')" ;;
  esac
fi
: "${REPO_SLUG:=nvm-sh/nvm}"

TAB="$(printf '\t')"

COMMITS_FILE="$(mktemp)" || exit 1
GH_ERR_FILE="$(mktemp)" || exit 1
trap 'rm -f "${COMMITS_FILE}" "${GH_ERR_FILE}"' EXIT

# each line: <section key> TAB <sha> TAB <bullet text>, in git log order
git log --no-merges --format='%H %s' "${PREV_REF}..${END_REF}" | while IFS=' ' read -r SHA SUBJECT; do
  LOWERED="$(printf '%s' "${SUBJECT}" | tr '[:upper:]' '[:lower:]')"
  STRIPPED="${SUBJECT#\[*\] }"
  case "${LOWERED}" in
    v[0-9]*.[0-9]*.[0-9]*)
      case "${SUBJECT}" in
        *' '*) # not a bump commit, just a subject that starts with a version
          printf >&2 'release-notes: no category prefix, filing under Misc: %s\n' "${SUBJECT}"
          KEY='misc' TEXT="${SUBJECT}"
        ;;
        *) continue ;; # a version bump commit
      esac
    ;;
    '[new] '*)                          KEY='new'        TEXT="${STRIPPED}" ;;
    '[fix] '* | '[patch] '*)            KEY='fix'        TEXT="${STRIPPED}" ;;
    '[refactor] '*)                     KEY='refactor'   TEXT="${STRIPPED}" ;;
    '[shellcheck] '*)                   KEY='refactor'   TEXT="${SUBJECT}" ;;
    '[robustness] '*)                   KEY='robustness' TEXT="${STRIPPED}" ;;
    '[perf] '* | '[performance] '*)     KEY='perf'       TEXT="${STRIPPED}" ;;
    '[dockerfile] '*)                   KEY='dockerfile' TEXT="${STRIPPED}" ;;
    '[docs] '* | '[doc] '*)             KEY='docs'       TEXT="${STRIPPED}" ;;
    '[readme] '*)                       KEY='docs'       TEXT="${SUBJECT}" ;;
    '[meta] '* | '[security] '* | '[dev deps] '*)
                                        KEY='misc'       TEXT="${SUBJECT}" ;;
    '[tests] '* | '[test] '*)           KEY='tests'      TEXT="${STRIPPED}" ;;
    '[actions] '* | '[debug] '*)        KEY='tests'      TEXT="${SUBJECT}" ;;
    *)
      printf >&2 'release-notes: no category prefix, filing under Misc: %s\n' "${SUBJECT}"
      KEY='misc' TEXT="${SUBJECT}"
    ;;
  esac
  printf '%s\t%s\t%s\n' "${KEY}" "${SHA}" "${TEXT}"
done > "${COMMITS_FILE}"

if ! [ -s "${COMMITS_FILE}" ]; then
  printf >&2 'release-notes: no commits found in %s..HEAD.\n' "${PREV_REF}"
fi

print_section() {
  if ! grep -q "^$1${TAB}" "${COMMITS_FILE}"; then
    return 0
  fi
  printf '\n%s\n\n' "$2"
  grep "^$1${TAB}" "${COMMITS_FILE}" | while IFS="${TAB}" read -r _KEY SHA TEXT; do
    REF=''
    case "${TEXT}" in
      *'(#'[0-9]*')') ;; # the subject already carries a reference
      *)
        if [ "${LOOKUP_PRS}" = 1 ]; then
          PR="$(gh api "repos/${REPO_SLUG}/commits/${SHA}/pulls" --jq '.[0].number // empty' 2>"${GH_ERR_FILE}")" || {
            if grep -q 'No commit found' "${GH_ERR_FILE}"; then
              PR='' # not pushed to GitHub yet, so it can not have come from a PR
            else
              printf >&2 'release-notes: failed to look up the PR for commit %s:\n' "${SHA}"
              cat >&2 "${GH_ERR_FILE}"
              exit 1
            fi
          }
          case "${PR}" in
            '' | *[!0-9]*) ;;
            *) REF=" (#${PR})" ;;
          esac
        fi
      ;;
    esac
    printf ' - %s%s\n' "${TEXT}" "${REF}"
  done || exit 1
}

printf '%s\n' "${NEW_VERSION}"
print_section 'new' 'New Stuff' &&
print_section 'fix' 'Bug Fixes' &&
print_section 'refactor' 'Refactors' &&
print_section 'robustness' 'Robustness' &&
print_section 'perf' 'Performance' &&
print_section 'dockerfile' 'Dockerfile' &&
print_section 'docs' 'Docs' &&
print_section 'misc' 'Misc' &&
print_section 'tests' 'Tests'
