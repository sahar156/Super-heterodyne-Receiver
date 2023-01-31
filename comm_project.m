%reading 2 audio messages
[message1,FS1]=audioread('Short_BBCArabic2.wav');
[message2,FS2]=audioread('Short_FM9090.wav');
%turning stereo to monophonic
mono_message1=(message1(:,1)+message1(:,2));
mono_message2=(message2(:,1)+message2(:,2));
length_message2=length(mono_message2);
length_message1=length(mono_message1);
%making 2 signals equal in leangth by adding zeros to the smallest one
if length_message1 >= length_message2
ZERO_PART = zeros(length_message1-length_message2,1);
mono_message2=vertcat(mono_message2,ZERO_PART);
length_message=length_message1;
elseif length_message2 >= lengh_message1
ZERO_PART = zeros(length_message2-length_message1,1);
mono_message1=vertcat(mono_message1,ZERO_PART);
length_message=length_message2;
end
%getting fft for the 2 signals
FT_message1=fft(mono_message1,length_message);
FT_message2=fft(mono_message2,length_message);
%adjusting the axis scale
frequency_axis = ((-length_message/2):((length_message/2)-1));
%plotting the 2 signals versus frequency
figure(1);
subplot(2,1,1);
plot((FS1/length_message)*frequency_axis,fftshift(abs(FT_message1)));
title('Fourier Transform of Message 1');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
subplot(2,1,2);
plot((FS2/length_message)*frequency_axis,fftshift(abs(FT_message2)));
title('Fourier Transform of Message 2');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
%checking Nyquist criteria
FC1=100000;
FC2=150000;
if FC1/2>FS1 
message1_interp=interp(mono_message1,10);
length_message1=length(message1_interp);
FS1=10*FS1;
end
if FC2/2>FS2 
message2_interp=interp(mono_message2,10);
length_message2=length(message2_interp);
FS2=10*FS2;
end
%generatting the carrier of each signal
n=1:length_message2;
C1=cos(2*pi*FC1*n*(1/FS1));
C2=cos(2*pi*FC2*n*(1/FS2));
%multiplying each signal with its carrier
message1_mod= C1'.*message1_interp;
message2_mod= C2'.*message2_interp;
%getting fft for the 2 modulated signals
message1_mod_ft=fftshift(abs(fft(message1_mod,length_message1)));
message2_mod_ft=fftshift(abs(fft(message2_mod,length_message2)));
frequency_axis2 = ((-length_message2/2):((length_message2/2)-1));
%plotting the 2 modulated signals
s=message1_mod_ft+message2_mod_ft;
figure(2);
plot((FS1/length_message2)*frequency_axis2,s);
title('Fourier Transform of the modulated Messages');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
%%%%%%% RF stage %%%%%%%%%
s2=message1_mod+message2_mod;
Audio1_AfterRFstage=bandpass(s2,[80800 119200],FS1);
Audio2_AfterRFstage=bandpass(s2,[130800 169200],FS2);
Audio1_AfterRFstage_FD=fftshift(fft(Audio1_AfterRFstage));
Audio2_AfterRFstage_FD=fftshift(fft(Audio2_AfterRFstage));
figure(3);
subplot(2,1,1);
plot((FS1/length_message2)*frequency_axis2,abs(Audio1_AfterRFstage_FD));
xlabel('Frequency');
ylabel('Magnitude');
title('the output of the RF filter for the fitrst signal');
subplot(2,1,2);
plot((FS1/length_message2)*frequency_axis2,abs(Audio2_AfterRFstage_FD));
xlabel('Frequency');
ylabel('Magnitude');
title('the output of the RF filter for the second signal');
%mixer stage
mix=cos(2*pi*(FC1+25000)*n*(1/FS1));
message1_mix=mix'.*Audio1_AfterRFstage;
message2_mix=mix'.*Audio2_AfterRFstage;
message1_mixfd=fftshift(fft(message1_mix));
message2_mixfd=fftshift(fft(message2_mix));
figure(4);
subplot(2,1,1);
plot((FS1/length_message2)*frequency_axis2,abs(message1_mixfd))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the first signal after mixer in RF stage')
subplot(2,1,2);
plot((FS1/length_message2)*frequency_axis2,abs(message2_mixfd))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the second signal after mixer in RF stage')
% IF stage
message1_IF=bandpass(message1_mix,[4000 50000],FS1);
message2_IF=bandpass(message2_mix,[5800 44200],FS2);
figure(5);
subplot(2,1,1);
plot((FS1/length_message2)*frequency_axis2,abs(fftshift(fft(message1_IF))))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the first signal after IF stage')
subplot(2,1,2);
plot((FS1/length_message2)*frequency_axis2,abs(fftshift(fft(message2_IF))))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the second signal after IF stage')
%lowering signals to baseband
mix2=cos(2*pi*(25000)*n*(1/FS1));
message1_IFdemodulated=mix2'.*message1_IF;
message1_IFdemodulatedfd=fftshift(fft(message1_IFdemodulated));
message2_IFdemodulated=mix2'.*message2_IF;
message2_IFdemodulatedfd=fftshift(fft(message2_IFdemodulated));
figure(6)
subplot(2,1,1);
plot((FS1/length_message2)*frequency_axis2,abs(message1_IFdemodulatedfd))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the first signal before lpf')
subplot(2,1,2);
plot((FS1/length_message2)*frequency_axis2,abs(message2_IFdemodulatedfd))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the second signal before lpf')
%filtering to obtain the signals
message1_final=lowpass(message1_IFdemodulated,19200,FS1);
message2_final=lowpass(message2_IFdemodulated,19200,FS2);
figure(7);
subplot(2,1,1);
plot((FS1/length_message2)*frequency_axis2,abs(fftshift(fft(message1_final))))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the first signal after LPF')
subplot(2,1,2);
plot((FS1/length_message2)*frequency_axis2,abs(fftshift(fft(message2_final))))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the second signal after LPF')
%playing the 2 sounds after demodulation
message1_final=downsample(message1_final,10);
sound(message1_final,FS1/10)
pause(15)
message2_final=downsample(message2_final,10);
sound(message2_final,FS2/10)
%output of the RF mixer (no RF filter)
mix3=cos(2*pi*(FC1+25000)*n*(1/FS1));
messeges_mix_noRF=mix3'.*s2;
messages_mixfd_noRF=fftshift(fft(messeges_mix_noRF));
figure(8);
plot((FS1/length_message2)*frequency_axis2,abs(messages_mixfd_noRF))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title(' output of the RF mixer (no RF filter)')
%Output of the IF filter (no RF filter)
message1_IF_noRF=bandpass(messeges_mix_noRF,[4000 50000],FS1);
message2_IF_noRF=bandpass(messeges_mix_noRF,[5800 44200],FS2);
figure(9);
subplot(2,1,1);
plot((FS1/length_message2)*frequency_axis2,abs(fftshift(fft(message1_IF_noRF))))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the first signal after IF stage(no RF filter)')
subplot(2,1,2);
plot((FS1/length_message2)*frequency_axis2,abs(fftshift(fft(message2_IF_noRF))))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the second signal after IF stage(no RF filter)')
%Output of the IF mixer before the LPF (no RF filter)
mix4=cos(2*pi*(25000)*n*(1/FS1));
message1_IFdemodulated_noRF=mix4'.*message1_IF_noRF;
message1_IFdemodulatedfd_noRF=fftshift(fft(message1_IFdemodulated_noRF));
message2_IFdemodulated_noRF=mix4'.*message2_IF_noRF;
message2_IFdemodulatedfd_noRF=fftshift(fft(message2_IFdemodulated_noRF));
figure(10)
subplot(2,1,1);
plot((FS1/length_message2)*frequency_axis2,abs(message1_IFdemodulatedfd_noRF))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the first signal before lpf(no RF filter)')
subplot(2,1,2);
plot((FS1/length_message2)*frequency_axis2,abs(message2_IFdemodulatedfd_noRF))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the second signal before lpf(no RF filter)')
%Output of the LPF (no RF filter)
message1_final_noRF=lowpass(message1_IFdemodulated_noRF,19200,FS1);
message2_final_noRF=lowpass(message2_IFdemodulated_noRF,19200,FS2);
figure(11);
subplot(2,1,1);
plot((FS1/length_message2)*frequency_axis2,abs(fftshift(fft(message1_final_noRF))))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the first signal after LPF(no RF filter)')
subplot(2,1,2);
plot((FS1/length_message2)*frequency_axis2,abs(fftshift(fft(message2_final_noRF))))
xlabel('frequency (Hz)')
ylabel('Magnitude');
title('the second signal after LPF(no RF filter)')





    






















