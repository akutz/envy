#!/bin/sh

# posix complaint
# verified by https://www.shellcheck.net

# The directory scraped for files that are transformed into environment
# variables.
ENVY_HOME=${ENVY_HOME:-${HOME}/.envy}

# If the the envy home directory does not exist then exit early.
if [ ! -e "${ENVY_HOME}" ]; then
  echo "ENVY_HOME must be set"
  exit 1
fi

# A space-delimited list of prefixes to prepend to copies of generated 
# env vars. For example, if ENVY_PREFIX="PROD_ TEST_" and the env var 
# LDAP_HOST is generated, then the following env var will be exported:
#
#     * LDAP_HOST
#     * PROD_LDAP_HOST
#     * TEST_LDAP_HOST
#ENVY_PREFIX=

# If ENVY_DRYRUN is set to "true" then the export commands will be
# printed to stdout instead of executed.
#ENVY_DRYRUN=

# Transforms a file path into an environment variable.
to_env_var() {
  echo "${1}" | tr '/' '_' | tr '[:lower:]' '[:upper:]'
}

# Gets a file's extension, including the . character. For example:
#   run.sh     -> .sh
#   run.sh.bak -> .bak
#
# Note: This function can be implemented more efficiently on systems
#       with GNU-Sed due to its support for the "q" command setting
#       a custom exit code. For example:
#
#           s#^.\{1,\}\(\..\{1,\}\)$#\1#; /\..\{1,\}/!{q1}
#
#       For the string "run.sh" the above pattern will print ".sh" and 
#       indicate a successful match with a zero exit code:
#
#           $ docker run --rm -it alpine
#           / # apk --no-cache add sed >/dev/null 2>&1
#           / # echo run.sh | \
#               sed 's#^.\{1,\}\(\..\{1,\}\)$#\1#; /\..\{1,\}/!{q1}'
#           .sh
#           / # echo $?
#           0
#
#       For the string "run" the above pattern will print "run" and
#       indcate a failed match with a non-zero exit code:
#
#           $ docker run --rm -it alpine
#           / # apk --no-cache add sed >/dev/null 2>&1
#           / # echo run | \
#               sed 's#^.\{1,\}\(\..\{1,\}\)$#\1#; /\..\{1,\}/!{q1}'
#           run
#           / # echo $?
#           1
#
#       However, because so many devs use macOS, and because ths sed
#       that ships with macOS does not support the above pattern, a
#       hack is used instead -- the output is compared to the input,
#       and if they match, it's assumed the file did not have an
#       extension and no value is returned.
get_file_ext() {
  if ext=$(echo "${1}" | sed 's#^.\{1,\}\(\..\{1,\}\)$#\1#') && \
     [ ! "${ext}" = "${1}" ]; then
    echo "${ext}"
  fi
}

# Gets a file path sans the exension.
#
# For more detail on the background of the pattern used to remove the
# file extension, pelase see "get_file_ext".
rm_file_ext() {
  # If the path does not contain a file-extension then print the path
  # as is.
  if ! echo "${1}" | grep '^.\{1,\}\..\{1,\}$' >/dev/null 2>&1; then
    echo "${1}"
  else
    echo "${1}" | sed 's#^\(.\{1,\}\)\..\{1,\}$#\1#'
  fi
}

# Find all of the files in ENVY_HOME. If the find operation fails then
# abort the script.
temp_file=$(mktemp)
if ! find "${ENVY_HOME}" \
          -type f -or -type l ! -name "$(printf "*\\n*")" \
          1> "${temp_file}"; then
  exit $?
fi

# Parse the discovered files.
while IFS= read -r file_path
do
  # Parse the file's extension.
  file_ext=$(get_file_ext "${file_path}")

  # Get the value for the environment variable(s).
  case $file_ext in
  .base64)
    val=$(base64 "${file_path}")
    ;;
  .gzip64)
    val=$(gzip -c9 "${file_path}" | base64)
    ;;
  *)
    val=$(cat "${file_path}")
    ;;
  esac

  # Remove "${ENVY_HOME}/" from ${file_path}
  file_path_tok=$(echo "${file_path}" | sed 's#^'"${ENVY_HOME}/"'##')

  # Remove the file's extension from the tokenized file path.
  file_path_tok=$(rm_file_ext "${file_path_tok}")
  
  # Define the environment variable's primary key.
  key=$(to_env_var "${file_path_tok}")

  # Export the environment variable's primary key.
  if [ "${ENVY_DRYRUN}" = "true" ]; then
    echo export "${key}=${val}"
  else
    export "${key}=${val}"
  fi

  # If ENVY_PREFIX is defined then use it to export the value
  # using additional keys.
  for prefix in ${ENVY_PREFIX}; do
    if [ "${ENVY_DRYRUN}" = "true" ]; then
      echo export "${prefix}${key}=${val}"
    else
      export "${prefix}${key}=${val}"
    fi
  done

done < "${temp_file}"

# Remove the temp file used for the find output.
rm -f "${temp_file}"