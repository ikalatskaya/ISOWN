# Dependencies for ISOWN

The following describe how to install external tools for ISOWN. 

## tabix
Download and uncompress tabix
```$
wget https://sourceforge.net/projects/samtools/files/tabix/tabix-0.2.5.tar.bz2

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

## weka (TBD)

