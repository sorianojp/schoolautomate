/**
*	Call this to truncate the float value to a fixed width. if bolGetCeil is true - then
*	get the ceiling value of the remainder - else just truncate.
*/
function truncateFloat(floatVal,noOfMaxDigit,bolGetCeil)
{
  if(isNaN(floatVal))
  {
    alert(floatVal+" is not a valid number");
    return;
  }
  if(eval(noOfMaxDigit) ==0)
    return floatVal;
  var mulFactor = Math.pow(10,noOfMaxDigit+1);
  floatVal = floatVal*mulFactor;
  if(bolGetCeil)
    floatVal = Math.ceil(floatVal);
  else
    floatVal = Math.floor(floatVal);
  
  //get here original value;
  floatVal = floatVal/mulFactor;
  
  retValue = new String(floatVal);
  var iIndex = retValue.indexOf('.',0);
  if(iIndex > retValue.length -2)
  	retValue = retValue.substring(0,retValue.length-2);
  
  return retValue;
}
function formatFloat(floatVal, noOfMaxDigit, bolGetCeil) {
	floatVal = truncateFloat(floatVal,noOfMaxDigit,bolGetCeil);
	floatVal = String(floatVal).toString();
	var strDecimalVal = ".00";
	
	var iIndexOf = floatVal.indexOf('.',0);
	if(iIndexOf > -1) {
		strDecimalVal = floatVal.substring(iIndexOf);
		floatVal = floatVal.substring(0, iIndexOf);		
	}
	
	//Now i have to put comma.. 
	var newFloatVal = "";
	var iLen = floatVal.length;var iDigit = 0;
	while(--iLen > -1) {
		++iDigit;
		if(iDigit > 3 && iDigit % 3 == 1) ///comma after every 3 digits 1,000,000,000,000,000.00
			newFloatVal = floatVal.charAt(iLen)+","+newFloatVal;
		else	
			newFloatVal = floatVal.charAt(iLen)+newFloatVal;
	}
	
	return newFloatVal+strDecimalVal;
}

function roundOffFloat(floatVal, noOfMaxDigit, bolRoundUp){
	var vDecimal = null;
	var iIndex  = 0;
  if(isNaN(floatVal))
  {
    alert(floatVal+" is not a valid number");
    return;
  }
	
  if(eval(noOfMaxDigit) == 0)
    return floatVal;
		
  var mulFactor = Math.pow(10, noOfMaxDigit+1);
	// sample float, noOfMaxDigit = 2, roundUp = true
	// 22.299999997
	//alert("floatVal1 - " + floatVal);

  floatVal = floatVal*mulFactor;
	// floatVal = 22.2999 * 1000
	// floatVal = 22299.999997
	//alert("floatVal after - " + floatVal);
	
	vDecimal = new String(floatVal);
	// vDecimal = 2299.9	
	
	iIndex = vDecimal.indexOf('.',0);
	//alert("vDecimal iIndex - " + iIndex);
	// iIndex = 5
	if(iIndex != -1){
		vDecimal = vDecimal.substring(iIndex, vDecimal.length);
		// vDecimal = .999997
		if(eval(vDecimal) >= .50){
			if(bolRoundUp || eval(vDecimal) > .50)
				floatVal += 1;
		}
		// floatVal = 22300.999997
	}

	//alert("vDecimal - " + vDecimal);
	//alert("floatVal2 - " + floatVal);
//	alert("mulFactor " + mulFactor);	
//	alert("floatVal " + floatVal);	
//get here original value;

  floatVal = floatVal/mulFactor;
	// floatval = 22.300999997
//  alert("floatVal " + floatVal);	
	//alert("floatValfinal - " + floatVal);
	
  retValue = new String(floatVal);
	// retValue  = 22.300999997
	//alert("retValue - " + retValue);
  iIndex = retValue.indexOf('.',0);
	//alert("iIndex - " + iIndex);
	// iIndex = 2
  if(iIndex > 0){
		// retValue.length = 12 - 1
		//alert("retValue.length - " + retValue.length);
		if(retValue.length-iIndex > noOfMaxDigit){
		 	retValue = retValue.substring(0, iIndex+noOfMaxDigit+1);
			//alert("did i go inside - " + retValue);
		}
		
		//alert("retValue.length - " + retValue);
	}
  
  return retValue;
}
