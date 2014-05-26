function datacost(data,varargin)

% Predicts which data plan is most likely to result in the lowest cost.
% Can be used for single users or multiple users/devices with one shared data plan.
% Fits the specified probability distribution function (PDF) to input data (default is normal).
% Runs 1000 simulations for specified period of time (default is 24 months).
% Calculates the cost of the total amount of data based on each specified data plan and overage costs.
% By default if quota is exceeded with only 4 days remaining in billing cycle, no extra data are purchased.
% Number of days in month is based on total simulated usage for that month divided by 30 days.
% For more than two devices, the shared family plans are used by default. Otherwise the individual plans are used.
%
% There is  no limit on the number of users that can be included other than the available system memory.
% data are stored in a MxNxU matrix where M is the number of months, N is the number of simulations (1000),
% and U is the number of users. MATLAB requires continuous blocks of memory to store variables,
% so it is possible to run out of usable memory, especially as N is increased.
% %
% REQUIRED INPUT:
%	data  cell array of monthly data consumption amounts in GB, one cell per user/device
%
%OPTIONAL INPUTS (defualt value if not specified) {input type}:
%	month (24) number of months to run simulation into the future.
%	tax (0) consumption tax rate as percentage, e.g., 8% is '8'
%	line (800) {scaler} Cost for each additional SIM card. Defulat based on NTT Docomo lowest cost with Mopera ISP.
%	addamount (1) {scaler} Bundeled amout of additional data that is purchased after quota is exceeded.
%	addcost (1000) {scaler} Cost of the data specified in addamount. Defualt is 1 GB at 1,000 yen.
%	thresh (4) {sclaer} Number of days remaining in the month up until which additional data are purchased.
%	planprice (3500 500 5700 | 9500 12500 16000 22500) {vector} cost of individual | family plans for NTT Docomo
%	quota (2 5 7 | 10 15 20 30) {vector} Data quotas for NTT Docomo individual | family plans
%	dist (normal) {cell array} Distribution type that is fit to input 'data' to create probability density function (pdf). If only one value is input, it is applied to all data.
%	currency (man yen) {character} Currency of prices
%	plot (all) {character} 'all': plots results and PDFs; 'none': plotting off; 'results': plots only results; 'pdfs' plots only PDFs
% 
%This function could be used in conjunction with the ALLFITDIST function to find the best fit.
% However, the validity of this approach is questionable since realistically, the number of input data
% will most likely be very few.
% http://www.mathworks.com/matlabcentral/fileexchange/34943-fit-all-valid-parametric-probability-distributions-to-data

tic

p = inputParser;
p.KeepUnmatched = true;
p.CaseSensitive = false;
p.FunctionName='datacost';

%set defaults for options
d_month=24;
d_tax=[];
d_line=800;
d_addamount=1;
d_addcost=1000;
d_thresh=4;
if length(data)<=2
	d_planprice=[3500 5000 5700];
	d_quota=[2 5 7];
else
	d_planprice=[9500 12500 16000 22500];
	d_quota=[10 15 20 30];
end
d_dist=repmat({'normal'},1,length(data));
d_currency='man yen';
d_plot='all';

if datenum(version('-date'))<datenum('May 19, 2013')
	addParamValue(p,'month',d_month,@isnumeric);
	addParamValue(p,'tax',d_tax,@isnumeric);
	addParamValue(p,'line',d_line,@isnumeric);
	addParamValue(p,'addamount',d_addamount,@isnumeric);
	addParamValue(p,'addcost',d_addcost,@isnumeric);
	addParamValue(p,'thresh',d_thresh,@isnumeric);
	addParamValue(p,'planprice',d_planprice,@isnumeric);
	addParamValue(p,'quota',d_quota,@isnumeric);
	addParamValue(p,'dist',d_dist,@iscell);
	addParamValue(p,'currency',d_currency,@ischar);
	addParamValue(p,'plot',d_plot,@ischar);
else
	addParameter(p,'month',d_month,@isnumeric);
	addParameter(p,'tax',d_tax,@isnumeric);
	addParameter(p,'line',d_line,@isnumeric);
	addParameter(p,'addamount',d_addamount,@isnumeric);
	addParameter(p,'addcost',d_addcost,@isnumeric);
	addParameter(p,'thresh',d_thresh,@isnumeric);
	addParameter(p,'planprice',d_planprice,@isnumeric);
	addParameter(p,'quota',d_quota,@isnumeric);
	addParameter(p,'dist',d_dist,@iscell);
	addParameter(p,'currency',d_currency,@ischar);
	addParameter(p,'plot',d_plot,@ischar);
