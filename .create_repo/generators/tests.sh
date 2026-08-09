#!/usr/bin/env bash
# .create_repo/generators/tests.sh
# Scaffolds tests/ with a minimal sample test for the chosen framework.
# These are starting points, not full framework setup (no vendoring of
# the framework itself) - adjust to taste once generated.

generate_tests() {
  echo "==> tests/ ($TEST_FW)"
  mkdirp "tests"

  case "$TEST_FW" in
    Unity)
      cat > "tests/test_main.c" <<'EOF'
#include "unity.h"

void setUp(void) {}
void tearDown(void) {}

void test_example(void) {
    TEST_ASSERT_EQUAL_INT(4, 2 + 2);
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(test_example);
    return UNITY_END();
}
EOF
      echo "  created tests/test_main.c (vendor Unity into tests/vendor/ or fetch via CMake/FetchContent)"
      ;;
    cmocka)
      cat > "tests/test_main.c" <<'EOF'
#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include <cmocka.h>

static void test_example(void **state) {
    (void) state;
    assert_int_equal(2 + 2, 4);
}

int main(void) {
    const struct CMUnitTest tests[] = {
        cmocka_unit_test(test_example),
    };
    return cmocka_run_group_tests(tests, NULL, NULL);
}
EOF
      echo "  created tests/test_main.c (link against -lcmocka)"
      ;;
    criterion)
      cat > "tests/test_main.c" <<'EOF'
#include <criterion/criterion.h>

Test(example, addition) {
    cr_assert_eq(2 + 2, 4);
}
EOF
      echo "  created tests/test_main.c (link against -lcriterion)"
      ;;
    Catch2)
      cat > "tests/test_main.cpp" <<'EOF'
#define CATCH_CONFIG_MAIN
#include <catch2/catch_all.hpp>

TEST_CASE("addition works", "[example]") {
    REQUIRE(2 + 2 == 4);
}
EOF
      echo "  created tests/test_main.cpp (add Catch2 via CMake FetchContent or find_package)"
      ;;
    GoogleTest)
      cat > "tests/test_main.cpp" <<'EOF'
#include <gtest/gtest.h>

TEST(ExampleTest, Addition) {
    EXPECT_EQ(2 + 2, 4);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
EOF
      echo "  created tests/test_main.cpp (add GoogleTest via CMake FetchContent or find_package)"
      ;;
    doctest)
      cat > "tests/test_main.cpp" <<'EOF'
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>

TEST_CASE("addition works") {
    CHECK(2 + 2 == 4);
}
EOF
      echo "  created tests/test_main.cpp (single-header, drop doctest.h into include/)"
      ;;
  esac
}
