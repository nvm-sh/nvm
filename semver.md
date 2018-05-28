# Semantic version interpretation documentation

Node versions are interpretted from the semver expression located in the engines.node value of the local package.json file. The algorithm for interpretting the semver is expressed at a high level below and is intended to work with the [semantic versioner for npm](https://docs.npmjs.com/misc/semver).

## 1. Convert the semver into the following grammar:

> ```
> semver         ::= comparator_set ( ' || '  comparator_set )*
> comparator_set ::= comparator ( ' ' comparator )*
> comparator     ::= ( '<' | '<=' | '>' | '>=' | '' ) [0-9]+ '.' [0-9]+ '.' [0-9]+
> ```

## 2. Resolve each comparator set to its newest compatible node version

**First, if semver only contains a single comparator_set, we may be able to quickly find the newest compatible version.**

```pseudocode
if semver is looking for an exact match of some specified version and the specified version is a valid node version
  resolve to the specified version
else if semver is looking for a version less than or equal to some specified version and the specified version is a valid node version
  resolve to the specified version
else if semver is looking for a version greater than or equal to some specified version and the current newest node version is greater than or equal to the specified version
  resolve to the current newest node version
else if semver is looking for a version strictly greater than to some specified version and the current newest node version is greater than the specified version
  resolve to the current newest node version
else
  quick resolution of semver interpretation not possible
```

**If quick resolution of semver interpretation does not work, try more complex semver interpretation algorithm.**

```pseudocode
initialize highest_compatible_versions to an empty list
initialize node_version_list to the list of current remote node versions
for each current_comparator_set in the semver {
  for each current_node_version in node_version_list {
    for each current_comparator in current_comparator_set {
      if current_node_version is compatible with current_comparator
        continue seeing if current_node_version might be compatible with all comparators in current_comparator_set
      else if current_node_version is not compatible with current_comparator
        if it can be determined that no older version will satisfy this comparator, we can move on to the next comparator_set in the semver
      else
        stop seeing if current_node_version is compatible with all comparators in current_comparator_set and move on to the next version
    }
    if current_node_version was found to be compatible with all comparators in current_comparator_set
      add current_node_version to the highest_compatible_versions list
  }
}

resolve to the highest version among all the versions collected in highest_compatible_versions
```

