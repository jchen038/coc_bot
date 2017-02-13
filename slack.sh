COMMAND=$1
PID=bot.pid

case "$COMMAND" in
	start)
		if [ ! -f $PID ]; then
			nohup ruby start.rb &
			echo "$!" > $PID
			echo "$!"
		else
			echo "Process Exist"
		fi
		;;
	stop)
		line=$(head -1 $PID)
		kill -9 $line
		rm $PID
		;;
	pid)
		line=$(head -1 $PID)
		echo $line
		;;
	*)
	  echo $"Usage: $0 {start|stop|pid}"
    exit 1
esac