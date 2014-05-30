%based on the mean and median usage of each user, the 15 GB plan with overages
%at first appears to be cheaper (about 17 GB / month), but simulation indicates
%that the 20 GB plan has a higher probability of costing less over 24 months.

%The 20 GB plan is likely to save about 1,000 yen per month

user1=[0.25; 2; 1; 1.5; 2.1; 3.25; 0.50; 2; 2.5; 3; 1.5; 2.25; 2.14; 4.80; 1.82; 3.52; 2.71; 1.98; 1.52; 2.56; 2.06; 1.72; 2.38; 3.94; 3.00; 1.26; 0.51; 1.33; ];; user2=[11; 11; 9; 9; 7; 7; 6; 6; 5; 5; 4; 6; 6; 7; 7; 7; ];; user3=[4.09; 3.91; 2.79; 4.80; 4.68; 5.19; 5.25];
user2=[11; 11; 9; 9; 7; 7; 6; 6; 5; 5; 4; 6; 6; 7; 7; 7];
user3=[4.09; 3.91; 2.79; 4.80; 4.68; 5.19; 5.25];
user4=[2.50; 2.10; 2.23; 1.91; 2.01; 3.05; 3.50; 1.12; 0.80; 2.01; 1.20; 2.70; 4.11; 5.04; 6.31; 6.96; 6.53; 6.99; 6.12; 6.26; 5.52; 5.91];

data={user1 user2 user3 user4};

%distributions for PDFs
dist={'gamma' 'normal' 'ev','bimodal'};

%if you bet an error in newer versions use this instead.
%dist={'gamma' 'normal' 'extremevalue','bimodal'};

%determine mean and meadian usage
for i=1:length(data)
	m(1,i)=mean(data{i});
	m(2,i)=median(data{i});
	s(i)=std(data{i});
end
disp('low range, mean high range')
disp([sum(m(1,:))-sum(s) sum(m(1,:)) sum(m(1,:))+sum(s)])
disp('low range, median high range')
disp([sum(m(2,:))-sum(s) sum(m(2,:)) sum(m(2,:))+sum(s)])

%determine if environment is MATLAB
vv=ver;
for i=1:length(vv)
	v(i)=strcmp('MATLAB',vv(i).Name);
end
v=sum(v);
clear vv

if v==1
	datacost(data,'dist',dist);
else
	datacost(data,24,800,1,1000, 4,[9500 12500 16000 22500], [10 15 20 30],'man yen','all')
end
