# Exercise

## SICP

> ![INFO] Structure and Interpretation of Computer Programs
> 
> EBooks: https://web.mit.edu/6.001/6.037/sicp.pdf
>
> Solutions: http://community.schemewiki.org/?SICP-Solutions

### 开发环境准备

SICP 需要用到 Scheme 语言, 这里可以使用 Racket 代替:

```bash
brew install minimal-racket # 安装 Racket
raco pkg install racket-langserver # 安装 Racket LSP
raco pkg install sicp # 安装 SICP
racket -l sicp -i # 加载 SICP 并启动交互式命令行
racket -l sicp example.rkt # 加载 SICP 并编译运行 .rkt 脚本
```

如何验证成功加载 SICP 语法包:

- `(inc n)` 预定义的递增过程
- `(dec n)` 预定义的递减过程
- `(random n)` 预定义的随机数生成器 

可以使用 VSCode 中的插件: [Magic Racket](https://marketplace.visualstudio.com/items?itemName=evzen-wybitul.magic-racket)

SICP REPL 基础用法:

```scheme
,exit
```

代码基础结构:

```scheme
#lang sicp
(#%require sicp-pict)           ; 加载 SICP Picture Language
(#%require "other.rkt")         ; 加载外部脚本
(#%provide export)              ; 导出内部对象
(define _inner 1)               ; 定义内部对象 
```

- 加载外部脚本只能获得导出对象
- 加下划线可以告诉语法检查器忽略未使用异常
