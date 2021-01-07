#pragma once

#define T_EOF       0

// 标识类型
#define RESERVED    1
#define INTEGER     2
#define REAL        3
#define STRING      4
#define ID          5
#define OPERATOR    6
#define DELIMITER   7
#define COMMENT     8

// 错误类型
#define INT_OUT_OF_RANGE     -1
#define STR_WITH_TAB         -2
#define STR_OVER_LONG        -3
#define ID_OVER_LONG         -4
#define BAD_CHAR             -5

#define STR_UNTERMINATED     -6
#define COMMENT_UNTERMINATED -7
