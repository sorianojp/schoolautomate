/*** use these function as builtin java script function.**/

//Example: var myStr2 = myStr.trim();  
String.prototype.trim = function(){
	return (this.replace(/^[\s\xA0]+/, "").replace(/[\s\xA0]+$/, ""))
}

//if (myStr2.startsWith(“Earth”)) return TRUE
String.prototype.startsWith = function(str) {
	return (this.match("^"+str)==str)
}

//if (myStr2.endsWith(“planet”)) return TRUE
String.prototype.endsWith = function(str) {
	return (this.match(str+"$")==str)
}

//More to come if found.