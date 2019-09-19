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
sst_anom=sst_anom(:,:,85:816);
```

Similarly things happen to the extreme warming index data.

```
% Extreme Warming index
ew_index=NaN(360,180,828);
for i=1950:2018
    data_here=['ew_' num2str(i)];
    load(data_here);
    ew_index(:,:,(1:12)+(i-1950)*12)=ew_here;
end
```

Also load the climate mode indexes and restrict them into the corresponding periods.

```
% Climate Modes
load('pdo_line');%1950 - 2017
pdo_line=pdo_line(85:end,:);
load('sam_line');%1957 - 2018
sam_line=sam_line(1:732,:);
load('npgo_line');%1950 - 2018
npgo_line=npgo_line(85:816,:);
load('enso_line');%1950 - 2018
enso_line=enso_line(85:816,:);
load('amo_line');%1950 - 2018
amo_line=amo_line(85:816,:);
```

Then we could fit the model. But before that, we need to calculate <a href="https://www.codecogs.com/eqnedit.php?latex=\Delta&space;T" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\Delta&space;T" title="\Delta T" /></a> 
and cut its time periods.

```
% Calculate DeltaT
dif_sst=cat(3,diff(sst_anom(:,:,1:2),1,3),diff(sst_anom,1,3));
dif_used=dif_sst(:,:,85:816);

% Restrict time period
ew_index=ew_index(:,:,85:816);
sst_anom=sst_anom(:,:,85:816);
```

Then let's fit the model.

```
x=parpool(2);
x.IdleTimeout=6000;
% Here I execute parallel computation, using 2 CPU in my local machine. If you use super computer you could use more I think.


%% Fitting the Model

coef_t_fixed=NaN(360,180,2);
coef_enso_fixed=NaN(360,180,2);
coef_amo_fixed=NaN(360,180,2);
coef_pdo_fixed=NaN(360,180,2);
coef_npgo_fixed=NaN(360,180,2);
coef_sam_fixed=NaN(360,180,2);

parfor i=1:360;
    tic
    coef_t_fixed_here=NaN(180,2);
    coef_enso_fixed_here=NaN(180,2);
    coef_amo_fixed_here=NaN(180,2);
    coef_pdo_fixed_here=NaN(180,2);
    coef_npgo_fixed_here=NaN(180,2);
    coef_sam_fixed_here=NaN(180,2);
    for j=1:180;
        fixed_here=squeeze(ew_index(i,j,:));
        
        if nansum(isnan(fixed_here))==0 && nansum(fixed_here==0)~=length(fixed_here)
            
            data_used=[squeeze(dif_used(i,j,:)) enso_line(:,end) amo_line(:,end) pdo_line(:,end) npgo_line(:,end) sam_line(:,end)];
            
           fixed_bin=(double(fixed_here~=0));
           fixed_bin_cell=cell(length(fixed_bin),1);
           fixed_bin_cell(fixed_bin==0)={'Normal'};
           fixed_bin_cell(fixed_bin~=0)={'Hot'};
           fixed_bin_cell=categorical(fixed_bin_cell);
           
           
           [B_fixed,dev_fixed,stats_fixed] = mnrfit(data_used,fixed_bin_cell);
           
           coef_t_fixed_here(j,1)=B_fixed(2);
           coef_t_fixed_here(j,2)=stats_fixed.p(2);
           coef_enso_fixed_here(j,1)=B_fixed(3);
           coef_enso_fixed_here(j,2)=stats_fixed.p(3);
           coef_amo_fixed_here(j,1)=B_fixed(4);
           coef_amo_fixed_here(j,2)=stats_fixed.p(4);
           coef_pdo_fixed_here(j,1)=B_fixed(5);
           coef_pdo_fixed_here(j,2)=stats_fixed.p(5);
           coef_npgo_fixed_here(j,1)=B_fixed(6);
           coef_npgo_fixed_here(j,2)=stats_fixed.p(6);
           coef_sam_fixed_here(j,1)=B_fixed(7);
           coef_sam_fixed_here(j,2)=stats_fixed.p(7);
           
        end
    end
    
    coef_t_fixed(i,:,:)=coef_t_fixed_here;
    coef_enso_fixed(i,:,:)=coef_enso_fixed_here;
    coef_amo_fixed(i,:,:)=coef_amo_fixed_here;
    coef_pdo_fixed(i,:,:)=coef_pdo_fixed_here;
    coef_npgo_fixed(i,:,:)=coef_npgo_fixed_here;
    coef_sam_fixed(i,:,:)=coef_sam_fixed_here;
    
    toc
