use v6;

grammar SQM::Writer::SQMQRYLang {
	token TOP { 
		^ \s*
		<destinations>
		\s+
		<case>+
		\s* $
	}
	
	token begin-register-dests	{ 'BEGIN' \s+ 'REGISTER' \s+ 'DESTINATIONS' }
	token end-register-dests	{ 'END'   \s+ 'REGISTER' \s+ 'DESTINATIONS' }
	
	token destination { 
		<begin-register-dests> \s+
		[ <output-dest> \s+ ]+ 
		<end-register-dests>
	}
	token output-dest { 
		<output-ref> \s* = \s* <output-path>
	}
	token output-ref {
		\w+
	}
	token output-path {
		[ <volume>? <path-sep>? [<path-elem> <path-sep>]* <path-elem> ] | '*STDIO' | '*STDERR' | '*MEM' ]
	}	
	token volume {
		<[A .. Z a .. z]> ':'
	}	
	token path-sep {
		<[\\ \/]> 
	}
	token path-elem {
		<-[\\ \/ \? \% \* \: \| \" \' \< \> ]>+ 
	}	
	
	
		 '=' \s* <attrib-value> \s* ';' \s* }
	token class-begin		{ \s* 'class' \s+ <class-name> \s* '{' \s* }
	token array-begin		{ \s* <array-name>'[]' \s* '=' \s* '{' \s* }
	token array-elem		{ \s* <array-elem-value>  [ \s* | \s* ',' ] \s* }	
	token closer			{ \s* '}' \s* ';' }
	
	token attrib-name		{ \w+ }
	token attrib-value		{ [ <quoted-string> | <empty-string> | '-'? \d+ [ \.\d+ ]? ] }
	token array-name		{ \w+ }
	token class-name		{ \w+ }
	token array-elem-value 	{ [ <quoted-string> | <empty-string> | '-'? \d+ [ \.\d+ ]? ] }	
	
	token quoted-string	{ '"' [ <-[\"]> | '""'  ]+ '"' }
	token empty-string	{ '""' }

}