UHD_4_chanMap = [chanMap0ind xcoords ycoords];
tester = (ones(384));
celltest = mat2cell(UHD_4_chanMap, tester(1,:), [1,1,1]);
structtest = cell2struct(celltest, fieldnames(MEH_chanMap), 2);
UHD_4_chanMap = structtest.';