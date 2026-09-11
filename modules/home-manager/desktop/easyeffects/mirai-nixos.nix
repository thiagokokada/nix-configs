_:

{
  outputDevice = "alsa_output.pci-0000_00_1f.3.analog-stereo";
  outputDeviceDescription = "HDA Intel PCH Analog Stereo";

  autoload = {
    analog-output-speaker = "Framework 13 Pro";
    analog-output-headphones = "Effects off";
  };

  presetFiles = {
    # https://github.com/stirlingsilver/fw13pro-customizations/blob/main/FW13SpeakersV2-Loudness.json
    "Framework 13 Pro".output = ./FW13SpeakersV2-Loudness.json;
  };

  presets = {
    "Effects off".output = {
      blocklist = [ ];
      plugins_order = [ ];
    };
  };
}
