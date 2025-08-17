# builder file.
# required programms on path: csbuilder,  mpn, docker

cs load_sing -m -n "./././"
docker_imp -m syntax -m -n /s \f

echo File singature created! At ./build/syngature.sync

mpn compile -src "./" \c -conf "././_config"

echo created js files! At ./build/assets/Ci38.js, ./build/assets/ready.js

echo Starting!

nodejs ./build/assets/ready.js



