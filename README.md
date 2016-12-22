# ImageCompletion
Final Project for CS670 Computer Vision. University of Massachusetts Amherst. Fall 2016.

1. NAIVE METHODS<br/>
	-- findClosestPatch.m<br/>
	-- removedPatches.m<br/>
	-- removedPatchesWhileSmoothing.m<br/>

2. FRAGMENT-BASED IMAGE COMPLETION<br/>
	-- imageCompletion.m (main file, runs everything)<br/>
	-- fastApprox.m<br/>
	-- getConfidenceMap.m<br/>
	-- getLevelSet.m<br/>
	-- findPatchSize.m<br/>
	-- getMatchingPatch.m<br/>
	-- updateCoordinates.m<br/>
	-- createComposite.m<br/>
	-- getLaplacianPyramid.m<br/>
	-- reconstructFromLaplacianPyramid.m<br/>

3. PATCHMATCH (Used in conjunction with 2. Still uses imageCompletion.m as the main file.)<br/>
	-- getMatchingPatchFromNNF.m<br/>
	-- getNNF.m<br/>
	-- testPatchMatch.m (only to test PatchMatch implementation)<br/>

References<br/>
[1]  C.  Barnes,   E.  Shechtman,   A.  Finkelstein,   and  D.  Gold-man.   Patchmatch:  a randomized correspondence algorithmfor structural image editing.ACM Transactions on Graphics-TOG, 28(3):24, 2009.<br/>
[2]  M. Bertalmio, G. Sapiro, V. Caselles, and C. Ballester.   Im-age inpainting.  InProceedings of the 27th annual conferenceon Computer graphics and interactive techniques, pages 417–424. ACM Press/Addison-Wesley Publishing Co., 2000.<br/>
[3]  I. Drori, D. Cohen-Or, and H. Yeshurun.  Fragment-based im-age  completion.   InACM  Transactions  on  graphics  (TOG),volume 22, pages 303–312. ACM, 2003.<br/>
[4]  A. A. Efros and W. T. Freeman. Image quilting for texture syn-thesis and transfer.  InProceedings of the 28th annual confer-ence on Computer graphics and interactive techniques, pages341–346. ACM, 2001.<br/>
[5]  A.  A.  Efros  and  T.  K.  Leung.    Texture  synthesis  by  non-parametric sampling.   InIEEE International Conference onComputer Vision (ICCV), 1999, volume 2, pages 1033–1038.IEEE, 1999.<br/>
[6]  J.  Hays  and  A.  A.  Efros.   Scene  completion  using  millionsof photographs.   InACM Transactions on Graphics (TOG),volume 26, page 4. ACM, 2007.<br/>
[7]  Y.  Wexler,  E.  Shechtman,  and  M.  Irani.   Space-time  videocompletion.    InComputer  Vision  and  Pattern  Recognition,2004. CVPR 2004. Proceedings of the 2004 IEEE ComputerSociety Conference on, volume 1, pages I–120. IEEE.<br/>
