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
  assert(v != NULL);
  lept_context c;
  c.json = json;
  v->type = LEPT_NULL;
  lept_parse_whitespace(&c); // 跳过开头的空白字符

  lept_status_code ret;
  if ((ret = lept_parse_value(&c, v)) == LEPT_PARSE_OK) {
    lept_parse_whitespace(&c);
    if (*c.json != '\0')
      ret = LEPT_PARSE_ROOT_NOT_SINGULAR;
  }
  return ret;
}

lept_type lept_get_type(lept_node *v) {
  assert(v != NULL);
  return v->type;
}
