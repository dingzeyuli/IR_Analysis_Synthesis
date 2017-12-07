clear
close all

filename = '~/Codes/BST/data/Audio/h178_OfficeFoyer_1txts.wav';


files = dir('~/Codes/BST/data/Audio/*.wav');

ppp = zeros(length(files) ,1);
VrKrt = zeros(length(files) ,1);
Tgs = zeros(length(files) ,1);

parfor i = 1:length(files)
  i
  H = [];
  filename = [files(i).folder  '/'  files(i).name];
  [x, fs] = audioread(filename);
  x = x(:,1);

  H.h = x;
  H.fs = fs;
  H.h_snps=H.h;


  %figure
  %subplot(3,1,1)
  K = IRKrt(H,10);
  %plot(K.krt)

  krt = K.krt;
  krt = smooth(krt,100);

  threshold = mean(krt) * 1.3;
  start_index = find(krt>threshold, 1);
  end_index = start_index + find(krt(start_index:end) < threshold ,1);
  
  ppp(i) = end_index/fs*1000;
  Tgs(i) = K.Tgs;
  VrKrt(i) = K.VrKrt;
  
end