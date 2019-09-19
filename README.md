Using Logistic Regression to evaluate the interaction between extreme warming and climate modes
==================================================================

Logistic Regression (LR) could be used as a practical approach to examine the connection between binary variables and its potential covariates. Here is a tutorial about how to use LR to evaluate the interaction between extreme warming and climate modes using MATLAB codes.

Data description
-------------

Three major data are used in this tutorial. 1) Sea surface temperature anomalies during 1950 to 2018 from HadISST data (Titchner and Rayner, 2014). 2) Extreme warming binary index during 1950 to 2018, where 1 indicates the existence of extreme warming in corresponding grid and 0 otherwise. 3) Climate mode index, including MEI, AMO, PDO ,NPGO, and SAM.

Model description
-------------

The governing equation of the LR used here is:

<a href="https://www.codecogs.com/eqnedit.php?latex=ln(\frac{p}{1-p})=b_0&plus;b_1&space;\Delta&space;T&plus;b_2&space;MEI&plus;b_3&space;AMO&plus;b_4&space;PDO&plus;b_5&space;NPGO&plus;b_6&space;SAM" target="_blank"><img src="https://latex.codecogs.com/gif.latex?ln(\frac{p}{1-p})=b_0&plus;b_1&space;\Delta&space;T&plus;b_2&space;MEI&plus;b_3&space;AMO&plus;b_4&space;PDO&plus;b_5&space;NPGO&plus;b_6&space;SAM" title="ln(\frac{p}{1-p})=b_0+b_1 \Delta T+b_2 MEI+b_3 AMO+b_4 PDO+b_5 NPGO+b_6 SAM" /></a>

Where `p` is the probability of the existence for extreme warming, <a href="https://www.codecogs.com/eqnedit.php?latex=\Delta&space;T" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\Delta&space;T" title="\Delta T" /></a> is the change of the SST with respect to previous time step, MEI, AMO, PDO, NPGO, and SAM are corresponding climate mode indexes. 

This equation could be transfered to:

<a href="https://www.codecogs.com/eqnedit.php?latex=\frac{p}{1-p}={exp}^{b_0&space;&plus;&space;b_1&space;\Delta&space;T&space;&plus;&space;b_2&space;MEI&space;&plus;&space;b_3&space;AMO&space;&plus;&space;b_4&space;PDO&space;&plus;&space;b_5&space;NPGO&space;&plus;&space;b_6&space;SAM}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\frac{p}{1-p}={exp}^{b_0&space;&plus;&space;b_1&space;\Delta&space;T&space;&plus;&space;b_2&space;MEI&space;&plus;&space;b_3&space;AMO&space;&plus;&space;b_4&space;PDO&space;&plus;&space;b_5&space;NPGO&space;&plus;&space;b_6&space;SAM}" title="\frac{p}{1-p}={exp}^{b_0 + b_1 \Delta T + b_2 MEI + b_3 AMO + b_4 PDO + b_5 NPGO + b_6 SAM}" /></a>

When covariates (<a href="https://www.codecogs.com/eqnedit.php?latex=\Delta&space;T" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\Delta&space;T" title="\Delta T" /></a>, `MEI`, `AMO`, `PDO` and `NPGO`) increase 1 unit, the probability of extreme warming with respect to no extreme warming (<a href="https://www.codecogs.com/eqnedit.php?latex=\frac{p}{1-p}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\frac{p}{1-p}" title="\frac{p}{1-p}" /></a>) would increase to <a href="https://www.codecogs.com/eqnedit.php?latex=\frac{p}{1-p}&space;{exp}^{b_i}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\frac{p}{1-p}&space;{exp}^{b_i}" title="\frac{p}{1-p} {exp}^{b_i}" /></a>.

Step - by - Step Code
-------------

Firstly, we need to load the corresponding data. Firstly we load the SST anomalies. Since github does not allow too large dataset, I have to separate the whole data into files in every year. So we need to reconstruct them here.

```
%% Loading data
% SST anomalies
sst_anom=NaN(360,180,828);
for i=1950:2018
    data_here=['sst_anom_' num2str(i)];
    load(data_here);
    sst_anom(:,:,(1:12)+(i-1950)*12)=sst_here;
end
```



