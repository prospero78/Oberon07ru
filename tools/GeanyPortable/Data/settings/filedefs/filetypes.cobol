# For complete documentation of this file, please see Geany's main documentation

[styling]
# foreground;background;bold;italic
default=0x000000;0xffffff;false;false
identifier=0x000000;0xffffff;false;false
comment=0xd00000;0xffffff;false;false
comment2=0x3f5fbf;0xffffff;false;false
commentline=0xd00000;0xffffff;false;false
preprocessor=0x007f7f;0xffffff;false;false
preprocessor2=0x007f7f;0xffffff;false;false
number=0x007F00;0xffffff;false;false
hexnumber=0x007F00;0xffffff;false;false
word=0x111199;0xffffff;true;false
string=0xff901e;0xffffff;false;false
stringeol=0x000000;0xe0c0e0;false;false
character=0x404000;0xffffff;false;false
operator=0x301010;0xffffff;false;false
asm=0x804080;0xffffff;false;false

[keywords]
# all items must be in one line
primary=лндскэ 
# additional keywords, will be highlighted with style "word2"
# these are the builtins for Python 2.5 created with ' '.join(dir(__builtins__))
identifiers=ArithmeticError AssertionError AttributeError BaseException DeprecationWarning EOFError Ellipsis EnvironmentError Exception False FloatingPointError FutureWarning GeneratorExit IOError ImportError ImportWarning IndentationError IndexError KeyError KeyboardInterrupt LookupError MemoryError NameError None NotImplemented NotImplementedError OSError OverflowError PendingDeprecationWarning ReferenceError RuntimeError RuntimeWarning StandardError StopIteration SyntaxError SyntaxWarning SystemError SystemExit TabError True TypeError UnboundLocalError UnicodeDecodeError UnicodeEncodeError UnicodeError UnicodeTranslateError UnicodeWarning UserWarning ValueError Warning ZeroDivisionError _ __debug__ __doc__ __import__ __name__ abs all any apply basestring bool buffer callable chr classmethod cmp coerce compile complex copyright credits delattr dict dir divmod enumerate eval execfile exit file filter float frozenset getattr globals hasattr hash help hex id input int intern isinstance issubclass iter len license list locals long map max min object oct open ord pow property quit range raw_input reduce reload repr reversed round set setattr slice sorted staticmethod str sum super tuple type unichr unicode vars xrange zip

[lexer_properties]
fold.comment.cobol=1
fold.quotes.cobol=1
# only highlight keywords like read,write if in appropriate context
lexer.cobol.smart.highlighting=1

[settings]
# default extension used when saving files
#extension=py

# the following characters are these which a "word" can contains, see documentation
#wordchars=_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

# if only single comment char is supported like # in this file, leave comment_close blank
comment_open= (* 
comment_close= *) 

# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
	#command_example();
# setting to false would generate this
#	command_example();
# This setting works only for single line comments
comment_use_indent=true

# context action command (please see Geany's main documentation for details)
context_action_cmd=

[build_settings]
# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)
compiler=python -c "import py_compile; py_compile.compile('%f')"
run_cmd=python "%f"

[build-menu]
EX_00_LB=_Execute
EX_00_CM=d:\\Code\\WinPython-32bit-2.7.10.3\\python-2.7.10\\python "%f"
EX_00_WD=
