use v6;

grammar sqm-reader {
	token TOP { 
		\s*
		[
				<attrib>		|
				<class-begin>	|
				<array-begin>	|
				<array-elem>	|
				<closer>
		] 
		<trailer>
	}
	token attrib			{ <attrib-name> \s* '=' \s* <attrib-value> ';' \s* }
	token class-begin		{ 'class' \s+ <class-name> \s* '{' }
	token array-begin		{ <array-name>'[]' \s* '=' \s* '{' }
	token array-elem		{ <array-elem-name> [\s* | \s* ',' \s*] }	
	token closer			{ '}' \s* ';' }
	token trailer			{ .* }
	
	token attrib-name		{ \w+ }
	token attrib-value		{ ['"' <-[\"]>+ '"'] | \d+ | [\d+\.\d+] }
	token array-name		{ \w+ }
	token class-name		{ \w+ }
	token array-elem-name 	{ ['"' <-[\"]>+ '"'] | \d+ | [\d+\.\d+] }
}

