#!/usr/athena/bin/perl
eval 'exec /usr/athena/bin/perl -S $0 ${1+"$@"}'
    if $running_under_some_shell;
			# this emulates #! processing on NIH machines.
			# (remove #! line above if indigestible)

eval '$'.$1.'$2;' while $ARGV[0] =~ /^([A-Za-z_0-9]+=)(.*)/ && shift;
			# process any FOO=bar switches

$[ = 1;			# set array base to 1
$, = ' ';		# set output field separator
$\ = "\n";		# set output record separator

$char_shift = 64;
## "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_";
$c2n{'A'} = 1;
$c2n{'B'} = 2;
$c2n{'C'} = 3;
$c2n{'D'} = 4;
$c2n{'E'} = 5;
$c2n{'F'} = 6;
$c2n{'G'} = 7;
$c2n{'H'} = 8;
$c2n{'I'} = 9;
$c2n{'J'} = 10;
$c2n{'K'} = 11;
$c2n{'L'} = 12;
$c2n{'M'} = 13;
$c2n{'N'} = 14;
$c2n{'O'} = 15;
$c2n{'P'} = 16;
$c2n{'Q'} = 17;
$c2n{'R'} = 18;
$c2n{'S'} = 19;
$c2n{'T'} = 20;
$c2n{'U'} = 21;
$c2n{'V'} = 22;
$c2n{'W'} = 23;
$c2n{'X'} = 24;
$c2n{'Y'} = 25;
$c2n{'Z'} = 26;
$c2n{'a'} = 27;
$c2n{'b'} = 28;
$c2n{'c'} = 29;
$c2n{'d'} = 30;
$c2n{'e'} = 31;
$c2n{'f'} = 32;
$c2n{'g'} = 33;
$c2n{'h'} = 34;
$c2n{'i'} = 35;
$c2n{'j'} = 36;
$c2n{'k'} = 37;
$c2n{'l'} = 38;
$c2n{'m'} = 39;
$c2n{'n'} = 40;
$c2n{'o'} = 41;
$c2n{'p'} = 42;
$c2n{'q'} = 43;
$c2n{'r'} = 44;
$c2n{'s'} = 45;
$c2n{'t'} = 46;
$c2n{'u'} = 47;
$c2n{'v'} = 48;
$c2n{'w'} = 49;
$c2n{'x'} = 50;
$c2n{'y'} = 51;
$c2n{'z'} = 52;
$c2n{'0'} = 53;
$c2n{'1'} = 54;
$c2n{'2'} = 55;
$c2n{'3'} = 56;
$c2n{'4'} = 57;
$c2n{'5'} = 58;
$c2n{'6'} = 59;
$c2n{'7'} = 60;
$c2n{'8'} = 61;
$c2n{'9'} = 62;
$c2n{'_'} = 63;

line: while (<>) {
    ($Fld1,$Fld2) = split(' ', $_, 9999);
    if (/^#/) {
	next line;
    }
    if (/^[ \t]*(error_table|et)[ \t]+[a-zA-Z][a-zA-Z0-9_]+/) {
	$table_number = 0;
	$table_name = $Fld2;
	$mod_base = 1000000;
	for ($i = 1; $i <= length($table_name); $i++) {
	    $table_number = ($table_number * $char_shift) +

	      $c2n{substr($table_name, $i, 1)};
	}
	# We start playing *_high, *low games here because the some
	# awk programs do not have the necessary precision (sigh)
	$tab_base_low = $table_number % $mod_base;
	$tab_base_high = int($table_number / $mod_base);
	$tab_base_sign = 1;

	# figure out: table_number_base=table_number*256
	$tab_base_low = $tab_base_low * 256;
	$tab_base_high = ($tab_base_high * 256) + int($tab_base_low /

	  $mod_base);
	$tab_base_low = $tab_base_low % $mod_base;

	if ($table_number > 128 * 256 * 256) {
	    # figure out:  table_number_base -= 256*256*256*256
	    # sub_high, sub_low is 256*256*256*256
	    $sub_low = 256 * 256 * 256 % $mod_base;
	    $sub_high = int(256 * 256 * 256 / $mod_base);

	    $sub_low = $sub_low * 256;
	    $sub_high = ($sub_high * 256) + int($sub_low / $mod_base);
	    $sub_low = $sub_low % $mod_base;

	    $tab_base_low = $sub_low - $tab_base_low;
	    $tab_base_high = $sub_high - $tab_base_high;
	    $tab_base_sign = -1;
	    if ($tab_base_low < 0) {
		$tab_base_low = $tab_base_low + $mod_base;
		$tab_base_high--;
	    }
	}
	$curr_low = $tab_base_low;
	$curr_high = $tab_base_high;
	$curr_sign = $tab_base_sign;
	&Pick('>', $outfile) &&
	    (print $fh '/*');
	&Pick('>', $outfile) &&
	    (print $fh ' * ' . $outfile . ':');
	&Pick('>', $outfile) &&
	    (print $fh

	      ' * This file is automatically generated; please do not edit it.');
	&Pick('>', $outfile) &&
	    (print $fh ' */');
	&Pick('>', $outfile) &&
	    (print $fh '');
	&Pick('>', $outfile) &&
	    (print $fh '#include <com_err.h>');
	&Pick('>', $outfile) &&
	    (print $fh '');
    }

    if (/^[ \t]*(error_code|ec)[ \t]+[A-Z_0-9]+,/) {
	$tag = substr($Fld2, 1, length($Fld2) - 1);
	if ($curr_high == 0) {
	    &Pick('>', $outfile) &&
		(printf $fh "#define %-40s (%dL)\n", $tag,

		  $curr_sign * $curr_low);
	}
	else {
	    &Pick('>', $outfile) &&
		(printf $fh "#define %-40s (%d%06dL)\n", $tag,

		  $curr_high * $curr_sign, $curr_low);
	}
	$curr_low += $curr_sign;
	if ($curr_low >= $mod_base) {	#???
	    $curr_low -= $mod_base;
	    $curr_high++;
	}
	if ($curr_low < 0) {
	    $cur_low += $mod_base;
	    $cur_high--;
	}
    }
}

if ($tab_base_high == 0) {
    &Pick('>', $outfile) &&
	(print $fh '#define ERROR_TABLE_BASE_' . $table_name . ' (' .

	  sprintf('%d', $tab_base_sign * $tab_base_low) . 'L)');
}
else {
    &Pick('>', $outfile) &&
	(print $fh '#define ERROR_TABLE_BASE_' . $table_name . ' (' .

	  sprintf('%d%06d', $tab_base_sign * $tab_base_high,

	  $tab_base_low) . 'L)');
}
&Pick('>', $outfile) &&
    (print $fh '');
&Pick('>', $outfile) &&
    (print $fh 'extern struct error_table et_' . $table_name .

      '_error_table;');
&Pick('>', $outfile) &&
    (print $fh '');
&Pick('>', $outfile) &&
    (print $fh

      '#if !defined(_MSDOS) && !defined(_WIN32) && !defined(macintosh)');
&Pick('>', $outfile) &&
    (print $fh '/* for compatibility with older versions... */');
&Pick('>', $outfile) &&
    (print $fh 'extern void initialize_' . $table_name .

      '_error_table () /*@modifies internalState@*/;');
&Pick('>', $outfile) &&
    (print $fh '#define init_' . $table_name . '_err_tbl initialize_' .

      $table_name . '_error_table');
&Pick('>', $outfile) &&
    (print $fh '#define ' . $table_name . '_err_base ERROR_TABLE_BASE_' .

      $table_name);
&Pick('>', $outfile) &&
    (print $fh '#else');
&Pick('>', $outfile) &&
    (print $fh '#define initialize_' . $table_name . '_error_table()');
&Pick('>', $outfile) &&
    (print $fh '#endif');

sub Pick {
    local($mode,$name,$pipe) = @_;
    $fh = $name;
    open($name,$mode.$name.$pipe) unless $opened{$name}++;
}
