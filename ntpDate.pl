#!/usr/bin/perl
use FiLeS;
use strict;
use warnings;
use Net::NTP;
use parallelSsh;
use Data::Dumper;
use processLogFiles;
use Fcntl qw( :flock );
use Net::OpenSSH::Parallel;
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
    commands         => [ "ntpdate -q 193.79.237.14; echo %HOST%" ] );

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
my %response = get_ntp_response("0.se.pool.ntp.org",123);

#print "This is what we want: " . $response{'Reference Timestamp'} . "\n";

my $elapsed = tv_interval ($t0, $t1);

print "Elapsed time: ".$elapsed."\n";

=important
    We need to add the process time of ssh::parallel
    elapsed time + offset = time difference from ref server time
=cut

my $objectProcessLogFiles = processLogFiles->new( "refLogFile" , "refPrintOutput" );

# Get the NTP offset from several NTP servers
my $refHashProcessData = $objectProcessLogFiles->processDataLogFile( $dataLogFiles );

my $refHashProcessOffsetNTP = $objectProcessLogFiles->processNtpDate( $refHashProcessData );

print Dumper $refHashProcessOffsetNTP;

__END__

Sample of output:
Elapsed time: 8.877458
$VAR1 = {
          '10.0.0.6' => 'offset -0.021406 delay 0.06677',
          '10.0.0.17' => 'offset 0.000000 delay 0.00000'
        };
