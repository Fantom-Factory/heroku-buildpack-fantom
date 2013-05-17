
class CallBuildTarget {

	static Void main(Str[] args) {
		scriptFileName	:= args[0]
		methodName		:= args[1]
		
		buildType 		:= Env.cur.compileScript(`$scriptFileName`.toFile)
		buildClass		:= buildType.make
		buildMethod 	:= buildClass.typeof.method(methodName, false)
		
		buildMethod?.callOn(buildClass, null)
		
		if (buildMethod == null) 
			echo("Build Target '$methodName' not found")
	}
	
}