
	//---to appned error messageges
	function Append(errStr, error) {
		if(errStr == "") {
			errStr = error;
		} else if(error != "") {
			errStr = errStr + ", " + error;
		}
		return errStr;
	}

	//---checks given pattern and returns true or false
	function isPattern(PATTERN, PARAM) {
		var regExprn = new RegExp(PATTERN);
		return regExprn.test(PARAM);
	}

//---checks for blanks and returns true or false
      function isBlank(PARAM) {
	   if(PARAM == "") return true;
	   else return false;
      }

/**
*	This is called to check generic information - check for only if it is blank and max / min field length
* 	Mostly used for book information
*/
	function checkGenericInfo(PARAM, LABEL, MIN, MAX) 
	{
		var errMessage = "", isBLANK;
		isBLANK = isBlank(PARAM);
		if(isBLANK) 
			errMessage = LABEL + " is blank";
		else
			errMessage = checkLength(PARAM, MIN, MAX, LABEL);
		
		return errMessage;
	}
		

//----Function to check for validity of the Recipient Name field.
	function checkName(PARAM, LABEL, isRequired, MIN, MAX) {
		var errMessage = "", isBLANK;
		isBLANK = isBlank(PARAM);
		if(isBLANK && isRequired) {
			errMessage = LABEL + " is blank";
		} else if(isNameChars(PARAM) && !isBLANK) {
			errMessage = LABEL + " is not valid";
		} else if(!isBLANK) {
			errMessage = checkLength(PARAM, MIN, MAX, LABEL);
		}
              	return errMessage;
	}

//---validation for City, returns blank or err message
	function checkAddress(PARAM, LABEL, isRequired) {
		var errMessage = "", isBLANK;
		isBLANK = isBlank(PARAM);
		if(isBLANK && isRequired) {
			errMessage = LABEL + " is blank";
		} else if(!isAddress(PARAM) && !isBLANK) {
			errMessage = LABEL + " is not valid"
		} else if(!isBLANK) {
			errMessage = checkLength(PARAM, 10, 128, LABEL);
		}
		return errMessage;
	}

//---validation for Address, returns true or false
	function isAddress(PARAM) {
		var ADDRESS_CHARS_LIST = "~!%^[]\"|\?<>=+";
		return !isAnyCharFromCharListInString(PARAM, ADDRESS_CHARS_LIST);
	}
        function isNameChars(PARAM) {
		var SPECIAL_CHARS_LIST = "~$%^\"[]|?<>=+:;#@*`";
		return isAnyCharFromCharListInString(PARAM, SPECIAL_CHARS_LIST);
	}

	function isSpecialChars(PARAM) {
		var SPECIAL_CHARS_LIST = "~$%^\"]|?<>=+:;";
		return isAnyCharFromCharListInString(PARAM, SPECIAL_CHARS_LIST);
	}

//---checks for chars given in spCharList and and returns true or false
	function isAnyCharFromCharListInString(inString, spCharList) {
		var iPos;
		for(iPos=0;iPos<spCharList.length;iPos++) {
			if(isCharInString(inString, spCharList.charAt(iPos))) return true;
		}
		return false;
	}
//---checks for chars given in spCharList and and returns true or false
	function isOnlyCharListInString(inString, spCharList) {
		var iPos, unwantedChars = 0;
		for(iPos=0;iPos<inString.length;iPos++) {
			if(isCharNotInString(spCharList, inString.charAt(iPos))) return false;//unwantedChars++;
		}
		if(unwantedChars > 0) return false;
		return true;
	}

//---checks for charToFind and returns true or false
	function isCharNotInString(String1, charToFind) {
		if(String1.indexOf(charToFind) == -1) return true;
		return false;
	}

	//---checks for charToFind and returns true or false
	function isCharInString(inString, charToFind) {
		var i;
		for(i=0;i<inString.length;i++) {
			if(inString.charAt(i) == charToFind) return true;
		}
		return false;
	}
	//---Function to check for validity of the First Name field.
	function checkLength(PARAM, MIN, MAX, LABEL) {
		var errMessage = "";
		if(MIN == 0 && MAX == 0) return errMessage;
		if(MAX== 0 && PARAM.length<MIN)
			errMessage=LABEL + " length should be min "+MIN+" characters.";
		else if(MIN == 0 && PARAM.length > MAX)
			errMessage=LABEL + " length should be max "+MIN+" characters.";
		else if(((PARAM.length < MIN || PARAM.length > MAX) && (MIN != MAX))) {
			errMessage = LABEL + " length should be between " + MIN + " and " + MAX + " characters";
		} else if(PARAM.length > MAX) {
			errMessage = LABEL + " should be maxmimum " + MAX + " characters in length";
		}
		return errMessage;
	}


