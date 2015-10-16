# CLEF Test Collections

Developers of each system were invited to create scripts that would index and search across [CLEF](http://www.clef-initiative.eu). The table below summarizes the main details about the CLEF collections in 12 different European and non-European languages, considered in the experiments; all the data can be freely downloaded by means of the [DIRECT](http://direct.dei.unipd.it/) system.


## Test Collections

Language   	| Corpora           							  		|  Encoding   								| # docs | # topics	|
:-----------|:------------------------------------------------------|:------------------------------------------|-------:| --------:|
Bulgarian  	| SEGA2002 <br /> STANDART2002 							| UTF-8										| 69195  | 	149    	|
German     	| FRANKFURTER1994 <br /> SDA1994 <br /> SPIEGEL1994 <br /> SPIEGEL1995  	| ISO-8859-1			| 225371 |	155  	|
Spanish    	| EFE1994 <br /> EFE1995						  		| ISO-8859-1								| 454045 |	97   	|
Persian	   	| HAMSHAHRI		 								  		| UTF-8										| 166774 |	100	 	|
Finnish	   	| AAMULEHTI1994 <br /> AAMULEHTI1995			  		| ISO-8859-1								| 55344	 | 	120	 	|        
French	   	| LEMONDE1994 <br /> LEMONDE1995 <br /> ATS1994 <br /> ATS1995	| ISO-8859-1						| 177452 |	99 	 	|	
Hungarian  	| MAGYAR2002									  		| UTF-8										| 49530  |  148	 	|
Italian	   	| AGZ1994<br /> AGZ1995 <br /> LASTAMPA1994 			| ISO-8859-1(AGZ) <br /> US-ASCII(LASTAMPA)	| 157558 |  90	 	|
Dutch	   	| ALGEMEEN1994 <br /> ALGEMEEN1995 <br /> NRC1994 <br /> NRC1995	| ISO-8859-1					| 190604 |	156     |
Portuguese 	| FOLHA1994 <br /> FOLHA1995 <br /> PUBLICO1994 <br /> PUBLICO1995  | ISO-8859-1					| 210734 |	100	    |	
Russian		| IZVESTIA1995									  		| UTF-8										| 16716  |	62	    |
Swedish		| TT1994 <br /> TT1995							  		| UTF-8										| 142819 |	103	    |

### Topic Sets

Language   	| Topic Set 		| Topid IDs  												| Topic file        |  					  		
:-----------|------------------:| :---------------------------------------------------------|:-----------------|
Bulgarian  	| AH Mono BG		| 251-291	293-325;	351-375; <br /> 401-450 			| bg_topics.xml 	|
German     	| AH Mono DE		| 41-43; 45-143; 145; 147-169; <br /> 171-190; 192-200		| de_topics.xml 	|
Spanish    	| AH Mono ES		| 41-49; 60; 62-69; 80-99; <br /> 110-119; 130-149; 160-168; <br /> 170-179; 190-200 | es_topics.xml 	|
Persian	   	| AH Mono FA		| 551-650													| fa_topics.xml 	|
Finnish	   	| AH Mono FI 		| 92; 94-95; 98; 100; 102-103; <br /> 105-107; 109; 111; 114-116; <br /> 118-119; 122-126; 128; 130-132; <br /> 137-140; 142-143; 147-159; <br /> 161-166; 168; 170-174; 176-181; <br /> 183-185; 187; 190; 192-193; <br /> 196-205; 207-230; 232-239;<br /> 241-246; 248-250;   																							 | fi_topics.xml 	|
French	   	| AH Mono FR 		| 251-331; 333-350											| fr_topics.xml 	|
Hungarian  	| AH Mono HU 		| 251-325; 351-369; 371-375; <br /> 401-450					| hu_topics.xml 	|
Italian	   	| AH Mono IT 		| 41-42; 44-49; 60-63;  65-69; <br /> 80-99;  110-119; 130-145; <br /> 147-149; 161-168; 171; 173-174; <br /> 176-179; 190; 192-200 									| it_topics.xml 	|
Dutch	   	| AH Mono NL 		| 41-159; 161-165; 167-190; <br /> 192-193; 195-200															| nl_topics.xml 	|
Portuguese 	| AH Mono PT 		| 251-350													| pt_topics.xml 	|
Russian		| AH Mono RU		| 143; 147-149; 151; 153-155; 157; <br /> 163-164; 168-169; 172; 176-181; <br /> 183; 187; 192-193; 197-203; 207;  <br /> 209-216; 218; 220-221; 224-228;  <br /> 230-235; 237-239; 241-242;  <br /> 244-245; 250     | ru_topics.xml 	  |	
Swedish		| AH Mono SV 		| 91-109; 111-159; 161-166; <br /> 168-190; 192-193; 195-197; <br /> 199-200															| sv_topics.xml 	|

# Retrieval Effectiveness

For the CLEF collections there were 3 systems together with their required scripts: Indri, Lucene, Terrier; in the case of Terrier different retrieval models (BM25, Hiemstra LM, PL2, and TFIDF) were experimented in conjunction with different configurations for [stop lists](http://members.unine.ch/jacques.savoy/clef/index.html) and [stemmers](https://github.com/snowballstem). All the details about the experiments (MAP@1000 calculated by *trec_eval* are reported in the tables below.


System  | Model 	   | Stop  | Stem  | bg      | de      | es      | fa      | fi      | fr      |
:-------|:-------------|:------|:------|:--------|:--------|:--------|:--------|:--------|:--------|
Terrier | BM25         |   	   |       | 0.2092  | 0.2733  | 0.3627  | 0.4033  | 0.3464	 | --	   |
Terrier | BM25		   | ✔ 	   |	   | 0.2081  | 0.2742  | 0.3656  | 0.4022  | 0.3392	 | --	   |
Terrier | BM25		   |	   | ✔	   | -- 	 | 0.3194  | 0.4347  | -- 	   | 0.4339	 | --	   |
Terrier | BM25		   | ✔	   | ✔     | --      | 0.3215  | 0.4356  | --      | 0.4278	 | --	   |
Terrier | Hiemstra LM  |       |	   | 0.1647	 | 0.2520  | 0.3016  | 0.3140  | 0.3125	 | --	   |
Terrier | Hiemstra LM  | ✔	   | 	   | 0.1640	 | 0.2561  | 0.3081  | 0.3193  | 0.3156	 | --      |
Terrier | Hiemstra LM  |       | ✔	   | -- 	 | 0.2753  | 0.3673  | -- 	   | 0.3639	 | --	   |
Terrier | Hiemstra LM  | ✔	   | ✔	   | -- 	 | 0.2801  | 0.3783  | -- 	   | 0.3636	 | --	   |
Terrier | PL2		   | 	   |	   | 0.2043	 | 0.2625  | 0.3486  | 0.4081  | 0.3316	 | --	   |
Terrier | PL2		   | ✔	   | 	   | 0.2009	 | 0.2658  | 0.3572  | 0.4061  | 0.3388	 | --      |
Terrier | PL2		   |	   | ✔	   | --      | 0.3080  | 0.4168  | -- 	   | 0.4222	 | --	   |
Terrier | PL2		   | ✔     | ✔     | --	     | 0.3102  | 0.4211  | -- 	   | 0.4152  | --	   |
Terrier | TFIDF		   | 	   |	   | 0.2071	 | 0.2709  | 0.3597  | 0.4050  | 0.3457  | --	   |
Terrier | TFIDF		   | ✔	   | 	   | 0.2083	 | 0.2723  | 0.3658  | 0.4053  | 0.3393	 | --	   |
Terrier | TFIDF		   |	   | ✔	   | -- 	 | 0.3185  | 0.4313  | -- 	   | 0.4354  | --	   |
Terrier | TFIDF		   | ✔	   | ✔	   | --		 | 0.3167  | 0.4355  | -- 	   | 0.4269	 | --	   |
Lucene	| BM25   	   | ✔     | ✔	   | --	     | 0.3126  | 0.4251	 | 0.4158  | -- 	 | 0.3865  |
Indri	| LM Dirichlet | ✔	   | ✔	   | 0.2051  | 0.1365  | 0.3334	 | 0.3735  | --		 | 0.1444  |


System  | Model 	   | Stop  | Stem  | hu      | it      | nl      | pt      | ru      | sv      |
:-------|:-------------|:------|:------|:--------|:--------|:--------|:--------|:--------|:--------|
Terrier | BM25		   | 	   |	   | 0.2115  | 0.3233  | 0.3958	 | 0.3250  | 0.3666	 | 0.3384  |
Terrier | BM25		   | ✔     | 	   | 0.2178	 | 0.3182  | 0.3974	 | 0.3255  | 0.3449	 | 0.3371  |
Terrier | BM25		   |	   | ✔     | 0.3175	 | 0.3619  | 0.4209  | 0.3250  | 0.4740	 | 0.3817  |
Terrier | BM25		   | ✔     | ✔	   | 0.3254  | 0.3591  | 0.4234  | 0.3255  | 0.4753	 | 0.3886  |
Terrier | Hiemstra LM  | 	   |	   | 0.1642	 | 0.2778  | 0.3454  | 0.2738  | 0.2922	 | 0.3113  |
Terrier | Hiemstra LM  | ✔	   | 	   | 0.1685	 | 0.2820  | 0.3523	 | 0.2742  | 0.2949	 | 0.3160  |
Terrier | Hiemstra LM  |	   | ✔	   | 0.2559  | 0.3061  | 0.3585	 | 0.2738  | 0.3891	 | 0.3372  |
Terrier | Hiemstra LM  | ✔	   | ✔     | 0.2656  | 0.3092  | 0.3680  | 0.2742  | 0.3960	 | 0.3402  |
Terrier | PL2		   | 	   |	   | 0.2060  | 0.3110  | 0.3792  | 0.3183  | 0.3433	 | 0.3149  |
Terrier | PL2		   | ✔     | 	   | 0.2091	 | 0.3090  | 0.3832	 | 0.3184  | 0.3288	 | 0.3222  |
Terrier | PL2		   |	   | ✔	   | 0.3040  | 0.3521  | 0.4042  | 0.3183  | 0.4737	 | 0.3604  |
Terrier | PL2		   | ✔	   | ✔	   | 0.3179	 | 0.3472  | 0.4088	 | 0.3184  | 0.4711	 | 0.3708  |
Terrier | TFIDF		   | 	   |	   | 0.2107  | 0.3238  | 0.3946  | 0.3230  | 0.3643  | 0.3344  |
Terrier | TFIDF		   | ✔	   | 	   | 0.2181  | 0.3205  | 0.3975  | 0.3258  | 0.3403	 | 0.3354  |
Terrier | TFIDF		   |	   | ✔	   | 0.3105  | 0.3675  | 0.4222  | 0.3230  | 0.4764  | 0.3789  |
Terrier | TFIDF		   | ✔	   | ✔	   | 0.3252  | 0.3649  | 0.4253  | 0.3258  | 0.4647  | 0.3869  |
Lucene	| BM25		   | ✔	   | ✔	   | 0.3233  | 0.3486  | 0.4172  | --	   | 0.4717  | 0.3775  |
Indri	| LM Dirichlet | ✔	   | ✔	   | 0.2381  | 0.0984  | 0.2486  | --	   | 0.2991  | 0.3265  |


You can find runs and *trec_eval* results at: 

* [Terrier results](https://github.com/mmaistro/IR-Reproducibility/tree/mmaistro)

* [Lucene results](https://github.com/dibuccio/IR-Reproducibility)

* [Indri results](https://github.com/gmdn/IR-reproducibiliy-grium)

## Credits

* [CLEF Initiative](http://www.clef-initiative.eu)

* [Information Management Systems Research Group](http://ims.dei.unipd.it), University of Padua