#!/usr/bin/perl
use strict;
use warnings;
use Log::Log4perl;
use Net::OpenSSH::Parallel;

package parallelSsh;

sub new {
    my $class = shift;

    my $devices = {
	refHashConf           => shift,
        refHashDir            => shift,
        refHashLog            => shift,
	refHashGrepLinuxOSIPs => shift,
    };
    bless $devices, $class;

    return $devices;
}

sub getOsDistribution {

    use constant {
	sudoFalse => 0,
	sudoTrue  => 1,
    };

    my ( $classRef , $hashRefDir , $hashRefconf , $logConf , $grepLinuxOS ) = @_;

    # Initialize Logger
    Log::Log4perl::init($logConf->{Log4Perl}{logConfFile});
    my $logger = Log::Log4perl->get_logger("parallelSsh");

    my @mps = sort keys ( $hashRefconf );

    my $maximum_workers = @mps;
    my $maximum_connections = 2 * $maximum_workers;
    my $maximum_reconnections = 3;

    my %opts = ( workers       => $maximum_workers,
		 connections   => $maximum_connections,
		 reconnections => $maximum_reconnections );

    my $pssh = Net::OpenSSH::Parallel->new(%opts);

    my $num = 0;
    my @log_files = ();
    my @stdout_fh = ();
    my @stderr_fh = ();
    our %sudo_passwords = ();

    foreach my $mp ( @mps ) {
	push (@log_files , "".$hashRefDir->{Directories}{log_dir}."/".$hashRefconf->{$mp}{log}."");

	open $stdout_fh[$num] , '>' , "".$hashRefDir->{Directories}{log_dir}."/".$hashRefconf->{$mp}{log}.""
	    or $logger->error("unable to create/open file: $hashRefconf->{$mp}{log} - $!");
	open $stderr_fh[$num], '>>', "".$hashRefDir->{Directories}{err_dir}."/".$hashRefconf->{$mp}{error}.""
	    or $logger->error("unable to create/open file: $hashRefconf->{$mp}{error} - $!");

	$pssh->add_host( $hashRefconf->{$mp}{host} ,
			 user              => $hashRefconf->{$mp}{user},
			 port              => $hashRefconf->{$mp}{port},
			 password          => $hashRefconf->{$mp}{psw},
			 default_stderr_fh => $stderr_fh[$num],
			 default_stdout_fh => $stdout_fh[$num] );

	$sudo_passwords{$hashRefconf->{$mp}{host}} = $hashRefconf->{$mp}{psw};

	$num++;
    }

    if ( $grepLinuxOS->{constant} eq sudoTrue ) {
	if ( grep { defined($_) } $grepLinuxOS->{LinuxOSIPs}{Ubuntu_IPs} ) {
	    my @Ubuntu_cmds = ( 'echo %HOST%' ,
				"service ntp stop" ,
				"ntpd -gq" ,
				"service ntp start" );

	    sub sudoUbuntu {
		my ($label , $ssh , @cmd) = @_;
		foreach my $c (@cmd) {
		    $ssh->system( {stdin_data => "$sudo_passwords{$label}\n"} ,
				  'sudo' , '-Skp' , '' , '--' , split " " , $c );
		}
	    }

	    foreach my $Ubuntu_ip ( @{$grepLinuxOS->{LinuxOSIPs}{Ubuntu_IPs}} ) {
		$pssh->push($Ubuntu_ip , parsub => \&sudoUbuntu , @Ubuntu_cmds);
	    }
	} # End of if grep $Ubuntu_IPs

	if ( grep { defined($_) } $grepLinuxOS->{LinuxOSIPs}{Crux_IPs} ) {
	    foreach my $Crux_ip ( @{$grepLinuxOS->{LinuxOSIPs}{Crux_IPs}} ) {
		$pssh->push($Crux_ip , $grepLinuxOS->{commands}[$grepLinuxOS->{commandIndexHash}[0]] );
	    }
	} # End of if grep $Crux_IPs
    }
    else {
	# hostname -I another way to get IP
	$pssh->push( $grepLinuxOS->{LinuxOSIPs}->{allLinuxOSIPs}, command => $grepLinuxOS->{commands}[$grepLinuxOS->{commandIndexHash}[0]] );
    }

    $pssh->run;

    closeFH( @stdout_fh , @stderr_fh );

    return \@log_files;
}

sub closeFH {
    foreach my $fh (@_) { close $fh or die "Error closing $!\n"; }
}

1;
