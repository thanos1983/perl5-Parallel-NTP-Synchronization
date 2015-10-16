#!/usr/bin/perl
use FiLeS;
use strict;
use warnings;
use parallelSsh;
use Data::Dumper;
use processLogFiles;
use Fcntl qw(:flock);
use Net::OpenSSH::Parallel;

use constant {
    sudoFalse => 0,
    sudoTrue  => 1,
};

my $confFile = "conf.ini";
my $logConf = "log4perl.ini";
my $dirFile = "directories.ini";

my %grepLinuxOS = (
    commandIndexHash => [ 0 ] ,
    constant         => [ sudoFalse ] ,
    LinuxOSIPs       => { allLinuxOSIPs => "*" ,
			  Crux_IPs   => [ undef ] ,
			  Ubuntu_IPs => [ undef ] } ,
    commands         => [ "cat /etc/issue; echo %HOST%" ,
			  "echo %HOST%; /etc/rc.d/ntpd stop; ntpd -gq; /etc/rc.d/ntpd start;" ,
			  "ls /home/"] );

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

my ( $dataLogFiles ) = $objectParallelSsh->getOsDistribution( $refHashDirectories ,
							      $refHashConf ,
							      $refLog4PerlConf ,
							      \%grepLinuxOS );

my $objectProcessLogFiles = processLogFiles->new( "refLogFile" , "refPrintOutput" );

# Find the version Ubuntu or Crux
my $refHashProcessData = $objectProcessLogFiles->processDataLogFile( $dataLogFiles );

# Split Versions Ubuntu or Crux
my ( $refHashCruxIPs , $refHashUbuntuIPs ) = $objectProcessLogFiles->processLinuxVersion( $refHashProcessData );

$grepLinuxOS{constant} = sudoTrue;
$grepLinuxOS{commandIndexHash}[0] = 1;
$grepLinuxOS{LinuxOSIPs}{Crux_IPs} = $refHashCruxIPs;
$grepLinuxOS{LinuxOSIPs}{Ubuntu_IPs} = $refHashUbuntuIPs;

my ( $timestampLogFiles ) = $objectParallelSsh->getOsDistribution( $refHashDirectories ,
								   $refHashConf ,
								   $refLog4PerlConf ,
								   \%grepLinuxOS );

my $refHashProcessTimestampFile = $objectProcessLogFiles->processDataLogFile( $timestampLogFiles );

my $refHashData = $objectProcessLogFiles->processTimestampFile( $refHashProcessTimestampFile );

print Dumper $refHashData;

$grepLinuxOS{constant} = sudoFalse;
$grepLinuxOS{commandIndexHash}[0] = 2;

sleep(1); # sleep time before applying dagClockSynch

my ( $dagClockLogFiles ) = $objectParallelSsh->getOsDistribution( $refHashDirectories ,
								   $refHashConf ,
								   $refLog4PerlConf ,
								   \%grepLinuxOS );
__END__

Sample of output:

$VAR1 = {
          '10.0.0.6' => 'ntpd: time slew -0.017331s',
          '10.0.0.17' => 'ntpd: time slew -0.059259s'
        };
