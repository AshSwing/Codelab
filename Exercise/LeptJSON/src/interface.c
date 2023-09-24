/**
 * @file interface.c
 * @author AshSwing (ashswing@email.cn)
 * @brief
 * @version 0.0.1
 * @date 2023-09-21
 *
 * @copyright Copyright (c) 2023
 *
 */

#include "../include/leptjson.h"
#include <assert.h>
#include <stdio.h>

lept_status_code lept_parse(lept_node *v, const char *json) {
  lept_context c;
  assert(v != NULL);
  c.json = json;
  v->type = LEPT_NULL;
  lept_parse_whitespace(&c);

  return lept_parse_value(&c, v);
}

lept_type lept_get_type(lept_node *v) {
  assert(v != NULL);
  return v->type;
}

bool lept_get_boolean(lept_node *v) {
  assert(v != NULL);
  assert(v->type == LEPT_BOOL);
  return v->boolean;
}