end

%parse varargin
parse(p,varargin{:});
month=p.Results.month;
tax=p.Results.tax;
extraline=p.Results.line;
addamount=p.Results.addamount;
addcost=p.Results.addcost;
thresh=p.Results.thresh;
price=p.Results.planprice;
quota=p.Results.quota;
dist=p.Results.dist;
currency=p.Results.currency;
plots=p.Results.plot;



e=3;
numsim=10^e;
datam=zeros(month,numsim,length(data));
%cost matrix 
costm=zeros(month,length(quota),numsim);
costm(:,1:2,:)=costm(:,1:2,:)+(length(data)-1)*extraline;

for i=1:length(data)
	%gmdistribution requires column vectors
	if size(data{i},2)>1
		data{i}=data{i}';
	end
	pdfdata{i}=sort(data{i});
	pdfdata{i}(find(isnan(pdfdata{i})))=[];
	if max(quota)>max(pdfdata{i})
		x{i}=[pdfdata{i}(1):.01:max(quota)]';
	else
		x{i}=[pdfdata{i}(1):.01:max(pdfdata{i})]';
	end
	if strcmp('bimodal',dist{i})==1
		pd{i}=gmdistribution.fit(pdfdata{i},2);
		%random cannot create 2 dimensional matrix with gaussian mixed distribution object
		for j=1:numsim
			datam(:,j,i)=random(pd{i},month);
		end
	elseif strcmp('uniform',dist{i})==1
		%not yet implemented
	else
		pd{i}=fitdist(pdfdata{i},dist{i});
		if datenum(version('-date'))>=datenum('May 19, 2013')
			pd{i}=truncate(pd{i},min(pdfdata{i}),max(pdfdata{i}));
		end
		datam(:,:,i)=random(pd{i},month,numsim);
	end
	pdfs{i}=pdf(pd{i},x{i});
end

%sum all devices
datatot=sum(datam,3);

%calculate cost
for k=1:numsim
	%loop through for each data quota
	for j=1:length(quota)
		%start with initial price
		costm(:,j,k)=costm(:,j,k)+price(j);
		%determine amount over quota
		over(:,j,k)=datatot(:,k)-quota(j);
		over(:,j,k)=over(:,j,k)/addamount;
		%set negative values to zero
		over(find(over(:,j,k)<0),j,k)=0;
		%add overage cost for whole Gigabytes
		costm(:,j,k)=costm(:,j,k)+(addcost*floor(over(:,j,k)));
		%get fractional GBs used
		remain(:,j,k)=over(:,j,k)-floor(over(:,j,k));
		%multiple overage cost by a logical vector (0 or 1) if remainder exceeds threshold
		costm(:,j,k)=costm(:,j,k)+(remain(:,j,k)>(datatot(:,k)/30)*thresh)*addcost;
	end
end

