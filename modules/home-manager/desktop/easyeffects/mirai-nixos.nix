{ lib }:

let
  # https://www.reddit.com/r/framework/comments/1vbhb3y/
  bands = [
    {
      frequency = 29.952623;
      gain = 3.9299998;
    }
    {
      frequency = 59.76334;
      gain = 6.51;
    }
    {
      frequency = 119.24354;
      gain = 10.21;
    }
    {
      frequency = 237.92215;
      gain = 8.33;
    }
    {
      frequency = 474.71707;
      gain = 4.82;
    }
    {
      frequency = 947.1851;
      gain = 0.28;
    }
    {
      frequency = 1889.8828;
      gain = 0.08;
    }
    {
      frequency = 3770.8118;
      gain = -0.83;
    }
    {
      frequency = 7523.759;
      gain = 13.5;
    }
    {
      frequency = 15011.872;
      gain = 18.51;
    }
  ];

  equalizerBands = builtins.listToAttrs (
    lib.imap0 (index: band: {
      name = "band${toString index}";
      value = band // {
        mode = "RLC (BT)";
        mute = false;
        q = 1.5047603;
        slope = "x1";
        solo = false;
        type = "Bell";
        width = 4.0;
      };
    }) bands
  );
in
{
  outputDevice = "alsa_output.pci-0000_00_1f.3.analog-stereo";
  outputDeviceDescription = "HDA Intel PCH Analog Stereo";

  autoload = {
    analog-output-speaker = "Framework 13 Pro";
    analog-output-headphones = "Effects off";
  };

  presets = {
    "Framework 13 Pro".output = {
      blocklist = [ ];
      "plugins_order" = [
        "equalizer#0"
        "compressor#0"
        "limiter#0"
      ];
      "equalizer#0" = {
        balance = 0.0;
        bypass = false;
        input-gain = -19.0;
        left = equalizerBands;
        mode = "IIR";
        num-bands = 10;
        output-gain = 11.0;
        pitch-left = 0.0;
        pitch-right = 0.0;
        right = equalizerBands;
        split-channels = false;
      };
      "compressor#0" = {
        bypass = false;
        input-gain = 8.0;
      };
      "limiter#0" = {
        bypass = false;
        threshold = -1.0;
      };
    };
    "Effects off".output = {
      blocklist = [ ];
      "plugins_order" = [ ];
    };
  };
}
