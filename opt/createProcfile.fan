
class CreateProcfile {
	
	static Void main(Str[] args) {
		scriptFileName	:= args[0]
		procfileName	:= args[1]
		
		if (`$procfileName`.toFile.exists) {
			echo("'Procfile' already exists.")
			return
		}
		
		buildType 		:= Env.cur.compileScript(`$scriptFileName`.toFile)
		buildClass		:= buildType.make
		podName 		:= buildClass->podName
		
		procOut			:= `$procfileName`.toFile.out
		cmd				:= "web: fan $podName \$PORT"

		try {
			procOut.printLine
			procOut.printLine(cmd)
			procOut.printLine
			echo(cmd)
		} finally {
			procOut.close
		}
	}
}
