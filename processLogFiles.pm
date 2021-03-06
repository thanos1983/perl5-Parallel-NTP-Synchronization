#!/usr/bin/perl
use strict;
use warnings;

package processLogFiles;

sub new {
    my $class = shift;

    my $devices = {
	refArrayProcess => shift,
	refHashOffsetNTP => shift,
	refHashTimestampFiles => shift,
    };
    bless $devices, $class;

    return $devices;
}

sub processDataLogFile {
    use Fcntl qw( :flock );

    my ( $devices , $refStdinArray ) = @_;

    my %file_hash = ();

    foreach my $file ( @{$refStdinArray} ) {

	open my $fh , '<' , $file
	    or die "unable to open file: ".$file." $!";

	flock( $fh , LOCK_SH )
	    or die "Could not lock '".$file."' - $!\n";

	my $log_file = (split(/\//,$file))[-1];

	# Remove \n character and also blank lines
	chomp(my @lines = grep /\S/, <$fh>);

        # Push the data into a hash
	push(@{$file_hash{$log_file}}, @lines);

	close $fh
	    or die "unable to close file: ".$file." $!";
    }
    return $devices->{refArrayProcess} = \%file_hash if (%file_hash);
}

sub processLinuxVersion {
    my ( $devices , $refHashProcessData ) = @_;

    my %version_hash = ();

    # Bind the IP's with the OS version
    foreach my $key ( keys $refHashProcessData ) {
	$refHashProcessData->{$key}[0] = (split(/ /,$refHashProcessData->{$key}[0]))[0];

	# Push the version into a hash pointing to the ip
	push( @{$version_hash{$refHashProcessData->{$key}[0]} } , $refHashProcessData->{$key}[1] );
    }

    #push( @{$version_hash{"CRUX" }} , "127.0.0.2", "127.0.0.3");
    #push( @{$version_hash{"Ubuntu" }} , "127.0.0.4", "127.0.0.5");

    $devices->{refArrayProcess} = $version_hash{'CRUX'};
    $devices->{refHashOffsetNTP} = $version_hash{'Ubuntu'};

    return ($devices->{refArrayProcess} , $devices->{refHashOffsetNTP});
}

sub processTimestampFile {
    use Fcntl qw( :flock );

    my ( $devices , $refHashData ) = @_;

    my $data = "data.txt";

    open my $write , '>>' , $data
	or die "Could not open file: ".$data." - $!\n";

    flock( $write , LOCK_SH )
	or die "Could not lock '".$data."' - $!\n";

    my %data_hash = ();

    foreach my $data_file ( sort { @{$refHashData->{$b}} <=> @{$refHashData->{$a}} } keys $refHashData ) {
	#print "$data_file: ", join(", ", sort @{ $refHashData{$data_file} }), "\n";
	$data_hash{$refHashData->{$data_file}[0]} = $refHashData->{$data_file}[3];
	printf $write "%s %s\n" , $refHashData->{$data_file}[0] , $refHashData->{$data_file}[3];
    }

    close $write
	or die "Could not close '".$data."' - $!\n";

    return $devices->{refHashTimestampFiles} = \%data_hash if (%data_hash);
}

sub processOffsetNTP {
    use Fcntl qw( :flock );

    my ( $devices , $refHashData ) = @_;

    my $data = "offsetNTP.txt";

    open my $write , '>>' , $data
	or die "Could not open file: ".$data." - $!\n";

    flock( $write , LOCK_SH )
	or die "Could not lock '".$data."' - $!\n";

    my %data_hash = ();
    my $sample;
    foreach my $hashMP ( sort { @{$refHashData->{$b}} <=> @{$refHashData->{$a}} } keys $refHashData ) {
	foreach my $value ( 0 .. $#{ $refHashData->{$hashMP} } ) {
	    next if $value == 1 || $value =~ /^\s*$/;
	    $sample = substr $refHashData->{$hashMP}[$value] , -15 , 7;
	    #printf $write "%s %s\n" , $refHashData->{$hashMP}[-1] , $sample if $sample;
	    $data_hash{$refHashData->{$hashMP}[-1]} .= $sample;
	}
	print $write $refHashData->{$hashMP}[-1] . " " . $data_hash{$refHashData->{$hashMP}[-1]} . "\n";
    }

    close $write
	or die "Could not close '".$data."' - $!\n";

    return $devices->{refHashOffsetNTP} = \%data_hash if (%data_hash);
}

sub processNtpDate {
    use Fcntl qw( :flock );

    my ( $devices , $refHashData ) = @_;

    my $data = "ntpDate.txt";

    open my $write , '>>' , $data
	or die "Could not open file: ".$data." - $!\n";

    flock( $write , LOCK_SH )
	or die "Could not lock '".$data."' - $!\n";

    my %data_hash = ();
    my $tempValues;
    foreach my $hashMP ( sort { @{$refHashData->{$b}} <=> @{$refHashData->{$a}} } keys $refHashData ) {
	foreach my $value ( 0 .. $#{ $refHashData->{$hashMP} } ) {
	    next if $value == 1 || $value =~ /^\s*$/ || $value == 2;
	    $tempValues = $refHashData->{$hashMP}[$value];
	    my @lines = split(',',$tempValues);
	    foreach my $singleLine (@lines) {
		$singleLine =~ s/^\s+//;
	    }
	    $data_hash{$refHashData->{$hashMP}[-1]} .= $lines[2] . " " . $lines[3];
	}
	print $write $refHashData->{$hashMP}[-1] . " " . $data_hash{$refHashData->{$hashMP}[-1]} . "\n";
    }
    close $write
	or die "Could not close '".$data."' - $!\n";

    return $devices->{refHashOffsetNTP} = \%data_hash if (%data_hash);
}

1;

__END__

    sub arrayConversion {

	my ( $devices , @twoDimensionArray ) = @_;

	my @result;
	while ( @twoDimensionArray ) {
	    my $next = shift @twoDimensionArray;
	    if ( ref($next) eq 'ARRAY' ) {
		unshift @twoDimensionArray , @$next;
	    }
	    else {
		push @result, $next;
	    }
	}
	return $devices->{refArrayConversion} = \@result if (@result);
}
