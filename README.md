# ISOWN ( Identification of SOmatic mutations Without Normal tissues)

Irina Kalatskaya & Quang Trinh
ikalats@gmail.com

### INTRODUCTION

ISOWN is a supervised machine learning algorithm for predicting somatic mutations from tumor only samples.  

### DEPENDENCIES
The following dependencies are needed to run ISOWN:
* Java 1.8 ( at least 4GB of RAM is needed )
* Perl 
* Tabix
* Weka ( http://www.cs.waikato.ac.nz/ml/weka/downloading.html )

Make sure these are installed and their executables are included in your PATH. Instructions on how to these dependencies are [here](DEPENDENCIES.md)

### EXTERNAL DATABASES
The following external databases are required - the numbers in brackets are the versions tested and used and in the publication.  These external databases must be stored in 'external_databases' directory.
* COSMIC (v69)
* dbSNP (v142)
* ExAC (release 2)
* PolyPhen WHESS (released in 2015)
* Mutation Assessor (released in 2013)  

### VCF file format:
* Chromosome names should be preceded with "chr". for example, chr1.
* FORMAT string must contain DP (total read depth) and AD (allelic depths) attributes.
* If validating ISOWN using VCF files from tumor/normal pairs, then the order of the FORMAT column must be tumor followed by normal 

Some variant callers used ‘TUMOR’ or ‘NORMAL’ as actual sample names in the VCF files so to accommodate VCF files from as many variant callers as possible, ISOWN uses VCF file names as sample names instead.    


### VCF files preprocessing:

We recommend the following pre-processing of VCF files before running ISOWN predictions:
* Remove all variants that are not passed filters.
* Remove all homozygous variants.
* Remove all variants with random or unknown chromosomes and only retain variants with chromosomes 1 to 23, X and Y;
* Remove all variants with “N” in either reference or alternative column.
* Remove all variants with less than 10x coverage for whole exome sequencing or less than 50x coverage for targeted sequencing.
 
### INSTALLATION INSTRUCTIONS:
ISOWN is designed to be a stand alone command line application.  Unfortunately, we can not make some external databases included with ISOWN distribution due to licensing or agreements required by the data providers - for example COSMIC VCF database.  Below are instructions on where and how to download and index external databases to be used with ISOWN.  

Go to a directory where ISOWN will be stored.  Clone ISOWN from GitHub and then set ISOWN environment variable to point to where ISWON is
```s
git clone https://github.com/ikalatskaya/ISOWN

cd ISOWN

ISOWN_HOME=`pwd`
```

Check to make sure you have all the external dependencies before running ISOWN:
```$
perl ${ISOWN_HOME}/bin/check_dependencies.pl 
```

#### Format and index databases needed to run ISOWN

These following steps are only needed to be done once or only when a new database is available.  Each database must be converted and indexed with tabix ( http://www.htslib.org/doc/tabix.html ).  

Download both COSMIC CosmicCodingMuts.vcf.gz and CosmicNonCodingVariants.vcf.gz files from http://cancer.sanger.ac.uk/cosmic/download.
An account is needed to download COSMIC VCF files - see https://cancer.sanger.ac.uk/cosmic/register.  Once downloaded, run the following script to combine coding and non-coding VCF files into a single file, re-format the newly created file, and index it with tabix: 

```s
perl ${ISOWN_HOME}/bin/cosmic_format_index.pl  [ coding VCF.gz file ]  [ non-coding VCF.gz file ] [ output file ]
```
	
Download dbSNP from NCBI:

```s
wget ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606/VCF/00-All.vcf.gz --no-passive-ftp
```

Reformat and index dbSNP using the following script:

```s
perl ${ISOWN_HOME}/bin/ncbi_dbSNP_format_index.pl  00-All.vcf.gz 00-All.modified.vcf 
```

Download ExAC from Broad Institute

```s
wget ftp://ftp.broadinstitute.org/pub/ExAC_release/current/ExAC.r0.3.1.sites.vep.vcf.gz --no-passive-ftp
```

Reformat and index ExAC using the following script:

```s
perl ${ISOWN_HOME}/bin/exac_format_index.pl ExAC.r0.3.1.sites.vep.vcf.gz ExAC.r0.3.1.database.vcf
```
		
Download PolyPhen WHESS

```s
wget ftp://genetics.bwh.harvard.edu/pph2/whess/polyphen-2.2.2-whess-2011_12.tab.tar.bz2 --no-passive-ftp
```
Uncompress the downloaded tar.gz2

```s
tar jxvf polyphen-2.2.2-whess-2011_12.tab.tar.bz2
```
Reformat and index PolyPhen WHESS by using the following script:
```s
perl ${ISOWN_HOME}/bin/polyphen-whess_format_index.pl polyphen-2.2.2-whess-2011_12  PolyPhen-WHESS
```



NOTE:  this may take a few hours as PolyPhen WHESS database contained annotations for the whole human exome space.


Download Mutation Accessor from http://mutationassessor.org/

```$
wget http://mutationassessor.org/r2/MA.scores.hg19.tar.bz2 --no-passive-ftp
```

Uncompress
```s
tar xvfz MA.scores.hg19.tar.bz2
```
Reformat and index Mutation Assessor by using the following script:

```s
perl ${ISOWN_HOME}/bin/mutation-assessor_format_index_vcf.pl MA.hg19 2013_12_11_MA.vcf  
```
	
### RUNNING SOMATIC PREDICTIONS
The following steps describe how to run ISOWN.  Create a test directory in ISOWN to store out output files.

```$ 
mkdir ${ISOWN_HOME}/test; cd  ${ISOWN_HOME}/test
```

Step 1. Annotate VCF files with ANNOVAR, PolyPhen, Mutation Assessor, sequence content, dbSNP, COSMIC, and ExAC using the following script 
```$
perl ${ISOWN_HOME}/bin/database_annotation.pl [ INPUT_FILE ] [ OUTPUT_FILE ]
```

where

    INPUT_FILE is the input file in VCF format.
  
    OUTPUT_FILE is the output file in VCF format with annotations from ANNOVAR, PolyPhen, Mutation Assessor, etc.


For example, to annotate test VCF files in ${ISOWN_HOME}/test_data, do the following: 

```$
for i in `ls ${ISOWN_HOME}/test_data/*vcf`; do perl ${ISOWN_HOME}/bin/database_annotation.pl $i `basename $i` ; done
```

Step 2: Skip this step if using training data set provided.  This step describe how to generate training data sets based on user data.
If a subset of the samples have matching normals then they can be used to train ISOWN. To generate a training data set, variants in the VCF files should be annotated with either ‘SOMATIC’ or ‘GERMLINE in the INFO column. We recommend users to use only those variants that they strongly believe are true calls  to generate the training data set.  Some pre-processing such as filtering for passed filtered and some minimum read depth are necessary. To generate a training data set, run the following commands:

```$
perl ${ISOWN_HOME}/bin/generate_training_data_set.pl  [ INPUT_DIR ] [ OUTPUT_TRAINING_FILE ]
```
where

    INPUT_DIR is the directory contained the annotated VCF files
    
    OUTPUT_TRAINING_FILE is the output training file


For example, to generate a training data set file called ‘training_data.arff’  from all VCF files current directory:
```$
perl ${ISOWN_HOME}/bin/generate_training_data_set.pl ./ training_data.arff
```

Step 3: Reformat annotated VCF files into .emaf (extended MAF) and run the prediction using the following command:
```$
perl ${ISOWN_HOME}/bin/run_isown.pl [ INPUT_DIR ] [ OUTPUT_FILE ] [ ADDITIONAL_ARGUMENTS ] 
```
where

    INPUT_DIR is the absolute path of the folder that contained the annotated VCF files

    OUTPUT_FILE is the output predicted file name

    ADDITIONAL_ARGUMENTS is the string contained additional arguments to be used by classifier


For example, to reformat and run classifier in current directory with BRCA_TrainSet_100.arff data provided:
```$
perl ${ISOWN_HOME}/bin/run_isown.pl ./ test.output.txt " -trainingSet ${ISOWN_HOME}/training_data/BRCA_100_TrainSet.arff -sanityCheck false -classifier nbc"
```

where

   trainingSet PATH is the path to where the training file in ARFF format.  There are six training sets generated based on 100 randomly selected samples from BRCA, ESCA, KIRC, ESCA, COAD and UCEC that are in ${ISOWN_HOME}/training_data
   
   sanityCheck step is justified in the paper and represents a filtering of all predicted somatic mutations with sample frequency > 10%. Not applicable for single samples.  

   Classifier is by default NBC, user can change it to LADTree. Recommended for pancreatic datasets (and maybe other low mutational frequency cancer sets).


### Output file description:
Output file (FinalFile_SomaticMutations_ISOWN.txt) contains the list of the predicted somatic mutations in tab-delimited format indicating:
1. Genomic position and chromosome as well as wild type and mutation alleles; 

2. Name of the gene where this mutation was called (based on ANNOVAR annotation);

3. Type of the mutation (nonsynonymous/stopgain/splicing) based on ANNOVAR annotation; 

4. Number of samples in the provided set where this mutation was called; 

5. Whether mutation was catalogued by COSMIC_v69 or not; 

6. CNT ( number of samples with this mutation )

7. Annotation from Mutation Assessor; 

8. Amino acid change if applicable from ANNOVAR; 

8.  sample identification string 