//---validation for state/country, returns blank or err message
	function checkAlphaNumeric(PARAM, LABEL, isRequired) {
		var errMessage = "", isBLANK;

		var NUMERIC_CHAR_LIST = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		isBLANK = isBlank(PARAM);
		if(isBLANK && isRequired) {
			if (LABEL == "Diocese") {
				errMessage = "Please select a Diocese";
			} else {
				errMessage = LABEL + " is blank";
			}
		} else if(!isOnlyCharListInString(PARAM, NUMERIC_CHAR_LIST) && !isBLANK) {
			errMessage = LABEL + " is not valid";
		}
		return errMessage;
	}

//---function to trim input string, removes leading and trailing spaces
	function Trim(param)
	{
//--TEST
		var len = param.length, iNum = 0;
		var strReturn = "";
		var charVal = "";

		//--remove leading spaces
		while (iNum < len) {
			charVal = param.charAt(iNum)
			if(charVal != " ") {
				strReturn = param.substring(iNum, len);
				break;
			}
			//---decrese counter
			iNum++;
		}

		param = strReturn; strReturn = "";
		len = param.length; iNum = len - 1;
		//--remove trailing spaces
		while (iNum >= 0) {
			charVal = param.charAt(iNum)
			if(charVal != " ") {
				strReturn = param.substring(0, iNum + 1);
				break;
			}

			iNum--;
		}

		return strReturn;

	}

	/**
	*	Call this to check telephone number - blank space and -,+. are alowed for example
	*	+91 56 678-0456 and 1.408.629-4367 are valid entries ;-)
	*/
	function checkTelNumber(PARAM, LABEL,MIN,MAX) 
	{
		var errMessage = "", isBLANK;
		var NUMERIC_CHAR_LIST = "0123456789. -+";

		isBLANK = isBlank(PARAM);
		if(isBLANK ) 
			errMessage = LABEL + " is blank";
		else if(!isOnlyCharListInString(PARAM, NUMERIC_CHAR_LIST)) 
			errMessage = LABEL + " is not valid";
		else if(MIN != 0 && MAX != 0) 
			errMessage = checkLength(PARAM, MIN, MAX, LABEL);
		
		return errMessage;
	}
	
	//---validation for state/country, returns blank or err message
	function checkNumericOnly(PARAM, LABEL, isRequired, MIN, MAX, isAmount) {
		var errMessage = "", isBLANK;
		var NUMERIC_CHAR_LIST;
		if(isAmount)  NUMERIC_CHAR_LIST = "0123456789.";
		else NUMERIC_CHAR_LIST = "0123456789";

		isBLANK = isBlank(PARAM);
		
		if(isBLANK && isRequired) {
		//	if (LABEL == "Diocese") {
		//		errMessage = "Please select a Diocese";
	//		} else {
				errMessage = LABEL + " is blank";
	//		}
		} else if(!isOnlyCharListInString(PARAM, NUMERIC_CHAR_LIST) && !isBLANK) {
			errMessage = LABEL + " is not valid";
		} else if(MIN != 0 && MAX != 0) {
			errMessage = checkLength(PARAM, MIN, MAX, LABEL);
		}
		
		//alert(errMessage);
		return errMessage;
	}

