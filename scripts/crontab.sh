#!/bin/bash

tool='crontab'
log_file="/tmp/.crontab.log"
dest_file="$HOME/.crontab"

path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"

data_path="$path/../data"
data_file="$data_path/.crontab"

log_time=$(date +%Y-%m-%d_%H:%M:%S)


setup_vdirsyncer_schedule_job() {
	cat <<-EOF >> $dest_file
	*/30 * * * * ($(which vdirsyncer) sync | echo "$log_time : vdirsyncer sync") 1>> $log_file 2>&1
	EOF
}

select_running_jobs_to_delete() {
	$tool -u $USER -l > $dest_file || {
		$common display_error "load current cron job failed !"
		exit 1
	}

	while true; do
		$common display_subtitle "Lists of current $tool schedule command"
		echo ""
		cat -n $dest_file
		echo ""
		read -p "select job to remove (0 to exit): " choice
		tput clear

		if ! [[ $choice =~ ^[0-9]+$ ]];
		then
			$common display_error "invalid choice !"
			continue
		elif [[ $choice -eq 0 ]];
		then
			break
		elif [[ $choice -gt $(wc -l $dest_file | awk '{print $1}') ]];
		then
			$common display_error "max choice is $(wc -l $dest_file | awk '{print $1}') !"
			continue
		fi

		$common display_info "remove" "$(sed -n "${choice}p" $dest_file)\n"

		cat -n $dest_file  | sed -i "${choice}d" $dest_file || {
			$common display_error "load $choice failed !"
			exit 1
		}
	done
}

sync_local_defined_crontab_file() {
	if [[ -f $data_file ]] && [[ $(wc -l $data_file | awk '{print $1}') -ne 0 ]];
	then
		$common display_info "add" "local defined cron job"
		$common display_subtitle "Lists of local defined cron job"
		cat $data_file >> $dest_file | cat $data_file || {
			$common display_error "add local defined cron job failed !"
			exit 1
		}
	fi
}

install() {
	local schedule_jobs=('setup_vdirsyncer_schedule_job')

	$common display_title "Install $tool schedule command"

	$common display_info "load" "current defined cron job"

	$tool -u $USER -l > $dest_file || {
		$common display_error "load current cron job failed !"
		exit 1
	}

	if [[ $(wc -l $dest_file | awk '{print $1}') -ne 0 ]];
	then
		select_running_jobs_to_delete
	fi

	sync_local_defined_crontab_file

	$common display_subtitle "Setup $tool schedule command"

	for job in ${schedule_jobs[@]}; do
		$common display_info "add" "$job"

		$job || {
			$common display_error "$job failed !"
			exit 1
		}
	done

	$tool -u $USER $dest_file

	$common display_info "intalled" "$tool schedule command!"

	$common display_subtitle "Lists of $tool schedule command"

	$tool -u $USER -l
}

if [[ -z "$(which $tool)" ]];
then
	$common display_error "$tool not found !"
	exit 1
fi

if [[ $# -eq 0 ]];
then
	$common display_error "missing argument !"
	exit 1
fi

$1 $@ || {
	$common display_error "invalid argument !"
	exit 1
}

exit 0
