bbk-pj
======

Project developed as part of the dissertation for the program of MSc in Intelligent Technologies

by Sandro Antonio Vicente
email: sandrovicente@gmail.com

Birkbeck College, University of London
September 2014

=====

INTRODUCTION
------------

The files in this project are a set of scripts in Perl, Bash and R Statistical Package developed to perform data mining on a SIP-based telecommunication system of reference.

The system is further described in the project report.

This code is distributed under MIT license. Please refer to 'license.txt' file. 

PREREQUISITES
--------------------

- Linux; or
- Mac OS X

Packages required:

-	GNU Bash 3.2.48 and awk;
-	Perl 5 version 14.4, including the packages JSON::XS, LWP::Simple and Net::Stomp (installed from CPAN);
-	curl 7.19.7;
-	Sun Java JDK 1.7.0 or higher;
-	ElasticSearch 1.3.1 (install from http://www.elasticsearch.org/download);
-	R 3.0.0, including package plyr (*);
-	jq JSON processor 1.3 (install from http://stedolan.github.io/jq/download);
-   Apache Active MQ 5.10.0 (install from http://activemq.apache.org/activemq-5100-release.html).

(*) At the bottom of this file there is a section about how to install R 3.0.0 (or higher) on Debian Wheezy.

Optional

-   Apache Hadoop 2.3.0, but not necessary for standalone mode described below.

FILE STRUCTURE
--------------

+ colmat 
	Scripts for collection and matching. Cover all MapReduce phases (MR1, MR2, MR3 and MR4)

	ordererlib.pm

		Module containing the logic for the SIP message handlers, the SIP parsing and SIP ordering. 

	lm_env.pm

		Environment configuration: 
		. COMP_NET_ID: Table associating message handlers to component classes
		. COMP_ORDER: Table associating servers and IP addresses to component classes
		. COMP_HANDLERS: Table defining order of session initiation requests across component classes

	collector.pl

		Perform the collection and summarization from SIP logs using the environment configuration in 'Lm_env.pm' and the handlers and parser in 'Ordererlib.pm'. 

	collector_reduce.pl

		Collects all records with the same CoC and Cid combination and performs CoC ordering using 'order_sipn' logic. Calculates 'req_ts' and 'last_ts'. At this point generates LEs per component

	merger_map.pl

		Split key CoC+Cid and use Cid as key. Other fields remain.

	merger_reduce.pl

		Perform merge ordering LEs per component into a single LE across all components. Uses ordering to start merge.

	statlib.pm

		Module with simple statistical functions. Used for LE summarization and to calculate 'last_ts' and 'req_ts'.

	sname_collector.pl	
		
		Variant of the script 'collector.pl' to use the caller URI as one of the fields (MR-4 - SIP side Map)
	
	name_reduce.pl	
		
		Groups name resolution records with the same UUID in order to generate a single event. (MR-3)
	
	resolv_reduce.pl	
	
		Takes both name resolution records aggregates and SIP records from 'sname_collector' and performs matching using the SIP URI and time stamps. 
		Uses the module 'resolvlib.pm' (MR-4 Reduce)
	
	resolvlib.pm 	
		
		Has method 'sel_cid_name_prox' to match SIP and name resolution records using the closest timestamp 
	
	sipname_reduce.pl	
	
		Bind sip event records to name resolution records (MR-4)

	viewer.pl
		
		Allow visualization of full LEs 
	
	viewer_sum.pl
	
		Allow visualization of summarized LEs
		
+ analyser
	Scripts to push data into ElasticSearch and to retrieve data and send it through R scripts
	*** All scripts in 'analyser' folder requires a running ElasticSearch instance. 
	*** Apache ActiveMQ should be running if mq_pusher.pl and mq_puller.pl are used.

	create_index.sh 
	
		Creates indexes for documents in ElasticSearch
		
	pusher.pl 
	
		Pushes full LEs into ElasticSearch
		
	pusher_summary.pl

		Pushes summarized LEs into ElasticSearch
		
	query_summary.sh 
	
		Retrieves summarized data from ElasticSearch
		
	summary_cfg.R

		Configuration used by anomaly detection methods over summarized data
		
	summary_anomalies.R

		Uses the configuration in 'summary_cfg.R' and a CSV file containing summarized LEs and identify anomalies. Results are HLE stored in another CSV file
	
	query_full.sh 
	
		Retrieves aggregate from full LEs from ElasticSearch
	
	agg_cfg.R 
	
		Configuration parameters for anomaly detection based on thresholds over performance counters
		
	agg_checks.R

		Uses the configuration in 'agg_cfg.R' and a CSV file containing an aggregate from full LEs to identify anomalies. Generates HLEs in CSV format. 
		
	mq_pusher.pl

		Pushes HLEs in CSV file into an Apache ActiveMQ
		
	mq_puller.pl
	
		Retrieves HLEs from Apache ActiveMQ

+bin
	Scripts to run the three phases of DataMining process: MapReduce (1-4), push results into analytical database (ElasticSearch) and run analysis on data in analytica database	
	
	env.sh  
		
		General configuration parameters.
        Includes function to test if required packages are installed.
		
	run_mr.sh

		Run MapReduce steps 1, 2, 3 and 4 in standalone mode (no need for Hadoop)

	viewer.sh
	
		Allow visualization of results from 'run_mr.sh'
		
	run_push.sh  
	
		Pushes results from 'run_mr.sh' into ElasticSearch
		
	run_analysis.sh  

		Run analysis on data stored in ElasticSearch
		
+hadoop 

	Configurations and auxiliary scripts to run MR-1 and 2 on Apache Hadoop.
    
+var
    
    Files processed and generated by the data mining prototype. Contains three subfolders:
    
    log
    
        should contain log files to be processed

    tmp
    
        temporary files generated along the process
    
    result
        
        final results
	
PRE-EXECUTION
-------------

0. All packages in the 'PREREQUISITES' section.

1. Install and Start ElasticSearch - Out of box configuration

2. Start Apache ActiveMQ - out of box configuration

3. Copy the folder 'bbk-pj' with all its contents from the CD 
    The log files should be already in the subfolder 'var/log'
	
EXECUTION
---------

== Standalone mode

1. Perform settings on 'bin/env.sh'.

    1.1. Confirm if paths to the locations for the logs, temporaries and results are properly set.
    
        export BASE=/home/user/bbk-pj/var # base for data files
        export SOURCE=$BASE/log # source files (logs)
        export TEMP=$BASE/tmp # temporary files
        export DEST=$BASE/result # final result
	
	1.2. Confirm if full path to the name resolution log file is properly set
        
        export NAMELOGS=$SOURCE/name_resolver.log
    
	1.3. ElasticSearch configurations should be set: server, port and index name. For tests, it is recommendable have ElasticSearch running locally.
    
        export ELASTIC_SRV=localhost    # local host
        export ELASTIC_PORT=9200        # default port
        export ELASTIC_INDEX=telco      # default index

	1.4. Apache ActiveMQ configurations should be set. Also, for tests, it is recommendable to run ActiveMQ locally.

        export MQ_SRV=localhost
        export MQ_PORT=61613        # default port
        export MQ_USER=admin        # default user
        export MQ_PASS=admin        # default password

2. Run 'run_mr.sh' to start all MR processes in standalone mode.
    It stores the lists of events (LEs) serialized in JSON format in $DEST (var/result) as 'full_le.dmp'

3. Run 'viewer.sh' to check results. It allows the user to browse the LEs generated both in full and summary formats.

4. Run 'run_push.sh' to push all results from 'run_mr.sh' into ElasticSearch

5. Run 'run_analysis.sh' to run the analysis. It stores results in DEST location as 
	a_agg.csv - anomalies (HLEs) detected by checking performance counters
	a_summary.csv - anomalies (HLEs) detected by checking patterns in summarized LEs.

6. Run 'run_analysis.sh Q' to run the analysis and send the HLEs to the ActiveMQ queue. The default name for the queue is 'HLE'

7. Run 'pull.sh' to retrieve all the contents from the 'HLE' ActiveMQ queue. 
    
== HADOOP mode 

	Requires manual deployment of Hadoop 2.3.0
	Configurations used in the tests are stored in hadoop/etc/hadoop
	Please follow notes.txt
    
TESTS
-----

Unit tests have been developed for the Sip Parsing, Sip Ordering, Name matching and Summary functions.

	colmat/ordererlib_sip.t  
		test SIP parsing and ordering per component class
	
	colmat/ordererlib.t  
		test SIP ordering across all component classes

	colmat/resolvlib.t  
		test matching name resolution event records to SIP event records

	colmat/statlib.t
		test basic statistics for summarization
		
	run_tests.sh
		run all tests

        
EXTRA
-----

Installing R on Debian Wheezy

    IMPORTANT: Do not use the R from the default Debian 'apt' repository (2.1.5).
    
    Remove old one (2.1.5), if installed.
        sudo apt-get purge r-base*
	
	On  /etc/apt/sources.list, include:
		deb http://cran.ma.imperial.ac.uk/bin/linux/debian wheezy-cran3/
		
    Execute
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 06F90DE5381BA480
        sudo aptitude update
        sudo apt-get install r-base
    
    Start R and install package "plyr"
        > install.packages("plyr")
