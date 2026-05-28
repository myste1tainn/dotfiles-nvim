" Vim syntax file for PlantUML
" Based on the TextMate grammar from qjebbs/vscode-plantuml

if exists("b:current_syntax")
  finish
endif

syn case ignore

" Comments
syn match plantumlComment "^\s*'.*$"
syn region plantumlComment start="\s*\z('/\)" end="/'" contains=plantumlTodo
syn keyword plantumlTodo TODO FIXME XXX NOTE contained

" Strings
syn region plantumlString start=/"/ end=/"/ skip=/\\"/

" Start/End markers
syn match plantumlDelimiter "^\s*@startuml\>"
syn match plantumlDelimiter "^\s*@enduml\>"
syn match plantumlDelimiter "^\s*@startmindmap\>"
syn match plantumlDelimiter "^\s*@endmindmap\>"
syn match plantumlDelimiter "^\s*@startwbs\>"
syn match plantumlDelimiter "^\s*@endwbs\>"
syn match plantumlDelimiter "^\s*@startgantt\>"
syn match plantumlDelimiter "^\s*@endgantt\>"
syn match plantumlDelimiter "^\s*@startjson\>"
syn match plantumlDelimiter "^\s*@endjson\>"
syn match plantumlDelimiter "^\s*@startyaml\>"
syn match plantumlDelimiter "^\s*@endyaml\>"
syn match plantumlDelimiter "^\s*@startsalt\>"
syn match plantumlDelimiter "^\s*@endsalt\>"

" Diagram type keywords (line-beginning)
syn match plantumlKeyword "^\s*\(switch\|case\|usecase\|actor\|object\|participant\|boundary\|control\|entity\|database\|collections\|queue\|component\|interface\|package\|namespace\|node\|folder\|frame\|cloud\|rectangle\|storage\|agent\|artifact\|card\|file\|stack\|label\|map\|archimate\|diamond\|detach\|hexagon\|person\|circle\)\>"

" Control flow keywords
syn match plantumlKeyword "^\s*\(endswitch\|endif\|repeat\|start\|stop\|end\|fork\|again\|kill\|destroy\)\>"
syn match plantumlKeyword "^\s*\(end\s\+fork\|end\s\+split\|end\s\+merge\)\>"

" Conditional / loop
syn match plantumlConditional "^\s*\(if\|else\s*if\|elseif\|else\|then\|endif\)\>"
syn match plantumlConditional "^\s*\(while\|endwhile\|repeat\s\+while\)\>"
syn match plantumlConditional "\<\(is\|not\)\>"

" Other keywords
syn keyword plantumlKeyword as static abstract
syn match plantumlKeyword "^\s*\(title\|header\|footer\|legend\|caption\|newpage\|note\|end\s*note\|rnote\|hnote\)\>"
syn match plantumlKeyword "^\s*\(left\|right\|center\|over\|of\|on\|link\|end\s*header\|end\s*footer\|end\s*legend\)\>"
syn match plantumlKeyword "^\s*\(top\s\+to\s\+bottom\s\+direction\|left\s\+to\s\+right\s\+direction\)\>"
syn match plantumlKeyword "\<\(top\|bottom\|left\|right\|up\|down\)\>"

" Class / enum / abstract
syn match plantumlType "^\s*\(enum\|abstract\s\+class\|abstract\|class\|annotation\|circle_short_form\|diamond_short_form\)\>"

" Visibility modifiers
syn match plantumlSpecial "[+\-#~]" contained

" Arrows
syn match plantumlArrow "\(\.\|[-=]\)\+\(>\||\|\\|\|/\)\+"
syn match plantumlArrow "\(<\||\|\\|\|/\)\+\(\.\|[-=]\)\+"
syn match plantumlArrow "\(\.\|[-=]\)\{2,\}"
syn match plantumlArrow "[<>o*x}{]\+\(\.\|[-=]\)\+[<>o*x}{]*"
syn match plantumlArrow "[<>o*x}{]*\(\.\|[-=]\)\+[<>o*x}{]\+"

