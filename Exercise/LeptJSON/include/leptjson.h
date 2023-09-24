/**
 * @file leptjson.h
 * @author AshSwing (ashswing@email.cn)
 * @brief
 * @version 0.0.1
 * @date 2023-09-21
 *
 * @copyright Copyright (c) 2023
 *
 */

#ifndef LEPTJSON_H
#define LEPTJSON_H

#include <assert.h>
#include <stdbool.h>

/* 0. 宏定义 */

/**
 * @brief 判断首字符是否为 ch 的宏
 *
 */
#define EXPECT(c, ch)                                                          \
  do {                                                                         \
    assert(*c->json == (ch));                                                  \
    c->json++;                                                                 \
  } while (0)

/* 1. 码值表 */

// 节点类型
typedef enum {
  LEPT_NULL,
  LEPT_BOOL,
  LEPT_NUMBER,
  LEPT_STRING,
  LEPT_ARRAY,
  LEPT_OBJECT,
} lept_type;

// 状态码
typedef enum {
  LEPT_PARSE_OK = 0,        // OK
  LEPT_PARSE_END,           // END
  LEPT_PARSE_INVALID_VALUE, // 解析异常
} lept_status_code;

/* 2. 数据结构 */
// 节点
typedef struct {
  bool boolean;
  lept_type type;
} lept_node;

// 上下文
typedef struct {
  const char *json;
} lept_context;

/* 3. 接口 */

/**
 * @brief 字符串解析接口
 *
 * @param v 解析后的数据结构
 * @param json 原始字符串
 * @return lept_status_code
 */
lept_status_code lept_parse(lept_node *v, const char *json);

/**
 * @brief 获取节点类型
 *
 * @param v 节点
 * @return lept_type
 */
lept_type lept_get_type(lept_node *v);

/**
 * @brief 获取节点布尔值
 *
 * @param v
 * @return true
 * @return false
 */
bool lept_get_boolean(lept_node *v);

/* 3. 内部方法 */

/**
 * @brief 跳过空白字符
 *
 * @param c
 */
void lept_parse_whitespace(lept_context *c);

/**
 * @brief 解析空值
 *
 * @param c
 * @param v
 */
lept_status_code lept_parse_null(lept_context *c, lept_node *v);

/**
 * @brief 解析布尔值
 *
 * @param c
 * @param v
 */
lept_status_code lept_parse_bool(lept_context *c, lept_node *v);

/**
 * @brief 解析函数统一入口
 *
 * @param c
 * @param v
 * @return lept_status_code
 */
lept_status_code lept_parse_value(lept_context *c, lept_node *v);

#endif /* LEPTJSON_H */
