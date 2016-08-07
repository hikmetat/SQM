use v6;

use lib 'D:\Users\Hikmet\workspace\SQM2SQL';
use sqm-reader;
use sqm-reader-actions;


#my Str $lines = '	addOnsAuto[]=
#	{';
#$lines = "class Intel\n\{";

my Str @lines = 
'	addOnsAuto[]='						,
'	{'									,
'		"A3_Characters_F_BLUFOR",'		,
'		"a3_characters_f"'				,
'	};'									,
'	randomSeed=1795320;'				,
'	class Intel'						,
'	{'									,
'		startWeather=0.29999998;'		,
'		startWind=0;'					,
'		side="WEST";'					,
'	};'									,
;

my $match;

sub parse(Str @lines, %callbacks) {
	# loop through input lines
	my Str ( $block, $trailer, $event, %began );
	while @lines {
		
		# reset loop variables:
		# $block is the currently concatenated tines text block
		# $trailer is the remainder after matching
		# $event is the grammar generated event
		( $block, $trailer, $event ) = ('', '', '');
		
		# Concat line to existing block of text
		# and try to get a match. Continue until success
		repeat  {			
			$block ~= @lines.shift;
			$match = sqm-reader.parse($block, :actions(sqm-reader-actions));
		} until $match or !@lines;
		
		# if we terminated without a match return
		# but give feed-back on leftover text
		if !$match {
			say 'exiting with ', $block if $block !~~ /\s*/;
			return
		}

		# return the trailing part of the match
		@lines.unshift(~$match<trailer>);		

		# get grammar match data
		my %data = $match.made;
		# get event
		$event = %data<event>;	
		my Str ($name, $value) = ('','');
		$name = %data<name> if %data<name>:exists;
		$value = %data<attributes><value> if %data<attributes><value>:exists;
				
		# to rectify the closer event for which we
		# don't know about the opener, remember where we began
		# if the event is class-begin or array-begin
		%began = (type => ~$0, name => $name) if $event ~~ /(\w+) '-begin'/;
		
		#rectify the closer event if it is indeed 'closer'
		if $event eq 'closer' {
			$event = %began<type>~"-end";
			$name = %began<name>
		}
		


		%callbacks{$event}($name, $value);
		
	}
}

my %callbacks = 
	attrib		=> sub (Str $cname, Str $cvalue) { say "attrib: $cname --> $cvalue" 		},
	class-begin	=> sub (Str $cname, Str $cvalue) { say "begin class: $cname"	},
	array-begin	=> sub (Str $cname, Str $cvalue) { say "begin array: $cname"	},
	array-elem	=> sub (Str $cname, Str $cvalue) { say "array elem: $cname"	},
	class-end	=> sub (Str $cname, Str $cvalue) { say "end class: $cname"	},
	array-end	=> sub (Str $cname, Str $cvalue) { say "end array: $cname"	},
;

parse(@lines, %callbacks);
	
#my $match = sqm-reader.parse($lines);
#die '!!! ERROR !!!' unless ?$match;


#my $event-root = $match{$event};

#given $event {
#	when 'attrib'		{ say 'attrib: ' ~ $event-root<attrib-name>  ~ ' --> ' ~ $match<attrib><attrib-value> }
#	when 'class-begin'	{ say 'begin class: ' ~ $event-root<class-name> }
#	when 'array-begin'	{ say 'begin array: ' ~ $event-root<array-name> }
#	when 'array-elem'	{ say 'array elem: ' ~ $event-root<array-elem-name> }
#	when 'closer'		{ say 'end' }
#}




