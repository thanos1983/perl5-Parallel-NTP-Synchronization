#!/usr/bin/perl
use strict;
use warnings;

package FiLeS;

sub new {
    my $class = shift;

    my $files = {
	dirRefFile      => shift,
        confRefFile     => shift,
	logPerlConfFile =>shift,
    };
    bless $files, $class;

    return $files;
}

sub getConfFile {
    use Config::IniFiles;
    use Fcntl qw( :flock );

    my ($classRef) = @_;

    my $dataFiles = $classRef->{confRefFile};
    open my $fh , '<' , "".$dataFiles.""
	or die "Could not open file: ".$dataFiles." - $!\n";

    flock( $fh , LOCK_SH )
	or die "Could not lock '".$dataFiles."' - $!\n";

    tie my %ini, 'Config::IniFiles', ( -file => "".$dataFiles."" )
	or die "Error: IniFiles->new: @Config::IniFiles::errors";

    close $fh
	or die "Could not close '".$dataFiles."' - $!\n";

    return $classRef->{confRefFile} = \%ini if (%ini);
}

sub getDirFile {
    use Config::IniFiles;
    use Fcntl qw( :flock );

    my ($classRef) = @_;

    my $dataFiles = $classRef->{dirRefFile};
    open my $fh , '<' , "".$dataFiles.""
	or die "Could not open file: ".$dataFiles." - $!\n";

    flock( $fh , LOCK_SH )
	or die "Could not lock '".$dataFiles."' - $!\n";

    tie my %ini, 'Config::IniFiles', ( -file => "".$dataFiles."" )
	or die "Error: IniFiles->new: @Config::IniFiles::errors";

    close $fh
	or die "Could not close '".$dataFiles."' - $!\n";

    return $classRef->{dirRefFile} = \%ini if (%ini);
}

sub getlogPerlConfFile {
    use Config::IniFiles;
    use Fcntl qw( :flock );

    my ($classRef) = @_;

    my $dataFiles = $classRef->{logPerlConfFile};
    open my $fh , '<' , "".$dataFiles.""
	or die "Could not open file: ".$dataFiles." - $!\n";

    flock( $fh , LOCK_SH )
	or die "Could not lock '".$dataFiles."' - $!\n";

    tie my %ini, 'Config::IniFiles', ( -file => "".$dataFiles."" )
	or die "Error: IniFiles->new: @Config::IniFiles::errors";

    close $fh
	or die "Could not close '".$dataFiles."' - $!\n";

    return $classRef->{logPerlConfFile} = \%ini if (%ini);
}

sub makeDirectories {
    my ( $classRef , $hash_dir ) = @_;

    foreach my $dir ( sort keys %{ $hash_dir } ) {
	#print $dir . " {\n";
	foreach my $keys ( keys %{ $hash_dir->{ $dir } } ) {
	    #print "\t" . $keys . " \t=> ";
	    foreach my $path ( $hash_dir->{ $dir }->{ $keys } ) {
		#print $path . "\n";
		unless(-e $path or mkdir $path) {
		    mkdir ($path , 0755);
		}
	    }
	}
	#print "}\n";
    }
    return $classRef->{ dirRefFile } = $hash_dir if ( $hash_dir );
}

sub makeLog4PerlLogFile {

    my ( $classRef , $logConf ) = @_;

    my $logPerlConf = $logConf->{Log4Perl}{logIniFile};
    open(my $fh, '>', $logPerlConf) or die "Could not open file '$logPerlConf' $!";
    close $fh or die "Could not close file '$logPerlConf' $!";

    return $classRef->{ logPerlConfFile } = $logPerlConf if ( $logPerlConf );
}

1;

__END__

# Alternatively, convert referense to hash
my %localHash = %$hash_dir;
#print Dumper \%localHash;

foreach my $dir ( sort keys %localHash ) {
    print $dir . "{\n";
    foreach my $keys ( sort keys $localHash{$dir} ) {
	print "\t" . $keys . " \t=> ";
	foreach my $path ( $localHash{$dir}{$keys} ) {
	    print $path . "\n";
	    unless(-e $path or mkdir $path) {
		mkdir ($path , 0755);
	    }
#$dir_all{$dir} = $path;
	}
    }
    print "\t}\n";
}
print "}\n";
