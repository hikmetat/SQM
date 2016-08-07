use v6;
use Pod::To::HTML;
use MONKEY-SEE-NO-EVAL;

my &pgm-files  := &files.assuming( *, / 'pm' | 'pl'  /  );

my Str $DSEP = $*SPEC.dir-sep;
my Str $doc-root = $?FILE.IO.dirname.IO.abspath;
my $app-root = "$doc-root$DSEP\.\.";
my $lib-root = "$app-root\\lib";
my IO::Path @lib-dirlist = (subdirs($lib-root.IO), $lib-root.IO).flat;

for @lib-dirlist -> $libdir {
	for pgm-files( $libdir ) -> $libfile {
		gen-pod2html( ~$libfile, $doc-root )
	}
}


sub gen-pod2html( Str $source-file, Str $target-dir ) {
	my $bn = $source-file.IO.basename;
say $source-file, "\t", $bn;		
	EVAL slurp( $source-file ) ~ ';' ~ 
		 'my $outfh = open( \'' ~ $target-dir ~ $DSEP ~ $bn.substr(0, $bn.chars - $source-file.IO.extension.chars ) ~ 'html' ~ '\', :w );' ~ 
		 '$outfh.say( Pod::To::HTML.render($=pod) );';
	CATCH { say "$_"}
}



sub subdirs(IO::Path $dir) returns Array[IO::Path] {
	my IO::Path @dirs = dir($dir).grep({.d});
	
	for @dirs { @dirs.append( subdirs($_) ) }
	
	return @dirs
}

sub files(IO::Path $dir, Regex $filter) returns Array[IO::Path] {
	my IO::Path @files = dir($dir).grep({ .f and lc(.extension) ~~ $filter })
}


