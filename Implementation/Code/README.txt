IMAGE COMPLETION

1. NAIVE METHODS
	-- findClosestPatch.m
	-- removedPatches.m
	-- removedPatchesWhileSmoothing.m

2. FRAGMENT-BASED IMAGE COMPLETION
	-- imageCompletion.m (main file, runs everything)
	-- fastApprox.m
	-- getConfidenceMap.m
	-- getLevelSet.m
	-- findPatchSize.m
	-- getMatchingPatch.m
	-- updateCoordinates.m
	-- createComposite.m
	-- getLaplacianPyramid.m
	-- reconstructFromLaplacianPyramid.m

3. PATCHMATCH (Used in conjunction with 2. Still uses imageCompletion.m as the main file.)
	-- getMatchingPatchFromNNF.m
	-- getNNF.m
	-- testPatchMatch.m (only to test PatchMatch implementation)
