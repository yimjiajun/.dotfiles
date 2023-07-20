#!/bin/bash

# user defined
prj_branch="ecfw-zephyr_v3.2_Tesrc"
mchp_series="mec1523"

# fixed by tektagon project
defualt_board="mec1501_adl_p"
prj_workspace="$HOME/sandbox"
prj_name="ecfw-zephyr"
prj_path="$prj_workspace/$prj_name"
zephyr_base_path="$prj_workspace/ecfwwork/zephyr_fork"
mec_cpg_zephyr_docs_path="$HOME/CPGZephyrDocs"

display_msg() {
	local log=$1
	local msg=$2

	if [ "$#" -eq 0 ]; then
		return
	fi

	if [ "$#" -eq 1 ]; then
		log="dbg"
		msg=$1
	fi

	if [[ $log =~ [eE]rr* ]]; then
		echo -e -n "\033[31m"
		log="error"
	elif [[ $log =~ [wW]arn* ]]; then
		echo -e -n "\033[33m"
		log="warning"
	elif [[ $log =~ [dD]bg ]]; then
		echo -e -n "\033[32m"
		log="debug"
	elif [[ $log =~ [mM]sg* ]]; then
		echo -e -n "\033[93m"
		log="message"
	fi

	printf "[ %8s ]: %s\n" "$log" "$msg"
	echo -e -n "\033[0m"
}

if [[ -z $(command -v west) ]]; \
then
	display_msg 'msg' 'Please visit https://docs.zephyrproject.org/latest/develop/getting_started/index.html'
	display_msg 'msg' 'Or run "curl -sSL https://raw.githubusercontent.com/yimjiajun/.dotfiles/main/prj/zephyr.sh | bash"'
	display_msg 'err' 'West tool is not found, Please install west tool'
	exit 1
fi

