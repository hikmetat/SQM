use v6;


grammar file-path {

	token TOP {
		[ <path> <file-name> | <special-files> ]
	}	
	token path {
		<volume>? <path-sep>? [<path-elem> <path-sep>]* 
	}
	token file-name {
		<path-elem>
	}
	token volume {
		<[A .. Z a .. z]> ':'
	}	
	token path-sep {
		<[\\ \/]> 
	}
	token path-elem {
		<-[ \\ \/ \? \% \* \: \| \" \' \< \> ]>+ 
	}
	token special-files {
		[ '*STDIO' | '*STDERR' | '*MEM' ]
	}
}

sub MAIN {

my %tests =
	'file'							=> True,
	'file.txt'						=> True,
	'directory\file.ext'			=> True,
	'directory\subdir\file.ext'		=> True,
	'\directory\file.ext'			=> True,
	'\directory\subdir\file.ext'	=> True,
	'c:file.ext'					=> True,
	'C:\file.ext'					=> True,
	'*STDIO'						=> True,
	''								=> False,
	'direct%ory\subdir\file.ext'	=> False,
	'direct ory\subdir\fi le.ext'	=> True,
	'd:\\\ory\subdir\fi le.ext'		=> False,

;
my $match;
say sprintf("%-50s%-8s%-8s%-8s", 'TEST STRING', 'MATCH', 'EXPECT', 'STATUS');
for %tests.kv -> $test, $expectation {
	$match = file-path.parse($test);
	say sprintf("%-50s%-8s%-8s%-8s", "$test", ~?$match, ~$expectation, ~(?$match == $expectation ?? 'OK' !! 'FAILED'))	
}


}