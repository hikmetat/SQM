use v6;
use Test;
use lib 'lib';

my &test-files := &files.assuming( *, / 't' /  );
my &pgm-files  := &files.assuming( *, / 'pm' | 'pl'  /  );

my Str $DSEP = $*SPEC.dir-sep;

# get structure data
my Str $test-root = $?FILE.IO.dirname.IO.abspath;
my $app-root = "$test-root$DSEP\.\.";
my $lib-root = "$app-root\\lib";
my %app-root-dir-structure = 
	doc			=> 'Documentation directory', 
	lib			=> 'Library directory', 
	t		 	=> 'Test directory', 
	resources	=> 'Resource directory',
;

# Check application structure
subtest { for %app-root-dir-structure.kv -> $k, $v { ok "$app-root$DSEP$k".IO.e, "$v '$DSEP$k' exists." } }, 'Check application structure';

# check \t against \lib 
my IO::Path @lib-dirlist = subdirs($lib-root.IO);
my IO::Path @tst-dirlist = subdirs($test-root.IO);

# check \t structure against \lib
subtest { str-list-eq-after(@lib-dirlist, @tst-dirlist, $DSEP~'lib'~$DSEP, $DSEP~'t'~$DSEP) }, 'Check \t structure against \lib.';


@lib-dirlist.push: $lib-root.IO;
@tst-dirlist.push: $test-root.IO;

# check test files exist
subtest {
	for zip(@lib-dirlist, @tst-dirlist).flat -> $libdir, $tstdir {
	
		for pgm-files($libdir) -> $libfile {
			my Str $name = ($libfile.basename ~~ / (.*) \. {$libfile.extension} /)[0].Str;
			ok "{$tstdir}{$DSEP}{$name}\.t".IO.e, "{$libfile.basename} has test case {$tstdir}{$DSEP}{$name}\.t"
		} 
	}
}, 'check test files exist';

# check doc files exist
subtest {
	for @lib-dirlist -> $libdir {
	
		for pgm-files($libdir) -> $libfile {
			my Str $name = $app-root~$DSEP~'doc'~$libfile.basename~'.html';
			ok "{$app-root}{$DSEP}doc{$DSEP}{$libfile.basename}\.html".IO.e, "{$libfile.basename} has documentation {$DSEP}doc{$DSEP}{$libfile.basename}\.html"
		} 
	}
}, 'check doc files exist';

# perform unit tests
subtest {
	for @tst-dirlist -> $tstdir {
	
		subtest {
			for test-files($tstdir) -> $tstfile {
				EVAL slurp ~$tstfile
			}
		}, "$tstdir tests" 
	}
}, 'perform unit tests';








sub subdirs(IO::Path $dir) returns Array[IO::Path] {
	my IO::Path @dirs = dir($dir).grep({.d});
	
	for @dirs { @dirs.append( subdirs($_) ) }
	
	return @dirs
}

sub files(IO::Path $dir, Regex $filter) returns Array[IO::Path] {
	my IO::Path @files = dir($dir).grep({ .f and lc(.extension) ~~ $filter })
}

sub str-list-eq-after(@list1, @list2, Str $after1, Str $after2) returns Bool {
	@list1.grep( { ~$_~~ / $after1 / } ).elems == @list1.elems
	and
	@list2.grep( { ~$_~~ / $after2 / } ).elems == @list2.elems
	and
	?all( @list1.map({ ~$_~~ / $after1 (.*) $ /; ~$0 } ) <<eq>> @list2.map( { ~$_~~ / $after2 (.*) $ /; ~$0  } ) )
}


