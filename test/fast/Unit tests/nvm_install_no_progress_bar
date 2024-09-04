#!/bin/sh

set -e

cleanup () {
  nvm cache clear
  nvm deactivate
  rm -rf ${NVM_DIR}/v*
  nvm unalias default || true
}

die () { >&2 echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

cleanup

OUTPUT="$(TERM=dumb 2>&1 nvm install --no-progress v0.12.18)"
EXPECTED_OUTPUT="Downloading and installing node v0.12.18...
Downloading https://nodejs.org/dist/v0.12.18/node-v0.12.18-linux-x64.tar.xz...
Computing checksum with sha256sum
Checksums matched!
Now using node v0.12.18 (npm v2.15.11)
Creating default alias: default -> v0.12.18 *"

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "1: expected >
${EXPECTED_OUTPUT}<, got >
${OUTPUT}<"

cleanup

OUTPUT="$(TERM=dumb 2>&1 nvm install v0.12.18)"
EXPECTED_OUTPUT="Downloading and installing node v0.12.18...
Downloading https://nodejs.org/dist/v0.12.18/node-v0.12.18-linux-x64.tar.xz...
######################################################################### 100.0%
Computing checksum with sha256sum
Checksums matched!
Now using node v0.12.18 (npm v2.15.11)
Creating default alias: default -> v0.12.18 *"

[ "$(echo "${OUTPUT}" | wc -l)" = "$(echo "${EXPECTED_OUTPUT}" | wc -l)" ] || die "2: expected 7 lines, got $(echo "${OUTPUT}" | wc -l)"

# Preprocess function to handle carriage returns and extract final output
preprocess_output() {
    echo "$1" | awk '
    {
        # For each line in the input
        while (index($0, "\r") > 0) {
            # If a carriage return is found, process it
            pos = index($0, "\r")
            before_cr = substr($0, 1, pos - 1)
            after_cr = substr($0, pos + 1)
            # Overwrite the line up to the carriage return with content after it
            $0 = after_cr
        }
        print $0
    }' | sed '/^$/d'  # Remove any empty lines
}

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || {
  echo "$OUTPUT" \
  | while IFS= read -r output_line && IFS= read -r expected_line <&3; do
    line_number=$((line_number + 1))

    # Strip non-visible characters from both lines
    clean_output=$(preprocess_output "$output_line")

    if [ "${output_line}" != "${expected_line}" ] && ! echo "${clean_output}" | \grep -qE '^#+ 100\.0%$'; then
        echo "Difference on line ${line_number}:"
        echo "Output:    ${output_line}"
        echo "Expected:  ${expected_line}"
        echo "Byte-by-byte comparison:"
        echo "Output:    $(echo "${clean_output}" | od -An -tx1 | tr -d '\n')"
        echo "Expected:  $(echo "${expected_line}" | od -An -tx1 | tr -d '\n')"

        die "4: expected >
${EXPECTED_OUTPUT}<, got >
${OUTPUT}<"
    fi
done 3<<EOF
$EXPECTED_OUTPUT
EOF
}

cleanup
