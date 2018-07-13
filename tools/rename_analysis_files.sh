for file in AmBe_r00001142*.root
do
    mv -i "${file}" "${file/p001/p000}"
done
