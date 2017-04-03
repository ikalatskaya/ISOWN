# Dependencies for ISOWN

The following describe how to install external tools for ISOWN. 

## tabix
Download and uncompress tabix
```$
wget https://sourceforge.net/projects/samtools/files/tabix/tabix-0.2.5.tar.bz2 --no-check-certificate

tar xvjf tabix-0.2.5.tar.bz2
```

Compile tabix 
```$
cd tabix-0.2.5

make 
```
Once compiled, add tabix to PATH ( where _path_to_tabix_ is the folder directory where tabix is installed ).
```$
export PATH=$PATH:/path_to_tabix/tabix-0.2.5
```

## weka 
Download weka and uncompress it
```$
wget https://sourceforge.net/projects/weka/files/weka-3-6/3.6.13/weka-3-6-13.zip

unzip weka-3-6-13.zip
```
Copy weka.jar into bin ${ISOWN_HOME}/bin
```$
cp weka-3-6-13/weka.jar  ${ISOWN_HOME}/bin
```

## ANNOVAR
Download ANNOVAR from http://annovar.openbioinformatics.org/en/latest/user-guide/download/ and uncompress it.  Note: ANNOVAR requires user registration.
```$
tar xvf annovar.latest.tar.gz
```
Add ANNOVAR to PATH 
```$
export PATH=$PATH:/path_to_annovar
```

## Check dependencies
Run the following command to check to make sure all dependencies are installed:
```$
perl ${ISOWN_HOME}/bin/check_dependencies.pl 
```
