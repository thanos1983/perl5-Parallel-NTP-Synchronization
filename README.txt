This work was conducted for personal training purposes.
We aquire no responsibility for any possible damage on Software or Hardware that
 can be caused by the use of this script.

CONTENTS OF THIS FILE
---------------------

 * Introduction
 * Important notes
 * Requirements
 * Recommended modules
 * Installation
 * Configuration
 * Troubleshooting
 * FAQ
 * Maintainers

---------------------

 * Introduction
 The Parallel-NTP-Synchronization script is written in OOP way. The script has 
  the ability to connect and force pararallel NTP synchronization for different 
  LinuxOS NTP Servers.

 * Important notes
 Caution, the script can only force NTP synchronization to LinuxOS and not WinOS.
 
 The script is fully automated.

 * Requirements
 Internet/LAN connection to all OS.
 Basic initialization and correct operation of the script:
 1) Install NTP on each OS that you are planning to force NTP synchronization
  from the desired NTP server, also locally where the script will executed.

 2) Install ssh on all OS and also ssh to each PC inorder to add them on the ssh
  list of the OS that the script will be executed. I reccomend to ssh on both
  directions from the parentOS and also from the childOS. By doing so we can
  ensure that both OS can see each other and add both on trusted ssh list.
  This process will take less than 1 minute and will reduce the debugging process
  by hours.

 3) Install all the required Perl modules.

 * Recommended modules
 Net::NTP
 Config::IniFiles
 Net::OpenSSH::Parallel

 * Installation
 Installation can be completed with many different way depending upon the OS. 
 Sample of the most common way on linux:

 sudo cpan
 install Config::IniFiles

 Each module needs to be installed separately.

 * Configuration
 1) Before initialization of the main.pl script the user is required to modify
  the conf.ini file. Inside there are 5 subsections that are necessary to be
   modified before execution. Sample is given bellow:

 host     = 127.0.0.1
 user     = username
 psw      = password
 port     = 22 (default)
 log      = MP_1.log
 error    = MP_1.err

 2) Second step after configuring the conf.ini file is to configure the
  directories.ini file. Inside the directories.ini file there are 2 subsections
  that are needed to be modified based on the desired path of the parentOS.
  Sample is given bellow:

 log_dir  = /home/path/SampleFileLocation/LOG
 err_dir  = /home/path/SampleFileLocation/ERROR
 
  2) Third step after configuring the directories.ini file is to configure the
  directories.ini file. Inside the directories.ini file there are 2 subsections
  that are needed to be modified based on the desired path of the parentOS.
  Sample is given bellow:

 log_dir  = /home/path/SampleFileLocation/LOG
 err_dir  = /home/path/SampleFileLocation/ERROR

 3) As mentioned on section Requirements in order to be able to configure and
  execute successfully the script you need to follow all the steps mentioned on
  the section.

 * Troubleshooting
 1) Before start blamming the programmer try to check if you have followed step
  by step the predifined sections, all of them!!!!
 2) While we where experimenting we figure out also that firewall should be
  modified to accept ssh connections, ulternatively the script will be blocked.
  Although that if you have followed the steps mentioned before you would have
  detected the problem earlier.
 3) If all the above sections are completed correctly and still the script is
  not behaving as expected now it is a good time to start swearing and blame the
  programmer.
 4) Good luck in debugging.

 * FAQ
 1) The script is written to be operating on UbuntuOS and CruxOS. Unfortunately
  these two OS where needed for our project so if your question is why the
  script is not behaving correctly on any other LinuxOS distribution is because
  it was not created to do so.
 2) The script is not written to be operating on WindowsOS so do not expect to
  be working correctly.
 3) It is really easy to add another LinuxOS distribution if it desired. More
  information can be found on the next section.
 4) The script is not written to be operating on WindowsOS because some
  functions are not active on Windows which makes it impossible to do so.
 5) Possibly the script can be executed on MacOS with minor modifications due to
  LinuxOS core but it has never been tested.

 * Maintainers
 As mentioned before if you require to add another OS recommended LinuxOS
  distribution, you need to modify slightly the main.pl script and also the
  parallelSsh.pm module. On line 61 (main.pl) we see the
  "$grepLinuxOS{LinuxOSIPs}{Crux_IPs} = $refHashCruxIPs;" identically you can
  add "$grepLinuxOS{LinuxOSIPs}{Gentoo_IPs} = $refHashGentooIPs;"
  (attention this only a sample LinuxOS not tested with the specific OS).

 As a second step between lines 75 and 98 on (parallelSsh.pm module) you will
  find a sample how it is implemented for UbuntuOS and CruxOS the IP shorting
  part. Based on these lines you can easily create your own process for any
  other LinuxOS or MacOS. Hope this helps.

 The main reason that we have two different ways of implementation
  (Ubuntu and Crux) is that both OS have a different way of stop/reset/start the
  ntp synchronization process.

 Last Update of the file (2015/05/25).

 Best of luck in future implementation and improvement(s).