%mean and standard deviation of monthly cost
for i=1:length(quota)
	costmean(:,i)=mean(costm(:,i,:),3);
	coststd(:,i)=std(squeeze(costm(:,i,:))');
end

cum=cumsum(costm);
for i=1:length(quota)
	cummean(:,i)=mean(cum(:,i,:),3);
	cumstd(:,i)=std(squeeze(cum(:,i,:))');
end

% find the index in cum that corresponds to lowest cumulative price between n quot after n months
%if there is a tie, size of min() is 2, causing error
%so using a cell array, then finding the length of the contents of each cell
for i=1:numsim;
	result{i}=find(min(cum(end,:,i))==cum(end,:,i));
	len_result(i)=length(result{i});
end

% find the number of times the min corresponded to each index in quota 
for i=1:length(quota)
	prob(i)=length(find(cell2mat(result(find(len_result==1)))==i));
end

%examine the contents of the cells when two or more data plans produced the same total price
%assign the ties to the cheaper of the data plans
%this will throw an error if there was a three way tie due to matrix dimentions mismatch
%consider first the case where there is a tie between quota(1) and quota(2)
if max(cell2mat(result(find(len_result==2))))<quota(2)
	prob(1)=prob(1)+length(find(len_result==2));
end

%display results
prob=100.*(prob./numsim);
for i=1:length(quota)
	disp(['The ' num2str(quota(i)) 'GB plan is least expensive in ' num2str(prob(i)) '% of simulations'...
	'(ave ' num2str(cummean(end,i)) ' +/- ' num2str(round(cumstd(end,i))) ')'])
end


% plot results
colors=[255 0 0; 0 190 0; 0 0 255; 0 0 0; 255 153 0; 0 153 255; 255 0 255; 0 255 51]/255;

%FIGURE 1
%line plot

if strcmpi(plots,'all')==1 | strcmpi(plots,'results')==1
	figsize=[500 600 600 300];
	axessize=[45 42.5 535 225];
	figure('position',figsize)
	axes('units','pixels','position',axessize)
	hold(gca,'on')
	for i=1:size(cummean,2)
		if strcmp('man yen',currency)==1
			shadedErrorBar(1:month,cummean(:,i)/10^4,cumstd(:,i)/10^4,{'color',colors(i,:)},1)
		else
			shadedErrorBar(1:month,cummean(:,i),cumstd(:,i),{'color',colors(i,:)},1)
		end
	end
	ylabel(['Cumulative cost (' currency ')']);
	set(gca,'tickdir','out','xlim',[0 month+1],'xtick',[1:month])
	xlabel('Months into the future')
	
	%cumulative bar graph
	axes('units','pixels','position',[465 45 115 115])
	hold(gca,'on')
	for i=1:size(costmean,2)
		bar(i,sum(costmean(:,i)),'facecolor', colors(i,:))
		text(i,sum(costmean(:,i)),num2str(sum(costmean(:,i))),'rotation',90,'verticalalign','middle','horizontalalign','right','color','w')
		text(i,sum(costmean(:,i)),[' ' num2str(quota(i)) 'GB'],'rotation',90,'verticalalign','middle','horizontalalign','left','color','k')
	end
	axis off
	
	%probability horizontal bar
	barbox=[55/figsize(3) 195/figsize(4) 175/figsize(3) 40/figsize(4)];
	if isempty(find(prob==100))==0
		annotation('rectangle',barbox,'facecolor',colors(find(prob==100),:))
		annotation('textbox',[axessize(1)/figsize(3) .55, .1 .1],'string','0%','horizontalalignment','left','edgecolor','none')
		annotation('textbox',[barbox(1)+barbox(3)-.025 .55, .1 .1],'string','100%','horizontalalignment','left','edgecolor','none')
	else
		st=barbox(1);
		for i=1:length(prob)
			annotation('rectangle',[st barbox(2) barbox(3)*(prob(i)/100) barbox(4)],'facecolor',colors(i,:))
			st=st+(barbox(3)*(prob(i)/100));
		end
		annotation('textbox',[axessize(1)/figsize(3) .55, .1 .1],'string','0%','horizontalalignment','left','edgecolor','none')
		annotation('textbox',[barbox(1)+barbox(3)-.025 .55, .1 .1],'string','100%','horizontalalignment','left','edgecolor','none')
	end
	annotation('textbox',[barbox(1) .79, barbox(3) .1],'string',{['Percent chance of lowest cost'] ['over ' num2str(month) ' month period']},'horizontalalignment','center','edgecolor','none')

end

%PDFs figures
if strcmpi(plots,'all')==1 | strcmpi(plots,'pdfs')==1
	for i=1:length(pdfdata)
		%histogram of pdfdata
		figure('position',[500 500 300 300])
		axes('units','pixels','position',[42 50 215 215])
		hist(pdfdata{i})
		h=findobj(gca,'type','patch');
		set(h,'facecolor','k','edgecolor','w')
		xlimits=get(gca,'xlim');
		set(gca,'tickdir','out','box','off')
		ylabel('N')
		xlabel('Monthly data usage (GB)')
	
		%PDF
		axes('units','pixels','position',[42 50 215 215])
		plot(x{i},pdfs{i},'color',[1 0 0])
		set(gca,'xlim',xlimits,'box','off','tickdir','out','yaxislocation','right','xaxislocation','top','color','none','xticklabel',[])
		ylabel('Probability')
		if length(dist)==1
			title(dist{:})
		else
			title(dist{i})
		end
	end
end
toc
