/**
 * @file leptjson.c
 * @author AshSwing (ashswing@email.cn)
 * @brief
 * @version 0.0.1
 * @date 2023-09-21
 *
 * @copyright Copyright (c) 2023
 *
 */

#include "../include/leptjson.h"
#include <errno.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

void lept_parse_whitespace(lept_context *c) {
  const char *p = c->json;
  while (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r')
    p++;
  c->json = p;
}

lept_status_code lept_parse_null(lept_context *c, lept_node *v) {
  if (lept_literal_compare(c->json, "null")) {
    c->json += 4;
    v->type = LEPT_NULL;
    return LEPT_PARSE_OK;
  }
  return LEPT_PARSE_INVALID_VALUE;
}

lept_status_code lept_parse_boolean(lept_context *c, lept_node *v) {
  if (lept_literal_compare(c->json, "true")) {
    // true
    c->json += 4;
    v->type = LEPT_BOOL;
    v->boolean = true;
    return LEPT_PARSE_OK;
  } else if (lept_literal_compare(c->json, "false")) {
    c->json += 5;
    v->type = LEPT_BOOL;
    v->boolean = false;
    return LEPT_PARSE_OK;
  } else {
    return LEPT_PARSE_INVALID_VALUE;
  }
}

bool lept_get_boolean(lept_node *v) {
  assert(v != NULL);
  assert(v->type == LEPT_BOOL);
  return v->boolean;
}

lept_status_code lept_parse_number(lept_context *c, lept_node *v) {
  const char *p = c->json;
  if (*p == '-')
    p++;
  if (*p == '0')
    p++;
  else { // 整数部份
    if (!ISDIGIT1TO9(*p))
      return LEPT_PARSE_INVALID_VALUE; // 如果 0 开头, 后面跟着数字, 报错
    for (p++; ISDIGIT(*p); p++)
      ; // 跳过所有数字
  }
  if (*p == '.') { // 小数部份
    p++;
    if (!ISDIGIT(*p))
      return LEPT_PARSE_INVALID_VALUE; // 小数点后不是数字
    for (p++; ISDIGIT(*p); p++)
      ; // 跳过小数点后所有数字
  }
  if (*p == 'e' || *p == 'E') { // 指数部份
    p++;
    if (*p == '+' || *p == '-')
      p++;
    if (!ISDIGIT(*p))
      return LEPT_PARSE_INVALID_VALUE;
    for (p++; ISDIGIT(*p); p++)
      ;
  }
  errno = 0;
  v->number = strtod(c->json, NULL);
  if (errno == ERANGE && (v->number == HUGE_VAL || v->number == -HUGE_VAL))
    return LEPT_PARSE_NUMBER_TOO_BIG;
  v->type = LEPT_NUMBER;
  c->json = p;
  return LEPT_PARSE_OK;
}

double lept_get_number(lept_node *v) {
  assert(v != NULL);
  assert(v->type == LEPT_NUMBER);
  return v->number;
}

lept_status_code lept_parse_value(lept_context *c, lept_node *v) {
  switch (*c->json) {
  case 'n':
    return lept_parse_null(c, v);
  case 't':
  case 'f':
    return lept_parse_boolean(c, v);
  case '\0':
    return LEPT_PARSE_END;
  default:
    return lept_parse_number(c, v);
  }
}

static bool lept_literal_compare(const char *str, const char *literal) {
  const char *cursor = str;
  for (size_t i = 0; literal[i]; i++) {
    if (cursor[i] != literal[i]) {
      return false;
    }
  }
  return true;
}

static void lept_free(lept_node *v) {
  assert(v != NULL);
  if (v->type == LEPT_STRING) {
    free(v->string.str);
  }
  v->type = LEPT_NULL;
}

static void lept_set_string(lept_node *v, const char *s, size_t len) {
  assert(v != NULL);
  assert((s != NULL) || len == 0);
  lept_free(v);
  v->string.str = (char *)malloc(len + 1);
  memcpy(v->string.str, s, len);
  v->string.str[len] = '\0';
  v->string.len = len;
  v->type = LEPT_STRING;
}

void lept_set_boolean(lept_node *v, bool b) {
  assert(v != NULL);
  lept_free(v);
  v->type = LEPT_BOOL;
  v->boolean = b;
}