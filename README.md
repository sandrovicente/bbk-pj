bbk-pj
======

Birkbeck Project

Environment Required:

- Linux; or
- Mac OS X

Packages required:

-	GNU Bash 3.2.48 and gawk;
-	Perl 5 version 14.4, including the packages JSON::XS and LWP::Simple installed from CPAN;
-	curl 7.19.7
-	Sun Java JDK 1.7.0
-	ElasticSearch 1.3.1;
-	R 3.0.0, including package plyr;
-	jq JSON processor 1.3;

Structure:

- colmat 
	scripts for collection and matching
	cover all MapReduce phases (MR1, MR2, MR3 and MR4)

- analyser
	scripts to push data into ElasticSearch and to retrieve data and send it through R scripts

	*** Scripts on 'analyser' folder requires a running ElasticSearch instance.

