use v6;
use Test;
use lib '..\lib';
use File::Temp;
use Utilities::StreamBuffer;

#create temporary data file
my (Str $tmpfn, IO::Handle $tmpfh) = tempfile( :tempdir($?FILE.IO.dirname) );

my Str @data-arr =
'data file line 01',
"data file line 02\ndata file line 03",
'data file line 04',
'data file line 05',
'data file line 06',
'data file line 07',
'data file line 08';

my Int $entry-len = @data-arr[0].chars;

my Str $data-str = @data-arr.join("\n");

$tmpfh.say($data-str);
$tmpfh.close;



# create StreamBuffer variable
my Utilities::StreamBuffer $buffer;

# Creation of StreamBuffer from alternate sources
subtest {
	$tmpfh = open $tmpfn, :r;
	$buffer = Utilities::StreamBuffer.new( :input($tmpfh) );
	ok (($buffer.get eq'data file line 01') and ($buffer.input-type eq 'IO::Handle')), 'File handle creation';
	$buffer = Nil;
	$tmpfh.close;
	
	$buffer = Utilities::StreamBuffer.new( :input($tmpfn) );
	ok (($buffer.get eq 'data file line 01') and ($buffer.input-type eq 'Path')), 'File path creation';
	$buffer = Nil;
	
	$buffer = Utilities::StreamBuffer.new( :input($data-str) ); 
	ok (($buffer.get eq 'data file line 01') and ($buffer.input-type eq 'Text')), 'String creation';   
	$buffer = Nil;
	
	$buffer = Utilities::StreamBuffer.new( :input(@data-arr) );
	ok (($buffer.get eq 'data file line 01') and ($buffer.input-type eq 'Array')), 'Array creation';
	$buffer = Nil;	
	
	$buffer = Utilities::StreamBuffer.new( );
	ok ($buffer.input-type eq 'Null'), 'Null creation';
	$buffer = Nil;	
	
	dies-ok { $buffer = Utilities::StreamBuffer.new( :input(124.09) ) }, 'Creation failure on non Str/Arr/fh/path';
		
}, 'Creation of StreamBuffer from alternate sources';

#Handle line breaks from sources
subtest {
	my (Str $line1, Str $line2, Str $line3);
	
	$tmpfh = open $tmpfn, :r;
	$buffer = Utilities::StreamBuffer.new( :input($tmpfh) );
	($line1, $line2, $line3) = ($buffer.get, $buffer.get, $buffer.get);	
	ok (($line2 eq 'data file line 02') and ($line3 eq 'data file line 03')), 'File handle created LB handling';
	$buffer = Nil;
	$tmpfh.close;
	
	$buffer = Utilities::StreamBuffer.new( :input($tmpfn) );
	($line1, $line2, $line3) = ($buffer.get, $buffer.get, $buffer.get);	
	ok (($line2 eq 'data file line 02') and ($line3 eq 'data file line 03')), 'File path created LB handling';
	$buffer = Nil;
	
	$buffer = Utilities::StreamBuffer.new( :input($data-str) );
	($line1, $line2, $line3) = ($buffer.get, $buffer.get, $buffer.get);	
	ok (($line2 eq 'data file line 02') and ($line3 eq 'data file line 03')), 'String created LB handling';
	$buffer = Nil;
	
	$buffer = Utilities::StreamBuffer.new( :input(@data-arr) );
	($line1, $line2, $line3) = ($buffer.get, $buffer.get, $buffer.get);
	ok (($line2 eq 'data file line 02') and ($line3 eq 'data file line 03')), 'Array created LB handling';
	$buffer = Nil;	
	
	$buffer = Utilities::StreamBuffer.new( );
	$buffer.unget("data file line 01\ndata file line 02");
	$buffer.get;
	ok ($buffer.get eq 'data file line 02'), 'Null created LB handling';
	$buffer = Nil;				
	
}, 'Handle line breaks from sources';

