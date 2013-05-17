#!/bin/sh

# I know this test doesn't work, but if I could work out how to run it, I'd make it pass!

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testRelease()
{
  expected_release_output=`cat <<EOF
---
config_vars:
  JAVA_OPTS: -Xmx384m -Xss512k -XX:+UseCompressedOops


EOF`
  
  release

  assertCapturedEquals "${expected_release_output}"
}
