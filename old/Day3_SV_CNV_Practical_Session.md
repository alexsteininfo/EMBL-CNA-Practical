# **Variant calling: CNVs & SVs 2025**

## 

## Practical session 

Maxime Tarabichi


# 

# Copy-number calling {#copy-number-calling}

## Introduction {#introduction}

For this part of the session, we will run ASCAT on a series of tumor-normal samples, as well as a tumour sample only.

ASCAT is fast, accurate and versatile, as it can run on different platforms. However, if running on whole-genome sequencing data (typically at depth \>30X), [Battenberg](https://github.com/Wedge-lab/battenberg) is a resource-intensive, accurate and much more powerful tool for allele-specific copy-number calling, as it can also call subclonal events through statistical phasing of nearby SNPs and has been designed to work on multi-region profiling, as well as with external phasing information such as obtained through long-read sequencing.

That said, [Battenberg](https://github.com/Wedge-lab/battenberg) and other copy-number calling tools are all built around the same rationale as ASCAT, thus, understanding ASCAT is a large step towards understanding (allele-specific) copy-number calling in general, as well as Battenberg and other tools.

Here, to gain insight on the effect of noise in the data practically, we will also run ASCAT on two types of artificially “bad data”: 1\) after incrementally adding noise to the data (noise is the main factor of quality of the profiles); 2\) after purposely matching a tumour and normal from different patients, as this happens more often than one would think and needs to be identified early on.

## Installation {#installation}

R, ASCAT and dependencies have already been installed on the virtual machine for you. 

