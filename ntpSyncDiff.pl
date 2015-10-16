#!/usr/bin/perl
use FiLeS;
use strict;
use warnings;
use parallelSsh;
use Data::Dumper;
use processLogFiles;
use Fcntl qw( :flock );
use Net::OpenSSH::Parallel;
use lib '/home/tiny/Desktop/Net-SNTP-Client/lib/'; # note here
use Net::SNTP::Client qw ( getSNTPTime );
use Time::HiRes qw(gettimeofday tv_interval);

use constant {
    sudoFalse => 0,
    sudoTrue  => 1,
};

my %WARNS = ();
my @stdout_fh = ();
my @stderr_fh = ();
my @log_files = ();

my $confFile = "conf.ini";
my $logConf  = "log4perl.ini";
my $dirFile  = "directories.ini";

my %grepLinuxOS = (
    commandIndexHash => [ 0 ] ,
    constant         => [ sudoFalse ] ,
    LinuxOSIPs       => { allLinuxOSIPs => "*" },
    commands         => [ "ntpq -np; echo %HOST%" ] );

my $objectFiles      = FiLeS->new( $dirFile ,
				   $confFile ,
				   $logConf );

my $refHashConf      = $objectFiles->getConfFile();
my $refHashDir       = $objectFiles->getDirFile();
my $refLog4PerlConf  = $objectFiles->getlogPerlConfFile();

my $refHashDirectories  = $objectFiles->makeDirectories( $refHashDir );
my $refHashConfMakeFile = $objectFiles->makeLog4PerlLogFile( $refLog4PerlConf );

my $objectParallelSsh = parallelSsh->new( "hashConfRef" ,
					  "refHashDir" ,
					  "refHashLog" ,
					  "refHashGrepLinuxOSIPs" );

my $t0 = [gettimeofday];
my ( $dataLogFiles ) = $objectParallelSsh->getOsDistribution( $refHashDirectories ,
							      $refHashConf ,
							      $refLog4PerlConf ,
							      \%grepLinuxOS );
my $t1 = [gettimeofday];

my %hashInput = (
    -hostname      => "194.116.168.40",
    );

my ( $error , $hashRefOutput ) = getSNTPTime( %hashInput );

#print Dumper $hashRefOutput;
print "Clock Offset: " . $hashRefOutput->{'RFC4330'}{'Clock Offset'} . "\n";
print "Error: $error\n" if ($error);

my $elapsed = tv_interval ($t0, $t1);

print "Elapsed time: ".$elapsed."\n";

=important
    We need to add the process time of ssh::parallel
    elapsed time + offset = time difference from ref server time
=cut

my $objectProcessLogFiles = processLogFiles->new( "refLogFile" , "refPrintOutput" );

# Get the NTP offset from several NTP servers
my $refHashProcessData = $objectProcessLogFiles->processDataLogFile( $dataLogFiles );

my $refHashProcessOffsetNTP = $objectProcessLogFiles->processOffsetNTP( $refHashProcessData );

print Dumper $refHashProcessOffsetNTP;

__END__

    Sample of output:

    Clock Offset: -0.366012215614319
    Elapsed time: 0.648898
    $VAR1 = {
    '127.0.0.1' => ' offset -0.774  0.391 15.028 -0.828 -3.2951'
};