end

```

The fitted coefficients and its corresponding p - value are stored in `coef_*` variabiles. The dimension 1 and 2 of `coef_*` correspond to spatial scales, while the first layer of dimension 3 corresponds to fitted coefficients and the second layer corresponds to p - value.

Then we could plot the fitted results.

```
load('lon_lat');
load('colormap_nature');

lon=double(lon);lat=double(lat);
lon(lon<0)=180+lon(lon<0)+180;
m_proj('miller','lon',[nanmin(lon) nanmax(lon)],'lat',[nanmin(lat) nanmax(lat)]);
figure('pos',[10 10 1500 1500]);
h=tight_subplot(3,2,[0.05 0.01],[0.05 0.05],[0.01 0.01]);
axes(h(1))
data_here=coef_t_fixed(:,:,1);
data_here(abs(data_here)>40)=nan;
m_contourf(lon([181:end 1:180]),lat,(data_here([181:end 1:180],:,1))',linspace(-40,40,100),'linestyle','none');
colormap(colormap_nature);
[lat_full,lon_full]=meshgrid(lat,lon);
lon_full=lon_full([181:end 1:180],:);
lat_full=lat_full([181:end 1:180],:);
p_here=coef_t_fixed([181:end 1:180],:,2);
hold on
m_scatter(lon_full(p_here<0.05),lat_full(p_here<0.05),0.08,'k');
m_coast('patch',[0 0 0]);
m_grid('xtick',[],'ytick',[]);
caxis([-10 10]);
m_text(50,-60,'a) T (F)','fontsize',16,'fontweight','bold');
s=colorbar('fontsize',12,...
    'Ticks',linspace(-10,10,5),...
         'TickLabels',round(exp(linspace(-1,1,5)),3));
s.Label.String='p/(1-p)';

axes(h(2))
data_here=coef_enso_fixed(:,:,1);
data_here(abs(data_here)>13)=nan;
%m_pcolor(lon([181:end 1:180]),lat,(data_here([181:end 1:180],:,1))');
m_contourf(lon([181:end 1:180]),lat,(data_here([181:end 1:180],:,1))',linspace(-15,15,50),'linestyle','none');
colormap(h(2),colormap_nature);
hold on
[lat_full,lon_full]=meshgrid(lat,lon);
lon_full=lon_full([181:end 1:180],:);
lat_full=lat_full([181:end 1:180],:);
p_here=coef_enso_fixed([181:end 1:180],:,2);
hold on
m_scatter(lon_full(p_here<0.05),lat_full(p_here<0.05),0.08,'k');
m_coast('patch',[0 0 0]);
m_grid('xtick',[],'ytick',[]);
caxis([0 10]);
m_text(50,-60,'b) ENSO (F)','fontsize',16,'fontweight','bold');
caxis([-12 12]);
s=colorbar('fontsize',12,...
    'Ticks',linspace(-12,12,5),...
         'TickLabels',round(exp(linspace(-12*0.1,12*0.1,5)),3));
s.Label.String='p/(1-p)';

axes(h(3))
data_here=coef_amo_fixed(:,:,1);
data_here(abs(data_here)>13)=nan;
m_contourf(lon([181:end 1:180]),lat,(data_here([181:end 1:180],:,1))',linspace(-15,15,50),'linestyle','none');
colormap(h(3),colormap_nature);
hold on
[lat_full,lon_full]=meshgrid(lat,lon);
lon_full=lon_full([181:end 1:180],:);
lat_full=lat_full([181:end 1:180],:);
p_here=coef_amo_fixed([181:end 1:180],:,2);
m_scatter(lon_full(p_here<0.05),lat_full(p_here<0.05),0.08,'k');
hold on
m_coast('patch',[0 0 0]);
m_grid('xtick',[],'ytick',[]);
caxis([0 10]);
m_text(50,-60,'c) AMO (F)','fontsize',16,'fontweight','bold');
caxis([-13 13]);
s=colorbar('fontsize',12,...
    'Ticks',linspace(-12,12,5),...
         'TickLabels',round(exp(linspace(-13*0.1,13*0.1,5)),3));
s.Label.String='p/(1-p)';

axes(h(4))
data_here=coef_pdo_fixed(:,:,1);
data_here(abs(data_here)>7)=nan;
m_contourf(lon([181:end 1:180]),lat,(data_here([181:end 1:180],:,1))',linspace(-7,7,100),'linestyle','none');
colormap(h(4),colormap_nature);
hold on
[lat_full,lon_full]=meshgrid(lat,lon);
lon_full=lon_full([181:end 1:180],:);
lat_full=lat_full([181:end 1:180],:);
p_here=coef_pdo_fixed([181:end 1:180],:,2);
m_scatter(lon_full(p_here<0.05),lat_full(p_here<0.05),0.08,'k');
hold on
m_coast('patch',[0 0 0]);
m_grid('xtick',[],'ytick',[]);
caxis([0 10]);
m_text(50,-60,'d) PDO (F)','fontsize',16,'fontweight','bold');
caxis([-3 3]);
s=colorbar('fontsize',12,...
    'Ticks',linspace(-3,3,5),...
         'TickLabels',round(exp(linspace(-3*0.1,3*0.1,5)),3));
s.Label.String='p/(1-p)';

axes(h(5))
data_here=coef_npgo_fixed(:,:,1);
data_here(abs(data_here)>6)=nan;
m_contourf(lon([181:end 1:180]),lat,(data_here([181:end 1:180],:,1))',linspace(-7,7,100),'linestyle','none');
colormap(h(5),colormap_nature);
hold on
[lat_full,lon_full]=meshgrid(lat,lon);
lon_full=lon_full([181:end 1:180],:);
lat_full=lat_full([181:end 1:180],:);
p_here=coef_npgo_fixed([181:end 1:180],:,2);
m_scatter(lon_full(p_here<0.05),lat_full(p_here<0.05),0.08,'k');
hold on
m_coast('patch',[0 0 0]);
m_grid('xtick',[],'ytick',[]);
caxis([0 10]);
m_text(50,-60,'e) NPGO (F)','fontsize',16,'fontweight','bold');
caxis([-2 2]);
s=colorbar('fontsize',12,...
    'Ticks',linspace(-2,2,5),...
         'TickLabels',round(exp(linspace(-2*0.1,2*0.1,5)),3));
s.Label.String='p/(1-p)';

axes(h(6))
data_here=coef_sam_fixed(:,:,1);
data_here(abs(data_here)>3)=nan;
m_contourf(lon([181:end 1:180]),lat,(data_here([181:end 1:180],:,1))',linspace(-7,7,100),'linestyle','none');
colormap(h(6),colormap_nature);
hold on
[lat_full,lon_full]=meshgrid(lat,lon);
lon_full=lon_full([181:end 1:180],:);
lat_full=lat_full([181:end 1:180],:);
p_here=coef_sam_fixed([181:end 1:180],:,2);
m_scatter(lon_full(p_here<0.05),lat_full(p_here<0.05),0.08,'k');
hold on
m_coast('patch',[0 0 0]);
m_grid('xtick',[],'ytick',[]);
caxis([0 10]);
m_text(50,-60,'f) SAM (F)','fontsize',16,'fontweight','bold');
caxis([-2 2]);
s=colorbar('fontsize',12,...
    'Ticks',linspace(-2,2,5),...
         'TickLabels',round(exp(linspace(-2*0.1,2*0.1,5)),3));
s.Label.String='p/(1-p)';
```


![Image text](https://github.com/ZijieZhaoMMHW/Logistic_EW/blob/master/fitted_lr.png)




