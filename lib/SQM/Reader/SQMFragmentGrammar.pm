use v6;

grammar SQM::Reader::SQMFragmentGrammar {
	token TOP { 
		^ \s*
		[
				<attrib>		|
				<class-begin>	|
				<array-begin>	|
				<array-elem>	|
				<closer>
		] 
	}
	token attrib			{ \s* <attrib-name> \s* '=' \s* <attrib-value> \s* ';' \s* }
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

