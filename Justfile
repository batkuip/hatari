build-dir := "build-osx"
arch := `uname -m`
brew-prefix := `brew --prefix`
tos := justfile_directory() / "src/tos.img"
gemdos-hd := env_var("HOME") / "Projects/Atari/Harddisk"
hatari-app := justfile_directory() / build-dir / "src/Hatari.app"
hatari-bin := hatari-app / "Contents/MacOS/Hatari"

default: build

configure:
	cmake -S . -B {{build-dir}} \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_OSX_ARCHITECTURES={{arch}} \
		-DCMAKE_PREFIX_PATH={{brew-prefix}} \
		-DPython_EXECUTABLE={{brew-prefix}}/bin/python3.14 \
		-DENABLE_OSX_BUNDLE=1 \
		-DLibArchive_INCLUDE_DIR={{brew-prefix}}/opt/libarchive/include \
		-DLibArchive_LIBRARY={{brew-prefix}}/opt/libarchive/lib/libarchive.dylib

build: configure
	cmake --build {{build-dir}} -j8

clean:
	rm -rf "{{build-dir}}"

run args="":
	open -n "{{hatari-app}}" --args --tos "{{tos}}" --memsize 4 --drive-b off --fastfdc on --harddrive "{{gemdos-hd}}" --gemdos-drive skip --fast-boot on --tos-res stmed --fast-forward boot:on --fast-forward inf:off {{args}}

capture output="/tmp/hatari-psg-capture.csv" args="":
	HATARI_PSG_CAPTURE="{{output}}" "{{hatari-bin}}" --tos "{{tos}}" --memsize 4 --drive-b off --fastfdc on --harddrive "{{gemdos-hd}}" --gemdos-drive skip --fast-boot on --tos-res stmed --fast-forward boot:on --fast-forward inf:off --debug-except none --symload off {{args}}

capture-prg prg output="/tmp/hatari-psg-capture.csv" args="":
	HATARI_PSG_CAPTURE="{{output}}" "{{hatari-bin}}" --tos "{{tos}}" --memsize 4 --drive-b off --fastfdc on --harddrive "{{gemdos-hd}}" --gemdos-drive skip --fast-boot on --tos-res stmed --fast-forward boot:on --fast-forward inf:off --debug-except none --symload off {{args}} "{{prg}}"
