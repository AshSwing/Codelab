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

lept_status_code lept_parse_null(lept_context *c, lept_node *v) {
  EXPECT(c, 'n');
  if (c->json[0] != 'u' || c->json[1] != 'l' || c->json[2] != 'l') {
    return LEPT_PARSE_INVALID_VALUE;
  }
  c->json += 3;
  v->type = LEPT_NULL;
  return LEPT_PARSE_OK;
}

lept_status_code lept_parse_bool(lept_context *c, lept_node *v) {

  if (c->json[0] == 't' && c->json[1] == 'r' && c->json[2] == 'u' &&
      c->json[3] == 'e') {
    // true
    c->json += 4;
    v->type = LEPT_BOOL;
    v->boolean = true;
    return LEPT_PARSE_OK;
  } else if (c->json[0] == 'f' && c->json[1] == 'a' && c->json[2] == 'l' &&
             c->json[3] == 's' && c->json[4] == 'e') {
    c->json += 5;
    v->type = LEPT_BOOL;
    v->boolean = false;
    return LEPT_PARSE_OK;
  } else {
    return LEPT_PARSE_INVALID_VALUE;
  }
}

lept_status_code lept_parse_value(lept_context *c, lept_node *v) {
  switch (*c->json) {
  case 'n':
    return lept_parse_null(c, v);
  case 't':
  case 'f':
    return lept_parse_bool(c, v);
  case '\0':
    return LEPT_PARSE_END;
  default:
    return LEPT_PARSE_INVALID_VALUE;
  }
}