# perform get/unget
subtest {
	my (Str $line1, Str $line2, Str $line3, Str $line4);
	
	$tmpfh = open $tmpfn, :r;
	$buffer = Utilities::StreamBuffer.new( :input($tmpfh) );
	($line1, $line2, $line3) = ($buffer.get, $buffer.get, $buffer.get);
	$buffer.unget('line 03');	
	$line4 = $buffer.get;
	ok ($line4 eq 'line 03'), 'File handle created get/unget';
	$buffer = Nil;
	$tmpfh.close;
	
	$buffer = Utilities::StreamBuffer.new( :input($tmpfn) );
	($line1, $line2, $line3) = ($buffer.get, $buffer.get, $buffer.get);	
	$buffer.unget('line 03');	
	$line4 = $buffer.get;	
	ok ($line4 eq 'line 03'), 'File path created get/unget';
	$buffer = Nil;
	
	$buffer = Utilities::StreamBuffer.new( :input($data-str) );
	($line1, $line2, $line3) = ($buffer.get, $buffer.get, $buffer.get);	
	$buffer.unget('line 03');		
	$line4 = $buffer.get;		
	ok ($line4 eq 'line 03'), 'String created get/unget';
	$buffer = Nil;
	
	$buffer = Utilities::StreamBuffer.new( :input(@data-arr) );
	($line1, $line2, $line3) = ($buffer.get, $buffer.get, $buffer.get);
	$buffer.unget('line 03');	
	$line4 = $buffer.get;	
	ok ($line4 eq 'line 03'), 'Array created get/unget';
	$buffer = Nil;	
	
	$buffer = Utilities::StreamBuffer.new( );
	$buffer.unget('data file line 01');
	ok ($buffer.get eq 'data file line 01'), 'Null created get/unget';
	$buffer = Nil;			
}, 'Perform \'get\' and \'unget\'';

# Perform line/char number accounting
subtest {
	$buffer = Utilities::StreamBuffer.new( :input($data-str) );
	$buffer.get; 
	ok ($buffer.line-position == 1), 'Accounting for line following get';
	$buffer.get; $buffer.get;
	ok ($buffer.line-position == 3), 'Accounting for line following gets';
	ok ($buffer.char-position == $entry-len * 3), 'Accounting for char following gets';	
	my Str $retstr = 'line 03';
	$buffer.unget($retstr);			
	ok ($buffer.line-position == 2), 'Accounting for line unget';
	ok ($buffer.char-position == $entry-len * 3 - $retstr.chars), 'Accounting for char following unget';	
	$buffer = Nil;	
}, 'Perform line/char number accounting';

# Perform source switching
subtest {
	$tmpfh = open $tmpfn, :r;
	$buffer = Utilities::StreamBuffer.new( :input($tmpfh) );
	$buffer.get;
	$buffer.get;
	$buffer.source( :input("data file line 72\ndata file line 73\ndata file line 74") );
	$tmpfh.close;
	ok ($buffer.get eq 'data file line 72'), 'Switch FH to Text';
	ok ($buffer.line-position == 3), 'Switch FH to Text - line accounting';
	my @arr = 'data file line 82', 'data file line 83';
	$buffer.source( :input( @arr ), :reset-pos( True ) );
	$buffer.get;
	ok ($buffer.get eq 'data file line 83'), 'Switch Text to Array';
	ok ($buffer.line-position == 2), 'Switch Text to Array - line accounting reset';
	$buffer.unget('data file line 99');
	$buffer.source( :input( $tmpfn ), :flush( False ) );
	ok ($buffer.get eq 'data file line 99'), 'Switch Array to Path - no flush';
	ok ($buffer.buffered-lines.elems == 1), 'Switch Array to Path buffer size - no flush';
	$buffer = Nil;
		
}, 'Perform source switching';

# Perform at extremities
subtest {
	$tmpfh = open $tmpfn, :r;
	$buffer = Utilities::StreamBuffer.new( :input($tmpfh) );
	for 1..@data-arr.elems + 5 { $buffer.get }
	ok (!$buffer.get), 'End of input';
	ok ($buffer.buffered-lines.elems == 0), 'End of input buffer size';
}, 'Perform at extremities';