//--- validation for amount ,returns error message
//--- if any error or all Zero
// Fixed for amount with cents.
	function checkAmount(PARAM, LABEL, isRequired, MIN, MAX) {
			var errMessage = "";
		errMessage = checkNumericOnly(PARAM, LABEL, isRequired, MIN, MAX, true);

		if(errMessage=="" && parseInt(RemoveLeadingZero(PARAM))<=0)
			{
				errMessage = "Amount is Zero."
			}

		return errMessage;
	}
	
	function checkAmount(PARAM, LABEL, isRequired, MIN, MAX,isZeroAllowed) {
			var errMessage = "";
		errMessage = checkNumericOnly(PARAM, LABEL, isRequired, MIN, MAX, true);

		if(!isZeroAllowed && errMessage=="" && parseInt(RemoveLeadingZero(PARAM))<=0)
			{
				errMessage = "Amount is Zero."
			}

		return errMessage;
	}
	


	//--- HSS Function below takes a numeric string and removes all
	//--- leading Zeors and returns the altered string back

	function RemoveLeadingZero(param) {
		var i, len=param.length;
		var ch;
		for(i=0; i<len;i++) {
			ch = param.substring(i, i+1);
			if(ch != '0') {
				return param.substring(i, len);
			}
		}
		 return param;
	}


//--- HSS validation for any numeric value ,returns true message
//--- if all chars are Zero false otherwise. Oct 3,2002

function CheckAllZero(inString)
	{
		var i;
		var boolAllZero;
		boolAllZero = true;
		inString = Trim(inString);
		for(i=0;i<inString.length;i++)
			{
				if(inString.charAt(i)=="0")
					{}
				else
					{
						boolAllZero = false;
						break;
					}
			}

	return boolAllZero;

	}

//---validation for state/country, returns blank or err message
	function checkAlphaNumeric(PARAM, LABEL, isRequired) {
		var errMessage = "", isBLANK;

		var NUMERIC_CHAR_LIST = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		isBLANK = isBlank(PARAM);
		if(isBLANK && isRequired) {
			//if (LABEL == "Diocese") {
			//	errMessage = "Please select a Diocese";
			//} else {
				errMessage = LABEL + " is blank";
			//}
		} else if(!isOnlyCharListInString(PARAM, NUMERIC_CHAR_LIST) && !isBLANK) {
			errMessage = LABEL + " is not valid";
		}
		return errMessage;
	}
//---validation for FundID
//	function checkFundID(PARAM, LABEL, isRequired, len){
//		var errorMsg ;
//		errorMsg = checkAlphaNumeric(PARAM, LABEL, isRequired);
//		if(errorMsg == ""){
//			if(PARAM.length != len){
//				errorMsg = "The length of FundID should be " + len;
//			}
//		}
//		return errorMsg;
//	}

//---validation for vehicle details like chesis numbe,plate number, returns blank or err message
	function checkVehicle(PARAM, isRequired, LABEL) {
		var errMessage = "", isBLANK;
		isBLANK = isBlank(PARAM);
		var PHONE_CHAR_LIST = "0123456789 -()abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		if (isBLANK && isRequired) {
			errMessage = LABEL + " is blank";
		}else if(!isOnlyCharListInString(PARAM, PHONE_CHAR_LIST) && !isBLANK) {
			errMessage = LABEL + " is not valid";
		} //else if(!isBLANK) {
		//	if(!isStringHasXDigits(PARAM, 10)) {
		//		errMessage = "Fax number must contain 10 digits";
		//	}
		//}

		return errMessage;
	}
//---validation for case no, returns blank or err message
	function checkCaseNumber(PARAM, isRequired, LABEL) {
		var errMessage = "", isBLANK;
		isBLANK = isBlank(PARAM);
		var PHONE_CHAR_LIST = "0123456789 -()";
		if (isBLANK && isRequired) {
			errMessage = LABEL + " is blank";
		}else if(!isOnlyCharListInString(PARAM, PHONE_CHAR_LIST) && !isBLANK) {
			errMessage = LABEL + " is not valid";
		} //else if(!isBLANK) {
		//	if(!isStringHasXDigits(PARAM, 10)) {
		//		errMessage = "Fax number must contain 10 digits";
		//	}
		//}

		return errMessage;
	}

//--- check date, if date is valid,if greater than today date.
/*
function checkDate(PARAM,isRequired,LABEL)
{
	var errMessage = "", isBLANK;
	isBLANK = isBlank(PARAM);
	if (isBLANK && isRequired)
		errMessage = LABEL + " is blank";
	else
	{
		todayDate = new Date();
		if(todayDate >

		*/