for re_install in {1..3}; do
	if ! [ -d "$prj_workspace" ]; \
	then
		if [ -n "$prj_branch" ]; then
			prj_branch="--branch $prj_branch"
		fi

		display_msg 'msg' "Clone Tektagon ecfw-zephyr project into $prj_path [$(echo $prj_branch | cut -d ' ' -f2)]"

		git clone 'git@git.ami.com:security/nightfury/opensourceprojects/ecfw-zephyr.git' \
			$prj_branch $prj_path 1>/dev/null || \
		{
			display_msg 'err' 'Failed to download repository'
			break
		 }

		chmod +x $prj_path/Build.sh
	elif [ $re_install -ge 2 ]; \
	then
		display_msg 'msg' "Backcup current $prj_workspace to ${prj_workspace}~"

		if [ -d ${prj_workspace}~ ]; then
			rm -rf ${prj_workspace}~
		fi

		mv $prj_workspace ${prj_workspace}~
		continue
	fi

	display_msg 'msg' "Initialize west workspace"

	cd $prj_workspace

	west init -l $prj_path 1>/dev/null 2>&1 || \
	{
		if ! [ -f $prj_workspace/.west/config ] && \
			[ -d $prj_workspace/.west ]; \
		then
			rm -rf $prj_workspace/.west

			west init -l $prj_path 1>/dev/null || {
				display_msg 'err' 'Failed to initialize west workspace'
				continue
			}
		fi
	}

	display_msg 'msg' 'Update and download west manifest'

	west update --narrow 1>/dev/null || {
		display_msg 'err' 'Failed to update west manifest'
		continue
	}

	if [[ -d 'ecfwwork/zephyr_fork' ]]; \
	then
		display_msg 'msg' 'Setup west configuration'
		west config --local zephyr.base 'ecfwwork/zephyr_fork'
		west config --local zephyr.base-prefer 'configfile'
		west config --local build.board $defualt_board
	else
		display_msg 'warn' 'Unexpected zephyr base directory'

		if [ -z $ZEPHYR_BASE ]; \
		then
			display_msg 'err' 'Please setup run zephyr-env.sh to setup manually'
			break
		fi
	fi

	if [[ "$(west config zephyr.base-prefer)" == "configfile" ]]; \
	then
		zephyr_base="$(west config zephyr.base)"
	else
		zephyr_base=$ZEPHYR_BASE
	fi

	display_msg 'msg' "Update zephyr kernel to $zephyr_base"

	git -C $(west topdir)/$zephyr_base am \
		$(west topdir)/$(west config manifest.path)/zephyr_patches/patches_v3_2.patch 1>/dev/null || \
	{
		git -C $(west topdir)/$zephyr_base am --abort

		git -C $(west topdir)/$zephyr_base am \
			$(west topdir)/$(west config manifest.path)/zephyr_patches/patches_v3_2.patch 1>/dev/null || \
		{
			display_msg 'err' 'Failed to update git patch to zephyr kernel'
			continue
		}
	}

	display_msg 'msg' 'Check CPGZephyrDocs repository'

	if [ -d $mec_cpg_zephyr_docs_path ]; \
	then
		if ! [[ $(git -C $mec_cpg_zephyr_docs_path remote get-url origin) \
			=~ .*"security/nightfury/opensourceprojects/cpgzephyrdocs".* ]]; \
		then
			if [ -d ${mec_cpg_zephyr_docs_path}~ ]; \
			then
				rm -rf ${mec_cpg_zephyr_docs_path}~
			fi

			display_msg 'msg' 'Backup current CPGZephyrDocs repository to ${mec_cpg_zephyr_docs_path}~'

			mv $mec_cpg_zephyr_docs_path ${mec_cpg_zephyr_docs_path}~
		fi
	fi

	if ! [ -d $mec_cpg_zephyr_docs_path ]; \
	then
		display_msg 'msg' 'Download CPGZephyrDocs'

		git clone git@git.ami.com:security/nightfury/opensourceprojects/cpgzephyrdocs.git \
			--branch CPGZephyrDocs_ECsigning \
			$mec_cpg_zephyr_docs_path 1>/dev/null || \
		{
			display_msg 'err' 'Failed to download CPGZephyrDocs'
		}

		find $mec_cpg_zephyr_docs_path -type f \
			! -name '*.md' ! -name '*.pdf' ! -name '*.txt' ! -name '*.pem' \
			! -name '*.bin' ! -name '*.exe' \
			-exec chmod +x {} +
	fi

	display_msg 'msg' "Setup SPI image generator - $mchp_series"

	if [[ -z $mchp_series ]];then
		mchp_series=$defualt_board
	fi

	if [[ $mchp_series =~ .*[mM][eE][cC]15.* ]]; \
	then
		if [[ $mchp_series =~ .*[mM][eE][cC]150.* ]]; then
			display_msg 'warn' "$mchp_series is not in use by env in this project"
			# spi_gen="$mec_cpg_zephyr_docs_path/MEC1501/SPI_image_gen/everglades_spi_gen_lin64"
			# spi_cfg="$mec_cpg_zephyr_docs_path/MEC1701/SPI_image_gen/spi_cfg.txt"
		elif [[ $mchp_series =~ .*[mM][eE][cC]152.* ]]; then
			display_msg 'warn' "$mchp_series is not in use by env in this project"
			# spi_gen="$mec_cpg_zephyr_docs_path/MEC152x/SPI_image_gen/everglades_spi_gen_RomE"
			# spi_cfg="$mec_cpg_zephyr_docs_path/MEC152x/SPI_image_gen/spi_cfg.txt"
		else
			display_msg 'err' "Unexpected MCHP series - $mchp_series"
			break
		fi

		if [[ -n $spi_gen ]];\
		then
			if [[ $(grep -c 'export EVERGLADES_SPI_GEN' "${HOME}/.$(basename ${SHELL})rc") -ne 0 ]]; \
			then
				sed -i '/export EVERGLADES_SPI_GEN/d' "${HOME}/.$(basename ${SHELL})rc"
			fi

			display_msg 'msg' "Setup SPI image generator - (EVERGLADES_SPI_GEN) $spi_gen"
			echo "export EVERGLADES_SPI_GEN=$spi_gen" >> "${HOME}/.$(basename ${SHELL})rc"
			export EVERGLADES_SPI_GEN=$spi_gen
		fi

		if [[ -n $spi_cfg ]];\
		then
			if [[ $(grep -c 'export EVERGLADES_SPI_CFG' "${HOME}/.$(basename ${SHELL})rc") -ne 0 ]]; \
			then
				sed -i '/export EVERGLADES_SPI_CFG/d' "${HOME}/.$(basename ${SHELL})rc"
			fi

			display_msg 'msg' "Setup SPI image configuration - (EVERGLADES_SPI_CFG) $spi_cfg"
			echo "export EVERGLADES_SPI_CFG=$spi_cfg" >> "${HOME}/.$(basename ${SHELL})rc"
			export EVERGLADES_SPI_CFG=$spi_cfg
		fi

	elif [[ $mchp_series =~ .*[mM][eE][cC]172.* ]]; \
	then
		if [[ $mchp_series =~ .*[mM][eE][cC]172.* ]]; then
			display_msg 'warn' "$mchp_series is not in use by env in this project"
			# spi_gen="$mec_cpg_zephyr_docs_path/MEC172x/SPI_image_gen/mec172x_spi_gen_lin_x86_64"
			# spi_cfg_path="$mec_cpg_zephyr_docs_path/MEC172x/SPI_image_gen/"
		else
			display_msg 'err' "Unexpected MCHP series - $mchp_series"
			break
		fi

		if [[ -n $spi_gen ]];\
		then
			if [[ $(grep -c 'export MEC172X_SPI_GEN' "${HOME}/.$(basename ${SHELL})rc") -ne 0 ]]; \
			then
				sed -i '/export MEC172X_SPI_GEN/d' "${HOME}/.$(basename ${SHELL})rc"
			fi

			display_msg 'msg' "Setup SPI image generator - (MEC172X_SPI_GEN) $spi_gen"
			echo "export MEC172X_SPI_GEN=$spi_gen" >> "${HOME}/.$(basename ${SHELL})rc"
			export MEC172X_SPI_GEN=$spi_gen
		fi

		if [[ -n $spi_cfg_path ]]; \
		then
			if [[ $(grep -c 'export MEC172X_SPI_CFG' "${HOME}/.$(basename ${SHELL})rc") -ne 0 ]]; \
			then
				sed -i '/export MEC172X_SPI_CFG/d' "${HOME}/.$(basename ${SHELL})rc"
			fi

			display_msg 'msg' "Setup SPI image configuration path - (MEC172X_SPI_CFG) $spi_cfg_path"
			echo "export MEC172X_SPI_CFG=$spi_cfg_path" >> "${HOME}/.$(basename ${SHELL})rc"
			export MEC172X_SPI_CFG=$spi_cfg_path
		fi
	else
		display_msg 'err' "Unexpected MCHP series - $mchp_series, build without spi generation"
	fi

	if [[ -z $(command -v wine) ]]; \
	then
		display_msg 'msg' 'Setup wine to run window executable file'
		display_msg 'msg' 'This may take a while, please wait...'

		sudo dpkg --add-architecture i386 && \
		sudo apt-get update 1>/dev/null && \
		sudo apt-get install -y wine64 wine32 1>/dev/null || \
		{
			display_msg 'err' 'Failed to install wine'
			break
		}
	fi

	display_msg 'msg' 'Success Setup ecfw-zephyr project'

	exit 0
done

	display_msg 'err' 'Failed to setup ecfw-zephyr project'

exit 1
