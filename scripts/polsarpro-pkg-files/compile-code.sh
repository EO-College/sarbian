#!/bin/bash

(
    cd PolSARproSIM
    echo "PolSARproSIM"
    gcc -o PolSARproSim.exe PolSARproSim.c Allometrics.c Attenuation.c Branch.c c3Vector.c c33Matrix.c Complex.c Cone.c Crown.c Cylinder.c d3Vector.c d33Matrix.c Drawing.c Facet.c GraphicIMage.c GrgCyl.c Ground.c InfCyl.c JLkp.c Jnz.c Leaf.c LightingMaterials.c MonteCarlo.c Perspective.c Plane.c PolSARproSim_Direct_Ground.c PolSARproSim_Forest.c PolSARproSim_Procedures.c PolSARproSim_Progress.c PolSARproSim_Short_Vegi.c Ray.c RayCrownIntersection.c Realisation.c SarIMage.c Shuffling.c Sinc.c soilsurface.c Spheroid.c Tree.c YLkp.c -lm
    gcc -o PolSARproSim_ImgSize.exe PolSARproSim_ImgSize.c -lm
    gcc -o PolSARproSim_FE_Kz.exe ../lib/PolSARproLib.c PolSARproSim_FE_Kz.c -lm
) &

(
    cd PolSARproSIMgr
    echo "PolSARproSIMgr"
    gcc -o PolSARproSim_gr.exe PolSARproSim.c Allometrics.c Attenuation.c Branch.c c3Vector.c c33Matrix.c Complex.c Cone.c Crown.c Cylinder.c d3Vector.c d33Matrix.c Drawing.c Facet.c GraphicIMage.c GrgCyl.c Ground.c InfCyl.c JLkp.c Jnz.c Leaf.c LightingMaterials.c MonteCarlo.c Perspective.c Plane.c PolSARproSim_Direct_Ground.c PolSARproSim_Forest.c PolSARproSim_Procedures.c PolSARproSim_Progress.c PolSARproSim_Short_Vegi.c Ray.c RayCrownIntersection.c Realisation.c SarIMage.c Shuffling.c Sinc.c soilsurface.c Spheroid.c Tree.c YLkp.c -lm
    gcc -o PolSARproSimGR_ImgSize.exe PolSARproSimGR_ImgSize.c -lm
    gcc -o PolSARproSim_FE_Kz.exe ../lib/PolSARproLib.c PolSARproSim_FE_Kz.c -lm
) &

(
    cd PolSARproSIMsv
    echo "PolSARproSIMsv"
    gcc -o PolSARproSim_sv.exe PolSARproSim.c Allometrics.c Attenuation.c Branch.c c3Vector.c c33Matrix.c Complex.c Cone.c Crown.c Cylinder.c d3Vector.c d33Matrix.c Drawing.c Facet.c GraphicIMage.c GrgCyl.c Ground.c InfCyl.c JLkp.c Jnz.c Leaf.c LightingMaterials.c MonteCarlo.c Perspective.c Plane.c PolSARproSim_Direct_Ground.c PolSARproSim_Forest.c PolSARproSim_Procedures.c PolSARproSim_Progress.c PolSARproSim_Short_Vegi.c Ray.c RayCrownIntersection.c Realisation.c SarIMage.c Shuffling.c Sinc.c soilsurface.c Spheroid.c Tree.c YLkp.c -lm
    gcc -o PolSARproSimSV_ImgSize.exe PolSARproSimSV_ImgSize.c -lm
    gcc -o PolSARproSim_FE_Kz.exe ../lib/PolSARproLib.c PolSARproSim_FE_Kz.c -lm
) &

(
    cd SVM
    echo "SVM"
    g++ -Wall -g -Wconversion -O3 -c svm.cpp
    g++ -Wall -g -Wconversion -O3 svm-predict.c svm.o -o svm_predict_polsarpro.exe -lm
    g++ -Wall -g -Wconversion -O3 svm-train.c svm.o -o svm_train_polsarpro.exe -lm
    g++ -Wall -g -Wconversion -O3 svm-scale.c svm.o -o svm_scale_polsarpro.exe -lm
    gcc -g ../lib/PolSARproLib.c svm_classifier.c -o svm_classifier.exe -lm
    gcc -g ../lib/PolSARproLib.c write_best_cv_results.c -o write_best_cv_results.exe -lm
    gcc -g ../lib/PolSARproLib.c grid_polsarpro.c -o grid_polsarpro.exe -lm
    gcc -g ../lib/PolSARproLib.c svm_confusion_matrix.c -o svm_confusion_matrix.exe -lm
) &

(
    cd PolSARap
    echo "PolSARap"
    g++ -I ../lib/alglib ../lib/alglib/ap.cpp ../lib/alglib/alglibinternal.cpp ../lib/alglib/linalg.cpp ../lib/alglib/alglibmisc.cpp ../lib/alglib/solvers.cpp ../lib/alglib/optimization.cpp PolSARap_Cryosphere_Decomposition.c -o PolSARap_Cryosphere_Decomposition.exe -lm
    gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Cryosphere_Inversion.c -o PolSARap_Cryosphere_Inversion.exe -lm
    gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Agriculture_Decomposition.c -o PolSARap_Agriculture_Decomposition.exe -lm
    gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Agriculture_Inversion_Dihedral.c -o PolSARap_Agriculture_Inversion_Dihedral.exe -lm
    gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Agriculture_Inversion_Surface.c -o PolSARap_Agriculture_Inversion_Surface.exe -lm
    gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Forest_Height_Estimation_Dual_Baseline.c -o PolSARap_Forest_Height_Estimation_Dual_Baseline.exe -lm
    gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Ocean.c -o PolSARap_Ocean.exe -lm
    gcc -g -Wall ../lib/PolSARproLib.c PolSARap_Urban.c -o PolSARap_Urban.exe -lm
) &

wait

echo ">>> Compiling smaller tools..."
LIB_FILES="lib/PolSARproLib.c"
C_FILES="$(find . \( -path ./SVM -o -path ./PolSARap -o -path "./PolSARproSIM*" -o -path ./lib \) -prune -o -name "*.c" -print)"
echo ">>> Got file list..."
for file in $C_FILES; do
    echo $file
    gcc -g -Wall $LIB_FILES $file -o ${file%.c}.exe  -lm &

    while [[ $(jobs | wc -l) -eq $(nproc) ]]; do
        sleep 0.1
    done
done

wait
