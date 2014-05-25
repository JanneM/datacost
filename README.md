datacost
========

A MATLAB function that fits the specified probability distribution function to mobile data consumption for predicting which data plan is most likely to result in the lowest future cost. Applicable to single or shared data plans.

% Predicts which data plan is most likely to result in the lowest cost.
% Can be used for single users or multiple users/devices with one shared data plan.
% Fits the specified probability distribution function (PDF) to input data (default is normal).
% Runs 1000 simulations for specified period of time (default is 24 months).
% Calculates the cost of the total amount of data based on each specified data plan and overage costs.
% By default if quota is exceeded with only 4 days remaining in billing cycle, no extra data are purchased.
% Number of days in month is based on total simulated usage for that month divided by 30 days.
%
% There is  no limit on the number of users that can be included other than the available system memory.
% data are stored in a MxNxU matrix where M is the number of months, N is the number of simulations (1000),
% and U is the number of users. MATLAB requires continuous blocks of memory to store variables,
% so it is possible to run out of usable memory, especially as N is increased.
% 
% This function could be used in conjunction with the ALLFITDIST function to find the best fit.
% However, the validity of this approach is questionable since realistically, the number of input data
% will most likely be very few.
% http://www.mathworks.com/matlabcentral/fileexchange/34943-fit-all-valid-parametric-probability-distributions-to-data
%
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
