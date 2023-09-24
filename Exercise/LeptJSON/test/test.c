/**
 * @file test.c
 * @author AshSwing (ashswing@email.cn)
 * @brief
 * @version 0.0.1
 * @date 2023-09-21
 *
 * @copyright Copyright (c) 2023
 *
 */

#include "../include/leptjson.h"
#include <stdio.h>

static int main_ret = 0;
static int test_count = 0;
static int test_pass = 0;

#define EXPECT_EQ_BASE(equality, expect, actual, format)                       \
  do {                                                                         \
    test_count++;                                                              \
    if (equality)                                                              \
      test_pass++;                                                             \
    else {                                                                     \
      fprintf(stderr, "%s:%d: expect: " format " actual: " format "\n",        \
              __FILE__, __LINE__, expect, actual);                             \
      main_ret = 1;                                                            \
    }                                                                          \
  } while (0)

#define EXPECT_EQ_INT(expect, actual)                                          \
  EXPECT_EQ_BASE((expect) == (actual), expect, actual, "%d")

#define EXPECT_EQ_DOUBLE(expect, actual)                                       \
  EXPECT_EQ_BASE((expect) == (actual), expect, actual, "%g")

#define TEST_ERROR(error, json)                                                \
  do {                                                                         \
    lept_node v;                                                               \
    EXPECT_EQ_INT(error, lept_parse(&v, json));                                \
    EXPECT_EQ_INT(LEPT_NULL, lept_get_type(&v));                               \
  } while (0)

#define TEST_NUMBER(expect, json)                                              \
  do {                                                                         \
    lept_node v;                                                               \
    EXPECT_EQ_INT(LEPT_PARSE_OK, lept_parse(&v, json));                        \
    EXPECT_EQ_INT(LEPT_NUMBER, lept_get_type(&v));                             \
    EXPECT_EQ_DOUBLE(expect, lept_get_number(&v));                             \
  } while (0)

static void test_parse_end() {
  lept_node v;
  EXPECT_EQ_INT(LEPT_PARSE_END, lept_parse(&v, ""));
  EXPECT_EQ_INT(LEPT_NULL, lept_get_type(&v));

  EXPECT_EQ_INT(LEPT_PARSE_END, lept_parse(&v, " "));
  EXPECT_EQ_INT(LEPT_NULL, lept_get_type(&v));
}

static void test_parse_invalid_value() {
  TEST_ERROR(LEPT_PARSE_INVALID_VALUE, "nul");
  TEST_ERROR(LEPT_PARSE_INVALID_VALUE, "?");
}

static void test_parse_null() {
  lept_node v;
  EXPECT_EQ_INT(LEPT_PARSE_OK, lept_parse(&v, "null"));
  EXPECT_EQ_INT(LEPT_NULL, lept_get_type(&v));
}

static void test_parse_bool() {
  lept_node v;
  EXPECT_EQ_INT(LEPT_PARSE_OK, lept_parse(&v, "true"));
  EXPECT_EQ_INT(true, lept_get_boolean(&v));
  EXPECT_EQ_INT(LEPT_PARSE_OK, lept_parse(&v, "false"));
  EXPECT_EQ_INT(false, lept_get_boolean(&v));
}

static void test_parse_not_singular() {
  lept_node v;
  EXPECT_EQ_INT(LEPT_PARSE_ROOT_NOT_SINGULAR, lept_parse(&v, "true null"));
}

static void test_parse_number() {
  TEST_NUMBER(0.0, "0");
  TEST_NUMBER(0.0, "-0");
  TEST_NUMBER(1E10, "1E10");
  TEST_NUMBER(1.234E-10, "1.234E-10");

  TEST_ERROR(LEPT_PARSE_INVALID_VALUE, "+0");
  TEST_ERROR(LEPT_PARSE_INVALID_VALUE, "INF");

  TEST_ERROR(LEPT_PARSE_NUMBER_TOO_BIG, "1e309");
  TEST_ERROR(LEPT_PARSE_NUMBER_TOO_BIG, "-1e22222");
}

static void test_parse() {
  test_parse_null();
  test_parse_bool();
  test_parse_end();
  test_parse_invalid_value();
  test_parse_not_singular();
  test_parse_number();
}

int main(int argc, char **argv) {
  printf("Test Running\n");
  printf("Exe Path: %s\n", argv[0]);
  printf("Total Params: %i\n", argc);
  test_parse();
  printf("%d/%d (%3.2f%%) passed\n", test_pass, test_count,
         test_pass * 100.0 / test_count);
  return main_ret;
  return 0;
}