/*
function isPattern(PATTERN, PARAM) {
		var regExprn = new RegExp(PATTERN);
		return regExprn.test(PARAM);
	}
*/
	//---function to check for valid Email and returns either blank or error message
	function checkEmail(PARAM, isRequired) {
		//---REG_PATTERN_EMAIL = "^([A-Za-z0-9_-]+\\.)*[A-Za-z0-9_-]+[^\\.]@([A-Za-z0-9_-]+\\.)*[A-Za-z0-9_-]+$"
		REG_PATTERN_EMAIL = "^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$"
		var errMessage = "", isBLANK;
		isBLANK = isBlank(PARAM);

		if(isBLANK && isRequired) {
			errMessage = "Email is blank";
		} else if(!isBLANK && PARAM.length < 5  ) {
			errMessage = "Email must at be atleast of 5 characters";
		} else if(!isBlank && !isPattern(REG_PATTERN_EMAIL, PARAM) ) {
			errMessage = "Email is not valid";
		} else if(!isBLANK) {
			errMessage = checkLength(PARAM, 5, 32, "Email");
		}
		return errMessage;
	}


	//---Check for negative values i.e. only numbers are allowed.with the current date
	// -- Two verifications -> date must be greater than current date for example -> expire date
	// -- and date must be less than current date -- for exmaple b'date, admission date etc,
	function checkDate(dVALUE, dNAME, mVALUE, mNAME, yVALUE, yNAME, bolMustGtThanCurrentDate) 
	{
	
		//alert(mVALUE);
		var errMessage = "", isBLANK;
		var NUMERIC_CHAR_LIST = "0123456789";
		if(dVALUE == "0") errMessage = "Date field is 0";
		if(mVALUE == "0") errMessage = "Month field is 0";
		if(yVALUE == "0") errMessage = "Year field is 0";
		if(errMessage.length > 0) return errMessage;

		var thisDate = new Date();

                var thisDay = thisDate.getDate();
		var thisYear = thisDate.getFullYear().toString();
                var thisMonth = thisDate.getMonth();

                isBLANK = isBlank(dVALUE);

                if(isBLANK) {
			errMessage = Append(errMessage, "'" + dNAME + "' is blank.");
		} else if(!isOnlyCharListInString(dVALUE, NUMERIC_CHAR_LIST)) {
			errMessage = Append(errMessage, "'" + dNAME + "' is not valid. It must be a positive integer.");
		} else if (parseInt(dVALUE, 10) > 31) {
			errMessage = Append(errMessage, "'" + dNAME + "' must be less or equal to 31.");
		}

                isBLANK = isBlank(mVALUE);
		if(isBLANK) {
			errMessage = Append(errMessage, "'" + mNAME + "' is blank.");
		} else if(!isOnlyCharListInString(mVALUE, NUMERIC_CHAR_LIST)) {
			errMessage = Append(errMessage, "'" + mNAME + "' is not valid. It must be a positive integer.");
		} else if (mVALUE > 12) {
			errMessage = Append(errMessage, "'" + mNAME + "' must be less or equal to 12.");
		}

		isBLANK = isBlank(yVALUE);
		if(isBLANK) {
			errMessage = Append(errMessage, "'" + yNAME + "' is blank.");
		} else if(!isOnlyCharListInString(yVALUE, NUMERIC_CHAR_LIST)) {
			errMessage = Append(errMessage, "'" + yNAME + "' is not valid. It must be a positive integer.");
		}
		if(isBlank(errMessage)) {
			if(yVALUE.length !=4)
                        errMessage = "the year should be in yyyy format";
                       if(isBlank(errMessage))
                                 //---check if date is greater than current date
                                mVALUE = parseInt(mVALUE, 10);
                                yVALUE = parseInt(yVALUE, 10);
                                dVALUE = parseInt(dVALUE, 10);
			//if(yVALUE < 10) yVALUE = thisYear.substring(0, thisYear.length-1) + yVALUE;
			//else yVALUE = thisYear.substring(0, thisYear.length-2) + yVALUE;

				   if(!bolMustGtThanCurrentDate) //for b'days/ admission date etc.
				   {
				   
					   if(yVALUE > thisYear) {
						 errMessage = Append(errMessage, "'" + yNAME + "' must be less or equal to current year.");
					   } else if(yVALUE == thisYear && mVALUE - 1 > thisMonth) {
					errMessage = Append(errMessage, "'" + mNAME + "' must be less than current month.");
				//--- Below two conditions are put on Oct 3,2002 to check if
				//--- month or year has zero value
					   }else if(yVALUE == thisYear && mVALUE - 1 == thisMonth && dVALUE >= thisDay) {
									 errMessage = Append(errMessage, "'" + dNAME + "' must be less than today'S date.");
					   }
					}
					else
					{						
					//alert("this day : "+thisDay+" mVALUE: "+thisMonth);
						if(yVALUE < thisYear)
							errMessage = Append(errMessage, "'" + yNAME + "' must be greater or equal to current year.");
					   	else if(yVALUE <= thisYear && mVALUE < thisMonth) 
					   		errMessage = Append(errMessage, "'" + mNAME + "' must be greater or equal to current month.");
					   	else if(yVALUE <= thisYear && mVALUE <= thisMonth+1 && dVALUE < thisDay) 
							errMessage = Append(errMessage, "'" + dNAME + "' must be greater or eual to today'S date.");
					}
					   
				   
				   if(parseInt(dVALUE) == 0 && errMessage.length>0 ) {
				errMessage = Append(errMessage, "'" + dNAME + "' cannot be Zero.");
		               }else if(parseInt(mVALUE) == 0 ) {
				errMessage = Append(errMessage, "'" + mNAME + "' cannot be Zero.");

			      } else if(parseInt(yVALUE) == 0) {
				errMessage = Append(errMessage, "'" + yNAME + "' cannot be Zero.");
			   }
		//--- HSS Oct 3, 2002 END
		}
		
		//make sure the date is valid ;-) 
		
		var bolValid = true;
		
		if(mVALUE == 1 && dVALUE >31) bolValid = false;//january
		if(mVALUE == 2) //february
		{
			var maxDaysInFeb;
			if(yVALUE %4 == 0) //leap year
			{//check for year with 2 ending zeros.

				if(yVALUE%100 == 0) //it is having leading 2 zeros
				{
					if(yVALUE%400 == 0)
						maxDaysInFeb = 29; 
					else 
						maxDaysInFeb = 28;
				}
				else
				{
					if(yVALUE%4 == 0) maxDaysInFeb = 29;
					else
						maxDaysInFeb = 28;
				}
			}
			else
			maxDaysInFeb = 28;
			if( dVALUE > maxDaysInFeb)
				bolValid = false;
	
		}
		if(mVALUE == 3 && dVALUE >31) bolValid = false;//march
		if(mVALUE == 4 && dVALUE >30) bolValid = false;//april
		if(mVALUE == 5 && dVALUE >31) bolValid = false;//may
		if(mVALUE == 6 && dVALUE >30) bolValid = false;//june
		if(mVALUE == 7 && dVALUE >31) bolValid = false;///july
		if(mVALUE == 8 && dVALUE >31) bolValid = false;//august
		if(mVALUE == 9 && dVALUE >30) bolValid = false;//sept
		if(mVALUE == 10 && dVALUE >31) bolValid = false;//october
		if(mVALUE == 11 && dVALUE >30) bolValid = false;//November
		if(mVALUE == 12 && dVALUE >31) bolValid = false;//December
		
		if(!bolValid)
			errMessage = "Date enter is not valid.Please check date entered corresponding to month";
		
		return errMessage;
	}

/** 
*	Call this is check password and retype password 
*/
function checkPassword(password,retypePassword,MIN, MAX)
{
	var errMessage = "", isBLANK;
	
	isBLANK = isBlank(password);
	
	if (isBLANK)
	{
		errMessage = "Password field is blank";
		return errMessage;
	}
	//trim the password and check if it contains blank space.
	var tempPassword = Trim(password);
	if(tempPassword.length != password.length)
	{
		errMessage = "Password contains space";
		return errMessage;
	}
	
	//check if password is alphanumeric
	var NUMERIC_CHAR_LIST = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

	if(!isOnlyCharListInString(password, NUMERIC_CHAR_LIST) )
	{
		errMessage = "Password can only be alphanumeric.";
		return errMessage;
	}
	
	//check now if password is b/w the mix and max limit
	if(password.length <MIN || password.length >MAX)
	{
		errMessage= "Password can be between "+MIN+" and "+MAX+" digits";
		return errMessage;
	}
	
	//check now if the password and retype password match
	if(password != retypePassword)
		errMessage = "Password and Retype password does not match";
	
	return errMessage;
	
}
		

