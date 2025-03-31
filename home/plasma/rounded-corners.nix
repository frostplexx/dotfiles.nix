_: {
  programs.plasma.configFile.kwinrc = {
    MaximizeTile = {
      DisableOutlineTile.value = false;
      DisableRoundTile.value = false;
    };
    Plugins.kwin4_effect_shapecornersEnabled.value = true;
    PrimaryOutline = {
      ActiveOutlineUseCustom.value = false;
      ActiveOutlineUsePalette.value = true;
      InactiveOutlineAlpha.value = 200;
      InactiveOutlineUseCustom.value = false;
      InactiveOutlineUsePalette.value = true;
    };
    Round-Corners = {
      AnimationEnabled.value = false;
      InactiveCornerRadius.value = 8;
      InactiveShadowSize.value = 40;
      ShadowSize.value = 40;
      Size.value = 8;
    };
    SecondOutline = {
      InactiveSecondOutlineThickness.value = 0;
      SecondOutlineThickness.value = 0;
    };
  };
}
