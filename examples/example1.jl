using EEGjl
using Winston

fname = "../data/Example-40Hz.bdf"

s = read_EEG(fname, verbose=true)

s = proc_hp(s, verbose=true)

s = proc_reference(s, "average", verbose=true)

    p = plot_timeseries(s, "Cz")
    file(p, "Eg1-RawData.png", width=1200, height=600)

    p = plot_timeseries(s)
    file(p, "Eg1-AllChannels.png", width=1200, height=800)

s = extract_epochs(s, verbose=true)

s = create_sweeps(s, epochsPerSweep=32, verbose=true)


###########
#
# Things past here still need a wrapper function
#
###########

meanSweeps = squeeze(mean(s.processing["sweeps"], 2), 2)

ChannelToAnalyse = 52

while ChannelToAnalyse <= 64

    if ChannelToAnalyse == 48
        ChannelToAnalyse += 1
    end

    ChanName = s.labels[ChannelToAnalyse]

    println("Processing channel $ChannelToAnalyse")

    fResult, s, n = proc_ftest(s.processing["sweeps"], 40.0391, 8192, ChannelToAnalyse)
    title = "Channel $(ChanName). SNR = $(round(fResult,2)) dB"

    singleChan = convert(Array{Float64}, vec(meanSweeps[:,ChannelToAnalyse]))

    f = plot_spectrum(singleChan, 8192, titletext=title, dBPlot=true,
        signal_level=s, noise_level=n, targetFreq=40.0391)
    file(f, "Eg1-SweepSpectrum-$(ChannelToAnalyse).png", width=1200, height=600)

    ChannelToAnalyse += 99
end