" Colors
syn match plantumlConstant "#[0-9a-fA-F]\{6\}\>"
syn match plantumlConstant "#\(Red\|Blue\|Green\|Yellow\|Orange\|Purple\|Pink\|White\|Black\|Gray\|Grey\|Cyan\|Magenta\|Brown\|Olive\|Navy\|Teal\|Maroon\|Silver\|Lime\|Aqua\|Fuchsia\|DarkRed\|DarkBlue\|DarkGreen\|LightBlue\|LightGreen\|LightGray\|LightGrey\)\>"

" Skinparam
syn match plantumlPreProc "^\s*skinparam\>"
syn match plantumlPreProc "^\s*\(hide\|show\|remove\)\>"
syn match plantumlPreProc "^\s*scale\>"

" Preprocessor directives
syn match plantumlPreProc "^\s*!\(include\|define\|undef\|ifdef\|ifndef\|else\|endif\|if\|elseif\|procedure\|endprocedure\|function\|endfunction\|return\|startsub\|endsub\|assert\|log\|local\|unquoted\|theme\|pragma\)\>"
syn match plantumlPreProc "^\s*!includeurl\>"
syn match plantumlPreProc "^\s*!includesub\>"
syn match plantumlPreProc "^\s*!include_many\>"
syn match plantumlPreProc "^\s*!include_once\>"

" Preprocessor variables
syn match plantumlIdentifier "$[a-zA-Z_][a-zA-Z0-9_]*"
syn match plantumlIdentifier "%[a-zA-Z_][a-zA-Z0-9_]*\>"

" Stereotypes
syn region plantumlSpecial start="<<" end=">>"

" Grouping
syn match plantumlStructure "^\s*\(group\|box\|alt\|opt\|loop\|par\|break\|critical\|ref\)\>"
syn match plantumlStructure "^\s*\(end\s*group\|end\s*box\|end\s*alt\|end\s*opt\|end\s*loop\|end\s*par\|end\s*break\|end\s*critical\|end\s*ref\)\>"
syn match plantumlStructure "^\s*\(activate\|deactivate\|autoactivate\|autonumber\|return\)\>"
syn match plantumlStructure "^\s*\(partition\|end\s*partition\)\>"
syn match plantumlStructure "^\s*\(split\|end\s*split\)\>"

" Creole markup
syn match plantumlSpecial "\*\*[^*]\+\*\*"
syn match plantumlSpecial "//[^/]\+//"
syn match plantumlSpecial "__[^_]\+__"
syn match plantumlSpecial "\~\~[^~]\+\~\~"

" Sequence diagram separators
syn match plantumlDelimiter "^\s*=\{2,\}.\+=\{2,\}\s*$"
syn match plantumlDelimiter "^\s*-\{2,\}\s*$"
syn match plantumlDelimiter "^\s*\.\{3,\}\s*$"

" Note markers
syn match plantumlKeyword "\<\(note\)\s\+\(left\|right\|over\|top\|bottom\)\>"
syn match plantumlKeyword "\<ref\s\+over\>"
syn match plantumlKeyword "\<end\s*note\>"

" Numbers
syn match plantumlNumber "\<\d\+\(\.\d\+\)\?\>"

" Colon labels
syn region plantumlLabel start=":" end="[;|<>/\]}]" end="$" contains=plantumlString,plantumlSpecial oneline

" Highlighting links
hi def link plantumlComment Comment
hi def link plantumlTodo Todo
hi def link plantumlString String
hi def link plantumlDelimiter PreProc
hi def link plantumlKeyword Keyword
hi def link plantumlConditional Conditional
hi def link plantumlType Type
hi def link plantumlArrow Operator
hi def link plantumlConstant Constant
hi def link plantumlPreProc PreProc
hi def link plantumlIdentifier Identifier
hi def link plantumlSpecial Special
hi def link plantumlStructure Structure
hi def link plantumlNumber Number
hi def link plantumlLabel String

let b:current_syntax = "plantuml"
