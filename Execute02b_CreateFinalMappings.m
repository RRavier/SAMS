disp('Interpolating sparse correspondences...')
if Flags('isDisc') == 0
    SetupHypOrb;
    CreateFinalMappingsSphere;
else
    CreateFinalMappingsDisc2;
end

disp('Mappings computed. Please visualize with plotColorMap before continuing');