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

void lept_parse_whitespace(lept_context *c) {
  const char *p = c->json;
  while (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r')
    p++;
  c->json = p;
}

lept_status_code lept_parse_value(lept_context *c, lept_node *v) {
  switch (*c->json) {
  case '\0':
    return LEPT_PARSE_END;
  default:
    return LEPT_PARSE_INVALID_VALUE;
  }
}