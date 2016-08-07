use v6;

grammar output-template {
	token TOP { 
		<params-label> <params-statements> <begin-label> <begin-statements> <body-label> <body-statements> <end-label> <end-statements> 
	}
	
	token params-label			{ \s* 'PARAMS' \s* ':' \s* }
	token begin-label			{ \s* 'BEGIN'  \s* ':' \s* }
	token body-label			{ \s* 'BODY'   \s* ':' \s* }
	token end-label				{ \s* 'END'   \s* ':' \s*  }
	
	token params-statements		{ <params-list> <before \s* 'BEGIN'> }
	token begin-statements		{ <statement-list> <before \s* 'BODY'> }
	token body-statements		{ <statement-list> <before \s* 'END'>  }
	token end-statements		{ <statement-list> }
	token params-list			{ [ <param> ';' ]* }	
	token statement-list		{ [ <statement> ';' ]* }
	
	token statement				{ [<-[ \: \; ]>]+ }
	token param					{ \s* <param-name> \s* '=' \s* <param-value> \s* }
	token param-name			{ [<-[ \: \; \= \s ]>]+ }
	token param-value			{ [<-[ \: \; \= \s ]>]+ }
	
}

