%require "3.0"
%locations
%{
#include <stdio.h>
int yylex(void);
void yyerror(const char *message);
extern int lexical_error;
%}
%token KW_LET KW_INT KW_PRINT KW_IF KW_ELSE KW_WHILE KW_FOR
%token IDENTIFIER INT_LITERAL
%token STRING_BEGIN STRING_TEXT STRING_END
%token ASSIGN EQ NE LT LE GT GE PLUS MINUS STAR SLASH PERCENT
%token SEMICOLON LPAREN RPAREN LBRACE RBRACE LEX_ERROR
%start program
%%
program: statement statements ;
statements: %empty | statements statement ;
statement:
    KW_LET IDENTIFIER ASSIGN expression SEMICOLON
  | assignment SEMICOLON
  | KW_PRINT LPAREN print_item RPAREN SEMICOLON
  | block
  | KW_IF LPAREN condition RPAREN block
  | KW_IF LPAREN condition RPAREN block KW_ELSE block
  | KW_WHILE LPAREN condition RPAREN block
  ;
block: LBRACE statements RBRACE ;
assignment: IDENTIFIER ASSIGN expression ;
print_item: expression | quoted_text ;
quoted_text: STRING_BEGIN text_opt STRING_END ;
text_opt: %empty | STRING_TEXT ;
condition: expression relop expression ;
relop: EQ | NE | LT | LE | GT | GE ;
expression: expression PLUS term | expression MINUS term | term ;
term: term STAR unary | term SLASH unary | term PERCENT unary | unary ;
unary: PLUS unary | MINUS unary | primary ;
primary: INT_LITERAL | IDENTIFIER | LPAREN expression RPAREN ;
%%
void yyerror(const char *message) {
    if (!lexical_error)
        fprintf(stderr, "PARSER_ERROR %d:%d %s\n",
                yylloc.first_line, yylloc.first_column, message);
}