However, should you run this in your home environment, you likely will have to install those yourself. Therefore, go to the [ASCAT github page](https://github.com/VanLoo-lab/ascat), where you can find the installation instructions in the README file.

## 

## Data	 {#data}

The data on which we will run ASCAT are the example data from the github page. They have been simulated such that users can test the tool and investigate their format.

In practice, you will start with a BAM file and will need to run a tool to extract these input files. This tool first uses an external software to count the number of reads carrying each genotype (A, C, G, T) at known SNP positions. 

For ASCAT, this software is called [alleleCount](https://github.com/cancerit/alleleCount), and the SNP positions are from the 1000 Genomes Project, pre-formatted for hg19 and hg38 [here](https://github.com/VanLoo-lab/ascat/tree/master/ReferenceFiles/WGS). 

Then an R script extract the read counts at the reference (Cr) and alternate (Ca) genotypes, respectively, and computes 

*BAF\_Tumour \= Ca/(Cr\+Ca)* in the tumour file;

*BAF\_Normal \= Ca/(Cr\+Ca)* in the normal file;

*LogR\_Tumour \= log2( Cr\+Ca / mean(Cr\+Ca) )* in the tumour file; 

*LogR\_Normal \= log2( Cr\+Ca / mean(Cr+Ca) )* in the normal file;

*LogR \= LogR\_Tumour \- LogR\_Normal*.

## Preparing LogR/BAF data from a BAM yourself {#preparing-logr/baf-data-from-a-bam-yourself}

Please see examples here:  
[https://github.com/VanLoo-lab/ascat/tree/master/ExampleData](https://github.com/VanLoo-lab/ascat/tree/master/ExampleData) 

Under section “*Processing targeted sequencing data*”

## 

## Step-by-step running of the pipeline {#step-by-step-running-of-the-pipeline}

You will have to move to the folder where the data sits or change the paths to the input files.

Below is a step-by-step run through the example code from the github page with some questions attached to each line. Try and go through each point and answer the questions:

### 0- Launch R in an interactive session {#0--launch-r-in-an-interactive-session}

To launch R: just type ‘R’ in a terminal.

Run the code line by line and have a look at the objects created in memory and on disk. Try to answer the questions attached to each line in italic.

Which version of R are you running? Hint: try “sessionInfo()”.

### 1- Load library {#1--load-library}

| library(ASCAT) |
| :---- |

Which version of ASCAT are you running?  
Which dependencies are loaded with ASCAT?

Copy the data from the internet to your home folder.

R: 

| dir.create("/home/training/day3")setwd("/home/training/day3") system("git clone https://github.com/VanLoo-lab/ascat.git")system("cp \-r ascat/ExampleData /home/training/day3") |
| :---- |

Terminal: 

| mkdir /home/training/day3git clone https://github.com/VanLoo-lab/ascat.gitcp \-r ascat/ExampleData /home/training/day3 |
| :---- |

### 2- Load data in ASCAT object  {#2--load-data-in-ascat-object}

If possible try to provide the full paths to those input files.

| setwd("/home/training/day3/ExampleData")library(ASCAT)ascat.bc \= ascat.loadData(Tumor\_LogR\_file \= "Tumor\_LogR.txt", Tumor\_BAF\_file \= "Tumor\_BAF.txt", Germline\_LogR\_file \= "Germline\_LogR.txt", Germline\_BAF\_file \= "Germline\_BAF.txt", gender \= rep('XX',100), genomeVersion \= "hg19")  |
| :---- |

Look inside the object the function “str”: str(ascat.bc)

What does each input parameter represent?   
Are samples males or females?   
How many SNPs are there in those data?   
How many SNPs would ASCAT use for whole-genome sequencing?

### 3- Plot the raw data {#3--plot-the-raw-data}

| ascat.plotRawData(ascat.bc, img.prefix \= "Before\_correction\_") |
| :---- |

Have a look at the output png files and try to interpret each sub-figure.

### 4- Correct for logR and plot the data again {#4--correct-for-logr-and-plot-the-data-again}

| ascat.bc \= ascat.correctLogR(ascat.bc, GCcontentfile \= "GC\_example.txt", replictimingfile \= "RT\_example.txt")ascat.plotRawData(ascat.bc, img.prefix \= "After\_correction\_") |
| :---- |

Look at the output again and compare before and after the correction.   
What can you say about the GC (GC% sequence) and RT effects (replication timing) in those samples?

### 5- Run segmentation step and plot results {#5--run-segmentation-step-and-plot-results}

| ascat.bc \= ascat.aspcf(ascat.bc) \# penalty=25 for targeted sequencing dataascat.plotSegmentedData(ascat.bc) |
| :---- |

Scroll through a few samples and compare their profiles. Do they look similar, different? How different?  
Can you identify problematic samples and point out their problems?   
How would you solve them?  
If you cannot identify bad fits \- answer again after point 8\.

**BONUS:** rerun with a (drastically) different penalty and compare the results.

| ascat.bc.high.penalty \= ascat.aspcf(ascat.bc, penalty=700, out.prefix="penalty.high")ascat.plotSegmentedData(ascat.bc.high.penalty, img.prefix="penalty.high") |
| :---- |

### 6- Run the ploidy/purity fitting and derive the genomewide allele-specific copy-number profiles with ASCAT {#6--run-the-ploidy/purity-fitting-and-derive-the-genomewide-allele-specific-copy-number-profiles-with-ascat}

| ascat.output \= ascat.runAscat(ascat.bc, write\_segments \= T) \# gamma=1 for HTS data |
| :---- |

Explore the output R object “ascat.output” and look in the files written to disk. What do they represent?

**BONUS:** rerun with a (drastically) different penalty and compare the results; make sure to give a different “img.prefix” value to the function not to overwrite the previous outputs.

### 7- Note the GAMMA parameter default value; run with gamma \= 1 and compare the results. {#7--note-the-gamma-parameter-default-value;-run-with-gamma-=-1-and-compare-the-results.}

| ascat.output2 \= ascat.runAscat(ascat.bc, gamma=1, img.prefix="g1", write\_segments \= T) \# gamma=1 for HTS data |
| :---- |

What is the gamma parameter?   
What gamma parameter should one use for sequencing data?  
Here, which gamma value leads to better fits and how can you tell?   
What can you conclude from the previous answer about these data?

### 8- Derive cohort quality and biological metrics {#8--derive-cohort-quality-and-biological-metrics}

| QC \= ascat.metrics(ascat.bc,ascat.output) |
| :---- |

What format has the QC object? Did the function print anything to disk?

Print the QC data.frame to disk (e.g. using the R function write.table).

Important metrics: mapd and fraction of genome with homozygous deletion

### 9- Save results as R objects  {#9--save-results-as-r-objects}

| save(ascat.bc, ascat.output, QC, file \= 'ASCAT\_objects.Rdata') |
| :---- |

Make sure to save the R objects \- these can be reused for reruns and future troubleshooting.

### 10- Bonus **advanced** \- test the limits of ASCAT after adding noise  {#10--bonus-advanced---test-the-limits-of-ascat-after-adding-noise}

Copy-paste the input files on disk and remove all but one sample from them.

Load the data.frame in memory and add 5 columns to each input file: for the BAF of tumour/normal, and for the LogR of the normal simply copy-paste the same data as for your original sample; for the LogR of the tumour, add 5 columns corresponding to the **same vector \+ Gaussian noise** with increasing noise levels (use the R function *rnorm* where you can tune the standard deviation).

Run ASCAT on your input files and compare the results with increasing levels of noise in the LogR track.

Can you imagine an experiment to assess when the fitting starts to break?   
Run that experiment.  
What happens to the fit when they “break”?  
Is ASCAT robust to noise in the LogR?  
Which is more susceptible to noise, BAF or LogR?   
Why?

### 11- Bonus **advanced** \- Refit profiles {#11--bonus-advanced---refit-profiles}

Look at the profile of Sample S63. Do you believe this is a good solution? Why?

Try and refit this profile using a different set of purity and ploidy boundaries (you can provide these as arguments to the runAscat function) to better match what you believe should be the profile.

Look at the new profile and compare the inferred ploidy values.  
Which one do you think is better?   
How to make sure which one is correct?

### 12- Bonus **advanced** \-Run ASCAT in “tumour-only” mode {#12--bonus-advanced--run-ascat-in-“tumour-only”-mode}

Use the predictGermline function to run on a tumour sample without patient-matched normal sample.

| PENALTY\<-70 gg \<- ascat.predictGermlineGenotypes(ascat.bc, platform \= "AffySNP6")ascat.bc \<- ascat.aspcf(ascat.bc, ascat.gg=gg, penalty \= PENALTY, out.prefix \= "tumour-only")ascat.plot \<- ascat.plotSegmentedData(ascat.bc, img.prefix \= "tumour-only")ascat.output \<- ascat.runAscat(ascat.bc, img.prefix \= "tumour-only") |
| :---- |

Compare the results with and without normal samples. Are there noticeable differences?

Look at a high purity sample with loss-of-heterozygosity (e.g. S80). 

Can you see what is happening? How could this be solved?

## Copy-number calling in single cell data {#copy-number-calling-in-single-cell-data}

### Data {#data-1}

We will run [ASCAT.sc](http://ASCAT.sc) on a subset of 100 BAM files from this recent Cell paper. We have processed the BAM of one of the chips, phased the SNPs and generated read counts at SNP positions for each of the BAM.

### [ASCAT.sc](http://ASCAT.sc) run {#ascat.sc-run}

| \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# setwd("/media/penelopeCloud/Day3\_CNV\_SV")bams \= dir("first100\_bams",pattern="bam\$",full=T)acdir \="allelecounts\_matching\_100/allelecountsallele\_count/"phasedir="beagle/"\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#ac \= lapply(gsub(".markdup.bam","",basename(bams)), function(x){    paste0(acdir,"allelecount\_",x,"\_chr",c(1:22),".txt")})\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#path\_to\_phases \<- list(    paste0(phasedir,"merged\_chr",c(1:22),"\_beagleoutput.vcf.gz"))\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#sapply(path\_to\_phases,file.exists)\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#outdir \= "outputs/"dir.create(outdir) \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# |
| :---- |

Take the example code from the Wiki [here](https://github.com/VanLoo-lab/ASCAT.sc/wiki/run_sc_sequencing), and parametrise it to run on our data:

| res \<- run\_sc\_sequencing(tumour\_bams=bams,                         allchr=paste0("chr",c(1:22)),                         sex=rep("female",length(bams)),                         binsize=500000,                         chrstring\_bam="chr",                         purs \= seq(0.99, 1, 0.001),                         ploidies \= seq(1.7,5, 0.01),                         maxtumourpsi=5,                         build="hg38",                         MC.CORES=1,                         outdir=outdir,                         projectname="test\_ebi\_course",                         segmentation\_alpha=1/3,                         path\_to\_phases=path\_to\_phases,                         list\_ac\_counts\_paths=ac,                         multipcf=TRUE) |
| :---- |

What does each parameter mean?

Once it ran through, you can plot all the single-cell allele-specific profiles and save them to disk, with the following command:

| pdf(paste0(outdir,"/all\_as\_cna\_profiles\_test\_ebi\_course.pdf"),width=15,height=5)tnull \<- lapply(1:length(res\$allProfiles\_AS), function(x){    try({        plot\_AS\_profile(res\$allProfiles\_AS\[\[x\]\]\$nprof.fixed)        title(paste0(names(res\$allTracks)\[x\]," \- bam",x) ,cex=.5)    })    write.table(res\$allProfiles\_AS\[\[x\]\]\$nprof.fixed,                    sep="\\t",col.names=T,row.names=F,quote=F,                    file=paste0(outdir,"/as\_cna\_profile\_",names(res\$allTracks)\[x\],"\_bam",x,".txt"))})dev.off() |
| :---- |

Have a look at the profiles and note commonalities and differences.

# Structural variant calling {#structural-variant-calling}

## Introduction {#introduction-1}

For this part of the session we will run GRIDSS2, a tool using split reads, spanning reads and assembly to call structural variants, as well as to call single break-end (e.g. where the other break-end ends up in non-mappable regions such as centromeres).

We will run GRIDSS2 on one of our BAM files to test its compute requirements. 

## Installation {#installation-1}

The software has been installed for you from github and comes with a few dependencies ([https://github.com/PapenfussLab/gridss\#pre-requisites](https://github.com/PapenfussLab/gridss#pre-requisites)).

## Running gridss on one of our BAM files {#running-gridss-on-one-of-our-bam-files}

| /home/training/gridss/gridss \--jvmheap 10g \-j /home/training/gridss/gridss-2.13.2-gridss-jar-with-dependencies.jar \-r /home/training/Documents/SRS\_bwa\_bam\_files/chr3.fa \-o output.vcf /home/training/Documents/SRS\_bwa\_bam\_files/ERR2304566\_3q29\_1M\_final.bam |
| :---- |

## SRS *vs.* LRS in a Chinese Han genome around *TP53* {#srs-vs.-lrs-in-a-chinese-han-genome-around-tp53}

### Generating downsampled BAM files for 1kPG around *TP53*

miniBAM files have been generated for you:

| TP53\_REGION="chr17:7661779-7687550" REGION="chr17:6661779-8687550"   \#±1,000,000 bp on either sidesamtools view \-@8 \-h \-C \-o HG00513.tp53.cram HG00513.final.cram "\${REGION}"samtools index HG00513.tp53.cram |
| :---- |

### Visualise SVs in this region

Load the two BAM files in the directory for Day3 in IGV  
Load the structural variant VCF  
Walk through the region to find SVs and visualise them in short vs. long reads.

