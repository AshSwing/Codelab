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
#include <stdlib.h>

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

/**
 * @brief 判断是否为数字
 *
 */
#define ISDIGIT(ch) ((ch) >= '0' && (ch) <= '9')

/**
 * @brief 判断是否为非零数字
 *
 */
#define ISDIGIT1TO9(ch) ((ch) >= '1' && (ch) <= '9')

/**
 * @brief 节点初始化
 *
 */
#define lept_init(v)                                                           \
  do {                                                                         \
    (v)->type = LEPT_NULL;                                                     \
  } while (0);

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
  LEPT_PARSE_OK = 0,            // OK
  LEPT_PARSE_END,               // END
  LEPT_PARSE_INVALID_VALUE,     // 解析异常
  LEPT_PARSE_ROOT_NOT_SINGULAR, // 异常分隔节点(解析后仍有非空字符)
  LEPT_PARSE_NUMBER_TOO_BIG,    // 数字溢出
} lept_status_code;

/* 2. 数据结构 */
// 节点
typedef struct {
  lept_type type;
  union { // 匿名Union可以直接访问
    struct {
      char *str;
      size_t len;
    } string;      // 字符串
    double number; // 数字
    bool boolean;  // 布尔值
  };
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
lept_status_code lept_parse_boolean(lept_context *c, lept_node *v);

/**
 * @brief 解析数字
 *
 * @param c
 * @param v
 * @return lept_status_code
 */
lept_status_code lept_parse_number(lept_context *c, lept_node *v);

/**
 * @brief 解析函数统一入口
 *
 * @param c
 * @param v
 * @return lept_status_code
 */
lept_status_code lept_parse_value(lept_context *c, lept_node *v);

/**
 * @brief 获取节点布尔值
 *
 * @param v
 * @return true
 * @return false
 */
bool lept_get_boolean(lept_node *v);

void lept_set_boolean(lept_node *v, bool b);

/**
 * @brief 获取节点数字
 *
 * @param v
 * @return double
 */
double lept_get_number(lept_node *v);

void lept_set_number(lept_node *v, double n);

/**
 * @brief 逐字符比较
 *
 * @param json
 * @param literal
 * @return true
 * @return false
 */
static bool lept_literal_compare(const char *str, const char *literal);

/**
 * @brief 内存释放
 *
 * @param v
 */
static void lept_free(lept_node *v);

/**
 * @brief 保存字符串
 *
 * @param v
 * @param s
 * @param len
 */
static void lept_set_string(lept_node *v, const char *s, size_t len);

const char *lept_get_string(lept_node *v);
size_t lept_get_string_length(lept_node *v);

#endif /* LEPTJSON_H */
