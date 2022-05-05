#!/bin/bash
git fetch --tags

if [ <<parameters.increment_tag>> = true ]; then # If the increment_tag parameter is enabled...
  echo " [Increment tag selected] "
  GITLATESTTAG=$(git tag --list "<<parameters.tag_pattern>>" | sort -V | tail -1)
  printf " Latest matching tag: $(git tag --list "<<parameters.tag_pattern>>" | sort -V | tail -1)"
  if [[ $GITLATESTTAG =~ ^(.*)(([0-9]+)\.([0-9]+)\.([0-9]+))(-.*)? ]]; then # If the tag has a valid SEMVER then proceed with upgrade
    echo "    Prefix: ${BASH_REMATCH[1]}"
    SEMPREFIX=${BASH_REMATCH[1]}
    echo "    Major: ${BASH_REMATCH[3]}"
    SEMVERMAJOR=${BASH_REMATCH[3]}
    echo "    Minor: ${BASH_REMATCH[4]}"
    SEMVERMINOR=${BASH_REMATCH[4]}
    echo "    Patch: ${BASH_REMATCH[5]}"
    SEMVERPATCH=${BASH_REMATCH[5]}
    echo "    Suffix: ${BASH_REMATCH[6]} "
    SEMVERSUFFIX=${BASH_REMATCH[6]}
    if [ <<parameters.increment_patch>> = true ]; then
      SEMVERPATCH=$(expr ${SEMVERPATCH} + 1)
      echo "Incrementing patch ${SEMVERPATCH}"
    fi
    if [ <<parameters.increment_minor>> = true ]; then
      SEMVERMINOR=$(expr ${SEMVERMINOR} + 1)
      echo "Incrementing minor ${SEMVERMINOR}"
    fi
    if [ <<parameters.increment_major>> = true ]; then
      SEMVERMAJOR=$(expr ${SEMVERMAJOR} + 1)
      echo "Incrementing major ${SEMVERMAJOR}"
    fi
    # Once the tag has been destructured and manipulated, put back together here
    GITNEWTAG="${SEMPREFIX}${SEMVERMAJOR}.${SEMVERMINOR}.${SEMVERPATCH}${SEMVERSUFFIX}"

  else # If no SEMVER found, but increment is enabled, fail.
    echo "Custom tag selected. Unable to find semver"
    exit 1
  fi
else # If increment tag is not selected, a custom tag must be used.
  printf "Creating custom new tag"
  GITNEWTAG=<<parameters.custom_tag>>
  printf "Custom tag: ${GITNEWTAG}"
fi

# Complete tag creation. Newly created tag will now exist in $GITNEWTAG

printf " Newly created tag: ${GITNEWTAG} "

printf "Pushing '${GITNEWTAG}' to origin for commit ${CIRCLE_SHA1} "

git tag ${GITNEWTAG} ${CIRCLE_SHA1}

git push origin ${GITNEWTAG}
