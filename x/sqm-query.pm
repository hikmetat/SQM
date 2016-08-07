use v6;

grammar sqm-query {
	token TOP { 
		<command>+
	}
	token command				{ \s* 'WHERE' \s+ <query-field-name> '[]'? \s* '=' \s* <query-field-value> \s+ 'EXTRACT' \s+ <extract-field-list> \s* ';' \s* }
	token query-field-name		{ \w+ }
	token query-field-value		{ [ \" [<-[ \" ]>]+ \" ] | \d+ | \d+\.\d+ }
	token extract-field-list	{ <extract-field-name> [ \s* ',' \s* <extract-field-name> ]* }
	token extract-field-name	{ \w+ }
	
}

