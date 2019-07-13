clear;
%fill in the path of normal audio file.
voice_file = '';

%read the signal from audio file.
[voice_signal, voice_samp_freq] = audioread(voice_file);

%pass through a low-pass filter to only keep frequencies below 8kHz
[b,a] = butter(10,2*8000/voice_samp_freq,'low');
voice_filter = filter(b,a,voice_signal(:,1));

%upsample the signal with 192kHz sample rate
ultra_samp_freq = 192000;
voice_resamp = resample(voice_filter,ultra_samp_freq,voice_samp_freq);
voice_resamp = 1/max(abs(voice_resamp)) * voice_resamp;

%ultrasound modulation with 30kHz to obtain attack ultrasound
dt = 1/ultra_samp_freq;
len = size(voice_resamp,1);
t = (0:dt:(len - 1)*dt)';
carrier_freq = 30000;
ultrasound = voice_resamp.*cos(2*pi*carrier_freq*t) + 1*cos(2*pi*carrier_freq*t);
%here we use double sideband modulation; instead we can only keep either
%upper sideband
%ultrasound = voice_resamp.*cos(2*pi*carrier_freq*t) - imag(hilbert(voice_resamp)).*sin(2*pi*carrier_freq*t) + 1*cos(2*pi*carrier_freq*t);
%or lower sideband
%ultrasound = voice_resamp.*cos(2*pi*carrier_freq*t) + imag(hilbert(voice_resamp)).*sin(2*pi*carrier_freq*t) + 1*cos(2*pi*carrier_freq*t);
ultrasound = 1/max(abs(ultrasound)) * ultrasound;

%write the attack signal into an audio file; fill in the path
ultrasound_file = '';
audiowrite(ultrasound_file, ultrasound,ultra_samp_freq);